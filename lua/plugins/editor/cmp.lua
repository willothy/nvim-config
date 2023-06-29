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
      ["<CR>"] = cmp.mapping(function(fallback)
        fallback()
        -- if cmp.visible() then
        -- 	if cmp.get_selected_entry() == nil then
        -- 		fallback()
        -- 	else
        -- 		cmp.confirm({ select = false })
        -- 	end
        -- elseif luasnip.expand_or_jumpable() then
        -- 	luasnip.expand_or_jump()
        -- else
        -- 	fallback()
        -- end
      end, { "i", "c" }),
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
      -- { name = "nvim_lsp_signature_help", priority = 1, max_item_count = 1 },
      { name = "nvim_lsp", priority = 1, max_item_count = 20 },
      { name = "nvim_lua", priority = 2, max_item_count = 10 },
      { name = "luasnip", priority = 2, max_item_count = 2 },
      { name = "async_path", priority = 2, max_item_count = 8 },
      { name = "nerdfont", priority = 3, max_item_count = 8 },
      { name = "calc", priority = 3, max_item_count = 8 },
      {
        name = "dictionary",
        priority = 2,
        max_item_count = 5,
        keyword_length = 2,
      },
    }),
    formatting = {
      format = function(_entry, vim_item)
        vim_item.kind =
          string.format("%s %s", icons[vim_item.kind], vim_item.kind)
        return vim_item
      end,
    },
  }
end

local function cmp_setup()
  local cmp = require("cmp")
  cmp.setup(cmp_opt())
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

  -- Setup crates
  --require("crates").setup()
  -- vim.api.nvim_create_autocmd("BufRead", {
  --     group = vim.api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
  --     pattern = "Cargo.toml",
  --     callback = function()
  --         cmp.setup.buffer({ sources = { { name = "crates" } } })
  --     end,
  -- })

  local function words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    local words = vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]
    return col ~= 0 and words:sub(col, col):match("%s") == nil, words
  end

  cmp.setup.cmdline(":", {
    sources = cmp.config.sources({
      { name = "async_path", group_index = 1 },
      { name = "cmdline", group_index = 1 },
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
      return not disabled[cmd] or cmp.close()
    end,
  })

  cmp.setup.cmdline("harpoon", {
    sources = cmp.config.sources({
      { name = "async_path" },
    }),
  })

  cmp.setup.cmdline({ "/", "?" }, {
    sources = cmp.config.sources({
      { name = "nvim_lsp_document_symbol" },
      { name = "cmdline_history" },
    }),
  })

  cmp.setup.cmdline("gitcommit", {
    sources = {
      { name = "commit" },
      { name = "async_path" },
    },
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

local function copilot_init() end

return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      -- Icons
      "onsails/lspkind.nvim",

      -- Sources
      "hrsh7th/cmp-buffer",
      -- "hrsh7th/cmp-path",
      "FelipeLema/cmp-async-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      -- "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lsp-document-symbol",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-calc",
      "Dosx001/cmp-commit",
      "dmitmel/cmp-cmdline-history",
      "chrisgrieser/cmp-nerdfont",
      "saadparwaiz1/cmp_luasnip",
      -- "uga-rosa/cmp-dictionary",

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
}
