if vim.g.minimal then return end

local function register(modes, mappings, opts)
  if type(modes) == "table" then
    vim.iter(modes):each(
      function(mode)
        require("which-key").register(
          mappings,
          vim.tbl_deep_extend("keep", { mode = mode }, opts or {})
        )
      end
    )
  else
    require("which-key").register(
      mappings,
      vim.tbl_deep_extend("keep", { mode = modes }, opts or {})
    )
  end
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
register({ "n" }, {})

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

register({ "n", "i" }, {
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
})

register("n", {
  ["<Tab>"] = { "V>", "Indent line" },
  ["<S-Tab>"] = { "V<", "Unindent line" },
})

register({ "n", "t" }, {
  ["<C-Up>"] = {
    function() require("smart-splits").move_cursor_up() end,
    "Move to window up",
  },
  ["<C-Down>"] = {
    function() require("smart-splits").move_cursor_down() end,
    "Move to window down",
  },
  ["<C-Left>"] = {
    function() require("smart-splits").move_cursor_left() end,
    "Move to window left",
  },
  ["<C-Right>"] = {
    function() require("smart-splits").move_cursor_right() end,
    "Move to window right",
  },
  ["<M-Up>"] = {
    function() require("smart-splits").resize_up() end,
    "Resize to window up",
  },
  ["<M-Down>"] = {
    function() require("smart-splits").resize_down() end,
    "Resize to window down",
  },
  ["<M-Left>"] = {
    function() require("smart-splits").resize_left() end,

    "Resize to window left",
  },
  ["<M-Right>"] = {
    function() require("smart-splits").resize_right() end,
    "Resize to window right",
  },
  ["<C-w>"] = {
    name = "window",
    ["<Up>"] = {
      function() require("smart-splits").move_cursor_up() end,
      "Move to window above",
    },
    ["<Down>"] = {
      function() require("smart-splits").move_cursor_down() end,
      "Move to window below",
    },
    ["<Left>"] = {
      function() require("smart-splits").move_cursor_left() end,
      "Move to window left",
    },
    ["<Right>"] = {
      function() require("smart-splits").move_cursor_right() end,
      "Move to window right",
    },
    ["k"] = {
      function() require("smart-splits").move_cursor_up() end,
      "Move to window abovw",
    },
    ["j"] = {
      function() require("smart-splits").move_cursor_down() end,
      "Move to window below",
    },
    ["h"] = {
      function() require("smart-splits").move_cursor_left() end,
      "Move to window left",
    },
    ["l"] = {
      function() require("smart-splits").move_cursor_right() end,
      "Move to window right",
    },
    ["="] = {
      function() require("focus").focus_equalise() end,
      "Equalize window sizes",
    },
    ["g"] = {
      function() require("focus").resize() end,
      "Autoresize based on golden ratio",
    },
    ["m"] = {
      function() require("focus").focus_maximise() end,
      "Maximize focused window",
    },
    ["f"] = {
      function() require("nvim-window").pick() end,
      "Pick window",
    },
    x = {
      function()
        require("winshift")
        vim.api.nvim_exec("WinShift swap", true)
      end,
      "Swap windows",
    },
    ["<C-w>"] = {
      function()
        require("winshift")
        vim.api.nvim_exec("WinShift", true)
      end,
      "Enter WinShift mode",
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

require("willothy.hydras")
