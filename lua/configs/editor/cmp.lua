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

local main_sources = cmp.config.sources({
  { name = "nvim_lsp", max_item_count = 40 },
  { name = "copilot", max_item_count = 2 },
  { name = "buffer", max_item_count = 4 },
  { name = "path" },
})

local enabled = true
local main_enabled = true
vim.api.nvim_create_user_command("CmpToggle", function(args)
  if args.bang then
    main_enabled = not main_enabled
    if main_enabled then
      cmp.setup({
        sources = main_sources,
      })
    else
      cmp.setup({
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
        }),
      })
    end
  else
    enabled = not enabled
    cmp.setup({
      enabled = enabled,
    })
  end
end, {
  bang = true,
})

local opts = {
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
  experimental = {
    ghost_text = true,
  },
  view = {
    entries = { name = "custom", selection_order = "near_cursor" },
  },
  sorting = {
    priority_weight = 10,
    comparators = {
      cmp.config.compare.exact,
      cmp.config.compare.scopes,
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
  sources = main_sources,
  mapping = {
    ["<M-k>"] = cmp.mapping(
      cmp.mapping.select_prev_item(cmp_select),
      { "i", "c" }
    ),
    ["<c-a>"] = cmp.mapping.complete({
      config = {
        sources = {
          { name = "cody" },
        },
      },
    }),
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
    end, { "i", "c" }),
    ["<C-e>"] = cmp.mapping(function()
      local suggestion = require("copilot.suggestion")
      if vim.snippet.active() then
        vim.snippet.exit()
      end
      if cmp.visible() then
        cmp.abort()
      elseif suggestion.is_visible() then
        suggestion.dismiss()
      end
    end, { "i", "c" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() and not vim.snippet.active() then
        cmp.select_prev_item()
      elseif vim.snippet.jumpable(-1) then
        vim.snippet.jump(-1)
      else
        fallback()
      end
    end, { "i", "c" }),
    ["<Tab>"] = cmp.mapping(function(_fallback)
      if cmp.visible() and not vim.snippet.active() then
        cmp.confirm({ select = true })
      elseif vim.snippet.jumpable(1) then
        vim.snippet.jump(1)
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
    { name = "cmdline", group_index = 0 },
    { name = "path", group_index = 0 },
    { name = "copilot", group_index = 0 },
    { name = "cmdline_history", group_index = 1 },
  }),
  sorting = {
    priority_weight = 10,
    comparators = {
      cmp.config.compare.kind,
      cmp.config.compare.recently_used,
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
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

require("cmp").setup.filetype("OverseerForm", {
  sources = {
    { name = "overseer" },
  },
})
