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
  rx.create_effect(function()
    if vim.api.nvim_buf_is_valid(buf) then
      local val = total.get()
      local star
      if err.get() then
        val = Text(err.get())
        star = Text("", "DiagnosticError")
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
      vim.bo[buf].modifiable = true
      line:render(buf, -1, 1)
      vim.bo[buf].modifiable = false
    end
  end)
  local buffer = ""
  vim.system({
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
      data = data:gsub("%s+", "\n")
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
---@param count integer?
function M.starred_repos(count)
  local buffer = ""
  vim.system(
    {
      "gh",
      "api",
      "-X",
      "GET",
      "/user/starred",
      "-F",
      "per_page=" .. (count or 1000),
      "--paginate",
    },
    {
      text = true,
    },
    vim.schedule_wrap(function(obj)
      local code, out, err = obj.code, obj.stdout, obj.stderr
      if code ~= 0 then
        vim.notify(err, "error")
        return
      end
      local repos = vim.json.decode(out, {}) or {}
      local function max_length(list)
        local max = 0
        for _, v in ipairs(list) do
          if #v > max then
            max = #v
          end
        end
        return max
      end
      local text = vim
        .iter(repos)
        :map(function(repo)
          return repo.name
        end)
        :totable()
      local buf, win = vim.lsp.util.open_floating_preview(text, "", {
        focus = true,
        focusable = true,
        border = "solid",
        wrap = true,
        width = math.min(
          60,
          vim.o.columns - 10,
          math.max(max_length(text), 10)
        ),
      })
      local to_unstar = {}
      vim.api.nvim_set_current_win(win)
      vim.keymap.set("n", "q", function()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end, { buffer = buf })
      local ns = vim.api.nvim_create_namespace("willothy.unstar_repos")
      local function set_line(line, starred)
        if not repos[line] then
          return
        end
        if starred then
          if to_unstar[line] then
            to_unstar[line] = nil
          end
        elseif not to_unstar[line] then
          to_unstar[line] = repos[line]
        end
      end
      local function toggle_line(line)
        if to_unstar[line] then
          set_line(line, true)
        else
          set_line(line, false)
        end
      end
      local function render()
        vim.schedule(function()
          vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
          for line, _ in pairs(to_unstar) do
            vim.api.nvim_buf_add_highlight(buf, ns, "Comment", line - 1, 0, -1)
          end
        end)
      end
      vim.keymap.set("n", "<CR>", function()
        local list = vim
          .iter(pairs(to_unstar))
          :map(function(line, repo)
            M.unstar_repo(repo.owner.login, repo.name)
            return line
          end)
          :totable()
        table.sort(list)
        to_unstar = {}
        vim.bo[buf].modifiable = true
        vim.iter(list):rev():each(function(line)
          table.remove(repos, line)
          vim.api.nvim_buf_set_lines(buf, line - 1, line, false, {})
        end)
        vim.bo[buf].modifiable = false
        -- vim.api.nvim_win_close(win, true)
      end, { buffer = buf, desc = "unstar selected" })
      vim.keymap.set("n", "dd", function()
        local line = vim.api.nvim_win_get_cursor(win)[1]
        toggle_line(line)
        render()
      end, { buffer = buf, desc = "toggle starred" })
      vim.keymap.set({ "x", "v" }, "d", function()
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes("<Esc>gv", true, false, true),
          "n",
          false
        )
        vim.defer_fn(function()
          local range_start = vim.api.nvim_buf_get_mark(buf, "<")[1]
          local range_end = vim.api.nvim_buf_get_mark(buf, ">")[1]
          if range_start > range_end then
            range_start, range_end = range_end, range_start
          end
          local first
          if to_unstar[range_start] then
            first = true
          else
            first = false
          end
          for line = range_start, range_end do
            set_line(line, first)
          end
          render()
        end, 10)
      end, { buffer = buf, desc = "toggle starred" })
      vim.api.nvim_create_autocmd("BufLeave", {
        buffer = buf,
        once = true,
        callback = function()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end,
      })
    end)
  )
end

return M
