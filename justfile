[private]
list:
    @just --list

test:
    @nvim --headless -u tests/init.lua
