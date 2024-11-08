-- Define all block drawing characters for finer control over partial blocks

local chars_l = {
  [1] = "▏",
  [2] = "▎",
  [3] = "▍",
  [4] = "▌",
  [5] = "▋",
  [6] = "▊",
  [7] = "▉",
  [8] = "█",
}
local chars_r = {
  [1] = "▕",
  [2] = "🮇",
  [3] = "🮈",
  [4] = "▐",
  [5] = "🮉",
  [6] = "🮊",
  [7] = "🮋",
  [8] = "█",
}

local chars_t = {
  [1] = "▔",
  [2] = "🮂",
  [3] = "🮃",
  [4] = "▀",
  [5] = "🮄",
  [6] = "🮅",
  [7] = "🮆",
  [8] = "█",
}

local chars_b = {
  [1] = "▁",
  [2] = "▂",
  [3] = "▃",
  [4] = "▄",
  [5] = "▅",
  [6] = "▆",
  [7] = "▇",
  [8] = "█",
}

-- Function to get the nearest character based on fractional block
local function get_partial_char(fraction, chars)
  if fraction >= 7 / 8 then
    return chars[8]
  end
  if fraction >= 6 / 8 then
    return chars[7]
  end
  if fraction >= 5 / 8 then
    return chars[6]
  end
  if fraction >= 4 / 8 then
    return chars[5]
  end
  if fraction >= 3 / 8 then
    return chars[4]
  end
  if fraction >= 2 / 8 then
    return chars[3]
  end
  if fraction >= 1 / 8 then
    return chars[2]
  end
  return chars[1]
end

-- Function to calculate scrollbar with partial blocks
local function calculate_scrollbar(
  window_height,
  buffer_height,
  scrolltop,
  horizontal
)
  local scrollbar_size =
    math.max(1, math.floor(window_height * (window_height / buffer_height)))
  local scroll_range = buffer_height - window_height

  -- Calculate top and bottom positions for the scrollbar
  local relative_scroll_position = (scrolltop / scroll_range)
    * (window_height - scrollbar_size)
  local top_position = math.floor(relative_scroll_position)
  local bottom_position =
    math.floor(relative_scroll_position + scrollbar_size - 1)

  -- Calculate partial fractions for the top and bottom characters
  local top_fraction = relative_scroll_position % 1
  local bottom_fraction = (relative_scroll_position + scrollbar_size) % 1

  -- Get the appropriate characters for top and bottom partial blocks
  local top_char =
    get_partial_char(top_fraction, horizontal and chars_l or chars_t)
  local bottom_char =
    get_partial_char(1 - bottom_fraction, horizontal and chars_r or chars_b)

  -- Number of full blocks between the top and bottom partial blocks
  local full_blocks = bottom_position - top_position - 1

  return top_char, bottom_char, math.max(0, full_blocks), top_position
end

local function render_bar(window_height, buffer_height, scrolltop)
  local top_char, bottom_char, full_blocks, top =
    calculate_scrollbar(window_height, buffer_height, scrolltop)

  local bar = {}

  for _ = 1, top do
    table.insert(bar, "")
  end

  table.insert(bar, bottom_char)

  for _ = 1, full_blocks do
    table.insert(bar, chars_l[8])
  end

  table.insert(bar, top_char)

  return bar
end

-- Example usage:
local window_height = 20 -- Example window height
local buffer_height = 50 -- Example buffer (content) height
-- local scrolltop = 50 -- Example scrolltop

for i = 0, 50 do
  local scrolltop = i
  local top_char, bottom_char, full_blocks, top =
    calculate_scrollbar(window_height, buffer_height, scrolltop)

  local bar = string.format(
    "%s\n%s\n%s\n%s\n",
    string.rep(" \n", top),
    bottom_char,
    string.rep(chars_l[8] .. "\n", full_blocks),
    top_char
  )

  -- print("Top partial:", top_char)
  -- print("Bottom partial:", bottom_char)
  -- print("Full blocks:", full_blocks)
  print(i)
  print(bar)
end
