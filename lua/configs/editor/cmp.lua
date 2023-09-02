---@diagnostic disable: missing-fields
local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  if col == 0 then
    return false
  end
  local str = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
  local curr_char = str:sub(col, col)
  local next_char = str:sub(col + 0, col + 1)
  -- local starting_spaces = #(str:match("^%s+") or "")
  return col ~= -1
    and curr_char:match("%s") == nil
    and next_char ~= '"'
    and next_char ~= "'"
    and next_char ~= "}"
    and next_char ~= ")"
    and next_char ~= "]"
end

local luasnip = require("luasnip")

local icons = willothy.icons

local format = {
  fields = { "kind", "abbr", "menu" },
  format = function(_, vim_item)
    local kind = vim_item.kind
    local icon = (icons.kinds[kind] or ""):gsub("%s+", "")
    vim_item.kind = " " .. icon
    vim_item.menu = kind
    local text = vim_item.abbr
    local max = math.floor(math.max(vim.o.columns / 4, 50))
    if vim.fn.strcharlen(text) > max then
      vim_item.abbr = vim.fn.strcharpart(text, -1, max - 1)
        .. icons.misc.ellipse
    end
    return vim_item
  end,
}

local opts = {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  experimental = {
    ghost_text = true,
  },
  -- window = {
  --   documentation = win_config,
  --   -- completion = win_config,
  -- },
  -- completion = {
  --   keyword_pattern="",
  --   keyword_length = 0,
  --   autocomplete = {
  --     "TextChanged",
  --     "InsertEnter",
  --   },
  -- },
  view = {
    entries = { name = "custom", selection_order = "near_cursor" },
  },
  sorting = {
    priority_weight = 10,
    comparators = {
      cmp.config.compare.scopes,
      cmp.config.compare.exact,
      cmp.config.compare.kind,
      cmp.config.compare.recently_used,
      cmp.config.compare.offset,
      cmp.config.compare.locality,
      require("clangd_extensions.cmp_scores"),
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  formatting = format,
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "copilot", max_item_count = 2 },
    { name = "luasnip", max_item_count = 4 },
    { name = "buffer", max_item_count = 4 },
    { name = "path", max_item_count = 4 },
  }),
  mapping = {
    ["<M-k>"] = cmp.mapping(
      cmp.mapping.select_prev_item(cmp_select),
      { "i", "c" }
    ),
    ["<M-j>"] = cmp.mapping(
      cmp.mapping.select_next_item(cmp_select),
      { "i", "c" }
    ),
    ["<M-Up>"] = cmp.mapping(cmp.mapping.select_prev_item(cmp.select)),
    ["<M-Down>"] = cmp.mapping(cmp.mapping.select_next_item(cmp.select)),
    ["<C-PageUp>"] = cmp.mapping(cmp.mapping.scroll_docs(-5), { "i", "c" }),
    ["<C-PageDown>"] = cmp.mapping(cmp.mapping.scroll_docs(5), { "i", "c" }),
    ["<C-Space>"] = cmp.mapping(function()
      cmp.complete()
    end),
    ["<C-e>"] = cmp.mapping(function()
      local suggestion = require("copilot.suggestion")
      if cmp.visible() then
        cmp.abort()
      elseif suggestion.is_visible() then
        suggestion.dismiss()
      end
    end, { "i", "c" }),
    ["<C-CR>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.confirm({ select = true })
      else
        fallback()
      end
    end, { "i", "c" }),
    -- ["<CR>"] = cmp.mapping(function(fallback) fallback() end, { "i", "c" }),
    ["<Tab>"] = cmp.mapping(function(_fallback)
      -- local suggestion = require("copilot.suggestion")
      -- if suggestion.is_visible() then
      --   suggestion.accept()
      -- else
      if cmp.visible() then
        cmp.confirm({ select = true })
        -- elseif luasnip.expand_or_jumpable() then
        -- 	luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        require("tabout").tabout()
        -- _fallback()
      end
    end, { "i", "c" }),
  },
}

require("copilot_cmp").setup()
cmp.setup(opts)

local pairs_cmp = require("nvim-autopairs.completion.cmp")
local ts_utils = require("nvim-treesitter.ts_utils")
local ts_node_func_parens_disabled = {
  -- don't create autopairs for
  -- `use crate::<function>`
  -- or
  -- `use crate::{ ..., <function> }`
  use_declaration = true,
  use_list = true,

  -- don't create autopairs for attribute macros (Rust)
  -- for example, there should not be autopairs after `test` in `#[test]`
  attribute_item = true,
  attribute = true,
  source_file = true,
}

local default_handler = pairs_cmp.filetypes["*"]["("].handler
pairs_cmp.filetypes["*"]["("].handler = function(
  char,
  item,
  bufnr,
  rules,
  commit_character
)
  local node = ts_utils.get_node_at_cursor()
  if node and ts_node_func_parens_disabled[node:type()] then
    if item.data then
      item.data.funcParensDisabled = true
    else
      char = ""
    end
  end
  default_handler(char, item, bufnr, rules, commit_character)
end

cmp.event:on("confirm_done", pairs_cmp.on_confirm_done())

cmp.setup.cmdline(":", {
  sources = cmp.config.sources({
    { name = "path", group_index = 0 },
    { name = "cmdline", group_index = 0 },
    { name = "copilot", group_index = 0 },
    { name = "cmdline_history", group_index = 1 },
  }),
  enabled = function()
    -- Set of disable commands
    local disabled = {
      IncRename = true,
    }
    -- get first word of cmdline
    local cmd = vim.fn.getcmdline():match("%S+")
    return (not disabled[cmd]) or cmp.close()
  end,
  formatting = format,
})

cmp.setup.filetype("harpoon", {
  sources = cmp.config.sources({
    { name = "path" },
  }),
  formatting = format,
  -- completion = {
  --   keyword_length = 0,
  -- },
  -- autocomplete = {
  --   "TextChanged",
  --   "InsertEnter",
  -- },
})

cmp.setup.filetype("gitcommit", {
  sources = {
    { name = "git" },
    { name = "commit" },
    { name = "path" },
  },
  formatting = format,
})

cmp.setup.cmdline({ "/", "?" }, {
  sources = cmp.config.sources({
    { name = "nvim_lsp_document_symbol" },
    { name = "buffer" },
  }),
  formatting = format,
})

require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
  sources = {
    { name = "dap" },
  },
  formatting = format,
})
