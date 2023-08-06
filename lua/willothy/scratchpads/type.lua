local class = function(name)
  return function(fields)
    local mt = {
      __index = fields,
      __call = function(self, ...)
        local o = setmetatable({}, { __index = self })
        if o.init then o:init(...) end
        return o
      end,
      __classname = name,
    }
    return setmetatable({}, mt)
  end
end

local test = class("test")({
  init = function(self, a, b)
    self.a = a
    self.b = b
  end,
  test = function(self)
    print(self.a, self.b)
  end,
})

local t = test(1, 2)
t:test()
