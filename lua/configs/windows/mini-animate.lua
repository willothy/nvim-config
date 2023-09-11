local subresize = function(easing)
  return function(sizes_from, sizes_to)
    -- Don't animate single window
    if #vim.tbl_keys(sizes_from) == 1 then
      return {}
    end

    -- Compute number of steps
    local n_steps = 0
    for win_id, dims_from in pairs(sizes_from) do
      local height_absdiff =
        math.abs(sizes_to[win_id].height - dims_from.height)
      local width_absdiff = math.abs(sizes_to[win_id].width - dims_from.width)
      n_steps = math.max(n_steps, height_absdiff, width_absdiff)
    end
    if n_steps <= 1 then
      return {}
    end

    -- Make subresize array
    local res = {}
    for i = 1, n_steps do
      local coef = i / n_steps
      local sub_res = {}
      for win_id, dims_from in pairs(sizes_from) do
        sub_res[win_id] = {
          height = easing(dims_from.height, sizes_to[win_id].height, coef),
          width = easing(dims_from.width, sizes_to[win_id].width, coef),
        }
      end
      res[i] = sub_res
    end

    return res
  end
end

---@alias ease_fn fun(from: integer, to: integer, coef: number): integer

---@type table<string, ease_fn>
local easing = {}

function easing.linear(from, to, coef)
  return math.floor(from + (to - from) * coef)
end

function easing.ease_in(from, to, coef)
  return math.floor(from + (to - from) * coef ^ 2)
end

function easing.ease_out(from, to, coef)
  return math.floor(from + (to - from) * (1 - (1 - coef) ^ 2))
end

local function duration(ms)
  return function(_, n)
    return ms / n
  end
end

local anim = require("mini.animate")
anim.setup({
  open = {
    enable = false,
    winconfig = anim.gen_winconfig.wipe({ direction = "from_edge" }),
    winblend = anim.gen_winblend.linear({ from = 100, to = 0 }),
    timing = anim.gen_timing.quartic({
      easing = "in",
      duration = 500,
      unit = "total",
    }),
  },
  close = {
    enable = true,
    winconfig = anim.gen_winconfig.wipe(),
    winblend = anim.gen_winblend.linear({ from = 40, to = 100 }),
    timing = anim.gen_timing.quartic({
      easing = "out",
      duration = 400,
      unit = "total",
    }),
  },
  cursor = { enable = false },
  scroll = {
    enable = false,
  },
  resize = {
    enable = true,
    timing = duration(200),
    subresize = subresize(easing.ease_out),
  },
})
