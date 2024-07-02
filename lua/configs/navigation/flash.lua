local flash = require("flash")

local on_key_ns

---Returns an iterator over words in a string
---@param str string
---@param offset integer?
---@return fun():string?, integer?
local function words(str, offset)
  offset = offset or 1
  return function()
    local start = str:find("%w+", offset)
    local word = str:match("%w+", start)
    if start == nil or word == nil then
      return
    end
    offset = start + #word
    return word, start
  end
end

---@class Chars
---List of chars that can be used as jump labels, used for char frequency
local Chars = setmetatable({}, {
  __call = function(self)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
  end,
})

---@param chars string
function Chars:setup(chars)
  for char in string.gmatch(chars, ".") do
    Chars[char] = 0
  end
end

---@class Location
---@field label string
---@field pos integer[]
---@field first boolean
local function Location(label, pos, first)
  local loc = {}
  loc.label = label
  loc.pos = pos
  loc.first = first or false
  return loc
end

---@class Locations
---@field ns integer
---@field list Location[]
---Singleton that keeps track of F/f/T/t eyeliner-like jump locs
local Locations = {}

---@class FlashLocConfig
---@field chars string Chars that can be used as labels
---@field hl string[] Highlight groups for primary and secondary matches
---@field range integer Number of lines to search

---@param opts FlashLocConfig?
function Locations:setup(opts)
  Locations.ns = vim.api.nvim_create_namespace("flash_locations")
  Locations = setmetatable({}, { __index = self })
  Locations.list = {}
  local config = require("flash.config").get()
  local labels = config.labels
  local exclude = config.modes.char.label.exclude
  for _, char in ipairs(vim.split(exclude, "")) do
    labels = labels:gsub(char, "")
  end
  labels = labels .. labels:upper()
  Locations.config = vim.tbl_deep_extend("force", {
    chars = labels,
    hl = {
      primary = "Constant",
      secondary = "Macro",
    },
    range = 15,
  }, opts or {})
  Chars:setup(Locations.config.chars)
end

function Locations:clear()
  vim.api.nvim_buf_clear_namespace(0, Locations.ns, 0, -1)
  if on_key_ns then
    ---@diagnostic disable-next-line: param-type-mismatch
    on_key_ns = vim.on_key(nil, on_key_ns) -- remove the listener
    on_key_ns = nil
  end
  Locations.list = {}
end

---@param line string
---@param start integer[]
---@param backward? boolean
---@param chars? Chars
---@param range_back? boolean
function Locations:fetch_line(line, start, backward, chars, range_back)
  chars = chars or Chars()
  local line_words = (
    backward
      and vim
        .iter(vim.iter(words(line:sub(1, range_back and -1 or start[2]))):totable())
        :rev()
    or vim.iter(words(line, start[2] + 2))
  )
  for word, pos in line_words do
    local label
    local partial
    for cnr, char in vim.iter(string.gmatch(word, ".")):enumerate() do
      if chars[char] then
        chars[char] = (chars[char] or 0) + 1
        if label == nil then
          if chars[char] > 1 and chars[char] <= 2 and partial == nil then
            partial = { cnr, char }
          elseif chars[char] == 1 then
            label = { cnr, char }
          end
        end
      end
    end
    if label or partial then
      if not label then
        label = partial
        partial = true
      else
        partial = false
      end
      table.insert(
        Locations.list,
        Location(label[2], { start[1], pos + label[1] - 1 }, not partial)
      )
    end
  end
end

function Locations:render()
  local config = Locations.config
  for _, loc in ipairs(Locations.list) do
    vim.api.nvim_buf_set_extmark(
      0,
      Locations.ns,
      loc.pos[1] - 1,
      loc.pos[2] - 1,
      {
        virt_text = {
          {
            loc.label,
            loc.first and config.hl.primary or config.hl.secondary,
          },
        },
        virt_text_pos = "overlay",
        priority = 6000,
      }
    )
  end
end

function Locations:fetch(back, cursor)
  cursor = cursor or vim.api.nvim_win_get_cursor(0)
  local ch = Chars()
  local lines
  if back then
    lines = vim
      .iter(
        vim.api.nvim_buf_get_lines(
          0,
          math.max(0, cursor[1] - Locations.config.range),
          cursor[1],
          false
        )
      )
      :rev()
      :totable()
  else
    lines = vim.api.nvim_buf_get_lines(
      0,
      cursor[1] - 1,
      math.min(cursor[1] + Locations.config.range, vim.fn.line("$") or 1),
      false
    )
  end
  for i, line in ipairs(lines) do
    if i == 1 then
      Locations:fetch_line(line, cursor, back, ch)
    else
      local row
      if back then
        row = cursor[1] - i + 1
      else
        row = cursor[1] + i - 1
      end
      Locations:fetch_line(line, { row, 0 }, back, ch, back == true)
    end
  end
end

local Char = require("flash.plugins.char")
local Repeat = require("flash.repeat")
local Util = require("flash.util")

-- Override the setup function of the Char plugin
local c = Char.setup
Char.setup = function(...)
  c(...)
  Repeat.setup()
  Locations:setup()

  for _, key in ipairs({
    "f",
    "F",
    "t",
    "T",
    ";",
    ",",
  }) do
    local desc = ""
    if key == "f" then
      desc = "to next char"
    elseif key == "F" then
      desc = "to prev char"
    elseif key == "t" then
      desc = "before next char"
    elseif key == "T" then
      desc = "before prev char"
    else
      desc = "which_key_ignore"
    end
    vim.keymap.set({ "n", "x", "o" }, key, function()
      if Repeat.is_repeat then
        Char.jumping = true
        Char.state:jump({ count = vim.v.count1 })
        Char.state:show()
        vim.schedule(function()
          Char.jumping = false
        end)
      else
        local back = false
        if key == "F" or key == "T" then
          back = true
        end
        local cursor = vim.api.nvim_win_get_cursor(0)
        Locations:fetch(back, cursor)

        Locations:render()
        Char._active = true
        Char.jump(key)
        local function await(cond, after)
          if not cond() then
            vim.defer_fn(function()
              await(cond, after)
            end, 250)
            return
          end
          after()
        end
        await(function()
          if not Char._active then
            return true
          end
          local new_cursor = vim.api.nvim_win_get_cursor(0)
          return new_cursor[1] ~= cursor[1] or new_cursor[2] ~= cursor[2]
        end, function()
          Locations:clear()
        end)
        -- Locations:clear()
      end
    end, {
      silent = true,
      desc = desc,
    })
  end

  vim.api.nvim_create_autocmd({ "BufLeave", "CursorMoved", "InsertEnter" }, {
    group = vim.api.nvim_create_augroup("flash_char", { clear = true }),
    callback = function(event)
      if (event.event == "InsertEnter" or not Char.jumping) and Char.state then
        Char._active = false
        Char.state:hide()
        Locations:clear()
      end
    end,
  })

  on_key_ns = vim.on_key(function(key)
    if
      (Char.state and key == Util.ESC and vim.fn.mode() == "n") or Char._active
    then
      Char._active = false
      Locations:clear()
      return
    end
  end, on_key_ns)
end

flash.setup({
  highlight = {
    groups = {
      match = "FlashMatch",
      current = "FlashCurrent",
      backdrop = "FlashBackdrop",
      label = "Constant",
      -- label = "FlashLabel",
    },
  },
  modes = {
    char = {
      enabled = true,
      jump_labels = false,
      label = { exclude = "hjkliardc" },
      keys = {
        "f",
        "F",
        "t",
        "T",
        -- remove ; and , and use clever-f style repeat
      },
      config = function(opts)
        opts.autohide = vim.fn.mode(true):find("no") and vim.v.operator == "y"

        opts.jump_labels = opts.jump_labels
          and vim.v.count == 0
          and vim.fn.reg_executing() == ""
          and vim.fn.reg_recording() == ""
      end,
    },
  },
})

return {
  fetch = function(back, cursor)
    Locations:fetch(back, cursor)
  end,
  render = function()
    Locations:render()
  end,
  clear = function()
    Locations:clear()
  end,
}
