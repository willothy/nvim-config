use nvim_oxi as oxi;
use oxi::{Dictionary, Function};

pub mod http;
pub mod object;
pub mod turso;

#[oxi::module]
pub fn sidecar() -> oxi::Result<Dictionary> {
    Ok(Dictionary::from_iter([
        ("request", Function::from_fn(http::request)),
        //
    ]))
}
