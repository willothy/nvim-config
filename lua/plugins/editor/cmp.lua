local function cmp_opt()
  local cmp = require("cmp")
  local cmp_select = { behavior = cmp.SelectBehavior.Select }

  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0
      and vim.api
          .nvim_buf_get_lines(0, line - 1, line, true)[1]
          :sub(col, col)
          :match("%s")
        == nil
  end

  local luasnip = require("luasnip")

  local icons = require("willothy.icons")

  return {
    snippet = {
      expand = function(args) luasnip.lsp_expand(args.body) end,
    },
    window = {
      documentation = cmp.config.window.bordered(),
      completion = cmp.config.window.bordered(),
    },
    view = {
      entries = { name = "custom", selection_order = "near_cursor" },
    },
    mapping = {
      ["<M-k>"] = cmp.mapping(
        cmp.mapping.select_prev_item(cmp_select),
        { "i", "c" }
      ),
      ["<M-j>"] = cmp.mapping(
        cmp.mapping.select_next_item(cmp_select),
        { "i", "c" }
      ),
      ["<M-Up>"] = cmp.mapping(
        cmp.mapping.select_prev_item(cmp.select),
        { "i", "c" }
      ),
      ["<M-Down>"] = cmp.mapping(
        cmp.mapping.select_next_item(cmp.select),
        { "i", "c" }
      ),
      ["<C-PageUp>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
      ["<C-PageDown>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
      ["<C-Space>"] = cmp.mapping({
        i = require("copilot.suggestion").next,
        c = cmp.complete,
      }),
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
      ["<CR>"] = cmp.mapping(function(fallback) fallback() end, { "i", "c" }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        local suggestion = require("copilot.suggestion")
        if suggestion.is_visible() then
          suggestion.accept()
        elseif cmp.visible() then
          cmp.confirm({ select = true })
        -- elseif luasnip.expand_or_jumpable() then
        -- 	luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "c" }),
    },
    sources = cmp.config.sources({
      { name = "nvim_lsp", priority = 1, max_item_count = 5, group_index = 1 },
      { name = "luasnip", priority = 2, max_item_count = 5, group_index = 1 },
      { name = "buffer", priority = 3, max_item_count = 5, group_index = 2 },
    }),
    formatting = {
      format = function(_entry, vim_item)
        vim_item.kind =
          string.format("%s%s", icons.kinds[vim_item.kind] or "", vim_item.kind)
        return vim_item
      end,
    },
  }
end

local function cmp_setup()
  local cmp = require("cmp")
  cmp.setup(cmp_opt())

  local ts_utils = require("nvim-treesitter.ts_utils")
  local pairs_cmp = require("nvim-autopairs.completion.cmp")
  local pairs = require("nvim-autopairs")
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
    local node_type = node:type()
    if ts_node_func_parens_disabled[node_type] then
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
      { name = "cmdline", group_index = 1 },
      { name = "async_path", group_index = 1 },
      { name = "cmdline_history", group_index = 2 },
      { name = "copilot", group_index = 2 },
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
  })

  cmp.setup.filetype("harpoon", {
    sources = cmp.config.sources({
      { name = "async_path" },
    }),
  })

  cmp.setup.filetype("gitcommit", {
    sources = {
      { name = "commit" },
      { name = "async_path" },
    },
  })

  cmp.setup.cmdline({ "/", "?" }, {
    sources = cmp.config.sources({
      { name = "nvim_lsp_document_symbol" },
      { name = "buffer" },
    }),
  })
end

local autopairs = {
  disable_filetype = { "TelescopePrompt" },
}

local copilot_opt = {
  suggestion = {
    enabled = true,
    auto_trigger = false,
    keymap = {},
  },
  panel = {},
}

return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      -- Icons
      "onsails/lspkind.nvim",

      -- Sources
      "hrsh7th/cmp-buffer",
      "FelipeLema/cmp-async-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
      "hrsh7th/cmp-calc",
      "Dosx001/cmp-commit",
      "dmitmel/cmp-cmdline-history",
      "saadparwaiz1/cmp_luasnip",

      -- Copilot
      "zbirenbaum/copilot.lua",

      -- Snippets
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",

      -- Autopairs
      "windwp/nvim-autopairs",
    },
    lazy = true,
    event = "InsertEnter",
    config = cmp_setup,
  },
  {
    "windwp/nvim-autopairs",
    lazy = true,
    opts = autopairs,
  },
  {
    "windwp/nvim-ts-autotag",
    config = true,
  },
  {
    "zbirenbaum/copilot.lua",
    lazy = true,
    opts = copilot_opt,
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = {
      "zbirenbaum/copilot.lua",
      "hrsh7th/nvim-cmp",
    },
    lazy = true,
    config = true,
  },
  {
    "kylechui/nvim-surround",
    opts = {
      keymaps = {
        insert = false,
        insert_line = false,
        normal = false,
        normal_cur = false,
        normal_line = false,
        normal_cur_line = false,
        visual = "S",
        visual_line = false,
        delete = "dS",
        change = "cS",
      },
    },
  },
}
