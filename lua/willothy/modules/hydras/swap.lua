local Hydra = require("willothy.modules.hydras").Hydra

local shared = require("nvim-treesitter.textobjects.shared")
local swap = require("nvim-treesitter.textobjects.swap")
local ts_utils = require("nvim-treesitter.ts_utils")

local queries = {
  "@parameter.inner",
  "@argument.inner",
  "@property.inner",
  "@function.outer",
  "@method.outer",
}
local current_query = 1
local query_string = queries[current_query]

local function get_or_create_namespace()
  return vim.api.nvim_create_namespace("hydra_swap_hl_node")
end

local function clear_highlight()
  local hl_ns = get_or_create_namespace()
  vim.api.nvim_buf_clear_namespace(0, hl_ns, 0, -1)
end

local function update_highlight(range)
  local hl_ns = get_or_create_namespace()
  local hl_group = "IncSearch"
  local start = { range[1], range[2] }
  local finish = { range[3], range[4] }
  vim.highlight.range(0, hl_ns, hl_group, start, finish)
end

local function set_cursor_on_node(node)
  local row, col, _ = node:start()
  vim.api.nvim_win_set_cursor(0, { row + 1, col })
end

local function choose_adjacent(forward)
  local _, _, node = shared.textobject_at_point(query_string)
  if not node then
    return
  end

  node = shared.get_adjacent(forward, node, query_string, nil, true)
  if not node then
    return
  end

  set_cursor_on_node(node)
  clear_highlight()
end

local function get_siblings_for_edit(node)
  local ranges, texts = {}, {}
  for sibling in node:parent():iter_children() do
    if sibling:named() then
      ranges[#ranges + 1] = ts_utils.node_to_lsp_range(sibling)
      texts[#texts + 1] = vim.treesitter.get_node_text(sibling, 0)
    end
  end
  return ranges, texts
end

local function sort_nodes(reverse)
  local _, _, node = shared.textobject_at_point(query_string)
  if not node then
    return
  end

  local ranges, texts = get_siblings_for_edit(node)

  table.sort(texts, function(a, b)
    if reverse then
      return a > b
    end
    return a < b
  end)

  local edits = {}
  for i, range in ipairs(ranges) do
    edits[#edits + 1] = { range = range, newText = texts[i] }
  end

  vim.lsp.util.apply_text_edits(edits, 0, "utf-8")

  clear_highlight()
end

local function reverse_nodes()
  local _, _, node = shared.textobject_at_point(query_string)
  if not node then
    return
  end

  local ranges, texts = get_siblings_for_edit(node)

  local edits = {}
  for i, range in ipairs(ranges) do
    edits[#edits + 1] = { range = range, newText = texts[#texts + 1 - i] }
  end

  vim.lsp.util.apply_text_edits(edits, 0, "utf-8")

  clear_highlight()
end

local hint = [[
 query: %{query}

 select^^     swap^^        _s_: sort
 _k_: next    _K_: next     _S_: sort rev.
 _j_: prev    _J_: prev     _r_: reverse

 _<Tab>_: switch query 
 _<Enter>_: edit query
 _<Esc>_, _q_: quit
]]

Hydra({
  name = "Swap",
  mode = "n",
  body = "gs",
  hint = hint,
  heads = {
    {
      "j",
      function()
        choose_adjacent(true)
      end,
      { desc = "choose" },
    },
    {
      "k",
      function()
        choose_adjacent(false)
      end,
      { desc = "choose" },
    },
    {
      "J",
      function()
        swap.swap_next(query_string)
      end,
      { desc = "swap" },
    },
    {
      "K",
      function()
        swap.swap_previous(query_string)
      end,
      { desc = "swap" },
    },
    {
      "s",
      function()
        sort_nodes(false)
      end,
    },
    {
      "S",
      function()
        sort_nodes(true)
      end,
      { desc = "sort" },
    },
    {
      "r",
      function()
        reverse_nodes()
      end,
      { desc = "reverse" },
    },
    {
      "<Enter>",
      function()
        query_string = vim.fn.input("query: ", query_string)
        vim.cmd.redraw({ bang = true })
        clear_highlight()
      end,
      { desc = "edit query" },
    },
    {
      "<Tab>",
      function()
        current_query = current_query + 1
        if current_query > #queries then
          current_query = 1
        end
        query_string = queries[current_query]
        clear_highlight()
      end,
      { desc = "switch query" },
    },
    { "<Esc>", nil, { exit = true } },
    { "q", nil, { exit = true } },
  },
  config = {
    hint = {
      border = "single",
      position = "bottom-left",
      funcs = {
        query = function()
          return query_string
        end,
      },
    },
    invoke_on_body = true,
    on_enter = function()
      local _, range, _ = shared.textobject_at_point(query_string)
      if not range then
        return
      end

      update_highlight(range)
    end,
    on_key = function()
      local _, range, _ = shared.textobject_at_point(query_string)
      if not range then
        return
      end

      update_highlight(range)
    end,
    on_exit = clear_highlight,
  },
})
