---Returns an iterator over words in a string
---@param str string
---@param offset integer
---@return fun():string, integer
local function words(str, offset)
  offset = offset or 1
  return function()
    local start = str:find("%w+", offset)
    local word = str:match("%w+", start)
    if start == nil or word == nil then return nil end
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
---@field ns Namespace
---@field list Location[]
---Singleton that keeps track of F/f/T/t eyeliner-like jump locs
local Locations = {}

---@class FlashLocConfig
---@field chars string Chars that can be used as labels
---@field hl string[] Highlight groups for primary and secondary matches
---@field range integer Number of lines to search

---@param opts FlashLocConfig
function Locations:setup(opts)
  Locations.ns = vim.api.nvim_create_namespace("flash_locations")
  Locations = setmetatable({}, { __index = self })
  Locations.list = {}
  Locations.config = vim.tbl_deep_extend("force", {
    chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
    hl = {
      primary = "Type",
      secondary = "Macro",
    },
    range = 15,
  }, opts or {})
  Chars:setup(Locations.config.chars)
end

function Locations:clear()
  vim.api.nvim_buf_clear_namespace(0, Locations.ns, 0, -1)
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
    local label ---@type integer
    local partial ---@type integer
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
    vim.api.nvim_buf_set_extmark(0, Locations.ns, loc.pos[1] - 1, loc.pos[2] - 1, {
      virt_text = {
        { loc.label, loc.first and config.hl.primary or config.hl.secondary },
      },
      virt_text_pos = "overlay",
      priority = 6000,
    })
  end
end

return {
  {
    "folke/flash.nvim",
    lazy = true,
    event = "VeryLazy",
    config = function()
      local flash = require("flash")
      local Repeat = require("flash.repeat")
      local Util = require("flash.util")
      local Char = require("flash.plugins.char")

      -- Override the setup function of the Char plugin
      Char.setup = function()
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
          vim.keymap.set({ "n", "x", "o" }, key, function()
            if Repeat.is_repeat then
              Char.jumping = true
              Char.state:jump({ count = vim.v.count1 })
              Char.state:show()
              vim.schedule(function() Char.jumping = false end)
            else
              local back = false
              if key == "F" or key == "T" then back = true end
              local cursor = vim.api.nvim_win_get_cursor(0)
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
                  math.min(cursor[1] + Locations.config.range, vim.fn.line("$")),
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
              Locations:render()
              Char.jump(key)
              Locations:clear()
            end
          end, {
            silent = true,
          })
        end

        vim.api.nvim_create_autocmd({ "BufLeave", "CursorMoved", "InsertEnter" }, {
          group = vim.api.nvim_create_augroup("flash_char", { clear = true }),
          callback = function(event)
            if
              (event.event == "InsertEnter" or not Char.jumping)
              and Char.state
            then
              Char.state:hide()
            end
          end,
        })

        vim.on_key(function(key)
          if Char.state and key == Util.ESC and vim.fn.mode() == "n" then
            Char.state:hide()
          end
        end)
      end

      flash.setup({
        label = {
          style = "overlay",
        },
        highlight = {
          groups = {
            match = "HlSearch",
            label = "Macro",
          },
        },
        modes = {
          char = {
            enabled = true,
          },
        },
      })
    end,
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          -- default options: exact mode, multi window, all directions, with a backdrop
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "<M-s>",
        mode = { "n", "o", "x" },
        function()
          -- show labeled treesitter nodes around the cursor
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "r",
        mode = "o",
        function()
          -- jump to a remote location to execute the operator
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "R",
        mode = { "n", "o", "x" },
        function()
          -- show labeled treesitter nodes around the search matches
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
    },
  },
}
