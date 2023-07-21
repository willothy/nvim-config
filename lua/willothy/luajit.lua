local ffi = require("ffi")

ffi.cdef([[
typedef struct {

} lua_State;

int lua_pushnumber(lua_State* l, int num);

void lua_close(lua_State* l);

lua_State* luaL_newstate();

void lua_getfield(lua_State* l, int idx, const char* key);
void lua_setfield(lua_State* l, int idx, const char* key);
int lua_tointeger(lua_State* l, int idx);
double lua_tonumber(lua_State* l, int idx);
const char* lua_tolstring(lua_State* l, int idx, size_t* len);
void lua_pushlstring(lua_State* l, const char* s, size_t len);

char* lua_typename(lua_State* l, int idx);
int lua_type (lua_State* l, int idx);
void* lua_newuserdata(lua_State* l, size_t size);
]])

local Type = vim.tbl_add_reverse_lookup({
	None = -1,
	Nil = 0,
	Boolean = 1,
	LightUserData = 2,
	Number = 3,
	String = 4,
	Table = 5,
	Function = 6,
	UserData = 7,
	Thread = 8,
})

local globals = -10002

local C = ffi.C

local state = C.luaL_newstate()
-- C.lua_pushnumber(state, 5)
C.lua_pushlstring(state, "hello", 5)
C.lua_setfield(state, globals, ffi.string("test"))
C.lua_getfield(state, globals, ffi.string("test"))
local t = Type[C.lua_type(state, -1)]
print(t)
-- print(ffi.string(t))
-- local x = C.lua_tolstring(state, 1, 4) --C.lua_tointeger(state, -1)
-- print(x)
