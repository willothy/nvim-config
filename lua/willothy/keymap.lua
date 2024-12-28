local wk = require("which-key")

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
        require("cokeline.mappings").pick("close")
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
      "<leader>ff",
      function()
        require("telescope").extensions.frecency.frecency({
          sorter = require("telescope").extensions.fzf.native_fzf_sorter(),
        })
      end,
      desc = "files",
    },
    {
      "<leader>fs",
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "live grep",
    },
    {
      "<leader>fp",
      function()
        require("telescope").extensions.projects.projects()
      end,
      desc = "projects",
    },
    {
      "<leader>fu",
      function()
        vim.cmd.UndotreeToggle()
      end,
      desc = "undo history",
    },
    {
      "<leader>fP",
      function()
        require("telescope.builtin").pickers()
      end,
      desc = "telescope pickers",
    },
  },
  {
    "<leader>w",
    group = "window",
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
        require("overseer")
        vim.cmd.OverseerFloat()
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
        require("configs.macros").toggle_menu()
      end,
      desc = "macros: menu",
    },
    {
      "Q",
      function()
        require("configs.macros").play_selected()
      end,
      desc = "macros: play",
    },
    {
      "q",
      function()
        require("configs.macros").toggle_recording()
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
    "<leader>m",
    group = "marks",
    {
      "<leader>md",
      function()
        require("marks").delete()
      end,
      desc = "marks: delete",
    },
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
    {
      "y",
      function()
        require("yanky").yank()
      end,
      desc = "yanky: yank",
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
      "<C-f>",
      function()
        require("spectre").toggle()
      end,
      desc = "spectre: search/replace",
    },
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
