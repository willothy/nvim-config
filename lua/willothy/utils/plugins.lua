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
    ["strat-hero.nvim"] = true,
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

-- TODO: redo with non-naive method (i.e. query github graphql api to actually check if its a fork)
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

return M
