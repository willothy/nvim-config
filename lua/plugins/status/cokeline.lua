local icons = require("willothy.icons")
local ns = vim.api.nvim_create_namespace("cokeline_diagnostics")

local function cokeline()
  local p = require("minimus.palette").hex
  local mappings = require("cokeline.mappings")
  local get_hex = require("cokeline.utils").get_hex

  local separators = {
    left = icons.blocks.left[4],
    right = icons.blocks.left[4],
  }

  local close_icon_normal = icons.actions.close
  local close_icon_hovered = icons.actions.close_box

  local components = {
    space = {
      text = " ",
      truncation = { priority = 1 },
    },
    space_if_not_focused = {
      text = function(buffer)
        if not buffer.is_focused then
          return " "
        else
          return ""
        end
      end,
      truncation = { priority = 1 },
    },
    sep = {
      left = {
        text = separators.left,
        fg = function(buffer)
          if buffer.is_focused then
            return get_hex("TabLineSel", "bg")
          else
            return get_hex("Comment", "fg")
          end
        end,
        bg = "TabLine",
      },
      right = {
        text = function(buffer)
          if buffer.is_last then
            return separators.right
          else
            return ""
          end
        end,
        fg = p.raisin_black,
        bg = "none",
      },
    },
    separator = function(side)
      return {
        text = function(buffer)
          if
            side == "left"--[[  and (buffer.is_focused or buffer.is_first) ]]
          then
            return separators.left
          elseif side == "right" and (buffer.is_focused or buffer.is_last) then
            return separators.right
          else
            return ""
          end
        end,
        fg = function(buffer)
          if buffer.is_focused then
            return get_hex("TabLineSel", "bg")
          else
            return get_hex("Comment", "fg")
          end
        end,
        bg = function(buffer)
          if
            (
              side == "left"
              and buffer.is_first
              and #require("cokeline.sidebar").get_components() == 0
            )
            or (side == "right" and buffer.is_last)
            or (
              side == "right"
              and #require("cokeline.buffers").get_visible() == 1
            )
          then
            return "TabLine"
          else
            return "TabLine"
          end
        end,
        truncation = { priority = 1 },
      }
    end,
    two_spaces = {
      text = "  ",
      truncation = { priority = 1 },
    },
    devicon = {
      text = function(buffer)
        if mappings.is_picking_focus() or mappings.is_picking_close() then
          return buffer.pick_letter .. " "
        end
        return buffer.devicon.icon
      end,
      fg = function(buffer)
        -- return buffer.is_focused and "TabLineSel"
        return (mappings.is_picking_focus() and "DiagnosticWarn")
          or (mappings.is_picking_close() and "DiagnosticError")
          or buffer.devicon.color
      end,
      style = function(_)
        return (mappings.is_picking_focus() or mappings.is_picking_close())
            and "italic,bold"
          or nil
      end,
      truncation = { priority = 1 },
    },
    index = {
      text = function(buffer) return buffer.index .. ": " end,
      truncation = { priority = 1 },
    },
    unique_prefix = {
      text = function(buffer) return buffer.unique_prefix end,
      fg = function(buffer)
        if buffer.is_focused then
          return "TabLineSel"
        else
          return "TabLine"
        end
      end,
      truncation = {
        priority = 3,
        direction = "left",
      },
    },
    filename = {
      text = function(buffer) return buffer.filename end,
      style = function(buffer)
        if buffer.is_focused then return "bold" end
        if buffer.is_hovered then return "underline" end
        return nil
      end,
      fg = function(buffer)
        --[[ if buffer.is_focused then
          return "TabLine"
        else ]]
        if buffer.diagnostics.errors ~= 0 then
          return "DiagnosticError"
        elseif buffer.diagnostics.warnings ~= 0 then
          return "DiagnosticWarn"
        elseif buffer.diagnostics.infos ~= 0 then
          return "DiagnosticInfo"
        else
          return "TabLine"
        end
      end,
      bg = "TabLine",
      truncation = {
        priority = 2,
        direction = "left",
      },
    },
    diagnostics = (function()
      local Popup = require("nui.popup")

      local popup = Popup({
        enter = false,
        focusable = false,
        border = {
          style = "rounded",
        },
        position = {
          row = 1,
          col = 0,
        },
        relative = "editor",
        size = {
          width = 20,
          height = 1,
        },
      })

      return {
        text = function(buffer)
          return (
            buffer.diagnostics.errors ~= 0
            and icons.diagnostics.errors .. " " .. buffer.diagnostics.errors
          )
            or (buffer.diagnostics.warnings ~= 0 and icons.diagnostics.warnings .. " " .. buffer.diagnostics.warnings)
            or ""
        end,
        fg = function(buffer)
          return (buffer.diagnostics.errors ~= 0 and "DiagnosticError")
            or (buffer.diagnostics.warnings ~= 0 and "DiagnosticWarn")
            or nil
        end,
        bg = "TabLine",
        truncation = { priority = 1 },
        on_click = function(_id, _clicks, _button, _modifiers, buffer)
          local trouble = require("trouble")
          if buffer.is_focused then
            trouble.toggle()
          elseif trouble.is_open() then
            if vim.bo.filetype == "Trouble" then
              buffer:focus()
              trouble.close()
            else
              buffer:focus()
            end
          else
            buffer:focus()
            trouble.open()
          end
        end,
        on_mouse_enter = function(buffer, mouse_col)
          local text = {}
          local width = 0
          if buffer.diagnostics.errors > 0 then
            table.insert(text, {
              icons.diagnostics.errors
                .. " "
                .. buffer.diagnostics.errors
                .. " ",
              "DiagnosticSignError",
            })
            width = width + #tostring(buffer.diagnostics.errors) + 3
          end
          if buffer.diagnostics.warnings > 0 then
            table.insert(text, {
              icons.diagnostics.warnings
                .. " "
                .. buffer.diagnostics.warnings
                .. " ",
              "DiagnosticSignWarn",
            })
            width = width + #tostring(buffer.diagnostics.warnings) + 3
          end
          if buffer.diagnostics.infos > 0 then
            table.insert(text, {
              icons.diagnostics.info .. " " .. buffer.diagnostics.infos .. " ",
              "DiagnosticSignInfo",
            })
            width = width + #tostring(buffer.diagnostics.infos) + 3
          end
          if buffer.diagnostics.hints > 0 then
            table.insert(text, {
              icons.diagnostics.hints .. " " .. buffer.diagnostics.hints .. " ",
              "DiagnosticSignHint",
            })
            width = width + #tostring(buffer.diagnostics.hints) + 3
          end
          popup.win_config.width = width
          popup.win_config.col = mouse_col - 1
          popup:mount()
          if not popup.bufnr then return end
          vim.api.nvim_buf_set_extmark(popup.bufnr, ns, 0, 0, {
            id = 1,
            virt_text = text,
            virt_text_pos = "overlay",
          })
        end,
        on_mouse_leave = function() popup:unmount() end,
      }
    end)(),
    close_or_unsaved = {
      text = function(buffer)
        if buffer.is_hovered then
          return buffer.is_modified and icons.misc.modified
            or (close_icon_hovered .. " ")
        else
          return buffer.is_modified and icons.misc.modified
            or (close_icon_normal .. " ") -- icons.actions.close
        end
      end,
      fg = "TabLine",
      style = "bold",
      truncation = { priority = 1 },
      on_click = function(_id, _clicks, _button, _modifiers, buffer)
        buffer:delete()
      end,
    },
    padding = {
      text = function(buffer) return buffer.is_last and " " or "" end,
      bg = "TabLineFill",
      fg = "none",
    },
    front_padding = {
      text = function(buffer) return buffer.is_focused and "" or " " end,
    },
    clock = {
      text = function(cx)
        return icons.misc.datetime
          .. (cx.is_hovered and os.date("%a %b %d") or os.date("%I:%M"))
      end,
      bg = "none",
      fg = p.blue,
    },
    run = {
      text = function() return string.format(" %s ", icons.dap.start) end,
      bg = "TabLineFill",
      fg = function(cx) return cx.is_hovered and p.lemon_chiffon or p.blue end,
      on_click = function(_id, _clicks, button, _modifiers, _buffer)
        if button == "l" then
          require("dapui").toggle()
        else
          vim.cmd("Greyjoy")
        end
      end,
    },
  }

  return {
    show_if_buffers_are_at_least = 1,
    buffers = {
      focus_on_delete = "next",
      new_buffers_position = "next",
      delete_on_right_click = false,
    },
    fill_hl = "TabLineFill",
    pick = {
      use_filename = false,
    },
    default_hl = {
      fg = function(buffer)
        return buffer.is_focused and "TabLineSel" or "TabLine"
      end,
      bg = function(buffer) return buffer.is_focused and "TabLine" or "TabLine" end,
    },
    components = {
      components.sep.left,
      -- components.separator("left"),
      components.space,
      -- components.space_if_not_focused,
      components.devicon,
      components.unique_prefix,
      components.filename,
      components.space,
      components.diagnostics,
      components.two_spaces,
      components.close_or_unsaved,
      components.space,
      -- components.space_if_not_focused,
      -- components.separator("right"),
      components.sep.right,
      components.padding,
    },
    rhs = {
      components.run,
      -- components.clock,
    },
    mappings = {
      disable_mouse = false,
    },
    tabs = {
      placement = "left",
      components = (function(hovered)
        return {
          {
            text = separators.left,
            fg = function(tab)
              return ((hovered and hovered == tab.number) or tab.is_active)
                  and get_hex("TabLineSel", "bg")
                or get_hex("Comment", "fg")
            end,
            bg = function(tab)
              return (hovered and hovered == tab.number) and "TabLineSel"
                or "TabLine"
            end,
            on_mouse_enter = function(tab) hovered = tab.number end,
            on_mouse_leave = function() hovered = false end,
          },
          {
            text = function(tab) return string.format(" %s ", tab.number) end,
            fg = function(tab)
              return (hovered and hovered == tab.number) and "TabLineSel"
                or "TabLine"
            end,
            bg = function(tab)
              return (hovered and hovered == tab.number) and "TabLineSel"
                or "TabLine"
            end,
            on_mouse_enter = function(tab) hovered = tab.number end,
            on_mouse_leave = function() hovered = false end,
          },
        }
      end)(),
    },
    sidebar = {
      filetype = { "SidebarNvim", "neo-tree", "edgy", "aerial" },
      components = {
        {
          text = icons.separators.circle.left,
          fg = p.gunmetal,
          bg = "none",
        },
        {
          text = " ",
          bg = function(cx) return cx.is_hovered and "TabLineSel" or "TabLine" end,
        },
      },
    },
  }
end

-- 
-- 

return {
  {
    "willothy/nvim-cokeline",
    -- dir = "~/projects/lua/cokeline/",
    branch = "dev",
    config = function() require("cokeline").setup(cokeline()) end,
    lazy = true,
    event = "VeryLazy",
  },
}
