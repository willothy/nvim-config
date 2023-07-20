local function telescope(picker)
  return function(...)
    local t = require("telescope")
    local ext = t.extensions
    if ext.menufacture[picker] ~= nil then
      ext.menufacture[picker](...)
    elseif require("telescope.builtin")[picker] then
      require("telescope.builtin")[picker](...)
    elseif ext[picker] then
      ext[picker][picker](...)
    else
      vim.notify(string.format("unknown picker %s", picker))
    end
  end
end

--- Lazy-load hydras on body keys, and add the body as a group
--- in which-key
local Hydra = function(hintfunc, config)
  if config == nil and type(hintfunc) == "table" then
    config = hintfunc
    hintfunc = nil
  end
  local this

  local on_enter = function(f)
    return function(...)
      if f then f(...) end
      vim.api.nvim_exec_autocmds("User", {
        pattern = "HydraEnter",
      })
    end
  end
  local on_exit = function(f)
    return function(...)
      if f then f(...) end
      vim.api.nvim_exec_autocmds("User", {
        pattern = "HydraLeave",
      })
    end
  end
  config.config.on_exit = on_exit(config.config.on_exit)
  config.config.on_enter = on_enter(config.config.on_enter)
  if config.body and config.body ~= "" then
    vim.keymap.set(config.mode, config.body, function()
      if this == nil then
        config.body = nil
        if hintfunc then config.hint = hintfunc(config) end
        this = require("hydra")(config)
      end
      this:activate()
    end)
    require("which-key").register({
      [config.body] = {
        name = (config.shortname or config.name):lower(),
        group = true,
        ["a"] = "which_key_ignore",
      },
    }, {})
  else
    local ready = false
    this = setmetatable({}, {
      __index = function(_, k)
        if not ready then
          ready = true
          this = require("hydra")(config)
          if k == "activate" then
            this:activate()
            return function() end
          end
        end
        return this[k]
      end,
    })
  end
  return this
end

local cmd = require("hydra.keymap-util").cmd

Hydra(function(config)
  ---@type Lines
  local Lines = require("willothy.lines")
  local backgrounds = require("willothy.lines.backgrounds")
  local elements = require("willothy.lines.elements")

  local keys = {}
  local exits = {}
  local ends = {}

  for _, head in ipairs(config.heads) do
    if head[3].ends then
      table.insert(ends, { key = head[1], desc = head[3].desc or "" })
    elseif head[3].exit == true then
      table.insert(exits, { key = head[1], desc = head[3].desc or "" })
    else
      table.insert(keys, { key = head[1], desc = head[3].desc or "" })
    end
  end

  local maps = Lines:actions(keys):trim_trailing_whitespace()

  local backups = {}
  vim.iter(ends):each(function(action)
    table.insert(backups, action)
    table.insert(backups, { key = "", desc = "" })
  end)
  backups = Lines:actions(backups):trim_trailing_whitespace()

  local first = true
  exits = Lines:new(
    vim
      .iter(exits)
      :map(function(exit) return exit.key end)
      :fold("", function(a, v)
        if first == true then
          first = false
          return "_" .. v .. "_"
        else
          return a .. ", " .. "_" .. v .. "_"
        end
      end) .. ": close"
  ):trim_trailing_whitespace()

  local vert_size = maps.dimensions[1]
    + exits.dimensions[1]
    + backups.dimensions[1]
    + 3

  local bg = backgrounds.space
  local btm = elements.misc.land_border:trim_trailing_whitespace()
  local fg = elements.telescope.dog:trim_trailing_whitespace()
  local drop = Lines:empty({ vert_size, bg.dimensions[2] })

  bg = bg:truncate_height(vert_size, 9)

  local map_col = bg.dimensions[2] - maps.dimensions[2] - 4

  return drop
    :overlay(bg)
    :overlay(btm, vert_size)
    :overlay(fg, (vert_size - fg.dimensions[1] + 1) - bg.dimensions[1], nil)
    :overlay(maps, 2, map_col, true)
    :overlay(backups, 3 + maps.dimensions[1], map_col, true)
    :overlay(exits, -1, map_col, false)
    :trim_trailing_whitespace()
    :escape()
    :render()
end, {
  name = "Telescope",
  config = {
    color = "blue",
    invoke_on_body = true,
    hint = {
      position = "bottom-left",
      border = "rounded",
    },
  },
  mode = "n",
  body = "<leader>f",
  heads = {
    {
      "s",
      telescope("live_grep"),
      { desc = "live grep" },
    },
    {
      "f",
      telescope("find_files"),
      { desc = "find files" },
    },
    {
      "g",
      telescope("git_files"),
      { desc = "git files" },
    },
    { "r", telescope("resume"), { desc = "resume" } },
    {
      "p",
      telescope("projects"),
      { desc = "projects" },
    },
    {
      "u",
      cmd("silent! UndotreeToggle"),
      { desc = "undotree" },
    },
    {
      "<Enter>",
      telescope("builtin"),
      { desc = "pickers", ends = true },
    },
    {
      "<Esc>",
      nil,
      { exit = true, nowait = true, desc = "close" },
    },
    { "q", nil, { exit = true, nowait = true, desc = "close" } },
  },
})

local hint = [[
  ^ ^        Options
  ^
  _v_ %{ve} virtual edit
  _i_ %{list} invisible characters  
  _s_ %{spell} spell
  _w_ %{wrap} wrap
  _c_ %{cul} cursor line
  _n_ %{nu} number
  _r_ %{rnu} relative number
  ^
       ^^^^                _<Esc>_
]]

Hydra({
  name = "Options",
  hint = hint,
  config = {
    color = "amaranth",
    invoke_on_body = true,
    hint = {
      border = "rounded",
      position = "bottom-left",
    },
  },
  mode = { "n", "x" },
  body = "<leader>o",
  heads = {
    {
      "n",
      function()
        if vim.o.number == true then
          vim.o.number = false
        else
          vim.o.number = true
        end
      end,
      { desc = "number" },
    },
    {
      "r",
      function()
        if vim.o.relativenumber == true then
          vim.o.relativenumber = false
        else
          vim.o.number = true
          vim.o.relativenumber = true
        end
      end,
      { desc = "relativenumber" },
    },
    {
      "v",
      function()
        if vim.o.virtualedit == "all" then
          vim.o.virtualedit = "block"
        else
          vim.o.virtualedit = "all"
        end
      end,
      { desc = "virtualedit" },
    },
    {
      "i",
      function()
        if vim.o.list == true then
          vim.o.list = false
        else
          vim.o.list = true
        end
      end,
      { desc = "show invisible" },
    },
    {
      "s",
      function()
        if vim.o.spell == true then
          vim.o.spell = false
        else
          vim.o.spell = true
        end
      end,
      { exit = true, desc = "spell" },
    },
    {
      "w",
      function()
        if vim.o.wrap ~= true then
          vim.o.wrap = true
          -- Dealing with word wrap:
          -- If cursor is inside very long line in the file than wraps
          -- around several rows on the screen, then 'j' key moves you to
          -- the next line in the file, but not to the next row on the
          -- screen under your previous position as in other editors. These
          -- bindings fixes this.
          vim.keymap.set(
            "n",
            "k",
            function() return vim.v.count > 0 and "k" or "gk" end,
            { expr = true, desc = "k or gk" }
          )
          vim.keymap.set(
            "n",
            "j",
            function() return vim.v.count > 0 and "j" or "gj" end,
            { expr = true, desc = "j or gj" }
          )
        else
          vim.o.wrap = false
          vim.keymap.del("n", "k")
          vim.keymap.del("n", "j")
        end
      end,
      { desc = "wrap" },
    },
    {
      "c",
      function()
        if vim.o.cursorline == true then
          vim.o.cursorline = false
        else
          vim.o.cursorline = true
        end
      end,
      { desc = "cursor line" },
    },
    { "<Esc>", nil, { exit = true } },
  },
})

local gitsigns = require("gitsigns")
local git_hydra_hint = [[
 _J_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
 _K_: prev hunk   _u_: undo last stage   _p_: preview hunk   _B_: blame show full 
 ^ ^              _S_: stage buffer      ^ ^                 _/_: show base file
 ^
 ^ ^              _<Enter>_: Neogit              _q_: exit
]]

Hydra({
  name = "Git",
  hint = git_hydra_hint,
  config = {
    -- buffer = bufnr,
    color = "pink",
    invoke_on_body = true,
    hint = {
      border = "rounded",
    },
    on_enter = function()
      vim.cmd("mkview")
      vim.cmd("silent! %foldopen!")
      vim.bo.modifiable = false
      gitsigns.toggle_signs(true)
      gitsigns.toggle_linehl(true)
    end,
    on_exit = function()
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      vim.cmd("loadview")
      vim.api.nvim_win_set_cursor(0, cursor_pos)
      vim.cmd("normal zv")
      gitsigns.toggle_signs(false)
      gitsigns.toggle_linehl(false)
      gitsigns.toggle_deleted(false)
    end,
  },
  mode = { "n", "x" },
  body = "<leader>gh",
  heads = {
    {
      "J",
      function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gitsigns.next_hunk() end)
        return "<Ignore>"
      end,
      { expr = true, desc = "next hunk" },
    },
    {
      "K",
      function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gitsigns.prev_hunk() end)
        return "<Ignore>"
      end,
      { expr = true, desc = "prev hunk" },
    },
    { "s", ":Gitsigns stage_hunk<CR>", { silent = true, desc = "stage hunk" } },
    { "u", gitsigns.undo_stage_hunk, { desc = "undo last stage" } },
    { "S", gitsigns.stage_buffer, { desc = "stage buffer" } },
    { "p", gitsigns.preview_hunk, { desc = "preview hunk" } },
    {
      "d",
      gitsigns.toggle_deleted,
      { nowait = true, desc = "toggle deleted" },
    },
    { "b", gitsigns.blame_line, { desc = "blame" } },
    {
      "B",
      function() gitsigns.blame_line({ full = true }) end,
      { desc = "blame show full" },
    },
    {
      "/",
      function() pcall(gitsigns.show) end,
      { exit = true, desc = "show base file" },
    }, -- show the base of the file
    {
      "<Enter>",
      function()
        if pcall(require, "neogit") then vim.cmd("Neogit") end
      end,
      { exit = true, desc = "Neogit" },
    },
    { "q", nil, { exit = true, nowait = true, desc = "exit" } },
  },
})

local pcmd = require("hydra.keymap-util").pcmd

-- local buffer_hydra = Hydra({
--   name = "Barbar",
--   config = {
--     on_key = function()
--       -- Preserve animation
--       vim.wait(200, function() vim.cmd("redraw") end, 30, false)
--     end,
--   },
--   heads = {
--     { "h", function() vim.cmd("BufferPrevious") end, { on_key = false } },
--     {
--       "l",
--       function() vim.cmd("BufferNext") end,
--       { desc = "choose", on_key = false },
--     },
--
--     { "H", function() vim.cmd("BufferMovePrevious") end },
--     { "L", function() vim.cmd("BufferMoveNext") end, { desc = "move" } },
--
--     { "p", function() vim.cmd("BufferPin") end, { desc = "pin" } },
--
--     { "d", function() vim.cmd("BufferClose") end, { desc = "close" } },
--     { "c", function() vim.cmd("BufferClose") end, { desc = false } },
--     { "q", function() vim.cmd("BufferClose") end, { desc = false } },
--
--     {
--       "od",
--       function() vim.cmd("BufferOrderByDirectory") end,
--       { desc = "by directory" },
--     },
--     {
--       "ol",
--       function() vim.cmd("BufferOrderByLanguage") end,
--       { desc = "by language" },
--     },
--     { "<Esc>", nil, { exit = true } },
--   },
-- })
--
-- local function choose_buffer()
--   if #vim.fn.getbufinfo({ buflisted = true }) > 1 then
--     buffer_hydra:activate()
--   end
-- end
--
-- vim.keymap.set("n", "gb", choose_buffer)

local window_hint = [[
 ^^^^^^^^^^^^     Move      ^^    Size   ^^   ^^     Split
 ^^^^^^^^^^^^-------------  ^^-----------^^   ^^---------------
 ^ ^ _k_ ^ ^  ^ ^ _K_ ^ ^   ^   _<C-k>_   ^   _s_: horizontally 
 _h_ ^ ^ _l_  _H_ ^ ^ _L_   _<C-h>_ _<C-l>_   _v_: vertically
 ^ ^ _j_ ^ ^  ^ ^ _J_ ^ ^   ^   _<C-j>_   ^   _q_: close
 focus^^^^^^  window^^^^^^  ^_=_: equalize^   _z_: maximize
 ^ ^ ^ ^ ^ ^  ^ ^ ^ ^ ^ ^   ^^ ^          ^   _o_: remain only
 _b_: choose buffer
]]

Hydra({
  name = "Windows",
  shortname = "ctrl",
  hint = window_hint,
  config = {
    color = "pink",
    invoke_on_body = true,
    hint = {
      border = "rounded",
      position = "bottom-left",
    },
  },
  mode = "n",
  body = "<C-w>w",
  heads = {
    { "h", function() require("smart-splits").move_cursor_left() end },
    { "j", function() require("smart-splits").move_cursor_down() end },
    { "k", function() require("smart-splits").move_cursor_up() end },
    { "l", function() require("smart-splits").move_cursor_right() end },

    { "H", cmd("WinShift left") },
    { "J", cmd("WinShift down") },
    { "K", cmd("WinShift up") },
    { "L", cmd("WinShift right") },

    { "<C-h>", function() require("smart-splits").resize_left(5) end },
    { "<C-j>", function() require("smart-splits").resize_down(5) end },
    { "<C-k>", function() require("smart-splits").resize_up(5) end },
    { "<C-l>", function() require("smart-splits").resize_right(5) end },
    { "=", cmd("FocusEqualise"), { desc = "equalize", exit = true } },

    { "s", pcmd("split", "E36") },
    { "<C-s>", pcmd("split", "E36"), { desc = false } },
    { "v", pcmd("vsplit", "E36") },
    { "<C-v>", pcmd("vsplit", "E36"), { desc = false } },

    { "z", cmd("FocusMaximise"), { exit = true, desc = "maximize" } },
    { "<C-z>", cmd("FocusMaximise"), { exit = true, desc = false } },

    { "o", "<C-w>o", { exit = true, desc = "remain only" } },
    { "<C-o>", "<C-w>o", { exit = true, desc = false } },

    {
      "b",
      function() require("cokeline.mappings").pick("focus") end,
      { exit = true, desc = "choose buffer" },
    },

    { "q", pcmd("close", "E444"), { desc = "close window" } },
    { "<C-c>", pcmd("close", "E444"), { desc = false } },
    { "<C-q>", pcmd("close", "E444"), { desc = false } },

    { "<Esc>", nil, { exit = true, desc = false } },
  },
})
