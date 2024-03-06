use std::{collections::HashMap, sync::Arc};

use mlua::{FromLua, Lua};
use mlua::{IntoLua, LuaSerdeExt};
use nvim_oxi as oxi;
use oxi::{
    conversion::ToObject,
    libuv::AsyncHandle,
    lua::{Poppable, Pushable},
    Dictionary, Object,
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

impl<'a> FromLua<'a> for RequestOpts {
    fn from_lua(
        value: mlua::prelude::LuaValue<'a>,
        lua: &'a Lua,
    ) -> mlua::prelude::LuaResult<Self> {
        let mut opts = RequestOpts {
            version: None,
            headers: None,
            body: None,
            timeout: None,
            bearer: None,
            json: None,
        };
        let value = match value {
            mlua::Value::Table(t) => t,
            _ => {
                return Err(mlua::Error::external(format!(
                    "expected table, got {}",
                    value.type_name()
                )))
            }
        };

        for pair in value.pairs::<mlua::Value, mlua::Value>() {
            let (key, value) = pair?;

            let key = match key {
                mlua::Value::String(key) => key,
                _ => {
                    return Err(mlua::Error::external(format!(
                        "invalid key: {}",
                        key.type_name()
                    )))
                }
            };

            match &*key.to_string_lossy() {
                "version" => match value {
                    mlua::Value::String(value) => {
                        opts.version = Some(value.to_string_lossy().to_string());
                    }
                    _ => {
                        return Err(mlua::Error::external(format!(
                            "invalid version: expected string, got {}",
                            value.type_name()
                        )))
                    }
                },
                "headers" => match value {
                    mlua::Value::Table(t) => {
                        let mut headers = HashMap::new();
                        for pair in t.pairs::<mlua::Value, mlua::Value>() {
                            let (k, v) = pair?;
                            let k = match k {
                                mlua::Value::String(k) => k,
                                _ => {
                                    return Err(mlua::Error::external(format!(
                                        "invalid header key: {}",
                                        k.type_name()
                                    )))
                                }
                            };
                            let v = match v {
                                mlua::Value::String(v) => v,
                                _ => {
                                    return Err(mlua::Error::external(format!(
                                        "invalid header value: {}",
                                        v.type_name()
                                    )))
                                }
                            };
                            headers.insert(k.to_str()?.to_string(), v.to_str()?.to_string());
                        }
                        opts.headers = Some(headers);
                    }
                    _ => {
                        return Err(mlua::Error::external(format!(
                            "invalid headers: expected table, got {}",
                            value.type_name()
                        )))
                    }
                },
                "body" => {
                    opts.body = Some(
                        value
                            .to_owned()
                            .into_json(lua)
                            .map_err(|e| mlua::Error::external(e.to_string()))?,
                    );
                }
                "timeout" => {
                    opts.timeout = match value {
                        mlua::Value::Integer(i) => Some(i as u64),
                        _ => {
                            return Err(mlua::Error::external(format!(
                                "invalid timeout: expected integer, got {}",
                                value.type_name()
                            )))
                        }
                    };
                }
                "bearer" => {
                    opts.bearer = match value {
                        mlua::Value::String(s) => Some(s.to_str()?.to_string()),
                        _ => {
                            return Err(mlua::Error::external(format!(
                                "invalid bearer: expected string, got {}",
                                value.type_name()
                            )))
                        }
                    };
                }
                "json" => match value {
                    mlua::Value::Boolean(b) => opts.json = Some(b),
                    _ => {
                        return Err(mlua::Error::external(format!(
                            "invalid json: expected boolean, got {}",
                            value.type_name()
                        )))
                    }
                },
                _ => {
                    return Err(mlua::Error::external(format!(
                        "invalid key: {}",
                        key.to_str()?
                    )))
                }
            }
        }
        Ok(opts)
    }
}

pub fn request<'a>(
    lua: &'a Lua,
    (LuaMethod(method), LuaUrl(url), opts, callback): (
        LuaMethod,
        LuaUrl,
        RequestOpts,
        mlua::Function,
    ),
) -> mlua::Result<mlua::Value<'a>> {
    // TODO: Can I reuse clients by caching them somewhere in the Lua runtime?
    let client = reqwest::ClientBuilder::new()
        .referer(true)
        .build()
        .map_err(|e| mlua::Error::external(e))?;

    let mut request = client.request(method, url);

    if let Some(version) = opts.version {
        match version.as_str() {
            "HTTP/0.9" => request = request.version(Version::HTTP_09),
            "HTTP/1.0" => request = request.version(Version::HTTP_10),
            "HTTP/1.1" => request = request.version(Version::HTTP_11),
            "HTTP/2" => request = request.version(Version::HTTP_2),
            "HTTP/3" => request = request.version(Version::HTTP_3),
            invalid => {
                return Err(mlua::Error::external(format!("invalid version {invalid}")));
            }
        }
    }

    if let Some(headers) = opts.headers {
        for (k, v) in headers {
            request = request.header(
                HeaderName::try_from(k).map_err(|e| mlua::Error::external(e))?,
                HeaderValue::try_from(v).map_err(|e| mlua::Error::external(e))?,
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
    let lua = lua as *const Lua;
    let handle = AsyncHandle::new({
        let rv = rv.clone();
        move || {
            let mut rv = rv.blocking_lock();

            // let lua = mlua::Lua::init_from_ptr(state)

            // This panics if the value was not set, because it should have been.
            // If this panics, it is a bug.
            let (ok, res) = match rv
                .take()
                .expect("to have set the return value before the async handle is called")
            {
                Ok(value) => match mlua::Value::from_json(value, unsafe { &*lua }) {
                    Ok(obj) => (true, Some(obj)),
                    Err(e) => (false, Some(e.to_string().into_lua(unsafe { &*lua })?)),
                },
                Err(err) => (false, Some(err.into_lua(unsafe { &*lua })?)),
            };
            // mlua::serde::ser::Serializer::new(lua)
            callback.call((ok, res))?;
            mlua::Result::Ok(())
        }
    })
    .map_err(|e| mlua::Error::external(e))?;

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
    Ok(mlua::Value::Nil)
}

pub struct LuaUrl(Url);

impl<'a> FromLua<'a> for LuaUrl {
    fn from_lua(value: mlua::Value, lua: &Lua) -> mlua::Result<Self> {
        let s = <String as FromLua>::from_lua(value, lua)?;
        Ok(LuaUrl(
            Url::parse(&s).map_err(|e| mlua::Error::external(format!("{e}")))?,
        ))
    }
}

impl<'a> IntoLua<'a> for LuaUrl {
    fn into_lua(self, lua: &Lua) -> mlua::Result<mlua::Value> {
        self.0.as_str().into_lua(lua)
    }
}

pub struct LuaMethod(reqwest::Method);

impl<'a> IntoLua<'a> for LuaMethod {
    fn into_lua(self, lua: &Lua) -> mlua::Result<mlua::Value> {
        self.0.as_str().into_lua(lua)
    }
}

impl<'a> FromLua<'a> for LuaMethod {
    fn from_lua(value: mlua::Value<'a>, lua: &'a Lua) -> mlua::Result<Self> {
        let s = <String as FromLua>::from_lua(value, lua)?;
        Ok(LuaMethod(
            reqwest::Method::from_bytes(s.as_bytes())
                .map_err(|e| mlua::Error::external(format!("{e}")))?,
        ))
    }
}
