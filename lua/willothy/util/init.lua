return setmetatable({}, {
  __index = function(_, k)
    return require("willothy.util." .. k)
  end,
})
