if vim.g.minimal then return end

local function register(modes, mappings, opts)
  require("which-key").register(
    mappings,
    vim.tbl_deep_extend("keep", { mode = modes }, opts or {})
  )
end

vim.keymap.set({ "n", "i", "t" }, "<C-Enter>", function()
  require("willothy.terminals").toggle()
end)

-- Spider
register({ "n", "o", "x" }, {
  name = "spider",
  w = {
    function()
      require("spider").motion("w")
    end,
    "Spider-w",
  },
  e = {
    function()
      require("spider").motion("e")
    end,
    "Spider-e",
  },
  b = {
    function()
      require("spider").motion("b")
    end,
    "Spider-b",
  },
  ge = {
    function()
      require("spider").motion("ge")
    end,
    "Spider-ge",
  },
})

require("which-key").register({
  ["<C-e>"] = {
    function()
      require("harpoon.ui").toggle_quick_menu()
    end,
    "Toggle harpoon quick menu",
  },
  ["<M-k>"] = {
    function()
      require("moveline").up()
    end,
    "Move line up",
  },
  ["<M-j>"] = {
    function()
      require("moveline").down()
    end,
    "Move line down",
  },
  ["<F1>"] = {
    function()
      require("cokeline.mappings").pick("focus")
    end,
    "Pick buffer",
  },
  ["<C-s>"] = {
    function()
      vim.cmd("write")
    end,
    "Save",
  },
}, { mode = { "n", "i" } })

register("n", {
  ["<Tab>"] = { "V>", "Indent line" },
  ["<S-Tab>"] = { "V<", "Unindent line" },
})

require("which-key").register({
  ["<C-Up>"] = {
    function()
      require("smart-splits").move_cursor_up()
    end,
    "which_key_ignore",
  },
  ["<C-Down>"] = {
    function()
      require("smart-splits").move_cursor_down()
    end,
    "which_key_ignore",
  },
  ["<C-Left>"] = {
    function()
      require("smart-splits").move_cursor_left()
    end,
    "which_key_ignore",
  },
  ["<C-Right>"] = {
    function()
      require("smart-splits").move_cursor_right()
    end,
    "which_key_ignore",
  },
  ["<M-Up>"] = {
    function()
      require("smart-splits").resize_up()
    end,
    "which_key_ignore",
  },
  ["<M-Down>"] = {
    function()
      require("smart-splits").resize_down()
    end,
    "which_key_ignore",
  },
  ["<M-Left>"] = {
    function()
      require("smart-splits").resize_left()
    end,

    "which_key_ignore",
  },
  ["<M-Right>"] = {
    function()
      require("smart-splits").resize_right()
    end,
    "which_key_ignore",
  },
  ["<C-k>"] = {
    function()
      require("smart-splits").move_cursor_up()
    end,
    "which_key_ignore",
  },
  ["<C-j>"] = {
    function()
      require("smart-splits").move_cursor_down()
    end,
    "which_key_ignore",
  },
  ["<C-h>"] = {
    function()
      require("smart-splits").move_cursor_left()
    end,
    "which_key_ignore",
  },
  ["<C-l>"] = {
    function()
      require("smart-splits").move_cursor_right()
    end,
    "which_key_ignore",
  },
}, { mode = { "n", "t" } })

register({ "n", "t" }, {
  ["<C-w>"] = {
    name = "window",
    ["<Up>"] = {
      function()
        require("smart-splits").move_cursor_up()
      end,
      "which_key_ignore",
    },
    ["<Down>"] = {
      function()
        require("smart-splits").move_cursor_down()
      end,
      "which_key_ignore",
    },
    ["<Left>"] = {
      function()
        require("smart-splits").move_cursor_left()
      end,
      "which_key_ignore",
    },
    ["<Right>"] = {
      function()
        require("smart-splits").move_cursor_right()
      end,
      "which_key_ignore",
    },
    ["k"] = {
      function()
        require("smart-splits").move_cursor_up()
      end,
      "which_key_ignore",
    },
    ["j"] = {
      function()
        require("smart-splits").move_cursor_down()
      end,
      "which_key_ignore",
    },
    ["h"] = {
      function()
        require("smart-splits").move_cursor_left()
      end,
      "which_key_ignore",
    },
    ["l"] = {
      function()
        require("smart-splits").move_cursor_right()
      end,
      "which_key_ignore",
    },
    ["-"] = { "<nop>", "which_key_ignore" },
    ["<"] = { "<nop>", "which_key_ignore" },
    [">"] = { "<nop>", "which_key_ignore" },
    ["_"] = { "<nop>", "which_key_ignore" },
    o = {
      "<nop>",
      "which_key_ignore",
    },
    ["="] = {
      function()
        require("focus").focus_equalise()
      end,
      "resize: equalize",
    },
    ["|"] = {
      function()
        require("focus").focus_maximise()
      end,
      "resize: maximize",
    },
    ["\\"] = {
      function()
        require("focus").focus_max_or_equal()
      end,
      "resize: max or equal",
    },
    ["+"] = {
      function()
        require("focus").focus_disable()
        require("focus").focus_enable()
        require("focus").resize()
      end,
      "resize: golden ratio",
    },
    V = {
      function()
        local opt = vim.o.splitright
        vim.o.splitright = true
        vim.cmd("vsplit")
        vim.o.splitright = opt
      end,
      "split: right",
    },
    v = {
      function()
        local opt = vim.o.splitright
        vim.o.splitright = false
        vim.cmd("vsplit")
        vim.o.splitright = opt
      end,
      "split: left",
    },
    S = {
      function()
        local opt = vim.o.splitbelow
        vim.o.splitbelow = true
        vim.cmd("split")
        vim.o.splitbelow = opt
      end,
      "split: below",
    },
    s = {
      function()
        local opt = vim.o.splitbelow
        vim.o.splitbelow = false
        vim.cmd("split")
        vim.o.splitbelow = opt
      end,
      "split: above",
    },
    H = { "swap: left" },
    J = { "swap: down" },
    K = { "swap: up" },
    L = { "swap: right" },
    T = { "move to new tab" },
    f = {
      function()
        local win = require("window-picker").pick_or_create({
          filter_rules = {
            bo = {
              buftype = {},
            },
            include_current_win = false,
          },
        })
        if not win then return end
        vim.api.nvim_set_current_win(win)
      end,
      "pick: focus",
    },
    x = {
      function()
        local win = require("window-picker").pick_window({
          filter_rules = {
            autoselect_one = false,
            bo = {
              buftype = {
                "nofile",
                "nowrite",
                "prompt",
              },
            },
          },
        })
        if not win then return end
        local curwin = vim.api.nvim_get_current_win()
        if
          require("stickybuf").is_pinned(win)
          or require("stickybuf").is_pinned(curwin)
        then
          -- hack to fix window dimming
          vim.api.nvim_set_current_win(curwin)
          return
        end

        local buf = vim.api.nvim_win_get_buf(win)
        local curbuf = vim.api.nvim_get_current_buf()
        if buf == curbuf or win == curwin then return end

        vim.api.nvim_win_set_buf(win, curbuf)
        vim.api.nvim_win_set_buf(curwin, buf)
      end,
      "pick: swap",
    },
    q = {
      function()
        local win = require("window-picker").pick_window({
          filter_rules = {
            include_current_win = true,
            autoselect_one = false,
          },
        })
        if not win then return end
        local ok, res = pcall(vim.api.nvim_win_close, win, false)
        if not ok then
          if vim.startswith(res, "Vim:E444") then
            vim.ui.select({ "Close", "Cancel" }, {
              prompt = "Close window?",
            }, function(i)
              if i == "Close" then
                vim.api.nvim_exec2("qa!", { output = true })
              end
            end)
          else
            vim.notify("could not close window", vim.log.levels.WARN)
          end
        end
      end,
      "pick: close",
    },
  },
})

register("t", {
  ["<Esc>"] = { "<C-\\><C-n>", "Exit terminal" },
})

local function find_tab_direction(step)
  local current_tab = vim.api.nvim_get_current_tabpage()
  local all_tabs = vim.api.nvim_list_tabpages()

  local next
  for i, tab in ipairs(all_tabs) do
    if tab == current_tab then
      next = all_tabs[(i + step - 1) % #all_tabs + 1]
    end
  end

  if next then vim.api.nvim_set_current_tabpage(next) end
end

require("which-key").register({
  ["["] = {
    name = "prev",
    b = {
      function()
        require("cokeline.mappings").by_step(
          "focus",
          -(vim.v.count >= 1 and vim.v.count or 1)
        )
      end,
      "buffer",
    },
    t = {
      function()
        local count = vim.v.count
        if count == 0 then count = 1 end
        find_tab_direction(-count)
      end,
      "tab",
    },
    e = {
      function()
        vim.diagnostic.goto_prev({ severity = "error" })
      end,
      "error",
    },
    m = {
      function()
        require("marks").prev()
      end,
      "mark",
    },
  },
  ["]"] = {
    name = "next",
    b = {
      function()
        require("cokeline.mappings").by_step(
          "focus",
          (vim.v.count >= 1 and vim.v.count or 1)
        )
      end,
      "buffer",
    },
    t = {
      function()
        local count = vim.v.count
        if count == 0 then count = 1 end
        find_tab_direction(count)
      end,
      "tab",
    },
    e = {
      function()
        vim.diagnostic.goto_next({ severity = "error" })
      end,
      "error",
    },
    m = {
      function()
        require("marks").next()
      end,
      "mark",
    },
  },
})

register({ "n", "t" }, {
  ["<S-Esc>"] = {
    "<Cmd>TroubleToggle document_diagnostics<CR>",
    "Diagnostics",
  },
  ["<S-CR>"] = {
    function()
      require("willothy.terminals").toggle()
    end,
    "Toggle terminal",
  },
})

register({ "n", "x" }, {
  ["<C-F>"] = {
    function()
      require("ssr").open()
    end,
    "Structural Search/Replace",
  },
  ["<C-CR>"] = {
    function()
      require("cokeline.mappings").pick("focus")
    end,
    "Pick buffer",
  },
})

local neogit = setmetatable({}, {
  __index = function(_, popup)
    return {
      function()
        require("neogit").open(popup ~= "status" and { popup } or nil)
      end,
      popup,
    }
  end,
})

require("which-key").register({
  v = {
    name = "view",
    o = {
      function()
        require("telescope.builtin").oldfiles()
      end,
      "oldfiles",
    },
    r = {
      function()
        require("telescope.builtin").registers()
      end,
      "registers",
    },
    s = {
      function()
        require("telescope.builtin").lsp_document_symbols()
      end,
      "document symbols",
    },
    l = {
      name = "legendary",
      k = {
        "<cmd>Legendary keymaps<cr>",
        "keymaps",
      },
      a = {
        "<cmd>Legendary autocmds<CR>",
        "autocmds",
      },
      c = {
        "<cmd>Legendary commands<cr>",
        "commands",
      },
      f = {
        "<cmd>Legendary functions<cr>",
        "functions",
      },
    },
  },
  m = {
    function()
      require("reach").marks()
    end,
    "marks",
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
    p = {
      function()
        require("willothy.terminals").py:toggle()
      end,
      "python repl",
    },
    l = {
      function()
        require("willothy.terminals").lua:toggle()
      end,
      "lua repl",
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
  },
  g = {
    name = "git",
    c = neogit.commit,
    b = neogit.branch,
    l = neogit.log,
    p = neogit.push,
    d = neogit.diff,
    r = neogit.rebase,
    S = neogit.stash,
    s = neogit.status,
    B = {
      function()
        require("gitlinker").link({
          action = require("gitlinker.actions").system,
        })
      end,
      "open in browser",
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
    "Move block up",
  },
  ["<M-j>"] = {
    function()
      require("moveline").block_down()
    end,
    "Move block down",
  },
  ["<Tab>"] = { ">gv", "Indent line" },
  ["<S-Tab>"] = { "<gv", "Unindent line" },
  ["<C-c>"] = { '"+y', "Copy selection" },
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
