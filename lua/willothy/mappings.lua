if vim.g.minimal then return end

require("which-key").register({
  v = {
    name = "view",
    L = {
      name = "legendary",
    },
  },
  g = {
    name = "git",
  },
  t = {
    name = "toggle",
    u = { vim.cmd.UndotreeToggle, "Toggle undotree" },
    t = {
      function()
        require("willothy.terminals").toggle()
      end,
      "terminal: toggle",
    },
    f = {
      function()
        require("willothy.terminals").toggle_float()
      end,
      "terminal: float toggle",
    },
    s = {
      function()
        vim.ui.input({
          prompt = "$ ",
          completion = "shellcmd",
        }, function(v)
          if v and type(v) == "string" then
            require("willothy.terminals").with():send(v)
          end
        end)
      end,
      "terminal: send",
    },
    d = {
      function()
        require("dapui").toggle()
      end,
      "dap ui",
    },
    r = {
      name = "repl",
      p = {
        function()
          require("willothy.terminals").py:toggle()
        end,
        "python",
      },
      l = {
        function()
          require("willothy.terminals").lua:toggle()
        end,
        "lua",
      },
    },
    h = {
      function()
        require("harpoon.mark").toggle_file()
      end,
      "harpoon: toggle current file",
    },
    H = {
      function()
        require("harpoon.ui").toggle_quick_menu()
      end,
      "harpoon: files",
    },
  },
  b = {
    name = "buffer",
    r = {
      function()
        require("reach").buffers()
      end,
      "reach: buffers",
    },
    s = {
      function()
        if vim.v.count == 0 then
          require("dropbar.api").pick()
        else
          require("dropbar.api").pick(vim.v.count)
        end
      end,
      "dropbar: open",
    },
    p = {
      function()
        require("cokeline.mappings").pick("focus")
      end,
      "pick & focus",
    },
    x = {
      function()
        require("cokeline.mappings").pick("close")
      end,
      "pick & close",
    },
    Q = {
      function()
        require("bufdelete").bufdelete(vim.v.count)
      end,
      "close current",
    },
  },
  p = {
    name = "files",
    f = {
      function()
        require("willothy.util.fs").browse("~/projects/")
      end,
      "projects",
    },
    v = {
      function()
        require("willothy.util.fs").browse()
      end,
      "current directory",
    },
    r = {
      function()
        require("willothy.util.fs").browse(
          require("willothy.util.fs").project_root()
        )
      end,
      "project root",
    },
    h = {
      function()
        require("willothy.util.fs").browse(vim.loop.os_homedir())
      end,
      "home directory",
    },
    n = {
      function()
        require("willothy.util.fs").browse(vim.fn.stdpath("config"))
      end,
      "nvim config",
    },
    z = {
      function()
        require("willothy.util.fs").browse(
          vim.fn.stdpath("config") .. "/../zsh"
        )
      end,
      "zsh config",
    },
  },
  c = {
    name = "codelens",
    a = {
      function()
        require("hollywood").code_actions()
      end,
      "code actions",
    },
    r = {
      function()
        require("glance").open("references")
      end,
      "references",
    },
    d = {
      function()
        require("glance").open("definitions")
      end,
      "definitions",
    },
    D = {
      vim.lsp.buf.declaration,
      "declaration",
    },
    T = {
      function()
        require("glance").open("type_definitions")
      end,
      "type definition",
    },
    i = {
      function()
        require("glance").open("implementations")
      end,
      "implementations",
    },
  },
  j = {
    name = "jump",
    d = {
      function()
        require("configs.navigation.portal").diagnostics({
          buffer = vim.api.nvim_get_current_buf(),
        })
      end,
      "diagnostics",
    },
    r = {
      function()
        require("configs.navigation.portal").references()
      end,
      "references",
    },
    j = {
      function()
        require("portal.builtin").jumplist.tunnel()
      end,
      "jumplist",
    },
    h = {
      function()
        require("portal.builtin").harpoon.tunnel()
      end,
      "harpoon",
    },
    q = {
      function()
        require("portal.builtin").quickfix.tunnel()
      end,
      "quickfix",
    },
    c = {
      function()
        require("portal.builtin").changelist.tunnel()
      end,
      "changelist",
    },
  },
}, { prefix = "<leader>" })

require("which-key").register({
  ["<M-k>"] = {
    function()
      require("moveline").block_up()
    end,
    "move: up",
  },
  ["<M-j>"] = {
    function()
      require("moveline").block_down()
    end,
    "move: down",
  },
  ["<Tab>"] = { ">gv", "indent: increase" },
  ["<S-Tab>"] = { "<gv", "indent: decrease" },
  ["<C-c>"] = { '"+y', "copy selection" },
  ["M"] = { ":MCvisual<CR>", "multicursor mode" },
}, {
  mode = "v",
})

local function fmt(name, is_after)
  return string.format("%s %s", name, is_after and "󱞣" or "󱞽")
end

require("which-key").register({
  p = {
    "<Plug>(YankyPutAfter)",
    fmt("put", true),
  },
  P = {
    "<Plug>(YankyPutBefore)",
    fmt("put"),
  },
  gp = {
    "<Plug>(YankyGPutAfter)",
    fmt("GPut", true),
  },
  gP = {
    "<Plug>(YankyGPutBefore)",
    fmt("GPut"),
  },
  ["]y"] = {
    "<Plug>(YankyCycleForward)",
    fmt("yanky: cycle", true),
  },
  ["[y"] = {
    "<Plug>(YankyCycleBackward)",
    fmt("yanky: cycle"),
  },
}, { mode = { "n", "x", "v" } })

require("which-key").register({
  s = {
    function()
      require("flash").jump()
    end,
    "flash: jump",
  },
  ["<M-s>"] = {
    function()
      require("flash").jump({ reverse = true })
    end,
    "flash: treesitter",
  },
  ["<M-r>"] = {
    function()
      -- show labeled treesitter nodes around the search matches
      require("flash").treesitter_search()
    end,
    "flash: treesitter Search",
  },
}, { mode = { "n", "x" } })

require("which-key").register({
  r = {
    function()
      require("flash").remote()
    end,
    "flash: remote",
  },
}, { mode = "o" })

require("which-key").register({
  ["<C-s>"] = {
    function()
      require("flash").toggle()
    end,
    "flash: toggle flash search",
  },
}, { mode = "c" })

require("which-key").register({
  ["<F5>"] = {
    function()
      require("configs.debugging.dap").launch()
    end,
    "dap: launch debugger",
  },
  ["<F8>"] = {
    function()
      require("dap").toggle_breakpoint()
    end,
    "dap: toggle breakpoint",
  },
  ["<F9>"] = {
    function()
      require("dap").continue()
    end,
    "dap: continue",
  },
  ["<F10>"] = {
    function()
      require("dap").step_over()
    end,
    "dap: step over",
  },
  ["<S-F10>"] = {
    function()
      require("dap").step_into()
    end,
    "dap: step into",
  },
  ["<F12>"] = {
    function()
      require("dap.ui.widgets").hover()
    end,
    "dap: step out",
  },
})

-- remove all mouse mappings
local disable = {
  "<2-LeftMouse>",
  "<3-LeftMouse>",
  "<4-LeftMouse>",
  "<2-RightMouse>",
  "<3-RightMouse>",
  "<4-RightMouse>",
}

for _, v in ipairs(disable) do
  vim.keymap.set({ "n", "v", "i" }, v, "<Nop>", { silent = true })
end
