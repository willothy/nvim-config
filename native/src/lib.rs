use std::{
    collections::HashMap,
    sync::{atomic::AtomicBool, Arc},
};

use nvim_oxi as oxi;
use oxi::{
    libuv::AsyncHandle,
    lua::{Poppable, Pushable},
    Dictionary, Function, Object,
};
use reqwest::{
    header::{HeaderMap, HeaderName, HeaderValue},
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

enum StringOrNil {
    String(String),
    Nil,
}

impl Pushable for StringOrNil {
    unsafe fn push(
        self,
        lstate: *mut oxi::lua::ffi::lua_State,
    ) -> Result<std::ffi::c_int, oxi::lua::Error> {
        match self {
            StringOrNil::String(s) => s.push(lstate),
            StringOrNil::Nil => oxi::Object::nil().push(lstate),
        }
    }
}

fn request(
    (method, url, opts, callback): (
        LuaMethod,
        LuaUrl,
        RequestOpts,
        Function<(bool, StringOrNil), ()>,
    ),
) -> oxi::Result<Object> {
    // TODO: Can I reuse clients by caching them somewhere in the Lua runtime?
    let mut request = reqwest::Client::new().request(method.0, url.0);

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
    } else {
        request = request.version(Version::HTTP_11);
    }

    if let Some(headers) = opts.headers {
        let mut h = HeaderMap::new();
        for (k, v) in headers {
            h.insert(
                HeaderName::try_from(k).map_err(err)?,
                HeaderValue::try_from(v).map_err(err)?,
            );
        }
        request = request.headers(h);
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

    // Since this needs to be async with tokio, libuv, *and* native threads (it's ugly, I know)
    // we need to use a few Arcs and Mutexes to share the return value and whether the request was
    // successful.
    let success = Arc::new(AtomicBool::new(true));
    let retval = Arc::new(Mutex::new(None));
    let handle = AsyncHandle::new({
        let res = retval.clone();
        let success = success.clone();
        move || {
            let res = res
                .blocking_lock()
                .take()
                .map(|s| StringOrNil::String(s))
                .unwrap_or(StringOrNil::Nil);

            let success = success.load(std::sync::atomic::Ordering::Relaxed);
            callback.call((success, res))?;
            oxi::Result::Ok(())
        }
    })?;
    // create a new thread so that the request doesn't get interrupted on return
    std::thread::spawn(move || {
        // TODO: can I reuse the tokio runtime by caching it in the Lua registry as userdata?
        let rt = tokio::runtime::Runtime::new().unwrap();
        let task = rt.spawn(async move {
            match request.send().await {
                Ok(res) => {
                    // we want to report it if there's an error with the actual request
                    retval.lock().await.replace(res.text().await.map_err(err)?);
                    handle.send()?;
                }
                Err(e) => {
                    success.store(false, std::sync::atomic::Ordering::Relaxed);
                    retval.lock().await.replace(format!("{:?}", e));
                    handle.send()?;
                }
            }
            oxi::Result::Ok(())
        });
        while !task.is_finished() {
            std::thread::yield_now();
        }
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
