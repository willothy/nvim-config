local statusline = require("willothy.lib.statusline")
local state = require("willothy.core.state")
local icons = require("willothy.ui.icons")

-- Helper to get hex from highlight group
local function get_hex(group, attr)
  local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
  if hl and hl[attr] then
    return string.format("#%06x", hl[attr])
  end
  return nil
end

-- Setup dynamic highlights
local function setup_highlights()
  vim.api.nvim_set_hl(0, "StatusLineMode", { fg = "#0f0f0f", bold = true })
  vim.api.nvim_set_hl(0, "StatusLineModeAccent", {})
  vim.api.nvim_set_hl(0, "StatusLineGit", { link = "StatusLine" })
  vim.api.nvim_set_hl(0, "StatusLineDiagnostic", { link = "StatusLine" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = setup_highlights,
})
setup_highlights()

-- Components

-- Mode indicator with separators (REACTIVE)
local mode_component = statusline.component(function()
  local mode_data = state.mode.get()
  local mode_char = string.char(mode_data.short_name:byte(1))

  -- Update dynamic highlight
  if mode_data.color and mode_data.color.fg then
    vim.api.nvim_set_hl(0, "StatusLineMode", {
      fg = "#0f0f0f",
      bg = string.format("#%06x", mode_data.color.fg),
      bold = true,
    })
    vim.api.nvim_set_hl(0, "StatusLineModeAccent", {
      fg = string.format("#%06x", mode_data.color.fg),
      bg = string.format("#%06x", mode_data.color.fg),
    })
  end

  return string.format("%%#StatusLineModeAccent#%s%%#StatusLineMode#%s%%#StatusLineModeAccent#%s%%* ",
    icons.blocks.left[4],
    mode_char,
    icons.blocks.right.half
  )
end)

-- Git branch (REACTIVE)
local git_branch_component = statusline.component(function()
  local branch = state.git_branch.get()
  if not branch or branch == "" then
    return ""
  end
  return string.format("%s %s ", icons.git.branch, branch)
end, {
  hl = "StatusLineGit",
  condition = function()
    return state.git_branch.get() ~= nil
  end,
})

-- Git diff stats (REACTIVE - uses buffer-scoped state)
local git_added_component = statusline.component(function()
  local buf = vim.api.nvim_get_current_buf()
  local status = state.buffer_git_status[buf].get()
  local added = status and status.added or 0
  if added == 0 then
    return ""
  end
  return string.format("%s %s ", icons.git.diff.added, added)
end, {
  hl = "GitSignsAdd",
})

local git_removed_component = statusline.component(function()
  local buf = vim.api.nvim_get_current_buf()
  local status = state.buffer_git_status[buf].get()
  local removed = status and status.removed or 0
  if removed == 0 then
    return ""
  end
  return string.format("%s %s ", icons.git.diff.removed, removed)
end, {
  hl = "GitSignsDelete",
})

local git_modified_component = statusline.component(function()
  local buf = vim.api.nvim_get_current_buf()
  local status = state.buffer_git_status[buf].get()
  local changed = status and status.changed or 0
  if changed == 0 then
    return ""
  end
  return string.format("%s %s ", icons.git.diff.modified, changed)
end, {
  hl = "GitSignsChange",
})

-- Overseer task status (static - updates on task events)
local overseer_component = statusline.static(function()
  if not package.loaded["overseer"] then
    return ""
  end

  local overseer = require("overseer")
  local tasks = require("overseer.task_list")
  local STATUS = require("overseer.constants").STATUS

  local symbols = {
    ["FAILURE"] = " 󰲼 ",
    ["CANCELED"] = " 󱄊 ",
    ["SUCCESS"] = " 󰦕 ",
    ["RUNNING"] = " 󰦖 ",
  }

  local colors = {
    ["FAILURE"] = "OverseerFAILURE",
    ["CANCELED"] = "OverseerCANCELED",
    ["SUCCESS"] = "OverseerSUCCESS",
    ["RUNNING"] = "OverseerRUNNING",
  }

  local task_list = tasks.list_tasks({ unique = true })
  if #task_list == 0 then
    return ""
  end

  local tasks_by_status = overseer.util.tbl_group_by(task_list, "status")

  for _, status in ipairs(STATUS.values) do
    local status_tasks = tasks_by_status[status]
    if symbols[status] and status_tasks then
      local hl = vim.api.nvim_get_hl(0, { name = colors[status], link = false })
      local color = hl and hl.fg and string.format("#%06x", hl.fg) or "gray"

      -- Return with inline highlight
      return string.format("%%#StatusLineDiagnostic#%s%%*", symbols[status])
    end
  end

  return ""
end, {
  condition = function()
    return package.loaded["overseer"] ~= nil
  end,
})

-- Diagnostic summary (REACTIVE)
local diagnostic_summary_component = statusline.component(function()
  return vim.diagnostic.status() or ""
end, {
  hl = "StatusLineDiagnostic",
})

-- DAP debugging status (static - updates on DAP events)
local dap_component = statusline.static(function()
  if not package.loaded["dap"] or not require("dap").session() then
    return ""
  end
  return " " .. require("dap").status() .. " "
end, {
  hl = "Debug",
  condition = function()
    return package.loaded["dap"] and require("dap").session()
  end,
})

-- Macro recording status (static - updates on MacroStateChanged)
local recording_component = statusline.static(function()
  if not package.loaded["willothy.macros"] then
    return ""
  end
  local status = require("willothy.macros").statusline()
  return status and status ~= "" and status .. " " or ""
end)

-- Devicon (static - updates on buffer change)
local devicon_component = statusline.static(function()
  if not package.loaded["nvim-web-devicons"] then
    return ""
  end

  local filename = vim.fn.expand("%")
  local extension = vim.fn.fnamemodify(filename, ":e")
  local devicons = require("nvim-web-devicons")
  local icon, color = devicons.get_icon_color(filename, extension)

  if not icon then
    icon, color = devicons.get_icon_color_by_filetype(
      vim.bo.filetype,
      { default = false }
    )
  end

  if icon then
    -- Create dynamic highlight for icon
    vim.api.nvim_set_hl(0, "StatusLineDevicon", { fg = color })
    return string.format("%%#StatusLineDevicon#%s%%* ", icon)
  end

  return ""
end, {
  condition = function()
    return package.loaded["nvim-web-devicons"] ~= nil
  end,
})

-- Filetype (static - updates on buffer change)
local filetype_component = statusline.static(function()
  local ft = vim.bo.filetype
  if ft == "" then
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
    return name ~= "" and name .. " " or ""
  end
  return ft .. " "
end, {
  hl = "StatusLine",
  condition = function()
    return vim.bo.filetype ~= "" or vim.api.nvim_buf_get_name(0) ~= ""
  end,
})

-- Session name from env (static - updates on DirChanged)
local sesh_component = statusline.static(function()
  local sesh = os.getenv("SESH_NAME")
  return (sesh and sesh ~= "") and sesh .. " " or ""
end, {
  hl = "StatusLine",
  condition = function()
    local sesh = os.getenv("SESH_NAME")
    return sesh and sesh ~= ""
  end,
})

-- Location: line:col (static - could be reactive if we add cursor to state)
local location_component = statusline.static(function()
  local pos = vim.api.nvim_win_get_cursor(0)
  return string.format("%03d:%02d ", pos[1], pos[2])
end, {
  hl = "StatusLine",
})

-- Percentage scrollbar (reactive - uses mode for color)
local percentage_component = statusline.component(function()
  local sbar = { "▔", "🮂", "🮃", "▀", "🮄", "🮅", "🮆", "█" }

  local ok, pos = pcall(vim.api.nvim_win_get_cursor, 0)
  if not ok then
    return ""
  end

  local curr_line = pos[1]
  local lines = vim.api.nvim_buf_line_count(0)
  if lines == 0 then
    return ""
  end

  local i = math.floor((curr_line - 1) / lines * #sbar) + 1
  i = math.max(1, math.min(i, #sbar))  -- Clamp to valid range

  -- Get mode color for accent (REACTIVE)
  local mode_data = state.mode.get()
  if mode_data.color and mode_data.color.fg then
    vim.api.nvim_set_hl(0, "StatusLinePercentage", {
      fg = string.format("#%06x", mode_data.color.fg),
    })
  end

  return string.format("%%#StatusLinePercentage#%s%%*", string.rep(sbar[i], 3))
end)

-- Spacer
local space = statusline.static(" ")

-- Configure statusline layout
statusline.setup({
  left = {
    mode_component,
    space,
    git_branch_component,
    git_added_component,
    git_removed_component,
    git_modified_component,
    overseer_component,
  },
  center = {
    diagnostic_summary_component,
  },
  right = {
    space,
    dap_component,
    recording_component,
    devicon_component,
    filetype_component,
    sesh_component,
    location_component,
    percentage_component,
  },
}, state)  -- Pass state module for watchers

-- Hook up events for non-reactive components
local event = require("willothy.lib.event")

-- Single debounced redraw for buffer/window/cursor changes
event.subscribe(
  { "BufEnter", "WinEnter", "CursorMoved", "CursorMovedI" },
  function()
    vim.cmd.redrawstatus()
  end,
  { debounce = 50 }
)

-- Immediate redraws for important state changes
event.subscribe({ "MacroStateChanged", "User" }, function(args)
  if args.match and args.match:match("^OverseerTask") then
    vim.cmd.redrawstatus()
  elseif args.event == "MacroStateChanged" then
    vim.cmd.redrawstatus()
  end
end)
