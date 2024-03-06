use mlua::{serde::LuaSerdeExt as _, Lua, LuaSerdeExt};
use std::collections::HashMap;

use nvim_oxi as oxi;
use serde::Serialize;

pub fn err(e: impl std::fmt::Display) -> oxi::Error {
    oxi::Error::from(oxi::api::Error::Other(format!("{e}")))
}

pub trait OxiTypeName {
    fn oxi_type_name(&self) -> &'static str;
}

impl OxiTypeName for oxi::Object {
    fn oxi_type_name(&self) -> &'static str {
        match self.kind() {
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
}

pub trait LuaJSON<'a> {
    fn into_json(self, lua: &'a Lua) -> mlua::Result<serde_json::value::Value>;

    fn from_json(value: serde_json::value::Value, lua: &'a Lua) -> mlua::Result<Self>
    where
        Self: Sized;
}

impl<'a> LuaJSON<'a> for oxi::Object {
    fn into_json(self, lua: &Lua) -> mlua::Result<serde_json::value::Value> {
        match self.kind() {
            oxi::ObjectKind::Boolean => {
                serde_json::to_value(unsafe { self.as_boolean_unchecked() })
                    .map_err(|e| mlua::Error::external(e))
            }
            oxi::ObjectKind::Integer => {
                serde_json::to_value(unsafe { self.as_integer_unchecked() })
                    .map_err(|e| mlua::Error::external(e))
            }
            oxi::ObjectKind::Float => serde_json::to_value(unsafe { self.as_float_unchecked() })
                .map_err(|e| mlua::Error::external(e)),
            oxi::ObjectKind::String => {
                serde_json::to_value(unsafe { self.into_string_unchecked().to_string() })
                    .map_err(|e| mlua::Error::external(e))
            }
            oxi::ObjectKind::Array => unsafe { self.into_array_unchecked() }
                .into_iter()
                .try_fold(Vec::new(), |mut list, v| {
                    list.push(v.into_json(lua)?);
                    Ok(list)
                })
                .and_then(|list| serde_json::to_value(list).map_err(|e| mlua::Error::external(e))),
            oxi::ObjectKind::Dictionary => unsafe { self.into_dict_unchecked() }
                .into_iter()
                .try_fold(HashMap::new(), |mut table, (k, v)| {
                    table.insert(k.to_string(), v.into_json(lua)?);
                    Ok(table)
                })
                .and_then(|table| {
                    serde_json::to_value(table).map_err(|e| mlua::Error::external(e))
                }),
            // oxi::ObjectKind::Nil     |
            // oxi::ObjectKind::LuaRef  |
            // oxi::ObjectKind::Buffer  |
            // oxi::ObjectKind::Window  |
            // oxi::ObjectKind::TabPage |
            _ => Err(mlua::Error::external(
                oxi::conversion::Error::FromWrongType {
                    expected: "string, number, array, or dictionary",
                    actual: self.oxi_type_name(),
                },
            )),
        }
    }

    fn from_json(value: serde_json::value::Value, _lua: &Lua) -> mlua::Result<oxi::Object>
    where
        Self: Sized,
    {
        value
            .serialize(oxi::serde::Serializer::new())
            .map_err(|e| mlua::Error::external(e))
    }
}

impl<'a> LuaJSON<'a> for mlua::Value<'a> {
    fn into_json(self, lua: &Lua) -> mlua::Result<serde_json::value::Value> {
        match self {
            mlua::Value::Nil => Ok(serde_json::Value::Null),
            mlua::Value::Boolean(b) => Ok(serde_json::Value::Bool(b)),
            mlua::Value::LightUserData(ptr) => Err(mlua::Error::external(
                oxi::conversion::Error::FromWrongType {
                    expected: "string, number, array, or dictionary",
                    actual: "lightuserdata",
                },
            )),
            mlua::Value::Integer(i) => {
                serde_json::to_value(i).map_err(|e| mlua::Error::external(e))
            }
            mlua::Value::Number(n) => serde_json::to_value(n).map_err(|e| mlua::Error::external(e)),
            mlua::Value::String(s) => {
                serde_json::to_value(s.to_str()?).map_err(|e| mlua::Error::external(e))
            }
            mlua::Value::Table(t) => {
                let mut map = HashMap::new();
                for pair in t.pairs::<mlua::Value, mlua::Value>() {
                    let (k, v) = pair?;
                    if !k.is_string() {
                        return Err(mlua::Error::external(
                            oxi::conversion::Error::FromWrongType {
                                expected: "string",
                                actual: k.type_name(),
                            },
                        ));
                    }
                    map.insert(k.to_string()?, v.into_json(lua)?);
                }
                serde_json::to_value(map).map_err(|e| mlua::Error::external(e))
            }
            mlua::Value::Function(_) => Err(mlua::Error::external(
                oxi::conversion::Error::FromWrongType {
                    expected: "string, number, array, or dictionary",
                    actual: "function",
                },
            )),
            mlua::Value::Thread(_) => Err(mlua::Error::external(
                oxi::conversion::Error::FromWrongType {
                    expected: "string, number, array, or dictionary",
                    actual: "thread",
                },
            )),
            mlua::Value::UserData(_) => Err(mlua::Error::external(
                oxi::conversion::Error::FromWrongType {
                    expected: "string, number, array, or dictionary",
                    actual: "userdata",
                },
            )),
            mlua::Value::Error(_) => Err(mlua::Error::external(
                oxi::conversion::Error::FromWrongType {
                    expected: "string, number, array, or dictionary",
                    actual: "error",
                },
            )),
        }
    }

    fn from_json(value: serde_json::value::Value, lua: &'a Lua) -> mlua::Result<mlua::Value<'a>>
    where
        Self: Sized,
    {
        value.serialize(mlua::serde::Serializer::new(lua))
    }
}
