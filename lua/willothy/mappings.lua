if vim.g.minimal then return end

local function register(modes, mappings, opts)
  require("which-key").register(
    mappings,
    vim.tbl_deep_extend("keep", { mode = modes }, opts or {})
  )
end

local function mkportal(title, items, callback, opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, {
    max_results = 4,
  })
  local Content = require("portal.content")
  local Iterator = require("portal.iterator")
  local Portal = require("portal")

  local iter = Iterator:new(items)
  if opts.filter then iter = iter:filter(opts.filter) end
  if opts.map then iter = iter:map(opts.map) end
  iter = iter
    :map(
      function(v, _i)
        return Content:new({
          type = v.title or title,
          buffer = v.bufnr,
          cursor = { row = v.lnum, col = v.col },
          callback = callback,
        })
      end
    )
    :take(opts.max_results)

  local res = {
    source = iter,
    slots = opts.slots,
  }
  Portal.tunnel(res)
end

local function portal_diagnostics(opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, {
    max_results = 4,
  })
  local diagnostics = vim.diagnostic.get(opts.buffer or nil)
  local Content = require("portal.content")
  local Iterator = require("portal.iterator")
  local Portal = require("portal")

  local iter = Iterator:new(diagnostics)
    :take(4)
    :map(function(v, _i)
      return Content:new({
        type = "diagnostics",
        buffer = v.bufnr,
        cursor = { row = v.lnum, col = 1 },
        extra = v.col,
        callback = function(content)
          local buf = content.buffer
          local cursor = content.cursor
          local win = vim.api.nvim_get_current_win()
          local bufnr = vim.api.nvim_win_get_buf(win)
          if buf ~= bufnr then vim.api.nvim_set_current_buf(buf) end
          vim.api.nvim_win_set_cursor(win, { cursor.row, content.extra })
        end,
      })
    end)
    :take(opts.max_results)
  local res = {
    source = iter,
    slots = nil,
  }
  Portal.tunnel(res)
end

local function portal_references(context)
  local params = vim.lsp.util.make_position_params()
  params.context = context or {
    includeDeclaration = true,
  }
  vim.lsp.buf_request(
    0,
    "textDocument/references",
    params,
    function(err, result)
      if err then
        vim.notify(err.message)
        return
      end
      if not result then
        vim.notify("no references found")
        return
      end
      local references = result
      mkportal("references", references, function(content)
        local buf = content.buffer
        local cursor = content.cursor
        local win = vim.api.nvim_get_current_win()
        local bufnr = vim.api.nvim_win_get_buf(win)
        if buf ~= bufnr then vim.api.nvim_set_current_buf(buf) end
        vim.api.nvim_win_set_cursor(win, { cursor.row + 1, cursor.col })
      end, {
        map = function(v)
          return {
            title = "references",
            bufnr = vim.uri_to_bufnr(v.uri),
            lnum = v.range.start.line,
            col = v.range.start.character,
          }
        end,
      })
    end
  )
end

vim.keymap.set(
  { "n", "i", "t" },
  "<C-Enter>",
  function() require("willothy.terminals").toggle() end
)

-- Dap
-- register({ "n" }, {})

-- Spider
register({ "n", "o", "x" }, {
  name = "spider",
  w = {
    function() require("spider").motion("w") end,
    "Spider-w",
  },
  e = {
    function() require("spider").motion("e") end,
    "Spider-e",
  },
  b = {
    function() require("spider").motion("b") end,
    "Spider-b",
  },
  ge = {
    function() require("spider").motion("ge") end,
    "Spider-ge",
  },
})

require("which-key").register({
  ["<C-e>"] = {
    function() require("harpoon.ui").toggle_quick_menu() end,
    "Toggle harpoon quick menu",
  },
  ["<M-k>"] = {
    function() require("moveline").up() end,
    "Move line up",
  },
  ["<M-j>"] = {
    function() require("moveline").down() end,
    "Move line down",
  },
  ["<F1>"] = {
    function() require("cokeline.mappings").pick("focus") end,
    "Pick buffer",
  },
  ["<C-s>"] = {
    function() vim.cmd("write") end,
    "Save",
  },
}, { mode = { "n", "i" } })

register("n", {
  ["<Tab>"] = { "V>", "Indent line" },
  ["<S-Tab>"] = { "V<", "Unindent line" },
})

require("which-key").register({
  ["<C-Up>"] = {
    function() require("smart-splits").move_cursor_up() end,
    "which_key_ignore",
  },
  ["<C-Down>"] = {
    function() require("smart-splits").move_cursor_down() end,
    "which_key_ignore",
  },
  ["<C-Left>"] = {
    function() require("smart-splits").move_cursor_left() end,
    "which_key_ignore",
  },
  ["<C-Right>"] = {
    function() require("smart-splits").move_cursor_right() end,
    "which_key_ignore",
  },
  ["<M-Up>"] = {
    function() require("smart-splits").resize_up() end,
    "which_key_ignore",
  },
  ["<M-Down>"] = {
    function() require("smart-splits").resize_down() end,
    "which_key_ignore",
  },
  ["<M-Left>"] = {
    function() require("smart-splits").resize_left() end,

    "which_key_ignore",
  },
  ["<M-Right>"] = {
    function() require("smart-splits").resize_right() end,
    "which_key_ignore",
  },
  ["<C-k>"] = {
    function() require("smart-splits").move_cursor_up() end,
    "which_key_ignore",
  },
  ["<C-j>"] = {
    function() require("smart-splits").move_cursor_down() end,
    "which_key_ignore",
  },
  ["<C-h>"] = {
    function() require("smart-splits").move_cursor_left() end,
    "which_key_ignore",
  },
  ["<C-l>"] = {
    function() require("smart-splits").move_cursor_right() end,
    "which_key_ignore",
  },
}, { mode = { "n", "t" } })

register({ "n", "t" }, {
  ["<C-w>"] = {
    name = "window",
    ["<Up>"] = {
      function() require("smart-splits").move_cursor_up() end,
      "which_key_ignore",
    },
    ["<Down>"] = {
      function() require("smart-splits").move_cursor_down() end,
      "which_key_ignore",
    },
    ["<Left>"] = {
      function() require("smart-splits").move_cursor_left() end,
      "which_key_ignore",
    },
    ["<Right>"] = {
      function() require("smart-splits").move_cursor_right() end,
      "which_key_ignore",
    },
    ["k"] = {
      function() require("smart-splits").move_cursor_up() end,
      "which_key_ignore",
    },
    ["j"] = {
      function() require("smart-splits").move_cursor_down() end,
      "which_key_ignore",
    },
    ["h"] = {
      function() require("smart-splits").move_cursor_left() end,
      "which_key_ignore",
    },
    ["l"] = {
      function() require("smart-splits").move_cursor_right() end,
      "which_key_ignore",
    },
    ["="] = {
      function() require("focus").focus_equalise() end,
      "equalize",
    },
    ["|"] = {
      function() require("focus").focus_maximise() end,
      "maximize",
    },
    ["\\"] = {
      function() require("focus").focus_max_or_equal() end,
      "max or equal",
    },
    ["+"] = {
      function()
        require("focus").focus_disable()
        require("focus").focus_enable()
        require("focus").resize()
      end,
      "golden ratio",
    },
    v = { "split vertically" },
    s = { "split horizontally" },
    T = { "move to new tab" },
    H = { "swap left" },
    J = { "swap down" },
    K = { "swap up" },
    L = { "swap right" },
    f = {
      function()
        local win = require("window-picker").pick_window()
        if not win then return end
        vim.api.nvim_set_current_win(win)
      end,
      "pick - focus",
    },
    x = {
      function()
        local win = require("window-picker").pick_window()
        if not win then return end

        local buf = vim.api.nvim_win_get_buf(win)
        local curbuf = vim.api.nvim_get_current_buf()
        local curwin = vim.api.nvim_get_current_win()
        if buf == curbuf or win == curwin then return end

        vim.api.nvim_win_set_buf(win, curbuf)
        vim.api.nvim_win_set_buf(curwin, buf)
      end,
      "pick - swap",
    },
    q = {
      function()
        local win = require("window-picker").pick_window({
          filter_rules = {
            include_current_win = true,
            -- bo = {
            --   buftype = {
            --     "",
            --     "nofile",
            --   },
            -- },
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
      "pick - close",
    },
  },
})

register("t", {
  ["<Esc>"] = { "<C-\\><C-n>", "Exit terminal" },
})

require("which-key").register({
  ["["] = {
    name = "prev",
    b = {
      function() require("cokeline.mappings").by_step("focus", -1) end,
      "Focus previous buffer",
    },
    B = {
      function() require("cokeline.mappings").by_step("switch", -1) end,
      "Move previous buffer",
    },
  },
  ["]"] = {
    name = "next",
    b = {
      function() require("cokeline.mappings").by_step("focus", 1) end,
      "Focus next buffer",
    },
    B = {
      function() require("cokeline.mappings").by_step("switch", 1) end,
      "Move next buffer",
    },
  },
})

register({ "n", "t" }, {
  ["<S-Esc>"] = {
    "<Cmd>TroubleToggle document_diagnostics<CR>",
    "Diagnostics",
  },
  ["<S-CR>"] = {
    function() require("willothy.terminals").toggle() end,
    "Toggle terminal",
  },
})

register({ "n", "x" }, {
  ["<C-F>"] = {
    function() require("ssr").open() end,
    "Structural Search/Replace",
  },
  ["<C-CR>"] = {
    function() require("cokeline.mappings").pick("focus") end,
    "Pick buffer",
  },
})

require("which-key").register({
  v = "view",
  r = "lsp",
  a = {
    function() require("harpoon.mark").add_file() end,
    "Add file to harpoon",
  },
  -- f = {
  --   name = "telescope",
  --   f = "find files",
  --   s = "live grep",
  --   g = "git files",
  --   r = "resume",
  --   p = "projects",
  --   u = "undotree",
  --   ["<Enter>"] = "builtin pickers",
  -- },
  t = {
    name = "toggle",
    u = { vim.cmd.UndotreeToggle, "Toggle undotree" },
    t = {
      function() require("willothy.terminals").toggle() end,
      "Toggle terminal",
    },
    f = {
      function() require("willothy.terminals").toggle_float() end,
      "Toggle floating terminal",
    },
    h = {
      function()
        local h = require("harpoon.mark")
        local buf = vim.api.nvim_buf_get_name(0)
        if not h.get_current_index() then
          h.add_file(buf) -- mark is not in list
        else
          h.rm_file(buf) -- mark is in list
        end
      end,
      "Toggle current harpoon mark",
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
      "Send to terminal",
    },
    p = {
      function() require("willothy.terminals").py:toggle() end,
      "Python repl",
    },
    l = {
      function() require("willothy.terminals").lua:toggle() end,
      "Lua repl",
    },
    c = {
      name = "Actions",
      a = "Code actions",
      o = {
        function() require("telescope.builtin").oldfiles() end,
        "Telescope oldfiles",
      },
      r = {
        function() require("telescope.builtin").registers() end,
        "Telescope registers",
      },
      s = {
        function() require("telescope.builtin").lsp_document_symbols() end,
        "Telescope LSP document symbols",
      },
    },
  },
  b = {
    name = "buffer",
    p = {
      function() require("cokeline.mappings").pick("focus") end,
      "Pick buffer",
    },
    x = {
      function() require("cokeline.mappings").pick("close") end,
      "Delete buffer",
    },
  },
  p = {
    name = "project",
    f = {
      function() require("willothy.util").browse("~/projects/") end,
      "Browse projects",
    },
    v = {
      function() require("willothy.util").browse() end,
      "Browse current directory",
    },
    r = {
      function()
        require("willothy.util").browse(require("willothy.util").project_root())
      end,
      "Browse project root",
    },
    h = {
      function() require("willothy.util").browse(vim.loop.os_homedir()) end,
      "Browse home directory",
    },
    cr = {
      function()
        require("willothy.util").browse(require("willothy.util").crate_root())
      end,
      "Browse crate root",
    },
    pc = {
      function()
        require("willothy.util").browse(require("willothy.util").parent_crate())
      end,
      "Browse parent crate",
    },
  },
  c = {
    name = "comment",
    c = "Comment current line",
    b = "Block comment current line",
  },
  g = {
    name = "git",
    f = { vim.cmd.Git, "Open fugitive" },
    b = {
      function() require("blam").peek() end,
      "Peek line blame",
    },
    g = {
      function()
        -- hacky way of toggling diffview
        local diffview = require("diffview")
        local lib = require("diffview.lib")
        if lib.get_current_view() then
          diffview.close()
        else
          diffview.open()
        end
      end,
      "Diffview",
    },
  },
  d = {
    name = "Debugging",
    t = {
      function() require("dapui").toggle() end,
      "Toggle DAP UI",
    },
  },
  ["l$"] = "Add comment at end of line",
  n = {
    name = "neovim",
    v = {
      function() require("willothy.util").browse(vim.fn.stdpath("config")) end,
      "Browse nvim config",
    },
  },
  j = {
    name = "portal",
    gd = { portal_diagnostics, "global diagnostics" },
    d = {
      function() portal_diagnostics({ buffer = 0 }) end,
      "diagnostics",
    },
    r = { portal_references, "references" },
    j = {
      function() require("portal.builtin").jumplist.tunnel() end,
      "jumplist",
    },
    h = { function() require("portal.builtin").harpoon.tunnel() end, "harpoon" },
    q = {
      function() require("portal.builtin").quickfix.tunnel() end,
      "quickfix",
    },
    c = {
      function() require("portal.builtin").changelist.tunnel() end,
      "changelist",
    },
  },
}, { prefix = "<leader>" })

require("which-key").register({
  ["<M-k>"] = {
    function() require("moveline").block_up() end,
    "Move block up",
  },
  ["<M-j>"] = {
    function() require("moveline").block_down() end,
    "Move block down",
  },
  ["<Tab>"] = { ">gv", "Indent line" },
  ["<S-Tab>"] = { "<gv", "Unindent line" },
  ["<C-c>"] = { '"+y', "Copy selection" },
}, {
  mode = "v",
})
