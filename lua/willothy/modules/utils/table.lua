local M = {}

function M.show(t, column_order)
  -- Adapted for Neovim from https://github.com/hishamhm/tabular
  local draw = {
    NW = "/",
    NE = "\\",
    SW = "\\",
    SE = "/",
    N = "+",
    S = "+",
    E = "+",
    W = "+",
    V = "|",
    H = "-",
    X = "+",
  }

  local strsub = string.sub

  if (os.getenv("LANG") or ""):upper():match("UTF%-?8") then
    draw = {
      NW = "┌",
      NE = "┐",
      SW = "└",
      SE = "┘",
      N = "┬",
      S = "┴",
      E = "┤",
      W = "├",
      V = "│",
      H = "─",
      X = "┼",
    }

    strsub = function(s, i, j)
      local uj = vim.str_utf_pos(s, j + 1)
      if uj then
        uj = uj - 1
      end
      return s:sub(vim.str_utf_pos(s, i), uj)
    end
  end

  local strlen = vim.fn.strcharlen

  local show
  local show_as_columns

  local function output_line(out, line)
    table.insert(out, line)
    out.width = math.max(out.width or 0, strlen(line))
  end

  local function escape_chars(c)
    return "\\" .. string.byte(c)
  end

  local function show_as_list(tbl, color, seen, ids, skip_array)
    local tt = {}
    local width = 0
    local keys = {}

    for k, v in pairs(tbl) do
      if not skip_array or type(k) ~= "number" then
        table.insert(tt, { k, v })
        keys[k] = tostring(k)
        width = math.max(width, strlen(keys[k]))
      end
    end

    table.sort(tt, function(a, b)
      if type(a[1]) == "number" and type(b[1]) == "number" then
        return a[1] < b[1]
      else
        return tostring(a[1]) < tostring(b[1])
      end
    end)

    for i = 1, #tt do
      local k = keys[tt[i][1]]
      tt[i][1] = k .. " " .. ("."):rep(width - strlen(k)) .. ":"
    end

    return show_as_columns(tt, color, seen, ids, nil, true)
  end

  local function show_primitive(tbl)
    local out = {}
    local s = tostring(tbl)

    if vim.fn.strcharlen(s) then
      s = s:gsub("[\n\t]", {
        ["\n"] = "\\n",
        ["\t"] = "\\t",
      })
    else
      s = s:gsub("[%z-\31\127-\255]", escape_chars)
    end

    if strlen(s) > 80 then
      for i = 1, strlen(s), 80 do
        output_line(out, strsub(s, i, i + 79))
      end
    else
      output_line(out, s)
    end

    return out
  end

  show_as_columns = function(tbl, bgcolor, seen, ids, col_order, skip_header)
    local columns = {}
    local row_heights = {}

    local column_names
    local column_set

    if col_order then
      column_names = col_order
      column_set = {}
      for _, cname in ipairs(column_names) do
        column_set[cname] = true
      end
    end

    for i, row in ipairs(tbl) do
      if type(row) == "table" then
        for k, v in pairs(row) do
          local sk = tostring(k)
          if (not column_set) or column_set[sk] then
            if not columns[sk] then
              columns[sk] = {}
              columns[sk].width = strlen(sk)
            end
            local sv = show(v, nil, seen, ids)
            columns[sk][i] = sv
            columns[sk].width = math.max(columns[sk].width, sv.width)
            row_heights[i] = math.max(row_heights[i] or 0, #sv)
          end
        end
      end
    end

    if not col_order then
      column_names = {}
      column_set = {}
      for name, _row in pairs(columns) do
        if not column_set[name] then
          table.insert(column_names, name)
          column_set[name] = true
        end
      end
      table.sort(column_names)
    end

    local function output_cell(line, cname, text, color)
      local w = columns[cname].width
      text = text or ""
      if color then
        table.insert(line, color)
      elseif bgcolor then
        table.insert(line, bgcolor)
      end
      table.insert(line, text .. (" "):rep(w - strlen(text)))
      if color then
        table.insert(line, bgcolor)
      end
      table.insert(line, draw.V)
    end

    local out = {}

    local border_top = {}
    local border_bot = {}
    for i, cname in ipairs(column_names) do
      local w = columns[cname].width
      table.insert(border_top, draw.H:rep(w))
      table.insert(border_bot, draw.H:rep(w))
      if i < #column_names then
        table.insert(border_top, draw.N)
        table.insert(border_bot, draw.S)
      end
    end
    table.insert(border_top, 1, draw.NW)
    table.insert(border_bot, 1, draw.SW)
    table.insert(border_top, draw.NE)
    table.insert(border_bot, draw.SE)

    output_line(out, table.concat(border_top))
    if not skip_header then
      local line = { draw.V }
      local sep = { draw.V }
      for _, cname in ipairs(column_names) do
        output_cell(line, cname, cname)
        output_cell(sep, cname, draw.H:rep(strlen(cname)))
      end
      output_line(out, table.concat(line))
      output_line(out, table.concat(sep))
    end

    for i = 1, #tbl do
      for h = 1, row_heights[i] or 1 do
        local line = { draw.V }
        for _, cname in ipairs(column_names) do
          local row = columns[cname][i]
          output_cell(line, cname, row and row[h] or "", nil)
        end
        output_line(out, table.concat(line))
      end
    end
    output_line(out, table.concat(border_bot))

    local mt = tbl
    for k, _v in pairs(mt) do
      if type(k) ~= "number" then
        local out2 = show_as_list(mt, bgcolor, seen, ids, true)
        for _, line in ipairs(out2) do
          output_line(out, line)
        end
        break
      end
    end

    return out
  end

  show = function(tbl, color, seen, ids, col_order)
    if type(tbl) == "table" and seen[tbl] then
      local msg = "<see " .. ids[tbl] .. ">"
      return { msg, width = strlen(msg) }
    end
    seen[tbl] = true

    if type(tbl) == "table" then
      local tt = tbl
      if #tt > 0 and type(tt[1]) == "table" then
        return show_as_columns(tt, color, seen, ids, col_order)
      else
        return show_as_list(tt, color, seen, ids)
      end
    else
      return show_primitive(tbl)
    end
  end

  local function detect_cycles(tbl, n, seen)
    n = n or 0
    seen = seen or {}
    if type(tbl) == "table" then
      if seen[tbl] then
        return seen
      end
      n = n + 1
      seen[tbl] = n
      for _k, v in pairs(tbl) do
        seen, n = detect_cycles(v, n, seen)
      end
    end
    return seen, n
  end

  local ids = detect_cycles(t)
  return table.concat(show(t, nil, {}, ids, column_order), "\n")
end

return M
