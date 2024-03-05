use std::{collections::HashMap, sync::Arc};

use nvim_oxi as oxi;
use oxi::{
    conversion::ToObject,
    libuv::AsyncHandle,
    lua::{Poppable, Pushable},
    Dictionary, Function, Object,
};
use reqwest::{
    header::{HeaderName, HeaderValue},
    Url, Version,
};
use tokio::sync::Mutex;

#[derive(Debug, serde::Serialize, serde::Deserialize)]
pub struct RequestOpts {
    version: Option<String>,
    headers: Option<HashMap<String, String>>,
    body: Option<serde_json::Value>,
    timeout: Option<u64>,
    bearer: Option<String>,
    json: Option<bool>,
}
use oxi::lua::ffi::lua_State;

use crate::object::{err, LuaJSON as _, OxiTypeName as _};

impl Poppable for RequestOpts {
    unsafe fn pop(lua_state: *mut lua_State) -> Result<Self, oxi::lua::Error> {
        let mut opts = RequestOpts {
            version: None,
            headers: None,
            body: None,
            timeout: None,
            bearer: None,
            json: None,
        };
        for (key, value) in Dictionary::pop(lua_state)?.into_iter() {
            match &*key.to_string_lossy() {
                "version" => {
                    if let oxi::ObjectKind::String = value.kind() {
                        // Safety: ^^
                        opts.version = Some(unsafe { value.into_string_unchecked().to_string() });
                    } else {
                        return Err(oxi::lua::Error::RuntimeError(format!(
                            "invalid version: expected string, got {}",
                            value.oxi_type_name()
                        )));
                    }
                }
                "headers" => {
                    if let oxi::ObjectKind::Dictionary = value.kind() {
                        let mut headers = HashMap::new();
                        for (k, v) in unsafe { value.into_dict_unchecked() } {
                            if let oxi::ObjectKind::String = v.kind() {
                                // Safety: ^^
                                headers.insert(k.to_string(), unsafe {
                                    v.into_string_unchecked().to_string()
                                });
                            } else {
                                return Err(oxi::lua::Error::RuntimeError(format!(
                                    "invalid header value: expected string, got {}",
                                    v.oxi_type_name()
                                )));
                            }
                        }
                        opts.headers = Some(headers);
                    } else {
                        return Err(oxi::lua::Error::RuntimeError(format!(
                            "invalid headers: expected Dictionary, got {}",
                            value.oxi_type_name()
                        )));
                    }
                }
                "body" => {
                    let value = value
                        .to_owned()
                        .into_json()
                        .map_err(|e| oxi::lua::Error::RuntimeError(e.to_string()))?;
                    opts.body = Some(value);
                }
                "timeout" => {
                    if let oxi::ObjectKind::Integer = value.kind() {
                        // Safety: ^^
                        opts.timeout = Some(unsafe { value.as_integer_unchecked() as u64 });
                    } else {
                        return Err(oxi::lua::Error::RuntimeError(format!(
                            "invalid timeout: expected integer, got {}",
                            value.oxi_type_name()
                        )));
                    }
                }
                "bearer" => {
                    if let oxi::ObjectKind::String = value.kind() {
                        opts.bearer = Some(unsafe { value.into_string_unchecked().to_string() });
                    } else {
                        return Err(oxi::lua::Error::RuntimeError(format!(
                            "invalid bearer: expected string, got {}",
                            value.oxi_type_name()
                        )));
                    }
                }
                "json" => {
                    if let oxi::ObjectKind::Boolean = value.kind() {
                        // Safety: ^^
                        opts.json = Some(unsafe { value.as_boolean_unchecked() });
                    } else {
                        return Err(oxi::lua::Error::RuntimeError(format!(
                            "invalid json: expected boolean, got {}",
                            value.oxi_type_name()
                        )));
                    }
                }
                _ => {
                    return Err(oxi::lua::Error::RuntimeError(format!(
                        "invalid key: {}",
                        key
                    )))
                }
            }
        }
        Ok(opts)
    }
}

pub fn request(
    (LuaMethod(method), LuaUrl(url), opts, callback): (
        LuaMethod,
        LuaUrl,
        RequestOpts,
        Function<(bool, Option<Object>), ()>,
    ),
) -> oxi::Result<Object> {
    // TODO: Can I reuse clients by caching them somewhere in the Lua runtime?
    let client = reqwest::ClientBuilder::new()
        .referer(true)
        .build()
        .map_err(|e| err(e.to_string()))?;

    let mut request = client.request(method, url);

    if let Some(version) = opts.version {
        match version.as_str() {
            "HTTP/0.9" => request = request.version(Version::HTTP_09),
            "HTTP/1.0" => request = request.version(Version::HTTP_10),
            "HTTP/1.1" => request = request.version(Version::HTTP_11),
            "HTTP/2" => request = request.version(Version::HTTP_2),
            "HTTP/3" => request = request.version(Version::HTTP_3),
            invalid => {
                return Err(err(format!("invalid version {invalid}")));
            }
        }
    }

    if let Some(headers) = opts.headers {
        for (k, v) in headers {
            request = request.header(
                HeaderName::try_from(k).map_err(err)?,
                HeaderValue::try_from(v).map_err(err)?,
            );
        }
    }

    if let Some(body) = opts.body {
        request = request.json(&body);
    }

    if let Some(timeout) = opts.timeout {
        request = request.timeout(std::time::Duration::from_millis(timeout));
    }

    if let Some(bearer) = opts.bearer {
        request = request.bearer_auth(bearer);
    }

    let rv: Arc<Mutex<Option<Result<serde_json::Value, String>>>> = Arc::new(Mutex::new(None));
    let handle = AsyncHandle::new({
        let rv = rv.clone();
        move || {
            let mut rv = rv.blocking_lock();

            // This panics if the value was not set, because it should have been.
            // If this panics, it is a bug.
            let (ok, res) = match rv
                .take()
                .expect("to have set the return value before the async handle is called")
            {
                Ok(value) => match Object::from_json(value) {
                    Ok(obj) => (true, Some(obj)),
                    Err(e) => (
                        false,
                        Some(
                            e.to_string()
                                .to_object()
                                .expect("to convert error msg to Lua value"),
                        ),
                    ),
                },
                Err(err) => (
                    false,
                    Some(err.to_object().expect("to convert error msg to Lua value")),
                ),
            };
            callback.call((ok, res))?;
            oxi::Result::Ok(())
        }
    })?;
    // create a new thread so that the request doesn't get interrupted on return
    std::thread::spawn(move || {
        // TODO: can I reuse the tokio runtime by caching it in the Lua registry as userdata?
        let rt = tokio::runtime::Runtime::new()
            .map_err(|e| err(format!("failed to create tokio runtime: {e}")))?;
        rt.block_on(async move {
            match request.send().await {
                Ok(res) => {
                    if opts.json.unwrap_or(true) {
                        let mut rv = rv.lock().await;
                        match res.json().await {
                            Ok(value) => rv.replace(Ok(value)),
                            Err(e) => rv.replace(Err(format!("{}", e))),
                        }
                    } else {
                        let mut rv = rv.lock().await;
                        match res.text().await {
                            Ok(value) => rv.replace(Ok(serde_json::Value::String(value))),
                            Err(e) => rv.replace(Err(format!("{}", e))),
                        }
                    }
                }
                Err(e) => rv.lock().await.replace(Err(e.to_string())),
            };
            handle.send()?;
            oxi::Result::Ok(())
        })?;
        oxi::Result::Ok(())
    });
    Ok(Object::nil())
}

pub struct LuaUrl(Url);

impl Pushable for LuaUrl {
    unsafe fn push(
        self,
        lstate: *mut oxi::lua::ffi::lua_State,
    ) -> Result<std::ffi::c_int, oxi::lua::Error> {
        self.0.as_str().to_string().push(lstate)
    }
}

impl Poppable for LuaUrl {
    unsafe fn pop(lstate: *mut oxi::lua::ffi::lua_State) -> Result<Self, oxi::lua::Error> {
        let s = <String as Poppable>::pop(lstate)?;
        Ok(LuaUrl(Url::parse(&s).map_err(|e| {
            oxi::lua::Error::RuntimeError(format!("{e}"))
        })?))
    }
}

pub struct LuaMethod(reqwest::Method);

impl Pushable for LuaMethod {
    unsafe fn push(
        self,
        lstate: *mut oxi::lua::ffi::lua_State,
    ) -> Result<std::ffi::c_int, oxi::lua::Error> {
        self.0.as_str().to_string().push(lstate)
    }
}

impl Poppable for LuaMethod {
    unsafe fn pop(lstate: *mut oxi::lua::ffi::lua_State) -> Result<Self, oxi::lua::Error> {
        let s = <String as Poppable>::pop(lstate)?;
        Ok(LuaMethod(
            reqwest::Method::from_bytes(s.as_bytes())
                .map_err(|e| oxi::lua::Error::RuntimeError(format!("{e}")))?,
        ))
    }
}
