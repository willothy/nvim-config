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

fn err(e: impl std::fmt::Display) -> oxi::Error {
    oxi::Error::from(oxi::api::Error::Other(format!("{e}")))
}

struct LuaUrl(Url);

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

struct LuaMethod(reqwest::Method);

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

fn oxi_type_name(obj: &oxi::Object) -> &'static str {
    match obj.kind() {
        oxi::ObjectKind::Nil => "nil",
        oxi::ObjectKind::Boolean => "boolean",
        oxi::ObjectKind::Integer => "integer",
        oxi::ObjectKind::Float => "float",
        oxi::ObjectKind::String => "string",
        oxi::ObjectKind::Array => "array",
        oxi::ObjectKind::Dictionary => "Dictionary",
        oxi::ObjectKind::LuaRef => "luaref",
        oxi::ObjectKind::Buffer => "buffer",
        oxi::ObjectKind::Window => "window",
        oxi::ObjectKind::TabPage => "tabpage",
    }
}

fn from_value(value: serde_json::Value) -> Result<Object, oxi::conversion::Error> {
    match value {
        serde_json::Value::Null => Ok(Object::nil()),
        serde_json::Value::Bool(b) => b.to_object(),
        serde_json::Value::Number(n) => {
            if n.is_u64() {
                n.as_u64().expect("u64").to_object()
            } else if n.is_i64() {
                n.as_i64().expect("i64").to_object()
            } else {
                n.as_f64().expect("f64").to_object()
            }
        }
        serde_json::Value::String(s) => s.to_object(),
        serde_json::Value::Array(a) => {
            let mut list = Vec::new();
            for v in a {
                Vec::push(&mut list, from_value(v)?);
            }
            list.to_object()
        }
        serde_json::Value::Object(o) => {
            let mut table = HashMap::new();
            for (k, v) in o {
                table.insert(oxi::String::from(&*k), from_value(v)?);
            }
            table.to_object()
        }
    }
}

fn to_value(obj: oxi::Object) -> oxi::Result<serde_json::Value> {
    match obj.kind() {
        oxi::ObjectKind::Boolean => serde_json::to_value(unsafe { obj.as_boolean_unchecked() })
            .map_err(|e| {
                oxi::Error::ObjectConversion(oxi::conversion::Error::Serde(
                    oxi::serde::Error::Serialize(e.to_string()),
                ))
            }),
        oxi::ObjectKind::Integer => serde_json::to_value(unsafe { obj.as_integer_unchecked() })
            .map_err(|e| {
                oxi::Error::ObjectConversion(oxi::conversion::Error::Serde(
                    oxi::serde::Error::Serialize(e.to_string()),
                ))
            }),
        oxi::ObjectKind::Float => serde_json::to_value(unsafe { obj.as_float_unchecked() })
            .map_err(|e| {
                oxi::Error::ObjectConversion(oxi::conversion::Error::Serde(
                    oxi::serde::Error::Serialize(e.to_string()),
                ))
            }),
        oxi::ObjectKind::String => {
            serde_json::to_value(unsafe { obj.into_string_unchecked().to_string() }).map_err(|e| {
                oxi::Error::ObjectConversion(oxi::conversion::Error::Serde(
                    oxi::serde::Error::Serialize(e.to_string()),
                ))
            })
        }
        oxi::ObjectKind::Array => {
            let mut list = Vec::new();
            for v in unsafe { obj.into_array_unchecked() } {
                Vec::push(&mut list, to_value(v)?);
            }
            serde_json::to_value(list).map_err(|e| {
                oxi::Error::ObjectConversion(oxi::conversion::Error::Serde(
                    oxi::serde::Error::Serialize(e.to_string()),
                ))
            })
        }
        oxi::ObjectKind::Dictionary => {
            let mut table = HashMap::new();
            for (k, v) in unsafe { obj.into_dict_unchecked() } {
                table.insert(k.to_string(), to_value(v)?);
            }
            serde_json::to_value(table).map_err(|e| {
                oxi::Error::ObjectConversion(oxi::conversion::Error::Serde(
                    oxi::serde::Error::Serialize(e.to_string()),
                ))
            })
        }
        // oxi::ObjectKind::Nil     |
        // oxi::ObjectKind::LuaRef  |
        // oxi::ObjectKind::Buffer  |
        // oxi::ObjectKind::Window  |
        // oxi::ObjectKind::TabPage |
        _ => Err(oxi::Error::ObjectConversion(
            oxi::conversion::Error::FromWrongType {
                expected: "string, number, array, or dictionary",
                actual: oxi_type_name(&obj),
            },
        )),
    }
}

#[derive(Debug, serde::Serialize, serde::Deserialize)]
struct RequestOpts {
    version: Option<String>,
    headers: Option<HashMap<String, String>>,
    body: Option<serde_json::Value>,
    timeout: Option<u64>,
    bearer: Option<String>,
    json: Option<bool>,
}
use oxi::lua::ffi::lua_State;

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
                            oxi_type_name(&value)
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
                                    oxi_type_name(&v)
                                )));
                            }
                        }
                        opts.headers = Some(headers);
                    } else {
                        return Err(oxi::lua::Error::RuntimeError(format!(
                            "invalid headers: expected Dictionary, got {}",
                            oxi_type_name(&value)
                        )));
                    }
                }
                "body" => {
                    let value = to_value(value.to_owned())
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
                            oxi_type_name(&value)
                        )));
                    }
                }
                "bearer" => {
                    if let oxi::ObjectKind::String = value.kind() {
                        opts.bearer = Some(unsafe { value.into_string_unchecked().to_string() });
                    } else {
                        return Err(oxi::lua::Error::RuntimeError(format!(
                            "invalid bearer: expected string, got {}",
                            oxi_type_name(&value)
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
                            oxi_type_name(&value)
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

fn request(
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
                Ok(value) => match from_value(value) {
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

#[oxi::module]
pub fn sidecar() -> oxi::Result<Dictionary> {
    Ok(Dictionary::from_iter([
        ("request", Function::from_fn(request)),
        //
    ]))
}
