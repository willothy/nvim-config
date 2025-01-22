require("crates").setup({
  completion = {
    cmp = {
      enabled = true,
    },
    crates = {
      enabled = true,
    },
  },
  -- lsp = {
  --   enabled = true,
  --   actions = true,
  --   completion = true,
  --   hover = true,
  -- },
})

---VSCode-like smart indent.
---
---@param cmp blink.cmp.API
---@return boolean | nil
local function smart_indent(cmp)
  if cmp.snippet_active() then
    return cmp.accept()
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local ok, indent = pcall(require("nvim-treesitter.indent").get_indent, row)
  if not ok then
    indent = 0
  end

  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
  if cmp.is_visible() then
    return cmp.select_and_accept()
  elseif col < indent and line:sub(1, col):gsub("^%s+", "") == "" then
    -- smart indent like VSCode - indent to the correct level when
    -- pressing tab at the beginning of a line.

    vim.schedule(function()
      vim.api.nvim_buf_set_lines(0, row - 1, row, true, {
        string.rep(" ", indent or 0) .. line:sub(col),
      })

      vim.api.nvim_win_set_cursor(0, { row, math.max(0, indent) })
    end)

    return true
  elseif col >= indent then
    vim.schedule(require("tabout").taboutMulti)
    return true
  end
end

---IntelliJ-like smart backspace
---
---@param cmp blink.cmp.API
---@return boolean | nil
local function smart_backspace(cmp)
  -- TODO: check if we are trying to de-indent at the end of a block or the end of a comment.
  --
  -- allow deleting (maybe even quick-delete) the beginning of the line in those cases.
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  if row == 1 and col == 0 then
    return
  end

  if cmp.is_visible() then
    cmp.hide()
  end

  local ts = require("nvim-treesitter.indent")
  local ok, indent = pcall(ts.get_indent, row)
  if not ok then
    indent = 0
  end

  local line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
  if
    vim.fn.strcharpart(line, indent - 1, col - indent + 1):gsub("%s+", "")
    ~= ""
  then
    return
  end

  if indent > 0 and col > indent then
    local new_line = vim.fn.strcharpart(line, 0, indent)
      .. vim.fn.strcharpart(line, col)
    vim.schedule(function()
      vim.api.nvim_buf_set_lines(0, row - 1, row, true, {
        new_line,
      })
      vim.api.nvim_win_set_cursor(
        0,
        { row, math.min(indent or 0, vim.fn.strcharlen(new_line)) }
      )
    end)
    return true
  elseif row > 1 and (indent > 0 and col + 1 > indent) then
    local prev_line = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, true)[1]
    if vim.trim(prev_line) == "" then
      local prev_indent = ts.get_indent(row - 1) or 0
      local new_line = vim.fn.strcharpart(line, 0, prev_indent)
        .. vim.fn.strcharpart(line, col)
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(0, row - 2, row, true, {
          new_line,
        })

        vim.api.nvim_win_set_cursor(0, {
          row - 1,
          math.max(0, math.min(prev_indent, vim.fn.strcharlen(new_line))),
        })
      end)
      return true
    else
      local len = vim.fn.strcharlen(prev_line)
      local new_line = prev_line .. vim.fn.strcharpart(line, col)
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(0, row - 2, row, true, {
          new_line,
        })
        vim.api.nvim_win_set_cursor(0, { row - 1, math.max(0, len) })
      end)
      return true
    end
  end
end

require("blink.cmp").setup({
  keymap = {
    ["<C-h>"] = {
      "show",
      "show_documentation",
      "hide_documentation",
    },
    ["<C-space>"] = {
      "show",
      "show_documentation",
      "hide_documentation",
    },
    ["<C-e>"] = { "hide", "fallback" },

    ["<Tab>"] = {
      smart_indent,
      "snippet_forward",
      "fallback",
    },
    ["<S-Tab>"] = {
      function(cmp)
        if cmp.snippet_active({ direction = -1 }) then
          return false
        end

        vim.schedule(require("tabout").taboutBackMulti)
        return true
      end,
      "snippet_backward",
      "fallback",
    },

    ["<BS>"] = {
      smart_backspace,
      "fallback",
    },

    ["<Up>"] = { "select_prev", "fallback" },
    ["<Down>"] = { "select_next", "fallback" },
    ["<C-p>"] = { "select_prev", "fallback" },
    ["<C-n>"] = { "select_next", "fallback" },

    ["<C-u>"] = { "scroll_documentation_up", "fallback" },
    ["<C-d>"] = { "scroll_documentation_down", "fallback" },

    cmdline = {
      preset = "super-tab",
      ["<Up>"] = { "fallback" },
      ["<Down>"] = { "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback" },
    },
  },
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = "normal",
    kind_icons = willothy.ui.icons.kinds,
  },
  sources = {
    default = {
      "lsp",
      "path",
      "copilot",
      "snippets",
      "buffer",
    },
    per_filetype = {
      toml = {
        "crates",
        "lsp",
        "path",
        "copilot",
        "snippets",
        "buffer",
      },
      lua = {
        "lazydev",
        "lsp",
        "path",
        "copilot",
        "snippets",
        "buffer",
      },
    },
    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
        fallbacks = { "lsp" },
      },
      copilot = {
        name = "copilot",
        module = "blink-cmp-copilot",
        score_offset = 100,
        async = true,
      },
      crates = {
        name = "crates",
        module = "blink.compat.source",
        score_offset = 100,
        -- async = true,
      },
    },
  },
  completion = {
    -- trigger = {},
    -- list = {},
    -- accept = {},

    menu = {
      draw = {
        treesitter = { "lsp", "copilot" },
        padding = 1,
        gap = 1,
        columns = {
          { "kind_icon" },
          { "label", gap = 1 },
          { "kind" },
        },
        components = {
          kind_icon = {
            ellipsis = false,
            text = function(ctx)
              if ctx.item.source_name == "copilot" then
                return willothy.ui.icons.kinds.Copilot
              end
              return ctx.kind_icon
            end,
            highlight = function(ctx)
              if ctx.item.source_name == "copilot" then
                return "BlinkCmpKindCopilot"
              end
              return "BlinkCmpKind" .. ctx.kind
            end,
          },

          kind = {
            ellipsis = false,
            text = function(ctx)
              if ctx.item.source_name == "copilot" then
                local name = ctx.item.source_name
                return name:sub(1, 1):upper() .. name:sub(2) .. " "
              end
              return ctx.kind .. " "
            end,
            highlight = function(ctx)
              if ctx.item.source_name == "copilot" then
                return "BlinkCmpKindCopilot"
              end
              return "BlinkCmpKind" .. ctx.kind
            end,
          },

          label = {
            width = { fill = true, max = 60 },
            text = function(ctx)
              return ctx.label .. (ctx.label_detail or "")
            end,
          },
        },
      },
    },

    documentation = {
      auto_show = true,
      auto_show_delay_ms = 50,
    },

    ghost_text = {
      enabled = true,
    },
  },
  signature = {
    enabled = false,
  },
})

---@diagnostic disable-next-line: missing-fields
require("tabout").setup({
  tabkey = "",
  backwards_tabkey = "",
  -- completion = true,
  -- act_as_shift_tab = true,
})
