require("reach").setup({
  show_current = true,
})

local Display = require("reach.display")

function Display:new()
  local o = {}
  self.config = {
    relative = "editor",
    style = "minimal",
    focusable = false,
    border = "solid",
  }
  self.__index = self
  return setmetatable(o, self)
end

local changed = {}

function Display:add_highlights(highlights)
  for _, hl in pairs(highlights) do
    if hl.group:sub(1, 5) == "Reach" and not changed[hl.group] then
      changed[hl.group] = true
      local hl_val = willothy.hl.get(hl.group)
      hl_val.bg = willothy.hl.fetch_attr("NormalFloat", "bg")
      vim.api.nvim_set_hl(0, hl.group, hl_val)
    end

    self:highlight(hl.group, hl.line, hl.start, hl.finish)
  end
  vim.wo[self.win].winhighlight = "Normal:NormalFloat,FloatBorder:ReachBorder"
end
