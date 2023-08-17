local M = {}

function M.list_plugins()
  local plugins = vim
    .iter(require("lazy").plugins())
    :map(function(p)
      return p.name
    end)
    :fold("\n", function(acc, name)
      return acc .. name .. "\n"
    end)

  willothy.fn.popup(plugins, "installed forks")
end

function M.list_forks()
  local my_plugins = {
    ["minimus"] = true,
    ["flatten.nvim"] = true,
    ["wezterm.nvim"] = true,
    ["hollywood.nvim"] = true,
    ["futures.nvim"] = true,
    ["savior.nvim"] = true,
    ["nvim-cokeline"] = true,
    ["moveline.nvim"] = true,
  }

  local forks = vim
    .iter(require("lazy").plugins())
    :filter(function(p)
      return vim.startswith(p[1], "willothy")
    end)
    :map(function(p)
      return p.name
    end)
    :filter(function(name)
      return not my_plugins[name]
    end)
    :fold("\n", function(acc, name)
      return acc .. name .. "\n"
    end)

  willothy.fn.popup(forks, "installed forks")
end

return M
