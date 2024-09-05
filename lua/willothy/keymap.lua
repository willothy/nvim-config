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
      "<leader>bb",
      function()
        -- require("cokeline.mappings").pick("focus")
        require("reach").buffers()
      end,
      desc = "pick & focus",
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
      "]h",
      function()
        require("harpoon"):list("files"):next()
      end,
      desc = "harpoon mark",
    },
    {
      "]t",
      function()
        require("willothy.tab").switch_by_step(1)
      end,
      desc = "tab",
    },
    {
      "]e",
      function()
        vim.diagnostic.goto_next({
          severity = vim.diagnostic.severity.ERROR,
        })
      end,
      desc = "error",
    },
    {
      "]d",
      function()
        vim.diagnostic.goto_next()
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
      "[h",
      function()
        require("harpoon"):list("files"):prev()
      end,
      desc = "harpoon mark",
    },
    {
      "[t",
      function()
        require("willothy.tab").switch_by_step(-1)
      end,
      desc = "tab",
    },
    {
      "[e",
      function()
        vim.diagnostic.goto_prev({
          severity = vim.diagnostic.severity.ERROR,
        })
      end,
      desc = "error",
    },
    {
      "[d",
      function()
        vim.diagnostic.goto_prev()
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
        require("willothy.fs").browse(vim.fn.getcwd(-1))
      end,
      desc = "current dir",
    },
    {
      "<leader>pf",
      function()
        require("willothy.fs").browse("~/projects")
      end,
      desc = "projects dir",
    },
    {
      "<leader>pw",
      function()
        require("willothy.fs").browse("~/work")
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
        require("willothy.win").pick_focus()
      end,
      desc = "pick: focus",
    },
    {
      "<leader>wx",
      function()
        require("willothy.win").pick_swap()
      end,
      desc = "pick: swap",
    },
    {
      "<leader>wq",
      function()
        require("willothy.win").pick_close()
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
        require("trouble").toggle({
          mode = "diagnostics",
        })
      end,
      desc = "trouble: toggle",
    },
    {
      "<leader>tt",
      proxy = "<S-Enter>",
      desc = "terminal: toggle",
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
    group = "harpoon",
    {
      "<C-e>",
      function()
        local harpoon = require("harpoon")
        local list = harpoon:list("files")
        local width_ratio = 0.45
        if vim.o.columns > 130 then
          width_ratio = 0.35
        elseif vim.o.columns < 100 then
          width_ratio = 0.55
        end

        require("harpoon").ui:toggle_quick_menu(list, {
          ui_width_ratio = width_ratio,
          border = "solid",
          title_pos = "center",
          footer_pos = "center",
        })
      end,
      desc = "harpoon: marks",
    },
    {
      "<C-c>",
      function()
        local harpoon = require("harpoon")
        local list = harpoon:list("terminals")
        local width_ratio = 0.45
        if vim.o.columns > 130 then
          width_ratio = 0.35
        elseif vim.o.columns < 100 then
          width_ratio = 0.55
        end
        harpoon.ui:toggle_quick_menu(list, {
          ui_width_ratio = width_ratio,
          border = "solid",
          title_pos = "center",
          footer_pos = "center",
        })
      end,
      desc = "harpoon: commands",
    },
    {
      "<C-t>",
      function()
        local harpoon = require("harpoon")
        local list = harpoon:list("wezterm")
        local width_ratio = 0.45
        if vim.o.columns > 130 then
          width_ratio = 0.35
        elseif vim.o.columns < 100 then
          width_ratio = 0.55
        end
        harpoon.ui:toggle_quick_menu(list, {
          ui_width_ratio = width_ratio,
          border = "solid",
          title_pos = "center",
          footer_pos = "center",
        })
      end,
    },
    {
      "<C-a>",
      function()
        local harpoon = require("harpoon")
        local list = harpoon:list("files")

        if list:length() == list:add():length() then
          list:remove()
        end
      end,
      desc = "harpoon: add",
    },
  },
  {
    group = "macros",
    {
      "<C-q>",
      function()
        require("NeoComposer.ui").toggle_macro_menu()
      end,
      desc = "macros: menu",
    },
    {
      "Q",
      function()
        require("NeoComposer.macro").toggle_play_macro()
      end,
      desc = "macros: play",
    },
    {
      "q",
      function()
        require("NeoComposer.macro").toggle_record()
      end,
      desc = "macros: record",
    },
    {
      "cq",
      function()
        require("NeoComposer.macro").stop_macro()
      end,
      desc = "macros: stop",
    },
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
      -- {
      --   "<Tab>",
      --   function()
      --     if vim.fn.pumvisible() == 1 then
      --       require("stay-in-place").shift_right_visual()
      --     end
      --   end,
      --   mode = "n",
      -- },
      -- {
      --   "<S-Tab>",
      --   function()
      --     if vim.fn.pumvisible() == 1 then
      --       require("stay-in-place").shift_left_visual()
      --     end
      --   end,
      --   mode = "n",
      -- },
    },
  },
})

-- remove all mouse mappings
-- local disable = {
--   -- "<2-LeftMouse>",
--   -- "<LeftDrag>",
--   -- "<LeftRelease>",
--   "<3-LeftMouse>",
--   "<4-LeftMouse>",
--   "<RightMouse>",
--   "<2-RightMouse>",
--   "<3-RightMouse>",
--   "<4-RightMouse>",
-- }

-- for _, v in ipairs(disable) do
--   vim.keymap.set(
--     { "n", "v", "i" },
--     v,
--     function() end,
--     { expr = true, desc = "which_key_ignore" }
--   )
-- end
--

-- require("which-key").register({
--   ["<leader>n"] = {
--     nil,
--     "neorg",
--     group = true,
--   },
--   ["<leader>nn"] = "note",
--   ["<leader>nl"] = "list",
--   ["<leader>ni"] = "insert",
--   ["<leader>nt"] = "task",
--   ["<leader>nm"] = "mode",
--   ["<leader>o"] = {
--     function() end,
--     "options",
--     group = true,
--     _ = "which_key_ignore",
--   },
--   ["<leader>"] = {
--     t = {
--       name = "terminal",
--       t = bind(willothy.terminal.main, "toggle", willothy.terminal.main):with_desc(
--         "main"
--       ),
--       v = bind(
--         willothy.terminal.vertical,
--         "toggle",
--         willothy.terminal.vertical
--       ):with_desc("vertical"),
--       f = bind(willothy.terminal.float, "toggle", willothy.terminal.float):with_desc(
--         "float"
--       ),
--       x = bind(willothy.terminal.xplr, "toggle", willothy.terminal.xplr):with_desc(
--         "xplr"
--       ),
--       y = bind(willothy.terminal.yazi, "toggle", willothy.terminal.yazi):with_desc(
--         "yazi"
--       ),
--       s = bind(willothy.terminal, "send_to_main"):with_desc("send"),
--       o = { "<cmd>OverseerFloat<cr>", "overseer: show" },
--       r = {
--         function()
--           require("overseer").run_template()
--         end,
--         "overseer: run",
--       },
--       p = {
--         function()
--           willothy.terminal.py:toggle()
--         end,
--         "python",
--       },
--       l = {
--         function()
--           willothy.terminal.lua:toggle()
--         end,
--         "lua",
--       },
--     },
--   },
-- })
--
-- require("willothy.keymap.editor")
-- require("willothy.keymap.terminal")
-- require("willothy.keymap.cycle")
-- require("willothy.keymap.view")
-- require("willothy.keymap.find")
-- require("willothy.keymap.git")
-- require("willothy.keymap.buffer")
-- require("willothy.keymap.projects")
-- require("willothy.keymap.lsp")
-- require("willothy.keymap.jump")
-- require("willothy.keymap.window")
-- require("willothy.keymap.hydras")
