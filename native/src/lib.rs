use std::sync::{atomic::AtomicBool, Arc};

use nvim_oxi as oxi;
use oxi::{
    libuv::AsyncHandle,
    lua::{Poppable, Pushable},
    Dictionary, Function, Object,
};
use reqwest::Url;
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

fn get((url, callback): (LuaUrl, Function<(bool, String), ()>)) -> oxi::Result<Object> {
    // TODO: make this a more generic request function, not just get
    //
    // and make a sync version, maybe just as a Lua wrapper with vim.wait though
    let success = Arc::new(AtomicBool::new(true));
    let retval = Arc::new(Mutex::new(None));
    let handle = AsyncHandle::new({
        let res = retval.clone();
        let success = success.clone();
        move || {
            let res = res.blocking_lock().take().unwrap_or("unknown".to_string());

            let success = success.load(std::sync::atomic::Ordering::Relaxed);
            callback.call((success, res))?;
            oxi::Result::Ok(())
        }
    })?;
    // create a new thread so that the request doesn't get interrupted on return
    std::thread::spawn(|| {
        // TODO: can I reuse the tokio runtime by caching it in the Lua registry as userdata?
        let rt = tokio::runtime::Runtime::new().unwrap();
        let task = rt.spawn(async move {
            match reqwest::get(url.0).await {
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
        ("get", Function::from_fn(get)),
        //
    ]))
}
