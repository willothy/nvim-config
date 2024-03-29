local icons = willothy.ui.icons
local ns = vim.api.nvim_create_namespace("cokeline_diagnostics")

local mappings = require("cokeline.mappings")

local separators = {
  left = icons.blocks.left[4],
  right = icons.blocks.left[4],
}

local groups = {
  bg = "TabLine",
  bg_active = "TabLine",
  bg_fill = "TabLineFill",
  hl_active = "TabLineSel",
}

local SidebarOpen = {
  text = function(buffer)
    local open = require("cokeline.sidebar").get_win("left") and true or false
    if (open and buffer.is_readonly) or (buffer.is_first and not open) then
      return string.format(
        " %s ",
        open and icons.menu.actions.outline.left
          or icons.menu.actions.outline.right
      )
    end
    return ""
  end,
  fg = function(cx)
    return cx.is_hovered and groups.bg_active or groups.bg
  end,
  bg = function(cx)
    return cx.is_hovered and groups.bg_active or groups.bg
  end,
  on_click = function()
    require("edgy").toggle("left")
  end,
}

local Space = {
  text = " ",
  truncation = { priority = 1 },
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
  fg = groups.bg_active,
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
          return groups.bg
        else ]]
    if buffer.diagnostics.errors ~= 0 then
      return "DiagnosticError"
    elseif buffer.diagnostics.warnings ~= 0 then
      return "DiagnosticWarn"
    elseif buffer.diagnostics.infos ~= 0 then
      return "DiagnosticInfo"
    else
      return groups.bg
    end
  end,
  fg = function(buffer)
    --[[ if buffer.is_focused then
          return groups.bg
        else ]]
    if buffer.diagnostics.errors ~= 0 then
      return "DiagnosticError"
    elseif buffer.diagnostics.warnings ~= 0 then
      return "DiagnosticWarn"
    elseif buffer.diagnostics.infos ~= 0 then
      return "DiagnosticInfo"
    else
      return buffer.is_focused and groups.bg_active or groups.bg
    end
  end,
  -- bg = groups.bg,
  truncation = {
    priority = 2,
    direction = "right",
  },
}

local function create_popup()
  local Popup = require("nui.popup")

  return Popup({
    enter = false,
    focusable = false,
    border = {
      style = { " ", " ", " ", " ", " ", " ", " ", " " },
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
end

local Diagnostics
Diagnostics = {
  text = function(buffer)
    return (
      buffer.diagnostics.errors ~= 0
      and icons.diagnostics.errors .. " " .. buffer.diagnostics.errors .. " "
    )
      or (buffer.diagnostics.warnings ~= 0 and icons.diagnostics.warnings .. " " .. buffer.diagnostics.warnings .. " ")
      or ""
  end,
  fg = function(buffer)
    return (buffer.diagnostics.errors ~= 0 and "DiagnosticError")
      or (buffer.diagnostics.warnings ~= 0 and "DiagnosticWarn")
      or nil
  end,
  bg = function(buffer)
    return buffer.is_focused and groups.bg_active or groups.bg
  end,
  truncation = { priority = 1 },
  on_click = function(_id, _clicks, _button, _modifiers, buffer)
    local trouble = require("trouble")
    if buffer.is_focused then
      trouble.toggle()
    elseif trouble.is_open() then
      if vim.bo.filetype == "trouble" then
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
    Diagnostics.popup = Diagnostics.popup or create_popup()
    Diagnostics.popup.win_config.width = width - 1
    Diagnostics.popup.win_config.col = mouse_col - 1
    Diagnostics.popup:mount()
    if not Diagnostics.popup.bufnr then
      return
    end
    vim.api.nvim_buf_set_extmark(Diagnostics.popup.bufnr, ns, 0, 0, {
      id = 1,
      virt_text = text,
      virt_text_pos = "overlay",
    })
  end,
  on_mouse_leave = function()
    if Diagnostics.popup then
      Diagnostics.popup:unmount()
    end
  end,
}

local CloseOrUnsaved = {
  text = function(buffer)
    if buffer.is_hovered then
      return buffer.is_modified and (icons.misc.modified .. " ")
        or (icons.actions.close_round .. " ")
    else
      return buffer.is_modified and (icons.misc.modified .. " ")
        or (icons.actions.close .. " ")
    end
  end,
  fg = groups.bg,
  bold = true,
  truncation = { priority = 1 },
  on_click = function(_, _, _, _, buffer)
    buffer:delete()
  end,
}

local Padding = {
  text = function(cx)
    return cx.is_first and " " or ""
  end,
  highlight = "TabLineFill",
}

-- local Debug = {
--   text = function()
--     if package.loaded["dap"] and require("dap").session() then
--       return string.format(" %s ", icons.dap.action.stop)
--     end
--     return string.format(" %s ", icons.dap.action.start)
--   end,
--   bg = "TabLineFill",
--   fg = function(cx)
--     return cx.is_hovered and p.lemon_chiffon or p.blue
--   end,
--   on_click = function(_id, _clicks, button, _modifiers, _buffer)
--     if button == "l" then
--       if require("dap").session() then
--         require("dap").terminate()
--       else
--         require("configs.debugging").launch()
--       end
--     else
--       vim.cmd("Greyjoy")
--     end
--   end,
-- }

local function harpoon_sorter()
  local cache = {}
  local setup = false

  local function marknum(buf, force)
    local harpoon = require("harpoon")
    local b = cache[buf.number]
    if b == nil or force then
      local path =
        require("plenary.path"):new(buf.path):make_relative(vim.uv.cwd())
      for i, mark in ipairs(harpoon:list("files"):display()) do
        if mark == path then
          b = i
          cache[buf.number] = b
          break
        end
      end
    end
    return b
  end

  -- Use this in `config.buffers.new_buffers_position`
  return function(a, b)
    -- Only run this if harpoon is loaded, otherwise just use the default sorting.
    -- This could be used to only run if a user has harpoon installed, but
    -- I'm mainly using it to avoid loading harpoon on UiEnter.
    local has_harpoon = package.loaded["harpoon"] ~= nil
    if not has_harpoon then
      ---@diagnostic disable-next-line: undefined-field
      return a._valid_index < b._valid_index
    elseif not setup then
      local refresh = function()
        cache = {}
      end
      require("harpoon"):extend({
        ADD = refresh,
        REMOVE = refresh,
        REORDER = refresh,
      })
      setup = true
    end
    -- switch the a and b._valid_index to place non-harpoon buffers on the left
    -- side of the tabline - this puts them on the right.
    local ma = marknum(a)
    local mb = marknum(b)
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
  show_if_buffers_are_at_least = 0,
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
      return buffer.is_focused and groups.bg_active or groups.bg
    end,
    bg = function(buffer)
      return buffer.is_focused and groups.bg_active or groups.bg
    end,
  },
  components = {
    {
      text = function(buffer)
        return buffer.is_focused and separators.left
          or icons.separators.bar.left
      end,
      fg = function(buffer)
        return buffer.is_focused and "Directory" or "#2b3243" -- TODO: use hlgroup
      end,
      bg = function(buffer)
        return buffer.is_focused and groups.bg_active or groups.bg
      end,
    },
    Space,
    Devicon,
    UniquePrefix,
    Filename,
    Space,
    Diagnostics,
    CloseOrUnsaved,
    -- Space,
    {
      text = function(buffer)
        return buffer.is_last and icons.separators.bar.right or ""
      end,
      fg = "#2b3243", -- TODO: use hlgroup
      bg = function(buffer)
        return buffer.is_focused and groups.bg_active or groups.bg
      end,
    },
  },
  rhs = false,
  mappings = {
    disable_mouse = false,
  },
  tabs = {
    placement = "right",
    components = {
      Padding,
      {
        text = function(tab)
          return (tab.is_active or tab.is_hovered) and separators.left or "⎸"
        end,
        fg = function(tab)
          return tab.is_active and "Directory" or "#2b3243"
        end,
        bg = function(tab)
          return tab.is_focused and groups.bg_active or groups.bg
        end,
      },
      {
        text = function(tab)
          -- return tostring(tab.index) .. ":" .. tostring(tab.number)
          return string.format(
            " %s ",
            vim.fn.fnamemodify(vim.fn.getcwd(-1, tab.index or 1), ":t")
          )
        end,
        fg = groups.bg,
        bg = groups.bg,
      },
      {
        text = function(tab)
          return tab.is_last and "⎹" or ""
        end,
        fg = function(tab)
          return tab.is_focused and "Directory" or "#2b3243"
        end,
        bg = function(tab)
          return tab.is_focused and groups.bg_active or groups.bg
        end,
      },
    },
  },
  sidebar = {
    filetype = {
      "SidebarNvim",
      "neo-tree",
      "edgy",
      "aerial",
      "OverseerList",
    },
    components = {
      {
        text = separators.left,
        highlight = groups.bg,
      },
      {
        text = function()
          return string.rep(
            " ",
            math.max(0, require("cokeline.sidebar").get_width("left") - 4)
          )
        end,
        bg = groups.bg,
      },
      SidebarOpen,
    },
  },
}

require("cokeline").setup(opts)
