local dropbar = require("dropbar")
local icons = require("willothy.ui.icons")

local enable = function(buf, win, _)
  buf = vim._resolve_bufnr(buf)
  if
    not vim.api.nvim_buf_is_valid(buf)
    or not vim.api.nvim_win_is_valid(win)
  then
    return false
  end

  if
    not vim.api.nvim_buf_is_valid(buf)
    or not vim.api.nvim_win_is_valid(win)
    or vim.fn.win_gettype(win) ~= ""
    or vim.wo[win].winbar ~= ""
    or vim.bo[buf].ft == "help"
  then
    return false
  end

  local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
  if stat and stat.size > 1024 * 1024 then
    return false
  end

  local filetype = vim.bo[buf].filetype
  local disabled = {
    ["oil"] = true,
    ["trouble"] = true,
    ["qf"] = true,
    ["noice"] = true,
    ["dapui_scopes"] = true,
    ["dapui_breakpoints"] = true,
    ["dapui_stacks"] = true,
    ["dapui_watches"] = true,
    ["dapui_console"] = true,
    ["dap-repl"] = true,
    ["neocomposer-menu"] = true,
  }
  if disabled[filetype] then
    return false
  end

  -- if
  --   vim.bo[buf].buftype == "terminal" and vim.bo[buf].filetype ~= "terminal"
  -- then
  --   return false
  -- end

  return vim.bo[buf].ft == "markdown"
    or pcall(vim.treesitter.get_parser, buf)
    or not vim.tbl_isempty(vim.lsp.get_clients({
      bufnr = buf,
      method = "textDocument/documentSymbol",
    }))
end

-- local enable = function(buf, win)
--   -- if
--   --   require("cokeline.sidebar").get_win("left") == win
--   --   or require("cokeline.sidebar").get_win("right") == win
--   -- then
--   --   return false
--   -- end
--   -- if vim.wo[win].diff then
--   --   return false
--   -- end
--   local filetype = vim.bo[buf].filetype
--   local disabled = {
--     ["oil"] = true,
--     ["trouble"] = true,
--     ["qf"] = true,
--     ["noice"] = true,
--     ["dapui_scopes"] = true,
--     ["dapui_breakpoints"] = true,
--     ["dapui_stacks"] = true,
--     ["dapui_watches"] = true,
--     ["dapui_console"] = true,
--     ["dap-repl"] = true,
--     ["neocomposer-menu"] = true,
--   }
--   if disabled[filetype] then
--     return false
--   end
--   if vim.api.nvim_win_get_config(win).zindex ~= nil then
--     return vim.bo[buf].buftype == "terminal"
--       and vim.bo[buf].filetype == "terminal"
--   end
--   return vim.bo[buf].buflisted == true
--     and vim.bo[buf].buftype == ""
--     and vim.api.nvim_buf_get_name(buf) ~= ""
-- end

local close = function()
  local menu = require("dropbar.utils").menu.get_current()
  if not menu then
    return
  end
  menu:close()
end

-- vim.api.nvim_set_hl(0, "DropBarHover", {
--   link = "Visual",
--   -- italic = true,
--   -- underline = true,
-- })

dropbar.setup({
  sources = {
    terminal = {
      name = function(buf)
        local term = require("toggleterm.terminal").find(function(term)
          return term.bufnr == buf
        end)
        local name
        if term then
          name = term.display_name or term.cmd or term.name
        else
          name = vim.api.nvim_buf_get_name(buf)
        end
        return " " .. name
      end,
      name_hl = "Normal",
    },
    lsp = {
      valid_symbols = {
        "File",
        "Module",
        "Namespace",
        -- "Package",
        "Class",
        "Method",
        "Property",
        "Field",
        "Constructor",
        "Enum",
        "Interface",
        "Function",
        "Variable",
        "Constant",
        "String",
        "Number",
        "Boolean",
        "Array",
        "Object",
        "Keyword",
        "Null",
        "EnumMember",
        "Struct",
        "Event",
        "Operator",
        "TypeParameter",
      },
      max_depth = 6,
    },
    treesitter = {
      valid_types = {
        -- "array",
        -- "boolean",
        -- "break_statement",
        "call",
        -- "case_statement",
        "class",
        "constant",
        -- "constructor",
        -- "continue_statement",
        -- "delete",
        -- "do_statement",
        "element",
        "enum",
        "enum_member",
        -- "event",
        -- "for_statement",
        "function",
        -- "h1_marker",
        -- "h2_marker",
        -- "h3_marker",
        -- "h4_marker",
        -- "h5_marker",
        -- "h6_marker",
        -- "if_statement",
        "interface",
        -- "keyword",
        -- "macro",
        "method",
        "module",
        "namespace",
        -- "null",
        -- "number",
        -- "operator",
        "package",
        -- "pair",
        "property",
        "reference",
        -- "repeat",
        -- "rule_set",
        -- "scope",
        -- "specifier",
        "struct",
        -- "switch_statement",
        -- "type",
        -- "type_parameter",
        -- "unit",
        -- "value",
        -- "variable",
        -- "while_statement",
        -- "declaration",
        "field",
        -- "identifier",
        -- "object",
        -- "statement",
      },
      max_depth = 6,
    },
    path = {
      preview = "previous",
    },
  },
  icons = {
    kinds = {
      symbols = icons.kinds,
    },
    ui = {
      bar = {
        separator = string.format(" %s ", icons.separators.angle_quote.right),
        extends = icons.misc.ellipse,
      },
    },
  },
  bar = {
    enable = enable,
    attach_events = {
      -- "OptionSet",
      "BufWinEnter",
      "BufWritePost",
      -- "FileType",
      "BufEnter",
      -- "TermEnter",
    },
    padding = {
      left = 0,
      right = 1,
    },
  },
  menu = {
    keymaps = {
      q = close,
      ["<Esc>"] = close,
    },
    quick_navigation = true,
    scrollbar = {
      background = false,
    },
  },
  fzf = {
    prompt = "%#GitSignsAdd# ",
    keymaps = {
      ["<C-j>"] = function()
        require("dropbar.api").fuzzy_find_navigate("down")
      end,
      ["<C-k>"] = function()
        require("dropbar.api").fuzzy_find_navigate("up")
      end,
    },
  },
})

---@diagnostic disable-next-line: duplicate-set-field
vim.ui.select = function(items, opts, on_choice)
  local title = opts.prompt
  if title then -- add padding
    if not vim.startswith(title, " ") then
      title = string.format(" %s", title)
    end
    if not vim.endswith(title, " ") then
      title = string.format("%s ", title)
    end
  end
  return require("dropbar.utils.menu").select(
    items,
    vim.tbl_deep_extend("force", opts, {
      prompt = title,
    }),
    on_choice
  )
end

-- vim.go.winbar = "%{%v:lua.dropbar()%}"
