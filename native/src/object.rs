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

pub trait LuaJSON {
    fn into_json(self) -> oxi::Result<serde_json::value::Value>;

    fn from_json(value: serde_json::value::Value) -> oxi::Result<Self>
    where
        Self: Sized;
}

impl LuaJSON for oxi::Object {
    fn into_json(self) -> oxi::Result<serde_json::value::Value> {
        match self.kind() {
            oxi::ObjectKind::Boolean => {
                serde_json::to_value(unsafe { self.as_boolean_unchecked() }).map_err(|e| {
                    oxi::Error::ObjectConversion(oxi::conversion::Error::Serde(
                        oxi::serde::Error::Serialize(e.to_string()),
                    ))
                })
            }
            oxi::ObjectKind::Integer => {
                serde_json::to_value(unsafe { self.as_integer_unchecked() }).map_err(|e| {
                    oxi::Error::ObjectConversion(oxi::conversion::Error::Serde(
                        oxi::serde::Error::Serialize(e.to_string()),
                    ))
                })
            }
            oxi::ObjectKind::Float => serde_json::to_value(unsafe { self.as_float_unchecked() })
                .map_err(|e| {
                    oxi::Error::ObjectConversion(oxi::conversion::Error::Serde(
                        oxi::serde::Error::Serialize(e.to_string()),
                    ))
                }),
            oxi::ObjectKind::String => {
                serde_json::to_value(unsafe { self.into_string_unchecked().to_string() }).map_err(
                    |e| {
                        oxi::Error::ObjectConversion(oxi::conversion::Error::Serde(
                            oxi::serde::Error::Serialize(e.to_string()),
                        ))
                    },
                )
            }
            oxi::ObjectKind::Array => unsafe { self.into_array_unchecked() }
                .into_iter()
                .try_fold(Vec::new(), |mut list, v| {
                    list.push(v.into_json()?);
                    Ok(list)
                })
                .and_then(|list| {
                    serde_json::to_value(list).map_err(|e| {
                        oxi::Error::ObjectConversion(oxi::conversion::Error::Serde(
                            oxi::serde::Error::Serialize(e.to_string()),
                        ))
                    })
                }),
            oxi::ObjectKind::Dictionary => unsafe { self.into_dict_unchecked() }
                .into_iter()
                .try_fold(HashMap::new(), |mut table, (k, v)| {
                    table.insert(k.to_string(), v.into_json()?);
                    Ok(table)
                })
                .and_then(|table| {
                    serde_json::to_value(table).map_err(|e| {
                        oxi::Error::ObjectConversion(oxi::conversion::Error::Serde(
                            oxi::serde::Error::Serialize(e.to_string()),
                        ))
                    })
                }),
            // oxi::ObjectKind::Nil     |
            // oxi::ObjectKind::LuaRef  |
            // oxi::ObjectKind::Buffer  |
            // oxi::ObjectKind::Window  |
            // oxi::ObjectKind::TabPage |
            _ => Err(oxi::Error::ObjectConversion(
                oxi::conversion::Error::FromWrongType {
                    expected: "string, number, array, or dictionary",
                    actual: self.oxi_type_name(),
                },
            )),
        }
    }

    fn from_json(value: serde_json::value::Value) -> oxi::Result<oxi::Object>
    where
        Self: Sized,
    {
        value
            .serialize(oxi::serde::Serializer::new())
            .map_err(|e| oxi::Error::ObjectConversion(oxi::conversion::Error::Serde(e)))
    }
}
