use std::sync::{Arc, RwLock};

use libsql::{Builder, Connection, Database};
use mlua::{Error as LuaError, Integer, Lua, Table, UserData};

pub mod http;
pub mod object;

#[derive(Clone)]
pub struct LuaDatabase {
    #[allow(unused)]
    db: Arc<RwLock<Database>>,
    conn: Connection,
}

impl LuaDatabase {
    pub async fn execute(_lua: &Lua, this: &LuaDatabase, query: String) -> mlua::Result<Integer> {
        let rt = tokio::runtime::Runtime::new().unwrap();
        rt.block_on(async move {
            let result = this.conn.execute(&query, ()).await.into_lua_result()?;
            Ok(result as Integer)
        })
    }
}

impl UserData for LuaDatabase {
    fn add_fields<'lua, F: mlua::prelude::LuaUserDataFields<'lua, Self>>(fields: &mut F) {
        fields.add_field_method_get("test", |_, _this| Ok(chrono::Utc::now().to_string()));
    }

    fn add_methods<'lua, M: mlua::prelude::LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        methods.add_async_method("execute", Self::execute);
    }
}

pub(crate) trait IntoLuaResult<T, E> {
    fn into_lua_result(self) -> mlua::Result<T>
    where
        E: Into<Box<dyn std::error::Error + Send + Sync>>;
}

impl<T, E> IntoLuaResult<T, E> for Result<T, E> {
    fn into_lua_result(self) -> mlua::Result<T>
    where
        E: Into<Box<dyn std::error::Error + Send + Sync>>,
    {
        self.map_err(LuaError::external)
    }
}

pub async fn connect(_lua: &Lua, (url, token): (String, String)) -> mlua::Result<LuaDatabase> {
    let db = Builder::new_remote(url, token)
        .build()
        .await
        .into_lua_result()?;

    let conn = db.connect().into_lua_result()?;

    Ok(LuaDatabase {
        db: Arc::new(RwLock::new(db)),
        conn,
    })
}

#[mlua::lua_module]
pub fn sidecar(lua: &Lua) -> mlua::Result<Table> {
    let module = lua.create_table()?;

    module.set("connect", lua.create_async_function(connect)?)?;

    Ok(module)
}
