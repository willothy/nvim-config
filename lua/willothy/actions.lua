-- Per-buffer run/build/test actions bound under <localleader>. run/build are
-- dispatched as overseer tasks; test goes through neotest. Each language
-- registers its commands from its after/ftplugin file via M.setup().
local M = {}

-- reveal the overseer task panel, without toggling it shut if already open
local function reveal_panel()
  local ok, tasks = pcall(require, "willothy.tasks")
  if ok and not tasks:get() then
    tasks:toggle()
  end
end

-- start an overseer task for a shell command (string) or argv list
local function run_task(cmd, cwd, name)
  if not cmd or cmd == "" then
    vim.notify("actions: nothing to " .. (name or "run"), vim.log.levels.WARN)
    return
  end
  local task = require("overseer").new_task({
    name = name,
    cmd = cmd,
    cwd = cwd,
  })
  task:start()
  reveal_panel()
end

-- a cwd option may be a string or a function returning one (resolved per press)
local function resolve_cwd(opts)
  local cwd = opts.cwd
  if type(cwd) == "function" then
    local ok, res = pcall(cwd)
    cwd = ok and res or nil
  end
  return cwd
end

-- a function handler runs in-process and may return a command to hand to
-- overseer; a string/list handler is itself an overseer command
local function dispatch(handler, opts, verb)
  if type(handler) == "function" then
    local result = handler()
    if result ~= nil then
      run_task(result, resolve_cwd(opts), verb)
    end
    return
  end
  run_task(handler, resolve_cwd(opts), verb)
end

local VERBS = {
  { name = "run", key = "r", desc = "run" },
  { name = "build", key = "b", desc = "build" },
}

--- A cwd resolver: the nearest ancestor directory containing `marker`, relative
--- to the current buffer (nil if none is found).
--- @param marker string
--- @return fun(): string?
function M.root(marker)
  return function()
    local found = vim.fs.find(marker, {
      upward = true,
      path = vim.fn.expand("%:p:h"),
    })[1]
    return found and vim.fs.dirname(found) or nil
  end
end

--- Bind buffer-local <localleader> action maps. Call from an after/ftplugin file.
--- @param handlers { run?: string|string[]|fun(), build?: string|string[]|fun(), test?: boolean }
--- @param opts? { cwd?: string|fun(): string? }
function M.setup(handlers, opts)
  opts = opts or {}
  local buf = vim.api.nvim_get_current_buf()

  for _, verb in ipairs(VERBS) do
    local handler = handlers[verb.name]
    if handler then
      vim.keymap.set("n", "<localleader>" .. verb.key, function()
        dispatch(handler, opts, verb.name)
      end, { buffer = buf, desc = verb.desc })
    end
  end

  if handlers.test then
    vim.keymap.set("n", "<localleader>t", function()
      require("neotest").run.run()
    end, { buffer = buf, desc = "test nearest" })
    vim.keymap.set("n", "<localleader>T", function()
      require("neotest").run.run(vim.fn.expand("%:p"))
    end, { buffer = buf, desc = "test file" })
  end
end

return M
