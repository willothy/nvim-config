---@alias macros.State "idle" | "recording" | "playing" | "selecting"

---@type table<string, macros.State>
local State = {
  Idle = "idle",
  Recording = "recording",
  Playing = "playing",
  Selecting = "selecting",
}

---@type macros.State
local state = State.Idle

---@type snacks.win | nil
local win

---@type { title: string, sequence: string } | nil
local selected

local M = {}

function M.insert_macro(title, sequence)
  require("durable").kv.set(title, sequence, "macros")
  M.update_menu()
end

function M.delete_macro(title)
  require("durable").kv.delete(title, "macros")
  if selected and selected.title == title then
    selected = nil
  end
  M.update_menu()
end

function M.list_macros()
  return vim
    .iter(require("durable").kv.list("macros"))
    :map(function(entry)
      return {
        title = entry.key,
        sequence = entry.value,
      }
    end)
    :totable()
end

---@return string | nil
function M.get_macro(title)
  return require("durable").kv.get(title, "macros") --[[@as string|nil]]
end

function M.start_recording()
  if state ~= State.Idle then
    return
  end

  assert(vim.fn.reg_recording() == "", "Expected no recording in progress")

  state = State.Recording

  vim.fn.setreg("q", "")
  vim.cmd("silent! normal! qq")

  vim.api.nvim_exec_autocmds("User", {
    pattern = "MacroStateChanged",
    data = { state = state },
  })
end

function M.stop_recording()
  if state ~= State.Recording then
    return
  end

  assert(vim.fn.reg_recording() == "q", "Expected recording in progress")

  vim.cmd("silent! normal! q")

  local macro_str = vim.fn.getreg("q")

  selected = {
    sequence = macro_str:sub(1, -2),
  }

  state = State.Idle

  vim.api.nvim_exec_autocmds("User", {
    pattern = "MacroStateChanged",
    data = { state = state },
  })
end

function M.save_selected()
  if state ~= State.Idle and state ~= State.Selecting then
    vim.notify(
      string.format("Cannot save while %s", state),
      vim.log.levels.WARN,
      {
        id = string.format("no-save-while-%s", state),
      }
    )
    return
  end
  if selected == nil then
    vim.notify("No macro selected", vim.log.levels.WARN, {
      id = "no-macro-selected",
    })
    return
  end
  if selected.sequence == nil then
    vim.notify("No macro sequence found", vim.log.levels.WARN, {
      id = "no-macro-sequence",
    })
    return
  elseif selected.sequence == "" then
    vim.notify("Empty macro sequence", vim.log.levels.WARN, {
      id = "no-macro-sequence",
    })
    return
  end

  vim.ui.input(
    ---@diagnostic disable-next-line: missing-fields
    {
      title = "Macro name",
      message = "Enter a name for the macro",
    },
    vim.schedule_wrap(function(input)
      if input == "" or input == nil then
        vim.notify("Macro name cannot be empty.", vim.log.levels.WARN, {
          id = "empty-macro-name",
        })
        return
      end
      if selected == nil or selected.sequence == nil then
        vim.notify("No macro selected.", vim.log.levels.WARN, {
          id = "no-macro-selected",
        })
        return
      end
      M.insert_macro(input, selected.sequence)
    end)
  )
end

function M.select_macro(title)
  if state ~= State.Idle and state ~= State.Selecting then
    return
  end

  local macro = M.get_macro(title)

  if macro then
    selected = { title = title }
  else
    vim.notify(
      string.format("Macro '%s' not found", title),
      vim.log.levels.WARN,
      {
        id = string.format("macro-not-found-%s", title),
      }
    )
  end
end

function M.statusline()
  if state == State.Recording then
    return "%#MacroRecording#%* REC"
  elseif state == State.Playing then
    return "%#MacroPlaying#%* PLAY"
  end
  return ""
end

---@param snacks_win snacks.win
local function get_cursor_selected(snacks_win)
  if not snacks_win:win_valid() then
    return
  end
  local cursor = vim.api.nvim_win_get_cursor(snacks_win.win)

  local list = M.list_macros()

  local res = list[cursor[1]]

  if not res then
    vim.notify(
      "invalid selection - this is probably a bug",
      vim.log.levels.ERROR,
      {
        id = "invalid-selection",
      }
    )
  end
  return res
end

function M.open_menu()
  if state ~= State.Idle then
    return
  end

  win = require("snacks.win").new({
    position = "float",
    border = "solid",
    title = " Macros ",
    title_pos = "center",
    footer = selected and (selected.sequence or selected.title) or "",
    footer_pos = "center",
    backdrop = 100,
    height = 0.15,
    width = 0.4,
    zindex = 50,
    enter = true,
    fixbuf = true,
    text = function()
      return vim
        .iter(M.list_macros())
        :map(function(row)
          return row.title
        end)
        :totable()
    end,
    bo = {
      readonly = true,
      modifiable = false,
      buftype = "nofile",
      filetype = "macros",
    },
    keys = {
      ["<CR>"] = "select",
      d = "delete",
    },
    actions = {
      select = function(self)
        local cursor_selected = get_cursor_selected(self)

        if cursor_selected then
          M.select_macro(cursor_selected.title)
          M.close_menu()
        end
      end,
      delete = function(self)
        local cursor_selected = get_cursor_selected(self)

        if cursor_selected then
          M.delete_macro(cursor_selected.title)
        end
      end,
    },
    on_buf = function(self)
      vim.api.nvim_create_autocmd("WinClosed", {
        once = true,
        buffer = self.buf,
        callback = vim.schedule_wrap(function()
          M.close_menu()
        end),
      })
    end,
  })

  state = State.Selecting
end

function M.update_menu()
  vim.schedule(function()
    if not win then
      return
    end
    if not win:buf_valid() then
      return
    end

    local lines = vim
      .iter(M.list_macros())
      :map(function(row)
        return row.title
      end)
      :totable()

    vim.bo[win.buf].modifiable = true
    vim.bo[win.buf].readonly = false
    vim.api.nvim_buf_set_lines(win.buf, 0, -1, true, lines)
    vim.bo[win.buf].modifiable = false
    vim.bo[win.buf].readonly = true

    win.opts.footer = selected and (selected.title or selected.sequence) or ""
    win:update()
  end)
end

function M.close_menu()
  if state ~= State.Selecting then
    return
  end

  if not win then
    return
  end
  if win:win_valid() then
    win:close({})
  end
  win = nil

  state = State.Idle
end

function M.toggle_menu()
  if state == State.Selecting then
    M.close_menu()
  elseif state == State.Idle then
    M.open_menu()
  end
end

function M.toggle_recording()
  if state == State.Recording then
    M.stop_recording()
  elseif state == State.Idle then
    M.start_recording()
  end
end

function M.play_selected()
  local sequence
  if selected then
    if selected.sequence then
      sequence = selected.sequence
    elseif selected.title then
      sequence = M.get_macro(selected.title)
    end
  end
  if sequence == nil or sequence == "" then
    vim.notify("No macro selected", vim.log.levels.WARN, {
      id = "no-macro-selected",
    })
    return
  end

  local mode = vim.api.nvim_get_mode()

  state = State.Playing

  vim.api.nvim_exec_autocmds("User", {
    pattern = "MacroStateChanged",
    data = { state = state },
  })

  vim.api.nvim_feedkeys(sequence, mode.mode, false)

  vim.schedule(function()
    if state == State.Playing then
      state = State.Idle
    end
    vim.api.nvim_exec_autocmds("User", {
      pattern = "MacroStateChanged",
      data = { state = state },
    })
  end)
end

local did_setup = false
function M.setup()
  if did_setup then
    return
  end

  vim.api.nvim_set_hl(0, "MacroRecording", {
    fg = "#ff0000",
  })
  vim.api.nvim_set_hl(0, "MacroPlaying", {
    fg = "#00ff00",
  })
end

return M
