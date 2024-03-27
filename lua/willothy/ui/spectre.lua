local NC = require("nui-components")

local rows, columns, gap = NC.rows, NC.columns, NC.gap
local paragraph = NC.paragraph
local button, text_input = NC.button, NC.text_input

local view = NC.create_renderer({
  width = 40,
  height = 5,
})

local search = function()
  return columns(
    { size = 3 },
    text_input({
      autofocus = true,
      flex = 1,
      max_lines = 1,
      placeholder = "Search",
      window = {
        highlight = "Normal:Normal,FloatBorder:NormalNC",
      },
    }),
    NC.checkbox({
      label = "Aa",
      default_sign = "",
      checked_sign = "",
      border_style = "rounded",
      window = {
        highlight = "Normal:Normal,FloatBorder:NormalNC",
      },
    })
  )
end

local replace = function()
  return text_input({
    max_lines = 1,
    placeholder = "Replace",
    window = {
      highlight = "Normal:Normal,FloatBorder:NormalNC",
    },
  })
end

local results = function()
  local next_id = 1
  local Node = require("nui.tree").Node
  return NC.tree({
    size = 5,
    border_label = "Results",
    data = {
      NC.node({
        id = "c",
        text = "test1",
      }),
      NC.node({
        id = "b",
        text = "test2",
      }),
      NC.node({
        text = "test3",
        id = "a",
      }, {
        NC.node({
          text = "test1",
        }),
        NC.node({
          text = "test2",
        }),
      }),
    },
    on_select = function(node, component)
      if node:is_expanded() then
        node:collapse()
      else
        node:expand()
      end

      component:get_tree():render()
    end,
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
  return rows(
    { flex = 1 },
    search(), -- search input and case sensitive checkbox
    replace(), -- replace input
    results() -- Results file tree
  )
end

-- Directional form navigation
local function move(dir)
  vim.schedule(function()
    local dirs = {
      left = function(pos, current)
        return pos[2] < current[2]
      end,
      right = function(pos, current)
        return pos[2] > current[2]
      end,
      up = function(pos, current)
        return pos[1] < current[1]
      end,
      down = function(pos, current)
        return pos[1] > current[1]
      end,
    }

    local focused = view:get_last_focused_component()

    local focusable = vim
      .iter(view:get_focusable_components())
      :filter(function(_, component)
        return component ~= focused
      end)
      :map(function(component)
        local winid = component.winid
        return {
          component = component,
          pos = vim.api.nvim_win_get_position(winid),
        }
      end)
      :filter(function(component)
        return dirs[dir](
          component.pos,
          vim.api.nvim_win_get_position(focused.winid)
        )
      end)
      :totable()

    table.sort(focusable, function(a, b)
      local focused_pos = vim.api.nvim_win_get_position(focused.winid)

      if dir == "left" or dir == "right" then
        return math.abs(a.pos[2] - focused_pos[2])
          < math.abs(b.pos[2] - focused_pos[2])
      else
        return math.abs(a.pos[1] - focused_pos[1])
          < math.abs(b.pos[1] - focused_pos[1])
      end
    end)

    if focusable[1] then
      focusable[1].component:focus()
    end
  end)
end

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
      move("right")
    end,
  },
  {
    mode = { "n", "v", "i" },
    key = "<C-h>",
    handler = function()
      move("left")
    end,
  },
  {
    mode = { "n", "v", "i" },
    key = "<C-k>",
    handler = function()
      move("up")
    end,
  },
  {
    mode = { "n", "v", "i" },
    key = "<C-j>",
    handler = function()
      move("down")
    end,
  },
})

view:render(body)
