local _chars = {}
for char in string.gmatch("abcdefghijklmnopqrstuvwxyz", ".") do
  _chars[char] = true
end

---Returns an iterator over words in a string
---@return fun():string, integer
function words(str, offset)
  offset = offset or 1
  return function()
    local start = str:find("%w+", offset)
    local word = str:match("%w+", start)
    if start == nil or word == nil then return nil end
    offset = start + #word
    return word, start
  end
end

---@class Locations
---Singleton that keeps track of F/f/T/t eyeliner-like jump locs
local Locations = {}

Locations.ns = vim.api.nvim_create_namespace("flash_locations")

---@param lines string[]
---Returns the locations of the first occurence of each letter in a word
function Locations:first_occurrences(start_pos, lines)
  local chars = vim.deepcopy(_chars)
  local locations = {}
  local start_line, start_col = unpack(start_pos)

  for lnr, line in ipairs(lines) do
    local offset = 1
    if lnr == 1 then
      offset = start_col + 1
      local leading = line:match("^%w+", offset)
      if leading ~= nil then offset = offset + leading:len() + 1 end
    end
    for word, start in words(line, offset) do
      local has_loc = false
      for cnr, char in vim.iter(word:gmatch("%w")):enumerate() do
        if chars[char] == true then
          chars[char] = false
          if has_loc == false then
            has_loc = true
            table.insert(locations, {
              char = char,
              pos = { start_line + lnr - 1, start + cnr - 1 },
            })
          end
        end
      end
    end
  end

  return locations
end

function Locations:get(fwd)
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)

  local lines
  if fwd then
    lines =
      vim.api.nvim_buf_get_lines(bufnr, math.max(0, cursor[1] - 1), -1, false)
  else
    lines = vim.api.nvim_buf_get_lines(bufnr, 0, cursor[1], false)
  end
  local locs = self:first_occurrences(cursor, lines)
  for _, loc in ipairs(locs) do
    vim.api.nvim_buf_set_extmark(
      bufnr,
      self.ns,
      loc.pos[1] - 1,
      loc.pos[2] - 1,
      {
        virt_text = { { loc.char, "Macro" } },
        virt_text_pos = "overlay",
      }
    )
  end
end

function Locations:clear() vim.api.nvim_buf_clear_namespace(0, self.ns, 0, -1) end

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

        for _, key in ipairs({ "f", "F", "t", "T", ";", "," }) do
          vim.keymap.set({ "n", "x", "o" }, key, function()
            if Repeat.is_repeat then
              Char.jumping = true
              Char.state:jump({ count = vim.v.count1 })
              Char.state:show()
              vim.schedule(function() Char.jumping = false end)
            else
              local fwd = true
              if key == "F" or key == "T" then fwd = false end
              -- Only these lines are changed
              Locations:get(fwd)
              Char.jump(key)
              Locations:clear()
            end
          end, {
            silent = true,
          })
        end

        vim.api.nvim_create_autocmd(
          { "BufLeave", "CursorMoved", "InsertEnter" },
          {
            group = vim.api.nvim_create_augroup("flash_char", { clear = true }),
            callback = function(event)
              if
                (event.event == "InsertEnter" or not Char.jumping)
                and Char.state
              then
                Char.state:hide()
              end
            end,
          }
        )

        vim.on_key(function(key)
          if Char.state and key == Util.ESC and vim.fn.mode() == "n" then
            Char.state:hide()
          end
        end)
      end

      flash.setup({
        highlight = {
          label = {
            style = "overlay",
          },
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
        "S",
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
