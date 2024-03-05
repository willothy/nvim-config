[private]
list:
    @just --list

sidecar:
    cargo build --release
    cp target/release/libsidecar.so lua/sidecar.so

test:
    @nvim --headless -u tests/minimal_init.lua
