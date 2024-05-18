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

local icons = willothy.ui.icons

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

local comparators = require("cmp.config.compare")

local opts = {
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body)
    end,
  },
  completion = {
    completeopt = "menu,menuone,noselect",
    autocomplete = {
      "TextChanged",
      "TextChangedI",
      "TextChangedT",
    },
  },
  experimental = {
    ghost_text = true,
  },
  view = {
    entries = {
      name = "custom",
      selection_order = "bottom_up",
    },
  },
  sorting = {
    priority_weight = 10,
    comparators = {
      comparators.offset,
      comparators.scopes,
      comparators.exact,
      comparators.score,
      require("clangd_extensions.cmp_scores"),
      comparators.recently_used,
      -- comparators.locality,
      comparators.kind,
      comparators.length,
      comparators.order,
    },
  },
  formatting = format,
  sources = cmp.config.sources({
    { name = "nvim_px_to_rem" },
    { name = "copilot", max_item_count = 1 },
    { name = "snippets" },
    {
      name = "nvim_lsp" --[[ , max_item_count = 40 ]],
    },
    { name = "buffer", max_item_count = 4 },
    { name = "path" },
  }),
  mapping = {
    ["<M-k>"] = cmp.mapping(
      cmp.mapping.select_prev_item(cmp_select),
      { "i", "c", "t" }
    ),
    ["<M-j>"] = cmp.mapping(
      cmp.mapping.select_next_item(cmp_select),
      { "i", "c", "t" }
    ),
    ["<M-Up>"] = cmp.mapping(cmp.mapping.select_prev_item(cmp.select)),
    ["<M-Down>"] = cmp.mapping(cmp.mapping.select_next_item(cmp.select)),
    ["<C-PageUp>"] = cmp.mapping(cmp.mapping.scroll_docs(-5), { "i", "c" }),
    ["<C-PageDown>"] = cmp.mapping(cmp.mapping.scroll_docs(5), { "i", "c" }),
    ["<C-Space>"] = cmp.mapping(function()
      cmp.complete()
    end, { "i", "c", "t" }),
    ["<C-e>"] = cmp.mapping(function()
      local suggestion = require("copilot.suggestion")
      if vim.snippet.active() then
        vim.snippet.stop()
      end
      if cmp.visible() then
        cmp.abort()
      elseif suggestion.is_visible() then
        suggestion.dismiss()
      end
    end, { "i", "c" }),
    ["<C-n>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end),
    ["<C-p>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() and not vim.snippet.active({ direction = -1 }) then
        cmp.select_prev_item()
      elseif vim.snippet.active({ direction = -1 }) then
        vim.snippet.jump(-1)
      else
        fallback()
      end
    end, { "i", "c" }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))

      if vim.api.nvim_get_mode().mode == "t" then
        if cmp.visible() then
          cmp.confirm({ select = true })
        else
          fallback()
        end
        return
      end

      local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
      local ts = require("nvim-treesitter.indent")
      local ok, indent = pcall(ts.get_indent, row)
      if not ok then
        indent = 0
      end

      if cmp.visible() and not vim.snippet.active({ direction = 1 }) then
        cmp.confirm({ select = true })
      elseif vim.snippet.active({ direction = 1 }) then
        vim.snippet.jump(1)
      elseif has_words_before() then
        cmp.complete()
      elseif col < indent and line:sub(1, col):gsub("^%s+", "") == "" then
        -- smart indent like VSCode - indent to the correct level when
        -- pressing tab at the beginning of a line.

        vim.api.nvim_buf_set_lines(0, row - 1, row, true, {
          string.rep(" ", indent or 0) .. line:sub(col),
        })

        vim.api.nvim_win_set_cursor(0, { row, math.max(0, indent) })

        local client =
          vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })[1]
        local ctx = {}
        ctx.client_id = client.id
        ctx.bufnr = vim.api.nvim_get_current_buf()

        vim.lsp.inlay_hint.on_refresh(nil, nil, ctx, nil)
      elseif col >= indent then
        require("tabout").tabout()
      else
        fallback()
      end
    end, { "i", "c", "t" }),
    -- ["<BS>"] = cmp.mapping(function(fallback)
    --   -- TODO: check if we are trying to de-indent at the end of a block or the end of a comment.
    --   --
    --   -- allow deleting (maybe even quick-delete) the beginning of the line in those cases.
    --   local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    --
    --   if row == 1 and col == 0 then
    --     return
    --   end
    --
    --   if cmp.visible() then
    --     cmp.close()
    --   end
    --
    --   local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
    --
    --   local ts = require("nvim-treesitter.indent")
    --   local ok, indent = pcall(ts.get_indent, row)
    --   if not ok then
    --     indent = 0
    --   end
    --
    --   if
    --     vim.fn.strcharpart(line, indent - 1, col - indent + 1):gsub("%s+", "")
    --     == ""
    --   then
    --     if indent > 0 and col > indent then
    --       local new_line = vim.fn.strcharpart(line, 0, indent)
    --         .. vim.fn.strcharpart(line, col)
    --       vim.api.nvim_buf_set_lines(0, row - 1, row, true, {
    --         new_line,
    --       })
    --       vim.api.nvim_win_set_cursor(
    --         0,
    --         { row, math.min(indent or 0, vim.fn.strcharlen(new_line)) }
    --       )
    --     elseif row > 1 and (indent > 0 and col + 1 > indent) then
    --       local prev_line =
    --         vim.api.nvim_buf_get_lines(0, row - 2, row - 1, true)[1]
    --       if vim.trim(prev_line) == "" then
    --         local prev_indent = ts.get_indent(row - 1) or 0
    --         local new_line = vim.fn.strcharpart(line, 0, prev_indent)
    --           .. vim.fn.strcharpart(line, col)
    --         vim.api.nvim_buf_set_lines(0, row - 2, row, true, {
    --           new_line,
    --         })
    --
    --         vim.api.nvim_win_set_cursor(0, {
    --           row - 1,
    --           math.max(0, math.min(prev_indent, vim.fn.strcharlen(new_line))),
    --         })
    --       else
    --         local len = vim.fn.strcharlen(prev_line)
    --         local new_line = prev_line .. vim.fn.strcharpart(line, col)
    --         vim.api.nvim_buf_set_lines(0, row - 2, row, true, {
    --           new_line,
    --         })
    --         vim.api.nvim_win_set_cursor(0, { row - 1, math.max(0, len) })
    --       end
    --     else
    --       fallback()
    --     end
    --   else
    --     fallback()
    --   end
    -- end, { "i" }),
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
    if
      vim.api.nvim_get_option_value("buftype", {
        buf = 0,
      }) == "prompt"
    then
      return false
    end
    if vim.fn.reg_recording() ~= "" then
      return false
    end
    if vim.fn.reg_executing() ~= "" then
      return false
    end

    -- get first word of cmdline
    local cmd = vim.fn.getcmdline():match("%S+")
    return disabled[cmd] == nil
  end,
  formatting = format,
})

cmp.setup.filetype("harpoon", {
  sources = cmp.config.sources({
    { name = "path" },
  }),
  formatting = format,
})

-- cmp.setup.filetype("terminal", {
--   sources = cmp.config.sources({
--     { name = "cody" },
--     { name = "copilot" },
--     { name = "path" },
--     { name = "buffer" },
--   }),
--   formatting = format,
-- })

cmp.setup.filetype("gitcommit", {
  sources = {
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

require("cmp").setup.filetype("norg", {
  sources = {
    { name = "neorg" },
    { name = "copilot", max_item_count = 2 },
    { name = "cody" },
    { name = "buffer", max_item_count = 4 },
    { name = "path" },
  },
})

require("cmp").setup.filetype("markdown", {
  sources = {
    { name = "otter" },
    { name = "copilot", max_item_count = 2 },
    { name = "cody" },
    { name = "buffer", max_item_count = 4 },
    { name = "path" },
  },
})
