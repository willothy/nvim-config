local icons = require("willothy.icons")

local function config()
  local dropbar = require("dropbar")

  local opts = {
    general = {
      enable = function(buf, win)
        return not vim.api.nvim_win_get_config(win).zindex
          and vim.bo[buf].buftype == ""
          and vim.api.nvim_buf_get_name(buf) ~= ""
          and vim.bo[buf].filetype ~= "Trouble"
          and vim.bo[buf].filetype ~= "toggleterm"
          and not vim.wo[win].diff
      end,
    },
    icons = {
      kinds = icons.kinds,
      ui = {
        bar = {
          separator = " %#NormalNC#"
            .. icons.separators.angle_quote.right
            .. " ",
          extends = " %#NormalNC#…",
        },
      },
    },
    bar = {
      truncate = false,
      padding = {
        left = 0,
        right = 1,
      },
      sources = function(_buf, _win)
        local sources = require("dropbar.sources")
        return {
          sources.path,
          {
            get_symbols = function(buf, win, cursor)
              if vim.bo[buf].ft == "markdown" then
                return sources.markdown.get_symbols(buf, win, cursor)
              end
              for _, source in ipairs({
                sources.lsp,
                sources.treesitter,
              }) do
                local symbols = source.get_symbols(buf, win, cursor)
                if not vim.tbl_isempty(symbols) then return symbols end
              end
              return {}
            end,
          },
        }
      end,
    },
    menu = {
      keymaps = {
        q = function()
          local api = require("dropbar.api")
          local m = api.get_current_dropbar_menu()
          if not m then return end
          m:close()
        end,
        ["<Esc>"] = function()
          local api = require("dropbar.api")
          local m = api.get_current_dropbar_menu()
          if not m then return end
          m:close()
        end,
        ["<LeftMouse>"] = function()
          local api = require("dropbar.api")
          local m = api.get_current_dropbar_menu()
          if not m then return end
          local mouse = vim.fn.getmousepos()
          if mouse.winid ~= m.win then
            local parent_menu = api.get_dropbar_menu(mouse.winid)
            if parent_menu and parent_menu.sub_menu then
              parent_menu.sub_menu:close()
            end
            if vim.api.nvim_win_is_valid(mouse.winid) then
              vim.api.nvim_set_current_win(mouse.winid)
            end
            return
          end
          m:click_at({ mouse.line, mouse.column }, nil, 1, "l")
        end,
        ["<CR>"] = function()
          local m = require("dropbar.api").get_current_dropbar_menu()
          if not m then return end
          local cursor = vim.api.nvim_win_get_cursor(m.win)
          local component = m.entries[cursor[1]]:first_clickable(cursor[2])
          if component then m:click_on(component, nil, 1, "l") end
        end,
      },
    },
  }

  dropbar.setup(opts)
end

return {
  {
    "Bekaboo/dropbar.nvim",
    config = config,
  },
}
