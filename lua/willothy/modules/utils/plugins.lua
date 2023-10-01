local M = {}

function M.iter()
  return vim.iter(require("lazy").plugins())
end

function M.is_mine(p)
  return vim.startswith(p[1] or "", "willothy")
end

function M.is_fork(p)
  local my_plugins = {
    ["minimus"] = true,
    ["flatten.nvim"] = true,
    ["wezterm.nvim"] = true,
    ["hollywood.nvim"] = true,
    ["futures.nvim"] = true,
    ["savior.nvim"] = true,
    ["nvim-cokeline"] = true,
    ["moveline.nvim"] = true,
    ["veil.nvim"] = true,
    ["wrangler.nvim"] = true,
    ["micro-async.nvim"] = true,
    ["leptos.nvim"] = true,
  }
  return not my_plugins[p.name]
end

function M.is_local(p)
  ---@diagnostic disable: param-type-mismatch
  return not vim.startswith(p.dir, vim.fn.stdpath("data"))
end

function M.get_name(p)
  return p.name
end

function M.has_url(p)
  return p.url ~= nil
end

function M.any(...)
  local args = { ... }
  return function(p)
    for _, f in ipairs(args) do
      if f(p) then
        return true
      end
    end
    return false
  end
end

function M.all(...)
  local args = { ... }
  return function(p)
    for _, f in ipairs(args) do
      if not f(p) then
        return false
      end
    end
    return true
  end
end

function M.not_(f)
  return function(p)
    return not f(p)
  end
end

function M.list()
  local plugins = M.iter():map(M.get_name):fold("\n", function(acc, name)
    return acc .. name .. "\n"
  end)

  willothy.fn.popup(plugins, "installed plugins")
end

function M.list_local()
  local local_plugins = M.iter()
    :filter(M.is_local)
    :filter(M.has_url)
    :map(M.get_name)
    :fold("\n", function(acc, p)
      return acc .. p .. "\n"
    end)

  willothy.fn.popup(local_plugins, "local plugins")
end

function M.list_mine()
  local my_plugins = M.iter()
    :filter(M.is_mine)
    :filter(M.has_url)
    :filter(M.not_(M.is_fork))
    :map(M.get_name)
    :fold("\n", function(acc, p)
      return acc .. p .. "\n"
    end)

  willothy.fn.popup(my_plugins, "plugins by @willothy")
end

function M.list_forks()
  local forks = M.iter()
    :filter(M.any(M.is_mine, M.is_local))
    :filter(M.has_url)
    :filter(M.is_fork)
    :map(M.get_name)
    :fold("\n", function(acc, p)
      return acc .. p .. "\n"
    end)

  willothy.fn.popup(forks, "installed plugin forks")
end

function M.star_repo(owner, repo)
  vim.system({
    "gh",
    "api",
    "-X",
    "PUT",
    "/user/starred/" .. owner .. "/" .. repo,
  }, {}, function(obj)
    local code, err = obj.code, obj.stderr
    if code == 0 then
      vim.notify("Starred " .. owner .. "/" .. repo)
    else
      vim.notify(
        "Failed to star  " .. owner .. "/" .. repo .. ": " .. err,
        "error"
      )
    end
  end)
end

function M.unstar_repo(owner, repo)
  vim.system({
    "gh",
    "api",
    "-X",
    "DELETE",
    "/user/starred/" .. owner .. "/" .. repo,
  }, {}, function(obj)
    local code, _out, err = obj.code, obj.stdout, obj.stderr
    if code == 0 then
      vim.notify("Unstarred " .. owner .. "/" .. repo)
    else
      vim.notify(
        "Failed to unstar  " .. owner .. "/" .. repo .. ": " .. err,
        "error"
      )
    end
  end)
end

---@param user string?
function M.count_stars(user)
  user = user or vim.env.USER
  local width = math.max(12, #user + 2)
  local buf, win = vim.lsp.util.open_floating_preview({ "" }, "", {
    focus = true,
    focusable = true,
    wrap = true,
    width = width,
    height = 1,
    border = "solid",
    title = { { user, "NormalFloat" } },
    title_pos = "center",
  })
  vim.wo[win].winhl = "FloatBorder:NormalFloat"
  local rx = require("leptos")
  local total = rx.create_signal(0)
  local err = rx.create_signal()
  local Text = require("nui.text")
  local Line = require("nui.line")
  -- local rx = willothy.rx
  local handle
  rx.create_effect(function()
    local val = total.get()
    local star
    if err.get() then
      val = Text(err.get())
      star = Text("", "DiagnosticError")
      if handle then
        handle:kill(15) -- SIGTERM
      end
    else
      val = Text(tostring(val))
      star = Text("", "DiagnosticWarn")
    end
    if (val:length() + 2) > width then
      width = val:length() + 2
      willothy.utils.window.update_config(win, function(conf)
        conf.width = width
      end)
    end
    local lpad =
      Text(string.rep(" ", math.floor((width - val:length()) / 2) - 1))
    local line = Line({ lpad, star, Text(" "), val })
    if vim.api.nvim_buf_is_valid(buf) then
      vim.bo[buf].modifiable = true
      line:render(buf, -1, 1)
      vim.bo[buf].modifiable = false
    end
  end)
  local buffer = ""
  handle = vim.system({
    "gh",
    "api",
    "-X",
    "GET",
    "/users/" .. user .. "/repos",
    "--paginate",
    "-F",
    "per_page=10",
    "--jq",
    ".[].stargazers_count",
  }, {
    text = true,
    stdout = vim.schedule_wrap(function(e, data)
      if e then
        err.set(e)
        return
      end
      if not data then
        return
      end
      buffer = buffer .. data
      local num = vim
        .iter(vim.split(data, "\n"))
        :map(tonumber)
        :fold(0, function(acc, num)
          return acc + num
        end)
      total.update(function(t)
        return (t or 0) + num
      end)
    end),
  }, function(obj)
    if obj.code ~= 0 or #obj.stderr ~= 0 then
      local output = vim.json.decode(buffer)
      err.set(output.message)
    end
  end)
end

---View and/or bulk unstar github repos using a floating window and the gh cli
function M.starred_repos()
  local Text = require("nui.text")
  local Line = require("nui.line")
  local rx = require("leptos")

  local repos = rx.create_signal({})
  local err = rx.create_signal()
  local handle

  local buf, win = vim.lsp.util.open_floating_preview({}, "", {
    focus = true,
    focusable = true,
    border = "solid",
    wrap = true,
    width = 35,
    height = 15,
  })
  vim.wo[win].scrolloff = 0
  vim.api.nvim_set_current_win(win)
  vim.api.nvim_create_autocmd({ "BufLeave", "WinClosed" }, {
    buffer = buf,
    once = true,
    callback = function()
      err.set(true)
    end,
  })
  vim.keymap.set("n", "<Tab>", function()
    local cursor = vim.api.nvim_win_get_cursor(win)
    repos.update(function(list)
      if list[cursor[1]] then
        list[cursor[1]].unstar = not list[cursor[1]].unstar
        list[cursor[1]].text = Text(
          list[cursor[1]].name,
          list[cursor[1]].unstar and "Comment" or "NormalFloat"
        )
      end
    end)
  end, { buffer = buf })
  vim.keymap.set("n", "<CR>", function()
    repos.update(function(list)
      vim
        .iter(list)
        :enumerate()
        :rev()
        :filter(function(_, repo)
          return repo.unstar
        end)
        :each(function(line, repo)
          M.unstar_repo(repo.owner, repo.name)
          table.remove(list, line)
        end)
    end)
  end, { buffer = buf })

  -- error effect
  rx.create_effect(function()
    local e = err.get()
    if e then
      if type(e) == "string" then
        vim.notify(e, "error")
      end
      handle:kill(15) -- SIGTERM
      return
    end
  end)

  -- render effect
  rx.create_effect(function()
    local list = repos.get()

    vim.bo[buf].modifiable = true
    vim.iter(list):enumerate():each(function(i, repo)
      local line = Line({ repo.text })
      line:render(buf, -1, i)
    end)
    vim.bo[buf].modifiable = false

    local config = vim.api.nvim_win_get_config(win)

    config.title = {
      { "Starred", "FloatTitle" },
      { " (" .. tostring(#list) .. ")", "NormalFloat" },
    }
    config.title_pos = "center"

    vim.api.nvim_win_set_config(win, config)
  end)

  handle = vim.system({
    "gh",
    "api",
    "-X",
    "GET",
    "/user/starred",
    "-F",
    "per_page=15",
    "--paginate",
    "--jq",
    '.[] | { name, "owner": .owner.login } | tostring',
  }, {
    text = true,
    stdout = vim.schedule_wrap(function(e, data)
      if e then
        err.set(e)
        return
      end
      data = vim.split(data or "", "\n")
      repos.update(function(list)
        vim.iter(data):each(function(repo)
          repo = vim.json.decode(repo)
          repo.text = Text(repo.name, "NormalFloat")
          table.insert(list, repo)
        end)
      end)
    end),
  })
end

return M
