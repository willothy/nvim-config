local uv = vim.uv

local ffi = require("ffi")

if not _G.__defined_openpty then
  ffi.cdef([[
    typedef int pid_t;
    struct winsize {
      unsigned short ws_row;
      unsigned short ws_col;
      unsigned short ws_xpixel;
      unsigned short ws_ypixel;
    };
    int openpty(int *amaster, int* aslave, char *name, void *termp, const struct winsize *winp);
    int ioctl(int fd, unsigned long request, ...);
    pid_t setsid(void);
    int setpgid(pid_t pid, pid_t pgid);
    int getpid(void);
  ]])
end
_G.__defined_openpty = true

---@return ffi.cdata*
local function winsize(rows, cols)
  ---@class winsize: ffi.cdata*
  ---@field ws_row integer
  ---@field ws_col integer
  local winp = ffi.new("struct winsize")

  winp.ws_row = rows
  winp.ws_col = cols

  return winp
end

local function openpty(rows, cols)
  local amaster = ffi.new("int[1]")
  local aslave = ffi.new("int[1]")

  local winp = winsize(rows, cols)

  ffi.C.openpty(amaster, aslave, nil, nil, winp)

  return amaster[0], aslave[0]
end

local function get_shell()
  local shell = vim.env.SHELL
  if not shell or shell == "" then
    shell = vim.o.shell
    if not shell or shell == "" then
      shell = "/bin/bash"
    end
  end
  return shell
end

local id = 0
local function next_id()
  id = id + 1
  return id
end

local terminals = setmetatable({}, {
  __mode = "v",
})

---@class Willothy.Terminal: Willothy.Terminal.Options
---@field _proxy userdata
---@field _pty { master: integer, slave: integer }
---@field _pipe uv_pipe_t
---@field _child uv_process_t
---@field _autocmd integer
---@field _channel integer
---@field _buf integer
---@field _win integer
---@field _id integer
local Terminal = {}
Terminal.cmd = get_shell()

---@class Willothy.Terminal.Options
---@field cmd string
---@field args string[]

---@param opts Willothy.Terminal.Options | nil
function Terminal:new(opts)
  opts = opts or {}

  self.__index = self
  local term = setmetatable(opts, self)

  term._id = next_id()

  local proxy = newproxy(true)
  -- ensure that the terminal is closed when the proxy is collected
  getmetatable(proxy).__gc = function()
    term:_cleanup()
  end

  term._proxy = proxy

  terminals[term._id] = term

  return term
end

function Terminal.terminals()
  return terminals
end

---@param e any
function Terminal:_error(e)
  self:_cleanup()
  if type(e) ~= "string" then
    e = vim.inspect(e)
  end
  error(e)
end

function Terminal:_resize()
  if not self._pty or not self:is_open() then
    return
  end
  local TIOCSWINSZ = 0x5414
  local winp = winsize(
    vim.api.nvim_win_get_height(self._win) - 1,
    vim.api.nvim_win_get_width(self._win) - 2
  )
  ffi.C.ioctl(self._pty.master, TIOCSWINSZ, winp)
end

function Terminal:_write(data)
  if self._pipe and not self._pipe:is_closing() then
    self._pipe:write(data)
  end
end

function Terminal:_cleanup()
  -- cleanup child process
  if self._child and not self._child:is_closing() then
    self._child:kill("sigterm")
    self._child:close()
  end
  self._child = nil

  -- cleanup pipe
  if self._pipe and not self._pipe:is_closing() then
    self._pipe:read_stop()
    self._pipe:shutdown()
  end
  self._pipe = nil

  -- "drop" the fd's so we don't accidentally reuse them
  self._pty = nil

  -- cleanup vim things that require vim.schedule
  vim.schedule(function()
    if self._autocmd then
      vim.api.nvim_del_autocmd(self._autocmd)
      self._autocmd = nil
    end
    if self:is_open() then
      vim.api.nvim_win_close(self._win, true)
      self._win = nil
    end
    if self._channel then
      vim.fn.chanclose(self._channel)
      self._channel = nil
    end
    if self._buf and vim.api.nvim_buf_is_valid(self._buf) then
      vim.api.nvim_buf_delete(self._buf, {})
      self._buf = nil
    end
  end)
end

---@param rows integer | nil
---@param cols integer | nil
function Terminal:spawn(rows, cols)
  local master, slave = openpty(rows or 24, cols or 80)

  local pipe, ename, emsg = vim.loop.new_pipe(false)
  if not pipe then
    return self:_error(ename .. ": " .. emsg)
  end
  pipe:open(master)

  local child, _, spawn_emsg = uv.spawn(self.cmd, {
    args = self.args,
    stdio = { slave, slave, slave },
    detached = true,
  }, function()
    self:_cleanup()
  end)
  if not child then
    return self:_error(spawn_emsg)
  end

  ffi.C.setpgid(ffi.C.getpid(), ffi.C.getpid())
  --
  -- ffi.C.setsid()

  local TIOCSCTTY = 0x540E

  -- set controlling terminal for child process,
  -- and make it not the same as vim so that
  -- vim isn't killed when the terminal is killed
  ffi.C.ioctl(master, TIOCSCTTY, 0)

  local buf = vim.api.nvim_create_buf(false, true)
  local chan = vim.api.nvim_open_term(buf, {
    on_input = function(_, _, _, data)
      if data then
        self:_write(data)
      end
    end,
  })
  pipe:read_start(vim.schedule_wrap(function(_err, data)
    if self._channel and data then
      vim.api.nvim_chan_send(self._channel, data)
    end
  end))

  vim.bo[buf].filetype = "terminal"
  vim.api.nvim_buf_set_name(buf, "terminal-" .. self._id)

  vim.api.nvim_create_autocmd({ "BufDelete", "BufUnload", "BufWipeout" }, {
    once = true,
    buffer = buf,
    callback = function()
      self:_cleanup()
    end,
  })

  self._autocmd = vim.api.nvim_create_autocmd(
    { "WinResized", "WinScrolled" },
    {
      callback = vim.schedule_wrap(function()
        self:_resize()
      end),
      desc = "resize terminal automatically",
    }
  )
  self._buf = buf
  self._channel = chan
  self._pipe = pipe
  self._pty = {
    master = master,
    slave = slave,
  }
  self._child = child
end

---@param text string
function Terminal:send(text)
  if not vim.endswith(text, "\r\n") and not vim.endswith(text, "\r") then
    text = text .. "\r\n"
  end
  self:_write(text)
end

---@return boolean
function Terminal:is_alive()
  return self._buf
    and vim.api.nvim_buf_is_valid(self._buf)
    and self._child
    and not self._child:is_closing()
end

function Terminal:open()
  if self:is_open() then
    return
  end
  if not self:is_alive() then
    self:spawn()
  end
  self._win = vim.api.nvim_open_win(self._buf, true, {
    split = "below",
    win = -1,
  })
end

---@param win integer
---@param enter boolean | nil
function Terminal:open_in(win, enter)
  if win == 0 then
    win = vim.api.nvim_get_current_win()
  end
  if not self:is_alive() or not vim.api.nvim_win_is_valid(win) then
    return
  end
  if self:is_open() then
    self:close()
  end
  vim.api.nvim_win_set_buf(win, self._buf)
  if enter then
    vim.api.nvim_set_current_win(win)
  end
  self._win = win
end

function Terminal:close()
  if not self:is_open() then
    return
  end
  vim.api.nvim_win_close(self._win, true)
  self._win = nil
end

function Terminal:toggle()
  if self:is_open() then
    self:close()
  else
    self:open()
  end
end

---@return boolean
function Terminal:is_open()
  return self._win and vim.api.nvim_win_is_valid(self._win)
end

return Terminal
