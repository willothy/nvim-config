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

  local search_engine = spectre_search.rg

  spectre_state.options["ignore-case"] = not state.case_sensitive

  spectre_state.finder_instance = search_engine:new(
    spectre_state_utils.get_search_engine_config(),
    handler(state)
  )
  spectre_state.regex = require("spectre.regex.vim")

  spectre_state.finder_instance:search({
    cwd = vim.uv.cwd(),
    search_text = state.search_text:get_value(),
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

local search = function(state)
  return columns(
    { size = 3 },
    text_input({
      autofocus = true,
      flex = 1,
      max_lines = 1,
      placeholder = "Search",
      window = {
        highlight = winhighlight({
          NormalFloat = "Normal",
          FloatBorder = "NormalNC",
        }),
      },
      value = state.search_text,
      on_change = function(value)
        state.search_text = value
        update_search(state)
      end,
    }),
    NC.checkbox({
      label = "Aa",
      default_sign = "",
      checked_sign = "",
      border_style = "rounded",
      value = state.case_sensitive,
      on_change = function(value)
        state.case_sensitive = value
        update_search(state)
      end,
      window = {
        highlight = winhighlight({
          NormalFloat = "Normal",
          FloatBorder = "NormalNC",
          NuiComponentsCheckboxLabelChecked = "Normal",
          NuiComponentsCheckboxLabel = "NormalNC",
        }),
      },
    })
  )
end

local replace = function(state)
  return text_input({
    max_lines = 1,
    placeholder = "Replace",
    value = state.replace_text,
    on_change = function(value)
      state.replace_text = value
      update_search(state)
    end,
    window = {
      highlight = "Normal:Normal,FloatBorder:NormalNC",
    },
  })
end

local results = function(state)
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
  })
end

local body = function()
  local state = NC.create_signal({
    search_text = "",
    replace_text = "",
    case_sensitive = false,
    results = {},
  })

  return rows(
    { flex = 1 },
    search(state), -- search input and case sensitive checkbox
    replace(state), -- replace input
    results(state) -- Results file tree
  )
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
  local view = NC.create_renderer({
    width = 40,
    height = 5,
  })

  view:add_mappings({
    {
      mode = "n",
      key = "q",
      handler = function()
        view:close()
      end,
    },
    {
      mode = { "n", "v", "i" },
      key = "<C-l>",
      handler = function()
        local c = view:get_component_by_direction("right")
        if c then
          c:focus()
        end
      end,
    },
    {
      mode = { "n", "v", "i" },
      key = "<C-h>",
      handler = function()
        local c = view:get_component_by_direction("left")
        if c then
          c:focus()
        end
      end,
    },
    {
      mode = { "n", "v", "i" },
      key = "<C-k>",
      handler = function()
        local c = view:get_component_by_direction("up")
        if c then
          c:focus()
        end
      end,
    },
    {
      mode = { "n", "v", "i" },
      key = "<C-j>",
      handler = function()
        local c = view:get_component_by_direction("down")
        if c then
          c:focus()
        end
      end,
    },
  })

  M.running = view

  view:render(body)

  view:on_unmount(function()
    M.running = nil
    reset_search()
  end)
end

return M
