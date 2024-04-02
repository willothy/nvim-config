local NC = require("nui-components")

local rows, columns, gap = NC.rows, NC.columns, NC.gap
local paragraph = NC.paragraph
local button, text_input = NC.button, NC.text_input

local spectre_search = require("spectre.search")
local spectre_state = require("spectre.state")
local spectre_state_utils = require("spectre.state_utils")
local spectre_utils = require("spectre.utils")

--- Sooooo work in progress

local function handler(state)
  local results = {}
  return {
    on_start = function()
      results = {}
      spectre_state.is_running = true
    end,
    on_result = function(item)
      if not spectre_state.is_running then
        return
      end
      table.insert(results, NC.node(item))
      -- state.results = results
    end,
    on_error = function(err)
      vim.notify_once(err, vim.log.levels.ERROR)
    end,
    on_finish = function()
      if not spectre_state.is_running then
        return
      end
      spectre_state.is_running = false
      state.results = results
      results = {}
    end,
  }
end

local function reset_search()
  if spectre_state.finder_instance then
    spectre_state.finder_instance:stop()
    spectre_state.finder_instance = nil
  end
end

local update_search = vim.schedule_wrap(function(state)
  reset_search()

  local search_text = state.search_text:get_value()
  if state.search_text:get_value() == "" then
    state.results = {}
    return
  end

  local search_engine = spectre_search.rg

  spectre_state.options["ignore-case"] = not state.case_sensitive

  spectre_state.finder_instance = search_engine:new(
    spectre_state_utils.get_search_engine_config(),
    handler(state)
  )
  spectre_state.regex = require("spectre.regex.vim")

  spectre_state.finder_instance:search({
    cwd = vim.uv.cwd(),
    search_text = search_text,
    replace_query = state.replace_text:get_value(),
  })
end)

local function winhighlight(tbl)
  local s = ""
  for k, v in pairs(tbl) do
    if s == "" then
      s = k .. ":" .. v
    else
      s = s .. "," .. k .. ":" .. v
    end
  end
  return s
end

local function focus_handler(state, cursor)
  return function(self)
    self.border:set_highlight("FloatTitleTransparent")
    self:get_renderer():redraw()
    if not state.old_guicursor:get_value() then
      state.old_guicursor = vim.o.guicursor
    end
    if cursor then
      vim.o.guicursor = cursor
    elseif state.old_guicursor:get_value() then
      vim.o.guicursor = state.old_guicursor:get_value()
    end
  end
end
local function blur_handler(_state)
  return function(self)
    self.border:set_highlight("NormalNC")
    self:get_renderer():redraw()
  end
end
local function unmount_handler(state)
  return function()
    if state.old_guicursor:get_value() then
      vim.o.guicursor = state.old_guicursor:get_value()
      state.old_guicursor = nil
    end
  end
end

local component_winhl = winhighlight({
  Normal = "Normal",
  NormalFloat = "Normal",
  FloatBorder = "NormalNC",
  FloatTitle = "FloatTitleTransparent",
  NvimFloat = "Normal",
  NuiComponentsCheckboxLabelChecked = "Normal",
  NuiComponentsCheckboxLabel = "NormalNC",
})

local search = function(state)
  local on_focus = focus_handler(state)
  local on_blur = blur_handler(state)
  local on_unmount = unmount_handler(state)
  return columns(
    { size = 3 },
    text_input({
      autofocus = true,
      flex = 1,
      max_lines = 1,
      placeholder = "Search",
      window = {
        highlight = component_winhl,
      },
      value = state.search_text,
      on_change = function(value)
        state.search_text = value
        update_search(state)
      end,
      on_unmount = on_unmount,
      on_focus = on_focus,
      on_blur = on_blur,
    }),
    NC.checkbox({
      label = "Aa",
      default_sign = "",
      checked_sign = "",
      border_style = "rounded",
      value = state.case_sensitive,
      window = {
        highlight = component_winhl,
      },
      on_change = function(value)
        state.case_sensitive = value
        update_search(state)
      end,
      on_unmount = on_unmount,
      on_focus = focus_handler(state, "a:hor25"),
      on_blur = on_blur,
    })
  )
end

local replace = function(state)
  local on_focus = focus_handler(state)
  local on_blur = blur_handler(state)
  local on_unmount = unmount_handler(state)

  return text_input({
    max_lines = 1,
    placeholder = "Replace",
    value = state.replace_text,
    window = {
      highlight = component_winhl,
    },
    on_change = function(value)
      state.replace_text = value
      update_search(state)
    end,
    on_unmount = on_unmount,
    on_focus = on_focus,
    on_blur = on_blur,
  })
end

local results = function(state)
  local on_focus = function(self)
    self.border:set_highlight("FloatTitleTransparent")
    local winhl = vim.wo[self.winid].winhl
    -- Hack because nui tree messes up the winhl
    vim.schedule(function()
      if winhl == "" then
        vim.wo[self.winid].winhl = "Normal:Normal"
      else
        vim.wo[self.winid].winhl = winhl .. ",Normal:Normal"
      end
    end)
  end
  local on_blur = function(self)
    self.border:set_highlight("NormalNC")
  end
  local on_unmount = unmount_handler(state)
  return NC.tree({
    size = 5,
    border_label = "Results",
    data = state.results,
    on_select = function(node, component)
      if node:is_expanded() then
        node:collapse()
      else
        node:expand()
      end

      component:get_tree():render()
    end,
    window = {
      highlight = component_winhl,
    },
    ---@param node NuiTree.Node
    ---@param line NuiLine
    prepare_node = function(node, line, component)
      local depth = node:get_depth()
      line:append(string.rep(" ", (depth - 1) * 2))
      if node:has_children() then
        if node:is_expanded() then
          line:append("v ")
        else
          line:append("> ")
        end
      else
        line:append("- ")
      end
      line:append(node.text)
      return line
    end,
    on_focus = on_focus,
    on_blur = on_blur,
    on_unmount = on_unmount,
  })
end

local M = {}

function M.close()
  if M.running then
    M.running:close()
    M.running = nil
  end
  reset_search()
end

function M.open()
  local state = NC.create_signal({
    search_text = "",
    replace_text = "",
    case_sensitive = false,
    results = {},
    old_guicursor = nil,
  })

  local view = NC.create_renderer({
    width = 40,
    height = 5,
    keymap = {
      focus_left = "<C-h>",
      focus_right = "<C-l>",
      focus_down = "<C-j>",
      focus_up = "<C-k>",
    },
    on_close = function()
      vim.print("close")
    end,
  })

  view:add_mappings({
    {
      mode = "n",
      key = "q",
      handler = function()
        view:close()
      end,
    },
  })

  M.running = view

  view:render(function()
    return rows(
      { flex = 1 },
      search(state), -- search input and case sensitive checkbox
      replace(state), -- replace input
      results(state) -- Results file tree
    )
  end)

  view:on_unmount(function()
    M.running = nil
    reset_search()
  end)
end

-- M.open()

return M
