[private]
list:
    @just --list

test:
    @nvim --headless -u tests/minimal_init.lua
