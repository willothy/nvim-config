local function row(...)
  return { "row", { ... } }
end

local function col(...)
  return { "col", { ... } }
end

---@param buf number|string?
local function win(buf)
  return { "leaf", buf }
end

local layouts = setmetatable({}, {
  __layouts = {},
  __index = function(self, k)
    return vim.deepcopy(getmetatable(self).__layouts[k])
  end,
  __newindex = function(self, k, v)
    getmetatable(self).__layouts[k] = v
  end,
})

--
-- |‾‾‾‾‾|‾‾‾‾‾|
-- |     |  B  |
-- |  A  |-----|
-- |     |  C  |
-- |_____|_____|
--
layouts.tile_right = row(
  -- A
  win(),
  col(
    -- B
    win(),
    -- C
    win()
  )
)

--
-- |‾‾‾‾‾|‾‾‾‾‾|
-- |  A  |     |
-- |-----|  C  |
-- |  B  |     |
-- |_____|_____|
--
layouts.tile_left = row(
  col(
    -- A
    win(),
    -- B
    win()
  ),
  -- C
  win()
)

-- assign buffers in depth-first order to empty leaves, create a scratch buffer for any remaining empty windows,
-- and create the layout.
local function set_layout(name, bufs)
  if not bufs then
    bufs = vim.iter(vim.api.nvim_list_bufs()):filter(function(buf)
      return vim.api.nvim_buf_get_option(buf, "buflisted")
    end)
  else
    bufs = vim.iter(bufs)
  end
  local tmp_buf

  local function process(node)
    if node[1] == "leaf" then
      node[2] = bufs:next()
      if node[2] == nil then
        if not tmp_buf then
          tmp_buf = vim.api.nvim_create_buf(false, true)
        end
        node[2] = tmp_buf
      end
    else
      vim.iter(node[2]):each(process)
    end
    return node
  end

  local tree = process(layouts[name])
  vim.api.nvim_tabpage_set_layout(0, tree)
end

set_layout("tile_right", {
  "init.lua",
  "README.md",
})
