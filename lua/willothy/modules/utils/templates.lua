local M = {}

M.py = [[
def main():
    print("hello world")

if __name__ == "__main__":          
    main()
]]
M.python = M.py

M.lua = [[
local M = {}



return M
]]

M.rust = [[
fn main() {
    println!("Hello, world!");
}
]]

M.c = [[
#include <stdio.h>

int main() {
    printf("Hello, world!");
    return 0;
}
]]

M.cpp = [[
#include <iostream>

int main() {
    std::cout << "Hello, world!";
    return 0;
}
]]

M.html = [[
<!DOCTYPE html>
<html>
    <head>
        <title></title>
    </head>
    <body>
    </body>
</html>
]]

return M
