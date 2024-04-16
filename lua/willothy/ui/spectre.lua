local NC = require("nui-components")

local rows, columns, gap = NC.rows, NC.columns, NC.gap
local paragraph = NC.paragraph
local button, text_input = NC.button, NC.text_input

local spectre_search = require("spectre.search")
local spectre_state = require("spectre.state")
local spectre_state_utils = require("spectre.state_utils")
local spectre_utils = require("spectre.utils")

--- Sooooo work in progress

local function reset_search()
  if spectre_state.finder_instance then
    spectre_state.finder_instance:stop()
    spectre_state.finder_instance = nil
  end
end

---@type fun(search_text: (fun(): string), case_sensitive: (fun(): boolean), replace_text: (fun(): string), set_results_list: (fun(): any[]))
local update_search = function(
  search_text,
  case_sensitive,
  replace_text,
  set_results_list
)
end

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

local component_winhl = winhighlight({
  Normal = "Normal",
  NormalFloat = "Normal",
  FloatBorder = "NormalNC",
  FloatTitle = "FloatTitleTransparent",
  NvimFloat = "Normal",
  NuiComponentsCheckboxLabelChecked = "Normal",
  NuiComponentsCheckboxLabel = "NormalNC",
})

local function view(cx)
  local search_text, set_search_text = cx:create_signal("")

  local replace_text, set_replace_text = cx:create_signal("")

  local case_sensitive, set_case_sensitive = cx:create_signal(false)

  local results_list, set_results_list = cx:create_signal({})

  cx:create_effect(function()
    reset_search()

    if search_text() == "" then
      set_results_list({})
      return
    end

    local search_engine = spectre_search.rg

    spectre_state.options["ignore-case"] = not case_sensitive()

    local results = {}
    spectre_state.finder_instance =
      search_engine:new(spectre_state_utils.get_search_engine_config(), {
        on_start = function()
          results = {}
          spectre_state.is_running = true
        end,
        on_result = function(item)
          if not spectre_state.is_running then
            return
          end
          table.insert(results, NC.node(item))
        end,
        on_error = function(err)
          vim.notify_once(err, vim.log.levels.ERROR)
        end,
        on_finish = function()
          if not spectre_state.is_running then
            return
          end
          spectre_state.is_running = false
          local res_list = results
          results = {}
          set_results_list(res_list)
        end,
      })
    spectre_state.regex = require("spectre.regex.vim")

    spectre_state.finder_instance:search({
      cwd = vim.uv.cwd(),
      search_text = search_text(),
      replace_query = replace_text(),
    })

    -- vim.print(search_text())
    -- local fmt = "%s : %s : case sensitive? %s"
    -- vim.print(
    --   fmt:format(
    --     search_text(),
    --     replace_text(),
    --     case_sensitive() and "Yes" or "No"
    --   )
    -- )
  end)

  return rows(
    { flex = 1 },
    columns(
      { size = 3 },
      NC.text_input({
        autofocus = true,
        flex = 1,
        max_lines = 1,
        placeholder = "Search",
        window = {
          highlight = component_winhl,
        },
        value = search_text,
        on_change = set_search_text,
      }),
      NC.checkbox({
        label = "Aa",
        default_sign = "",
        checked_sign = "",
        border_style = "rounded",
        window = {
          highlight = component_winhl,
        },
        value = case_sensitive,
        on_change = set_case_sensitive,
      })
    ),
    -- Replace input
    text_input({
      max_lines = 1,
      placeholder = "Replace",
      window = {
        highlight = component_winhl,
      },
      value = replace_text,
      on_change = set_replace_text,
    }),
    -- Results
    NC.tree({
      size = 5,
      border_label = "Results",
      -- data = {},
      data = results_list,
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
      prepare_node = function(node, line, _component)
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
  -- local state = NC.create_signal({
  --   search_text = "",
  --   replace_text = "",
  --   case_sensitive = false,
  --   results = {},
  --   old_guicursor = nil,
  -- })

  local app = NC.create_renderer({
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

  app:add_mappings({
    {
      mode = "n",
      key = "q",
      handler = function()
        app:close()
      end,
    },
  })

  M.running = app

  app:render(view)

  app:on_unmount(function()
    M.running = nil
    reset_search()
  end)
end

M.open()

return M
