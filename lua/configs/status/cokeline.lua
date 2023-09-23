local icons = willothy.icons
local ns = vim.api.nvim_create_namespace("cokeline_diagnostics")

local p = require("minimus").hex
local mappings = require("cokeline.mappings")

local separators = {
  left = icons.blocks.left[4],
  right = icons.blocks.left[4],
}

local close_icon_normal = icons.actions.close
local close_icon_hovered = icons.actions.close_box

local SidebarOpen = {
  text = function(buffer)
    local open = require("cokeline.sidebar").get_win("left") and true or false
    if (open and buffer.is_readonly) or (buffer.is_first and not open) then
      return string.format(" %s ", open and "󰨂" or "󰨃")
    end
    return ""
  end,
  fg = function(cx)
    return cx.is_hovered and "TabLineSel" or "TabLine"
  end,
  bg = function(cx)
    return cx.is_hovered and "TabLineSel" or "TabLine"
  end,
  on_click = function()
    require("edgy").toggle("left")
  end,
}
local Space = {
  text = " ",
  truncation = { priority = 1 },
}

local Separator = {
  left = {
    text = separators.left,
    fg = function(cx)
      if cx.is_focused or cx.buf_hovered or cx.tab_hovered then
        return require("cokeline.hlgroups").get_hl_attr("TabLineSel", "bg")
      else
        return "Comment"
      end
    end,
    bg = function(cx)
      return (cx.buf_hovered or cx.tab_hovered) and "TabLineSel" or "TabLine"
    end,
  },
  right = {
    text = function(buffer)
      if buffer.is_last then
        return separators.right
      else
        return ""
      end
    end,
    fg = "TabLine",
    bg = "none",
  },
}

local Devicon = {
  text = function(buffer)
    if mappings.is_picking_focus() or mappings.is_picking_close() then
      return buffer.pick_letter .. " "
    end
    return buffer.devicon.icon
  end,
  fg = function(buffer)
    return (mappings.is_picking_focus() and "DiagnosticWarn")
      or (mappings.is_picking_close() and "DiagnosticError")
      or buffer.devicon.color
  end,
  italic = function(_)
    return mappings.is_picking_focus() or mappings.is_picking_close()
  end,
  bold = function(_)
    return mappings.is_picking_focus() or mappings.is_picking_close()
  end,
  truncation = { priority = 1 },
}

local UniquePrefix = {
  text = function(buffer)
    return buffer.unique_prefix
  end,
  fg = function(buffer)
    if buffer.is_focused then
      return require("cokeline.hlgroups").get_hl_attr("TabLineSel", "bg")
    else
      return "TabLine"
    end
  end,
  truncation = {
    priority = 3,
    direction = "left",
  },
}
local Filename = {
  text = function(buffer)
    return buffer.filename
  end,
  bold = function(buffer)
    return buffer.is_focused
  end,
  underline = function(buffer)
    return buffer.is_hovered and not buffer.is_focused
  end,
  sp = function(buffer)
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
}
local Diagnostics = (function()
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
          icons.diagnostics.errors .. " " .. buffer.diagnostics.errors .. " ",
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
          "DiagnosticSignpint",
        })
        width = width + #tostring(buffer.diagnostics.hints) + 3
      end
      popup.win_config.width = width
      popup.win_config.col = mouse_col - 1
      popup:mount()
      if not popup.bufnr then
        return
      end
      vim.api.nvim_buf_set_extmark(popup.bufnr, ns, 0, 0, {
        id = 1,
        virt_text = text,
        virt_text_pos = "overlay",
      })
    end,
    on_mouse_leave = function()
      popup:unmount()
    end,
  }
end)()
local CloseOrUnsaved = {
  text = function(buffer)
    if buffer.is_hovered then
      return buffer.is_modified and (icons.misc.modified .. " ")
        or (close_icon_hovered .. " ")
    else
      return buffer.is_modified and (icons.misc.modified .. " ")
        or (close_icon_normal .. " ") -- icons.actions.close
    end
  end,
  fg = "TabLine",
  bold = true,
  truncation = { priority = 1 },
  on_click = function(_, _, _, _, buffer)
    buffer:delete()
  end,
}

local Padding = {
  text = function(buffer)
    return buffer.is_last and " " or ""
  end,
  bg = "TabLineFill",
  fg = "none",
}

local Debug = {
  text = function()
    if package.loaded["dap"] and require("dap").session() then
      return string.format(" %s ", icons.dap.action.stop)
    end
    return string.format(" %s ", icons.dap.action.start)
  end,
  bg = "TabLineFill",
  fg = function(cx)
    return cx.is_hovered and p.lemon_chiffon or p.blue
  end,
  on_click = function(_id, _clicks, button, _modifiers, _buffer)
    if button == "l" then
      if require("dap").session() then
        require("dap").terminate()
      else
        require("configs.debugging").launch()
      end
    else
      vim.cmd("Greyjoy")
    end
  end,
}

local function harpoon_sorter()
  local harpoon = require("harpoon.mark")
  local cache = {}

  local function marknum(buf, force)
    local b = cache[buf.number]
    if b == nil or force then
      b = harpoon.get_index_of(buf.path)
      cache[buf.number] = b
    end
    return b
  end

  harpoon.on("changed", function()
    for _, buf in ipairs(require("cokeline.buffers").get_visible()) do
      cache[buf.number] = marknum(buf, true)
    end
  end)

  ---@param a Buffer
  ---@param b Buffer
  -- Use this in `config.buffers.new_buffers_position`
  return function(a, b)
    -- switch the a and b._valid_index to place non-harpoon buffers on the left
    -- side of the tabline - this puts them on the right.
    local ma = marknum(a) --b._valid_index
    local mb = marknum(b) --a._valid_index
    if ma and not mb then
      return true
    elseif mb and not ma then
      return false
    elseif ma == nil and mb == nil then
      ma = a._valid_index
      mb = b._valid_index
    end
    return ma < mb
  end
end

local opts = {
  show_if_buffers_are_at_least = 1,
  buffers = {
    focus_on_delete = "next",
    new_buffers_position = harpoon_sorter(),
    -- new_buffers_position = "next",
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
    bg = function(buffer)
      return buffer.is_focused and "TabLine" or "TabLine"
    end,
  },
  components = {
    Separator.left,
    Space,
    Devicon,
    UniquePrefix,
    Filename,
    Space,
    Diagnostics,
    Space,
    CloseOrUnsaved,
    Space,
    Separator.right,
    Padding,
  },
  rhs = {
    Debug,
  },
  mappings = {
    disable_mouse = false,
  },
  tabs = {
    placement = "right",
    components = {
      {
        text = function(tab)
          return tab.is_first and separators.left or ""
        end,
        fg = "TabLine",
      },
      {
        text = function(tab)
          return string.format(
            " %s ",
            vim.fn.fnamemodify(vim.fn.getcwd(-1, tab.index or 1), ":t")
          )
        end,
        fg = "TabLine",
        bg = "TabLine",
      },
      {
        text = icons.blocks.right.half,
        fg = function(tab)
          return (tab.tab_hovered or tab.is_active)
              and require("cokeline.hlgroups").get_hl_attr("TabLineSel", "bg")
            or require("cokeline.hlgroups").get_hl_attr("Comment", "fg")
        end,
        bg = function(tab)
          return tab.tab_hovered and "TabLineSel" or "TabLine"
        end,
      },
    },
  },
  sidebar = {
    filetype = { "SidebarNvim", "neo-tree", "edgy", "aerial", "OverseerList" },
    components = {
      {
        text = separators.left,
        highlight = "TabLine",
      },
      {
        text = function()
          return string.rep(
            " ",
            math.max(0, require("cokeline.sidebar").get_width("left") - 4)
          )
        end,
        bg = "TabLine",
      },
      SidebarOpen,
    },
  },
}

require("cokeline").setup(opts)
