//! Lua bindings for the Turso LibSQL library.

pub struct LuaDatabase {
    db: libsql::Database,
    conn: libsql::Connection,
}
