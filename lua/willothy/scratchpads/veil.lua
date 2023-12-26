local wins = {}

---@class Veil.WinInfo
---@field x integer
---@field y integer
---@field width integer
---@field height integer
---@field id integer

local M = {}

local function apply_options(scope, opts)
  for opt, val in pairs(opts) do
    vim.api.nvim_set_option_value(opt, val, scope)
  end
end

local function create_win(contents, config)
  local buf
  if type(contents) == "number" then
    buf = contents
  else
    if type(contents) == "string" then
      contents = { contents }
    elseif type(contents) ~= "table" then
      error("invalid contents")
    end
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, contents)
  end

  if vim.bo[buf].buftype == "terminal" then
    apply_options({ buf = buf }, {
      bufhidden = "wipe",
      swapfile = false,
      buflisted = false,
    })
  else
    apply_options({ buf = buf }, {
      buftype = "nofile",
      bufhidden = "wipe",
      swapfile = false,
      buflisted = false,
      filetype = "veil",
      modifiable = false,
    })
  end

  local wo = config.options or {}
  config.options = nil

  wo = vim.tbl_deep_extend("force", wo, {
    -- maybe?
    -- todo: make this configurable in Component
    number = false,
    relativenumber = false,
    signcolumn = "no",
    numberwidth = 1,
    foldcolumn = "0",
    statuscolumn = "",
  })

  local win = vim.api.nvim_open_win(buf, false, config)

  apply_options({ win = win }, wo)

  return win, buf
end

local function apply_mappings(buf, maps)
  for lhs, rhs in pairs(maps) do
    local mode = "n"
    if type(rhs) == "table" then
      mode = rhs[1]
      rhs = rhs[2]
    end
    vim.keymap.set(mode, lhs, rhs, { buffer = buf })
  end
end

---@type table<Veil.Placement, fun(width: integer, height: integer): { row: integer, col: integer }>
local placements = {
  left = function(_, height)
    return {
      row = math.floor(vim.o.lines / 2) - math.ceil(height / 2),
      col = 0,
    }
  end,
  right = function(width, height)
    return {
      row = math.floor(vim.o.lines / 2) - math.ceil(height / 2),
      col = vim.o.columns - width,
    }
  end,
  top = function(width, _)
    return {
      row = 0,
      col = math.floor(vim.o.columns / 2) - math.ceil(width / 2),
    }
  end,
  bottom = function(width, height)
    return {
      row = vim.o.lines - height,
      col = math.floor(vim.o.columns / 2) - math.ceil(width / 2),
    }
  end,
  center = function(width, height)
    return {
      row = math.floor(vim.o.lines / 2) - math.ceil(height / 2),
      col = math.floor(vim.o.columns / 2) - math.ceil(width / 2),
    }
  end,
}

local function create_wins()
  local width = 20
  local height = 10

  local term = require("toggleterm.terminal").Terminal:new({
    cmd = "btm",
    width = width,
    height = height,
  })
  term:spawn()
  local term_buf = term.bufnr

  for dir, place in pairs(placements) do
    local pos = place(width, height)
    local win, buf = create_win(term_buf, {
      relative = "editor",
      width = width,
      height = height,
      row = pos.row,
      col = pos.col,
    })
    wins[win] = buf
    apply_mappings(buf, {
      ["<C-h>"] = function()
        M.move("left")
      end,
      ["<C-l>"] = function()
        M.move("right")
      end,
      ["<C-k>"] = function()
        M.move("up")
      end,
      ["<C-j>"] = function()
        M.move("down")
      end,
      ["<Esc>"] = function()
        M.close()
      end,
    })
  end
end

function M.close()
  for win in pairs(wins) do
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    wins[win] = nil
  end
end

function M.setup(opts)
  create_wins()

  local autocmd
  autocmd = vim.api.nvim_create_autocmd("WinEnter", {
    callback = function()
      local win = vim.api.nvim_get_current_win()
      if not wins[win] then
        M.close()
        vim.api.nvim_del_autocmd(autocmd)
      end
    end,
  })
end

---@param a integer
---@param b integer
---@return number
local function dist(a, b)
  return math.abs(a - b)
end

---@type table<string, fun(w_info: Veil.WinInfo, cur: Veil.WinInfo): boolean>
local dirs = {
  left = function(w_info, cur)
    return w_info.x + w_info.width < cur.x
  end,
  right = function(w_info, cur)
    return w_info.x > cur.x + cur.width
  end,
  up = function(w_info, cur)
    return w_info.y + w_info.height < cur.y
  end,
  down = function(w_info, cur)
    return w_info.y > cur.y + cur.height
  end,
}

---@param win integer
---@return Veil.WinInfo
local function win_info(win)
  local pos = vim.api.nvim_win_get_position(win)
  return {
    x = pos[2], -- col
    y = pos[1], -- row
    width = vim.api.nvim_win_get_width(win),
    height = vim.api.nvim_win_get_height(win),
    id = win,
  }
end

---@param info1 Veil.WinInfo
---@param info2 Veil.WinInfo
---@return number
local function win_distance(info1, info2)
  return dist(info1.x, info2.x) + dist(info1.y, info2.y)
end

---@param dir "left" | "right" | "up" | "down"
function M.move(dir)
  local curwin = vim.api.nvim_get_current_win()

  if not wins[curwin] then
    local win = vim.iter(wins):next()
    if win then
      vim.api.nvim_set_current_win(win)
    end
    return
  end

  local cur_info = win_info(curwin)

  local best = vim
    .iter(wins)
    -- get list of valid windows in direction
    :filter(function(win)
      return vim.api.nvim_win_is_valid(win) and win ~= curwin
    end)
    :map(function(win)
      return win_info(win)
    end)
    :filter(function(info)
      if dirs[dir](info, cur_info) then
        return true
      end
    end)
    -- find closest window
    :fold(nil, function(best, info)
      if
        best == nil
        or (win_distance(info, cur_info) < win_distance(best, cur_info))
      then
        return info
      end
      return best
    end)

  if best then
    vim.api.nvim_set_current_win(best.id)
  end
end

function M.component()
  local config = {
    render = function()
      return {
        { "Veil", "Normal" },
      }
    end,
    handlers = {
      enter = function() end,
      leave = function() end,
      mouse_enter = function() end,
      mouse_leave = function() end,
      mouse_move = function() end,
    },
    mappings = {},
  }
end

---@alias Veil.Rendered ({ [1]: string, [2]: string })[][]
---@alias Veil.Event "enter" | "leave" | "mouse_enter" | "mouse_leave" | "mouse_move"
---@alias Veil.Placement "left" | "right" | "top" | "bottom" | "center"

---@alias Veil.Handler fun(self: Veil.Component, ...): ...: any

---@class Veil.Component.Config
---@field init fun(self: Veil.Component)
---@field render fun(self: Veil.Component): Veil.Rendered
---@field handlers table<Veil.Event, Veil.Handler>
---@field placement? Veil.Placement
---@field width number
---@field height number

---@class Veil.Component
---@field config Veil.Component.Config
---@field private extmark_id? integer
local Component = {}
Component.__index = Component

function Component.new(config)
  local self = {}

  self.config = vim.deepcopy(config)

  return setmetatable(self, Component)
end

function Component:init()
  local placement = placements[self.config.placement or "center"](
    self.config.width,
    self.config.height
  )
  self.win, self.buf = create_win({}, {
    relative = "editor",
    width = self.config.width or 20,
    height = self.config.height or 10,
    row = placement.row,
    col = placement.col,
  })

  if self.config.init then
    self.config.init(self)
  end
end

function Component:update(event, ...)
  if self.config.handlers[event] then
    local args = { ... }
    require("nio").run(function()
      self.config.handlers[event](self, unpack(args))
    end)
  end
end

function Component:render()
  local lines = self.config.render(self)
  if not lines then
    return
  end

  self.extmark_id = vim.api.nvim_buf_set_extmark(self.buf, M.ns, 0, 0, {
    id = self.extmark_id,
    virt_lines = lines,
  })
end

return M
