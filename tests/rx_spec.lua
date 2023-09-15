local helpers = require("plenary.busted")

local describe, it, before_each =
  helpers.describe, helpers.it, helpers.before_each

local rx = require("willothy.modules.rx")

---@type Rx.Runtime
local rt

describe("rx.lua", function()
  before_each(function()
    rt = rx.Runtime:new()
  end)

  it("creates a signal", function()
    local num = rt:create_signal(5)

    assert(num:get() == 5)
  end)

  it("registers effect depencies", function()
    local num = rt:create_signal(5)

    local id = rt:create_effect(function()
      num:get()
    end)

    assert(
      rt.signal_subscribers[num.id]:has(id),
      "effect did not register dependency"
    )
  end)

  it(
    "does not register signals used by child effects as dependencies",
    function()
      local num = rt:create_signal(5)
      local num2 = rt:create_signal(6)

      local id2
      local id = rt:create_effect(function()
        num:get()
        id2 = rt:create_effect(function()
          num2:get()
        end)
      end)

      assert(
        rt.signal_subscribers[num.id]:has(id),
        "effect1 did not register dependency"
      )
      assert(
        not rt.signal_subscribers[num.id]:has(id2),
        "singal2 registered as dependency of effect1"
      )
      assert(
        rt.signal_subscribers[num2.id]:has(id2),
        "effect2 did not register dependency"
      )
    end
  )

  it("dispatches effects", function()
    local num = rt:create_signal(5)
    local num2 = rt:create_signal(6)
    local id = rt:create_effect(function()
      num2:set(num:get() + 1)
    end)
    assert(num2:get() == 6, "effect did not run")
    num:set(10)
    assert(num2:get() == 11, "effect did not run")
  end)

  it("dispatches nested effects", function()
    local num = rt:create_signal(5)
    local num2 = rt:create_signal(6)
    local num3 = rt:create_signal(7)
    rt:create_effect(function()
      num2:set(num:get() + 1)
      rt:create_effect(function()
        num3:set(num2:get() + 1)
      end)
    end)
    assert(num2:get() == 6, "effect did not run")
    assert(num3:get() == 7, "effect did not run")
    num:set(10)
    assert(num2:get() == 11, "effect did not run")
    assert(num3:get() == 12, "effect did not run")
  end)
end)
