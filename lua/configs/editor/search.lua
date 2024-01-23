local tabs = {
  git = {
    branches = {
      name = "Branches",
      tele_func = function(...)
        willothy.fn.telescope.git_branches(...)
      end,
    },
    commits = {
      name = "Commits",
      tele_func = function(...)
        willothy.fn.telescope.git_commits(...)
      end,
    },
    stash = {
      name = "Stashes",
      tele_func = function(...)
        willothy.fn.telescope.git_stash(...)
      end,
    },
  },
  files = {
    files = {
      name = "Files",
      tele_func = function(opts)
        opts.sorter = require("telescope").extensions.fzf.native_fzf_sorter()
        require("telescope._extensions.frecency").exports.frecency(opts)
      end,
    },
    projects = {
      name = "Projects",
      tele_func = function(opts)
        willothy.fn.telescope.projects(opts)
      end,
    },
  },
}

local collections = {
  git = {
    initial_tab = 1,
    tabs = {
      tabs.git.branches,
      tabs.git.commits,
      tabs.git.stash,
    },
  },
  files = {
    initial_tab = 1,
    tabs = {
      tabs.files.files,
      tabs.files.projects,
    },
  },
}

require("search").setup({
  mappings = {
    next = "<Tab>",
    prev = "<S-Tab>",
  },
  tabs = vim.iter(collections.files.tabs):fold({}, function(acc, tab)
    table.insert(acc, {
      tab.name,
      function(opts)
        tab.tele_func(opts)
      end,
    })
    return acc
  end),
  collections = collections,
})

willothy.fn.create_command("Search", {
  command = function(args)
    local collection, tab = unpack(args.fargs)
    if tab then
      tab = tab:gsub("^%l", string.upper)
    end
    if collection and not collections[collection] then
      tab = collection:gsub("^%l", string.upper)
      collection = nil
    end
    require("search").open({
      collection = collection,
      tab_name = tab,
    })
  end,
  complete = function(_arg, line)
    local res = vim.api.nvim_parse_cmd(line, {})
    local argc = #res.args
    if argc == 0 or (argc == 1 and not line:match("%s$")) then
      local opts = {}
      vim.list_extend(opts, vim.tbl_keys(collections))
      vim.iter(tabs):each(function(_, group)
        vim.list_extend(opts, vim.tbl_keys(group))
      end)
      return opts
    else
      local argval = vim.trim(res.args[1] or "")
      if collections[argval] then
        return vim
          .iter(collections[argval].tabs)
          :map(function(tab)
            return tab.name:lower()
          end)
          :totable()
      end
    end
  end,
  nargs = "*",
})
