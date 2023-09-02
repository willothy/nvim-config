local M = {}

local _id = 0
local function next_id()
  local id = _id
  _id = _id + 1
  return id
end

--- Autocmd events
M.autocmd = {
  --- after adding a buffer to the buffer list
  BufAdd = "BufAdd",
  --- deleting a buffer from the buffer list
  BufDelete = "BufDelete",
  --- after entering a buffer
  BufEnter = "BufEnter",
  --- after renaming a buffer
  BufFilePost = "BufFilePost",
  --- before renaming a buffer
  BufFilePre = "BufFilePre",
  --- just after buffer becomes hidden
  BufHidden = "BufHidden",
  --- before leaving a buffer
  BufLeave = "BufLeave",
  --- after the 'modified' state of a buffer changes
  BufModifiedSet = "BufModifiedSet",
  --- after creating any buffer
  BufNew = "BufNew",
  --- when creating a buffer for a new file
  BufNewFile = "BufNewFile",
  --- read buffer using command
  BufReadCmd = "BufReadCmd",
  --- after reading a buffer
  BufReadPost = "BufReadPost",
  --- before reading a buffer
  BufReadPre = "BufReadPre",
  --- just before unloading a buffer
  BufUnload = "BufUnload",
  --- after showing a buffer in a window
  BufWinEnter = "BufWinEnter",
  --- just after buffer removed from window
  BufWinLeave = "BufWinLeave",
  --- just before really deleting a buffer
  BufWipeout = "BufWipeout",
  --- write buffer using command
  BufWriteCmd = "BufWriteCmd",
  --- after writing a buffer
  BufWritePost = "BufWritePost",
  --- before writing a buffer
  BufWritePre = "BufWritePre",
  --- info was received about channel
  ChanInfo = "ChanInfo",
  --- channel was opened
  ChanOpen = "ChanOpen",
  --- command undefined
  CmdUndefined = "CmdUndefined",
  --- command line was modified
  CmdlineChanged = "CmdlineChanged",
  --- after entering cmdline mode
  CmdlineEnter = "CmdlineEnter",
  --- before leaving cmdline mode
  CmdlineLeave = "CmdlineLeave",
  --- after entering the cmdline window
  CmdWinEnter = "CmdwinEnter",
  --- before leaving the cmdline window
  CmdWinLeave = "CmdwinLeave",
  --- after loading a colorscheme
  ColorScheme = "ColorScheme",
  --- before loading a colorscheme
  ColorSchemePre = "ColorSchemePre",
  --- after popup menu changed
  CompleteChanged = "CompleteChanged",
  --- after finishing insert complete
  CompleteDone = "CompleteDone",
  --- idem, before clearing info
  CompleteDonePre = "CompleteDonePre",
  --- cursor in same position for a while
  CursorHold = "CursorHold",
  --- idem, in Insert mode
  CursorHoldI = "CursorHoldI",
  --- cursor was moved
  CursorMoved = "CursorMoved",
  --- cursor was moved in Insert mode
  CursorMovedI = "CursorMovedI",
  --- diffs have been updated
  DiffUpdated = "DiffUpdated",
  --- directory changed
  DirChanged = "DirChanged",
  --- after changing the 'encoding' option
  EncodingChanged = "EncodingChanged",
  --- before exiting
  ExitPre = "ExitPre",
  --- append to a file using command
  FileAppendCmd = "FileAppendCmd",
  --- after appending to a file
  FileAppendPost = "FileAppendPost",
  --- before appending to a file
  FileAppendPre = "FileAppendPre",
  --- before first change to read-only file
  FileChangedRO = "FileChangedRO",
  --- after shell command that changed file
  FileChangedShell = "FileChangedShell",
  --- after (not) reloading changed file
  FileChangedShellPost = "FileChangedShellPost",
  --- read from a file using command
  FileReadCmd = "FileReadCmd",
  --- after reading a file
  FileReadPost = "FileReadPost",
  --- before reading a file
  FileReadPre = "FileReadPre",
  --- new file type detected (user defined)
  FileType = "FileType",
  --- write to a file using command
  FileWriteCmd = "FileWriteCmd",
  --- after writing a file
  FileWritePost = "FileWritePost",
  --- before writing a file
  FileWritePre = "FileWritePre",
  --- after reading from a filter
  FilterReadPost = "FilterReadPost",
  --- before reading from a filter
  FilterReadPre = "FilterReadPre",
  --- after writing to a filter
  FilterWritePost = "FilterWritePost",
  --- before writing to a filter
  FilterWritePre = "FilterWritePre",
  --- got the focus
  FocusGained = "FocusGained",
  --- lost the focus to another app
  FocusLost = "FocusLost",
  --- if calling a function which doesn't exist
  FuncUndefined = "FuncUndefined",
  --- after starting the GUI
  GUIEnter = "GUIEnter",
  --- after starting the GUI failed
  GUIFailed = "GUIFailed",
  --- when changing Insert/Replace mode
  InsertChange = "InsertChange",
  --- before inserting a char
  InsertCharPre = "InsertCharPre",
  --- when entering Insert mode
  InsertEnter = "InsertEnter",
  --- just after leaving Insert mode
  InsertLeave = "InsertLeave",
  --- just before leaving Insert mode
  InsertLeavePre = "InsertLeavePre",
  --- just before popup menu is displayed
  MenuPopup = "MenuPopup",
  --- after changing the mode
  ModeChanged = "ModeChanged",
  --- after setting any option
  OptionSet = "OptionSet",
  --- after :make, :grep etc.
  QuickFixCmdPost = "QuickFixCmdPost",
  --- before :make, :grep etc.
  QuickFixCmdPre = "QuickFixCmdPre",
  --- before :quit
  QuitPre = "QuitPre",
  --- upon string reception from a remote vim
  RemoteReply = "RemoteReply",
  --- when the search wraps around the document
  SearchWrapped = "SearchWrapped",
  --- after loading a session file
  SessionLoadPost = "SessionLoadPost",
  --- after ":!cmd"
  ShellCmdPost = "ShellCmdPost",
  --- after ":1,2!cmd", ":w !cmd", ":r !cmd".
  ShellFilterPost = "ShellFilterPost",
  --- after nvim process received a signal
  Signal = "Signal",
  --- sourcing a Vim script using command
  SourceCmd = "SourceCmd",
  --- after sourcing a Vim script
  SourcePost = "SourcePost",
  --- before sourcing a Vim script
  SourcePre = "SourcePre",
  --- spell file missing
  SpellFileMissing = "SpellFileMissing",
  --- after reading from stdin
  StdinReadPost = "StdinReadPost",
  --- before reading from stdin
  StdinReadPre = "StdinReadPre",
  --- found existing swap file
  SwapExists = "SwapExists",
  --- syntax selected
  Syntax = "Syntax",
  --- a tab has closed
  TabClosed = "TabClosed",
  --- after entering a tab page
  TabEnter = "TabEnter",
  --- before leaving a tab page
  TabLeave = "TabLeave",
  --- when creating a new tab
  TabNew = "TabNew",
  --- after entering a new tab
  TabNewEntered = "TabNewEntered",
  --- after changing 'term'
  TermChanged = "TermChanged",
  --- after the process exits
  TermClose = "TermClose",
  --- after entering Terminal mode
  TermEnter = "TermEnter",
  --- after leaving Terminal mode
  TermLeave = "TermLeave",
  --- after opening a terminal buffer
  TermOpen = "TermOpen",
  --- after setting "v:termresponse"
  TermResponse = "TermResponse",
  --- text was modified
  TextChanged = "TextChanged",
  --- text was modified in Insert mode(no popup)
  TextChangedI = "TextChangedI",
  --- text was modified in Insert mode(popup)
  TextChangedP = "TextChangedP",
  --- after a yank or delete was done (y, d, c)
  TextYankPost = "TextYankPost",
  --- after UI attaches
  UIEnter = "UIEnter",
  --- after UI detaches
  UILeave = "UILeave",
  --- user defined autocommand
  User = "User",
  --- whenthe user presses the same key 42 times
  UserGettingBored = "UserGettingBored",
  --- after starting Vim
  VimEnter = "VimEnter",
  --- before exiting Vim
  VimLeave = "VimLeave",
  --- before exiting Vim and writing ShaDa file
  VimLeavePre = "VimLeavePre",
  --- after Vim window was resized
  VimResized = "VimResized",
  --- after Nvim is resumed
  VimResume = "VimResume",
  --- before Nvim is suspended
  VimSuspend = "VimSuspend",
  --- after closing a window
  WinClosed = "WinClosed",
  --- after entering a window
  WinEnter = "WinEnter",
  --- before leaving a window
  WinLeave = "WinLeave",
  --- when entering a new window
  WinNew = "WinNew",
  --- after scrolling a window
  WinScrolled = "WinScrolled",
}

---@class EventOpts
---@field group string|number?
---@field pattern string|string[]?
---@field buffer buffer?
---@field desc string?
---@field once boolean?
---@field nested boolean?

---@param event string | string[]
---@param callback fun(args: table)
---@param opts EventOpts?
---@return integer augroup
function M.on(event, callback, opts)
  opts = opts or {}
  if type(event) == "string" then
    event = { event }
  end

  local usercmds = {}
  local autocmds = vim
    .iter(event)
    :map(function(evt)
      if M.autocmd[evt] then
        return evt
      else
        table.insert(usercmds, event)
      end
    end)
    :totable()

  opts.callback = callback
  opts.group = opts.group
    or vim.api.nvim_create_augroup(tostring(next_id()), { clear = true })

  vim.iter(usercmds):each(function(evt)
    vim.api.nvim_create_autocmd(
      "User",
      vim.tbl_deep_extend("keep", {
        pattern = evt,
        callback = callback,
        group = opts.group,
      }, opts)
    )
  end)

  if #autocmds > 0 then
    vim.api.nvim_create_autocmd(autocmds, opts)
  end

  ---@diagnostic disable-next-line: return-type-mismatch
  return opts.group
end

---@class EmitOpts
---@field pattern string|string[]?
---@field data any?
---@field buffer buffer?
---@field modeline boolean?
---@field group string|number?

---@param event string
---@param opts EmitOpts?
function M.emit(event, opts)
  opts = opts or {}
  local pattern = opts.pattern

  if not M.autocmd[event] then
    pattern = event
    event = "User"
  end
  opts.pattern = pattern
  vim.api.nvim_exec_autocmds(event, opts)
end

return M
