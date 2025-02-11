local wk = require("which-key")

-- -- ugly hack to seamlessly lazy-load avante on <leader>a
-- vim.keymap.set("n", "<leader>aa", function() end)
-- vim.keymap.set("n", "<leader>a", function()
--   vim.keymap.del("n", "<leader>a", {})
--   vim.keymap.del("n", "<leader>aa", {})
--   require("avante")
--   require("which-key").show({
--     keys = "<leader>a",
--   })
-- end, {
--   nowait = true,
-- })
--
wk.add({
  {
    "<leader>b",
    group = "buffer",
    {
      "<leader>bn",
      function()
        require("cokeline.mappings").by_step("focus", 1)
      end,
      desc = ":bnext",
    },
    {
      "<leader>bp",
      function()
        require("cokeline.mappings").by_step("focus", -1)
      end,
      desc = ":bprev",
    },
    {
      "<leader>bs",
      function()
        require("dropbar.api").pick(vim.v.count ~= 0 and vim.v.count or nil)
      end,
      desc = "dropbar select",
    },
    {
      "<leader>bx",
      function()
        require("cokeline.mappings").pick("close-multiple")
      end,
      desc = "pick & close",
    },
    {
      "<leader>bQ",
      function()
        require("bufdelete").bufdelete(vim.v.count)
      end,
      desc = "delete",
    },
  },
  {
    "]",
    group = "next",
    {
      "<leader>l",
      group = "next",
      proxy = "]",
    },
    {
      "]t",
      function()
        require("willothy.lib.tab").switch_by_step(1)
      end,
      desc = "tab",
    },
    {
      "]e",
      function()
        vim.diagnostic.jump({
          severity = vim.diagnostic.severity.ERROR,
          count = vim.v.count1,
        })
      end,
      desc = "error",
    },
    {
      "]d",
      function()
        vim.diagnostic.jump({
          count = vim.v.count1,
        })
      end,
      desc = "diagnostic",
    },
    {
      "]b",
      function()
        require("cokeline.mappings").by_step("focus", 1)
      end,
      desc = "buffer",
    },
  },
  {
    "[",
    group = "prev",
    {
      "<leader>h",
      group = "prev",
      proxy = "[",
    },
    {
      "[t",
      function()
        require("willothy.lib.tab").switch_by_step(-1)
      end,
      desc = "tab",
    },
    {
      "[e",
      function()
        vim.diagnostic.jump({
          severity = vim.diagnostic.severity.ERROR,
          count = -vim.v.count1,
        })
      end,
      desc = "error",
    },
    {
      "[d",
      function()
        vim.diagnostic.jump({
          count = -vim.v.count1,
        })
      end,
      desc = "diagnostic",
    },
    {
      "[b",
      function()
        require("cokeline.mappings").by_step("focus", -1)
      end,
      desc = "buffer",
    },
  },
  {
    "<leader>p",
    group = "project",
    {
      "<leader>pv",
      function()
        require("willothy.lib.fs").browse(vim.fn.getcwd(-1))
      end,
      desc = "current dir",
    },
    {
      "<leader>pp",
      function()
        require("willothy.lib.fs").browse(
          vim.fs.dirname(vim.api.nvim_buf_get_name(0))
        )
      end,
      desc = "file parent dir",
    },
    {
      "<leader>pf",
      function()
        require("willothy.lib.fs").browse("~/projects")
      end,
      desc = "projects dir",
    },
    {
      "<leader>pw",
      function()
        require("willothy.lib.fs").browse("~/work")
      end,
      desc = "work dir",
    },
  },
  {
    "<leader>f",
    group = "find",
    {
      "<leader>fi",
      function()
        require("snacks").picker.icons()
      end,
      desc = "icon",
    },
    {
      "<leader>ff",
      function()
        require("snacks").picker.files()
      end,
      desc = "files",
    },
    {
      "<leader>fh",
      function()
        require("snacks").picker.help()
      end,
      desc = "help",
    },
    {
      "<leader>fd",
      function()
        ---@diagnostic disable-next-line: missing-fields
        require("snacks").picker.lsp_symbols({
          workspace = true,
        })
      end,
      desc = "document symbols",
    },
    {
      "<leader>fH",
      function()
        require("snacks").picker.man()
      end,
      desc = "manpages",
    },
    {
      "<leader>fr",
      function()
        require("snacks").picker.recent()
      end,
      desc = "recent",
    },
    {
      "<leader>fR",
      function()
        require("snacks").picker.resume()
      end,
      desc = "resume",
    },
    {
      "<leader>fp",
      function()
        require("snacks").picker.projects()
      end,
      desc = "projects",
    },
    {
      "<leader>fz",
      function()
        require("snacks").picker.zoxide()
      end,
      desc = "zoxide",
    },
    {
      "<leader>fs",
      function()
        require("snacks").picker.grep()
      end,
      desc = "live grep",
    },
    {
      "<leader>fu",
      function()
        vim.cmd.UndotreeToggle()
        -- require("snacks").picker.pick({
        --   source = "undo",
        --   layout = {
        --     preview = false,
        --     fullscreen = false,
        --     layout = {
        --       noautocmd = true,
        --     },
        --   },
        -- })
      end,
      desc = "undo history",
    },
    {
      "<leader>fP",
      function()
        require("snacks").picker.pickers({
          layout = "vscode",
        })
      end,
      desc = "pickers",
    },
  },
  {
    "<leader>w",
    group = "window",
    {
      "<leader>wz",
      function()
        require("snacks").zen.zoom()
      end,
      desc = "zen mode",
    },
    {
      "<leader>w=",
      function()
        require("focus").focus_equalize()
      end,
      desc = "resize: equalize",
    },
    {
      "<leader>w|",
      function()
        require("focus").focus_maximize()
      end,
      desc = "resize: maximize",
    },
    {
      "<leader>w\\",
      function()
        require("focus").focus_max_or_equal()
      end,
      desc = "resize: max or equal",
    },
    {
      "<leader>w+",
      function()
        require("focus").focus_autoresize()
      end,
      desc = "resize: auto",
    },
    {
      "<leader>wh",
      function()
        require("smart-splits").move_cursor_left()
      end,
      desc = "move left",
      {
        "<C-w>",
        proxy = "<leader>w",
      },
      {
        "<C-h>",
        function()
          require("smart-splits").move_cursor_left()
        end,
        desc = "move left",
      },
    },
    {
      "<leader>wl",
      function()
        require("smart-splits").move_cursor_right()
      end,
      desc = "move right",
      {
        "<C-l>",
        function()
          require("smart-splits").move_cursor_right()
        end,
        desc = "move right",
      },
    },
    {
      "<leader>wk",
      function()
        require("smart-splits").move_cursor_up()
      end,
      desc = "move up",
      {
        "<C-k>",
        function()
          require("smart-splits").move_cursor_up()
        end,
        desc = "move up",
      },
    },
    {
      "<leader>wj",
      function()
        require("smart-splits").move_cursor_down()
      end,
      desc = "move down",
      {
        "<C-j>",
        function()
          require("smart-splits").move_cursor_down()
        end,
        desc = "move down",
      },
    },
    {
      "<leader>wf",
      function()
        require("willothy.lib.win").pick_focus()
      end,
      desc = "pick: focus",
    },
    {
      "<leader>wx",
      function()
        require("willothy.lib.win").pick_swap()
      end,
      desc = "pick: swap",
    },
    {
      "<leader>wq",
      function()
        require("willothy.lib.win").pick_close()
      end,
      desc = "pick: close",
    },
  },
  {
    "<leader>c",
    group = "lsp",
    {
      "<leader>ca",
      function()
        vim.lsp.buf.code_action()
      end,
      desc = "code action",
    },
    {
      "<leader>cr",
      function()
        vim.lsp.buf.references()
      end,
      desc = "references",
      {
        "gr",
        function()
          vim.lsp.buf.references()
        end,
        proxy = "<leader>cr",
        desc = "goto references",
      },
    },
    {
      "<leader>cd",
      function()
        vim.lsp.buf.definition()
      end,
      desc = "definition",
      {
        "gd",
        function()
          vim.lsp.buf.definition()
        end,
        proxy = "<leader>cd",
        desc = "goto definition",
      },
    },
    {
      "<leader>cD",
      function()
        vim.lsp.buf.declaration()
      end,
      desc = "declaration",
      {
        "gD",
        function()
          vim.lsp.buf.declaration()
        end,
        proxy = "<leader>cD",
        desc = "goto declaration",
      },
    },
    {
      "<leader>ct",
      function()
        vim.lsp.buf.type_definition()
      end,
      desc = "declaration",
      {
        "gt",
        function()
          vim.lsp.buf.type_definition()
        end,
        proxy = "<leader>ct",
        desc = "goto type definition",
      },
    },
    {
      "<leader>cn",
      function()
        require("inc_rename") -- ensure increname is loaded
        vim.api.nvim_feedkeys(
          ":IncRename " .. vim.fn.expand("<cword>"),
          "n",
          true
        )
      end,
      desc = "rename",
    },
    {
      "K",
      function()
        vim.lsp.buf.hover()
      end,
      desc = "lsp: hover",
    },
  },
  {
    "<leader>a",
    group = "ai",
  },
  {
    "<leader>u",
    group = "toggle",
  },
  {
    "<leader>r",
    group = "read",
    {
      "<leader>rN",
      desc = "Neovim News",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
          width = vim.o.columns > 140 and 0.6 or 0.85,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    },
    {
      "<leader>rH",
      desc = "Neovim Help",
      function()
        Snacks.win({
          file = vim.api.nvim_get_runtime_file("doc/help.txt", false)[1],
          width = vim.o.columns > 140 and 0.6 or 0.85,
          height = 0.6,
          wo = {
            spell = false,
            wrap = false,
            signcolumn = "yes",
            statuscolumn = " ",
            conceallevel = 3,
          },
        })
      end,
    },
  },
  {
    "<leader>t",
    group = "terminal",
    {
      "<Esc>",
      mode = "t",
      function()
        vim.cmd.stopinsert()
      end,
      desc = "terminal: exit",
    },
    {
      "<S-Enter>",
      function()
        require("willothy.terminal").toggle()
      end,
      desc = "terminal: toggle",
    },
    {
      "<C-Enter>",
      function()
        ---@diagnostic disable-next-line: missing-fields
        require("trouble").toggle({
          mode = "diagnostics",
        })
      end,
      desc = "trouble: toggle",
    },
    {
      "<leader>tv",
      function()
        ---@diagnostic disable-next-line: undefined-field
        require("willothy.terminal").vertical:toggle()
      end,
      desc = "terminal: vertical",
    },
    {
      "<leader>tf",
      function()
        require("willothy.terminal").toggle_float()
      end,
      desc = "terminal: floating",
    },
    {
      "<leader>ts",
      function()
        require("willothy.terminal").send_to_main()
      end,
      desc = "terminal: send",
    },
    {
      "<leader>to",
      function()
        require("willothy.tasks"):toggle()
      end,
      desc = "overseer: show",
    },
    {
      "<leader>tr",
      function()
        require("overseer").run_template()
      end,
      desc = "overseer: run",
    },
  },
  {
    "g",
    group = "go",
    {
      "g?",
      function()
        wk.show({ mode = "n" })
      end,
      desc = "which-key",
    },
    {
      "gc",
      group = "comment",
    },
    {
      "gH",
      proxy = "^",
      desc = "first non-blank",
    },
    {
      "gL",
      proxy = "$",
      desc = "last non-blank",
    },
  },
  {
    group = "spider",
    {
      "w",
      function()
        require("spider").motion("w")
      end,
      desc = "spider: next word",
    },
    {
      "b",
      function()
        require("spider").motion("b")
      end,
      desc = "spider: prev word",
    },
    {
      "e",
      function()
        require("spider").motion("e")
      end,
      desc = "spider: next end of word",
    },
    {
      "ge",
      function()
        require("spider").motion("w")
      end,
      desc = "spider: prev end of word",
    },
  },
  {
    group = "macros",
    {
      "<C-q>",
      function()
        require("willothy.macros").toggle_menu()
      end,
      desc = "macros: menu",
    },
    {
      "Q",
      function()
        require("willothy.macros").play_selected()
      end,
      desc = "macros: play",
    },
    {
      "q",
      function()
        require("willothy.macros").toggle_recording()
      end,
      desc = "macros: record",
    },
    -- {
    --   "cq",
    --   function() end,
    --   desc = "macros: stop",
    -- },
  },
  {
    group = "yanky",
    {
      "p",
      function()
        require("yanky").put("p")
      end,
      desc = "yanky: put after",
    },
    {
      "P",
      function()
        require("yanky").put("P")
      end,
      desc = "yanky: put before",
    },
    {
      "gp",
      function()
        require("yanky").put("gp")
      end,
      desc = "yanky: put",
    },
    {
      "gP",
      function()
        require("yanky").put("gP")
      end,
      desc = "yanky: put",
    },
  },
  {
    group = "flash",
    {
      "s",
      function()
        require("flash").jump()
      end,
      desc = "flash: jump",
    },
    {
      "r",
      function()
        local mode = vim.api.nvim_get_mode().mode
        if mode == "v" or mode == "V" or mode == "x" then
          require("flash").jump()
        else
          require("flash").remote()
        end
      end,
      mode = "o",
    },
    {
      "<C-s>",
      function()
        require("flash").toggle()
      end,
      desc = "flash: toggle",
      mode = "c",
    },
  },
  {
    group = "misc",
    {
      "u",
      desc = "edit: undo",
    },
    {
      "<C-r>",
      desc = "edit: redo",
    },
    {
      group = "indent",
      {
        "<lt>",
        group = "indent",
        {
          "<lt>",
          desc = "indent: decrease",
        },
      },
      {
        ">",
        group = "indent",
        {
          ">",
          desc = "indent: increase",
        },
      },
      {
        "=",
        group = "indent",
        {
          "=",
          desc = "indent: format",
        },
      },
    },
  },
})
