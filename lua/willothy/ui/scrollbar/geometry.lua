--- Helper for calculating placement of the scrollbar thumb and gutter

--- @class willothy.ScrollbarGeometry
--- @field width number
--- @field height number
--- @field row number
--- @field col number
--- @field zindex number
--- @field relative string
--- @field win number

local M = {}

-- eighth blocks: index k (1..8) = lower k/8 of the cell filled from the bottom
local BLOCKS = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }

--- round to an integer eighth in [1, 8]
local function clamp8(x)
  return math.max(1, math.min(8, math.floor(x + 0.5)))
end

-- cache the O(lines) wrapped-height computation; only content/width changes can
-- invalidate it, so cursor moves (the common trigger) reuse it
local height_cache = {}

--- @param target_win number
--- @return number
local function get_win_buf_height(target_win)
  local buf = vim.api.nvim_win_get_buf(target_win)

  -- not wrapping, so just get the line count
  if not vim.wo[target_win].wrap then
    return vim.api.nvim_buf_line_count(buf)
  end

  local width = vim.api.nvim_win_get_width(target_win)
  local tick = vim.b[buf].changedtick
  local cached = height_cache[buf]
  if cached and cached.tick == tick and cached.width == width then
    return cached.height
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local height = 0
  for _, l in ipairs(lines) do
    height = height + math.max(1, (math.ceil(vim.fn.strwidth(l) / width)))
  end
  height_cache[buf] = { tick = tick, width = width, height = height }
  return height
end

--- @param border string|string[]
--- @return number
local function get_col_offset(border)
  -- we only need an extra offset when working with a padded window
  if
    type(border) == "table"
    and border[1] == " "
    and border[4] == " "
    and border[7] == " "
    and border[8] == " "
  then
    return 1
  end
  return 0
end

--- Gets the starting line, handling line wrapping if enabled
--- @param target_win number
--- @param width number
--- @return number
local start_line_cache = {}
local get_content_start_line = function(target_win, width)
  local start_line = math.max(1, vim.fn.line("w0", target_win))
  if not vim.wo[target_win].wrap then
    return start_line
  end

  local bufnr = vim.api.nvim_win_get_buf(target_win)
  -- cache by (win, changedtick, top line, width): a cursor move within the same
  -- viewport reuses it; only a scroll or edit recomputes the O(lines) loop
  local tick = vim.b[bufnr].changedtick
  local cached = start_line_cache[target_win]
  if
    cached
    and cached.tick == tick
    and cached.start_line == start_line
    and cached.width == width
  then
    return cached.result
  end

  local wrapped_start_line = 1
  for _, text in
    ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, start_line - 1, false))
  do
    -- nvim_buf_get_lines sometimes returns a blob. see hrsh7th/nvim-cmp#2050
    if vim.fn.type(text) == vim.v.t_blob then
      text = vim.fn.string(text)
    end
    wrapped_start_line = wrapped_start_line
      + math.max(1, math.ceil(vim.fn.strdisplaywidth(text) / width))
  end
  start_line_cache[target_win] = {
    tick = tick,
    start_line = start_line,
    width = width,
    result = wrapped_start_line,
  }
  return wrapped_start_line
end

--- @param target_win number
--- @return { should_hide: boolean, thumb: willothy.ScrollbarGeometry, gutter: willothy.ScrollbarGeometry }
function M.get_geometry(target_win)
  local config = vim.api.nvim_win_get_config(target_win)
  local width = config.width
  local height = assert(config.height)
  local zindex = config.zindex or 30

  local buf_height = get_win_buf_height(target_win)
  if height >= buf_height then
    return { should_hide = true }
  end

  -- fractional thumb so its edges can land mid-cell
  local thumb_height = math.max(1, height * height / buf_height)

  local start_line = get_content_start_line(target_win, width or 1)
  start_line = math.min(start_line, buf_height)

  local pct = (start_line - 1) / (buf_height - height)
  pct = math.min(1, math.max(0, pct))
  local thumb_top = pct * (height - thumb_height)
  local thumb_bottom = thumb_top + thumb_height

  -- The float spans every row the (fractional) thumb touches; each cell's
  -- eighth-block char encodes how much of that cell the thumb covers. Fully
  -- covered cells are full blocks; the top edge is a bottom-aligned partial
  -- (normal hl) and the bottom edge a top-aligned partial (inverted hl, so its
  -- empty lower part renders in Normal-bg and the thumb is the cell background).
  local first = math.floor(thumb_top)
  local last = math.ceil(thumb_bottom) - 1
  local win_row = nil
  local lines = {}
  local cell_hls = {}
  for cell = first, last do
    local top = math.max(thumb_top, cell) - cell
    local bottom = math.min(thumb_bottom, cell + 1) - cell
    local covered = bottom - top
    if covered >= 0.0625 then -- skip negligible edge cells (would render blank)
      win_row = win_row or cell
      if covered >= 0.9375 then
        lines[#lines + 1] = BLOCKS[8]
        cell_hls[#cell_hls + 1] = "thumb"
      elseif bottom >= 0.9375 then
        lines[#lines + 1] = BLOCKS[clamp8(covered * 8)]
        cell_hls[#cell_hls + 1] = "thumb"
      else
        lines[#lines + 1] = BLOCKS[clamp8((1 - bottom) * 8)]
        cell_hls[#cell_hls + 1] = "thumb_inv"
      end
    end
  end
  win_row = win_row or first

  local col = width + get_col_offset(config.border) - 1

  return {
    should_hide = false,
    thumb = {
      width = 1,
      row = win_row,
      col = col,
      relative = "win",
      win = target_win,
      height = #lines,
      zindex = zindex + 2,
      lines = lines,
      cell_hls = cell_hls,
    },
    gutter = {
      width = 1,
      row = 0,
      col = col,
      relative = "win",
      win = target_win,
      height = height,
      zindex = zindex + 1,
    },
  }
end

return M
