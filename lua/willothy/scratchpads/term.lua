local uv = vim.uv

local ffi = require("ffi")

if not _G.defined_openpty then
  ffi.cdef([[
  struct winsize {
    unsigned short ws_row;
    unsigned short ws_col;
    unsigned short ws_xpixel;
    unsigned short ws_ypixel;
  };
  int openpty(int *amaster, int* aslave, char *name, void *termp, const struct winsize *winp);
  int ioctl(int fd, unsigned long request, ...);
]])
end
_G.defined_openpty = true

---@return ffi.cdata*
local function winsize(rows, cols)
  ---@class winsize: ffi.cdata*
  ---@field ws_row integer
  ---@field ws_col integer
  ---@field ws_xpixel integer
  ---@field ws_ypixel integer
  local winp = ffi.new("struct winsize")

  winp.ws_row = rows
  winp.ws_col = cols
  winp.ws_xpixel = 0
  winp.ws_ypixel = 0

  return winp
end

local function openpty(rows, cols)
  local amaster = ffi.new("int[1]")
  local aslave = ffi.new("int[1]")

  local winp = winsize(rows, cols)

  ffi.C.openpty(amaster, aslave, nil, nil, winp)

  return amaster[0], aslave[0]
end

local function spawn(program, args)
  local master, slave = openpty(24, 80)

  local pipe, ename, emsg = vim.loop.new_pipe(false)
  if not pipe then
    error(ename .. ": " .. emsg)
  end
  pipe:open(master)

  local handle = {}

  local child, _, spawn_emsg = uv.spawn(program, {
    args = args or {},
    stdio = { slave, slave, slave },
  }, function()
    handle:kill()
  end)
  if not child then
    error(spawn_emsg)
  end

  ---@type integer | nil
  local win
  ---@type integer | nil
  local buf = vim.api.nvim_create_buf(false, true)

  local TIOCSWINSZ = 0x5414

  function handle:resize()
    if not win or not vim.api.nvim_win_is_valid(win) then
      return
    end
    local winp = winsize(
      vim.api.nvim_win_get_height(win) - 1,
      vim.api.nvim_win_get_width(win) - 2
    )
    ffi.C.ioctl(master, TIOCSWINSZ, winp)
  end

  ---@diagnostic disable-next-line: param-type-mismatch
  local chan = vim.api.nvim_open_term(buf, {
    on_input = function(_, _, _, data)
      if data then
        handle:write(data)
      end
    end,
  })

  local autocmd = vim.api.nvim_create_autocmd(
    { "WinResized", "WinScrolled" },
    {
      callback = function()
        handle:resize()
      end,
    }
  )

  pipe:read_start(vim.schedule_wrap(function(err, data)
    if err then
      error(err)
    end
    if data and buf and vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_chan_send(chan, data)
    end
  end))

  local proxy = newproxy(true)
  getmetatable(proxy).__gc = function()
    handle:kill(true)
  end
  handle._proxy = proxy

  function handle:write(data)
    pipe:write(data)
  end

  function handle:kill(destroy)
    if not child:is_closing() then
      child:close()
    end
    if destroy and not pipe:is_closing() then
      pipe:close()
    end
    vim.schedule(function()
      if destroy then
        vim.api.nvim_del_autocmd(autocmd)
      end
      if win and vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
        win = nil
      end
      if buf and vim.api.nvim_buf_is_valid(buf) then
        vim.fn.chanclose(chan)
        vim.api.nvim_buf_delete(buf, {})
        buf = nil
      end
    end)
  end

  function handle:buf_valid()
    return buf and vim.api.nvim_buf_is_valid(buf)
  end

  function handle:buf()
    return buf
  end

  function handle:is_open()
    return win and vim.api.nvim_win_is_valid(win)
  end

  function handle:resurrect()
    child = uv.spawn(program, {
      args = args or {},
      stdio = { slave, slave, slave },
    }, function()
      handle:kill()
    end)
    if not self:buf_valid() then
      buf = vim.api.nvim_create_buf(false, true)
      chan = vim.api.nvim_open_term(buf, {
        on_input = function(_, _, _, data)
          if data and self:buf_valid() then
            self:write(data)
          end
        end,
      })
    end
  end

  function handle:open(enter)
    if not self:is_open() then
      if self:buf_valid() then
        self:resurrect()
      end
      vim.bo[buf].filetype = "terminal"
      win = vim.api.nvim_open_win(buf --[[@as integer]], enter or false, {
        split = "below",
        win = -1,
      })
      self:resize()
    end
  end

  function handle:close()
    if self:is_open() then
      vim.api.nvim_win_close(win --[[@as integer]], true)
    end
  end

  function handle:toggle(enter)
    if self:is_open() then
      self:close()
    else
      self:open(enter)
    end
  end

  return handle
end

return {
  spawn = spawn,
}
