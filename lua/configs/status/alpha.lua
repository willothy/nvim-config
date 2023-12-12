local if_nil = vim.F.if_nil
local fnamemodify = vim.fn.fnamemodify
local filereadable = vim.fn.filereadable

local default_header = {
  type = "text",
  val = {
    [[                                  __]],
    [[     ___     ___    ___   __  __ /\_\    ___ ___]],
    [[    / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\]],
    [[   /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \]],
    [[   \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
    [[    \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
  },
  opts = {
    hl = "Type",
    shrink_margin = true,
    position = "center",
  },
}

local leader = "SPC"

--- @param sc string
--- @param txt string
--- @param keybind string? optional
--- @param keybind_opts table? optional
local function button(sc, txt, keybind, keybind_opts)
  local sc_ = sc:gsub("%s", ""):gsub(leader, "<leader>")

  local opts = {
    position = "center",
    shortcut = "{" .. sc .. "} ",
    cursor = 1,
    -- width = 50,
    align_shortcut = "left",
    hl_shortcut = {
      { "Operator", 0, 1 },
      { "Number", 1, #sc + 1 },
      { "Operator", #sc + 1, #sc + 2 },
    },
    shrink_margin = true,
  }
  if keybind then
    keybind_opts =
      if_nil(keybind_opts, { noremap = true, silent = true, nowait = true })
    opts.keymap = { "n", sc_, keybind, keybind_opts }
  end

  local function on_press()
    local key =
      vim.api.nvim_replace_termcodes(keybind .. "<Ignore>", true, false, true)
    vim.api.nvim_feedkeys(key, "t", false)
  end

  return {
    type = "button",
    val = txt,
    on_press = on_press,
    opts = opts,
  }
end

local nvim_web_devicons = {
  enabled = true,
  highlight = true,
}

local function get_extension(fn)
  local match = fn:match("^.+(%..+)$")
  local ext = ""
  if match ~= nil then
    ext = match:sub(2)
  end
  return ext
end

local function icon(fn)
  local nwd = require("nvim-web-devicons")
  local ext = get_extension(fn)
  return nwd.get_icon(fn, ext, { default = true })
end

local function file_button(fn, sc, short_fn, autocd)
  short_fn = if_nil(short_fn, fn)
  local ico_txt
  local fb_hl = {}
  if nvim_web_devicons.enabled then
    local ico, hl = icon(fn)
    local hl_option_type = type(nvim_web_devicons.highlight)
    if hl_option_type == "boolean" then
      if hl and nvim_web_devicons.highlight then
        table.insert(fb_hl, { hl, 0, #ico })
      end
    end
    if hl_option_type == "string" then
      table.insert(fb_hl, { nvim_web_devicons.highlight, 0, #ico })
    end
    ico_txt = ico .. " "
  else
    ico_txt = ""
  end
  local cd_cmd = (autocd and " | cd %:p:h" or "")
  local file_button_el = button(
    sc,
    ico_txt .. short_fn,
    "<cmd>e " .. vim.fn.fnameescape(fn) .. cd_cmd .. " <CR>"
  )
  local fn_start = short_fn:match(".*[/\\]")
  if fn_start ~= nil then
    table.insert(fb_hl, { "Comment", #ico_txt, #fn_start + #ico_txt })
  end
  file_button_el.opts.hl = fb_hl
  return file_button_el
end

local default_mru_ignore = { "gitcommit" }

local mru_opts = {
  ignore = function(path, ext)
    return (string.find(path, "COMMIT_EDITMSG"))
      or (vim.tbl_contains(default_mru_ignore, ext))
  end,
  autocd = false,
}

local mru_cache = {}

--- @param start number
--- @param cwd string? optional
--- @param items_number number? optional number of items to generate, default = 10
local function mru(start, cwd, items_number, opts)
  if cwd and mru_cache[cwd] then
    return {
      type = "group",
      val = mru_cache[cwd],
      opts = {},
    }
  elseif mru_cache[true] then
    return {
      type = "group",
      val = mru_cache[true],
      opts = {},
    }
  end
  opts = opts or mru_opts
  items_number = if_nil(items_number, 10)
  local oldfiles = {}
  for _, v in pairs(vim.v.oldfiles) do
    if #oldfiles == items_number then
      break
    end
    local cwd_cond
    if not cwd then
      cwd_cond = true
    else
      cwd_cond = vim.startswith(v, cwd)
    end
    local ignore = (opts.ignore and opts.ignore(v, get_extension(v))) or false
    if (filereadable(v) == 1) and cwd_cond and not ignore then
      oldfiles[#oldfiles + 1] = v
    end
  end

  local tbl = {}
  local longest = 0
  for i, fn in ipairs(oldfiles) do
    local short_fn
    if cwd then
      short_fn = fnamemodify(fn, ":.")
    else
      short_fn = fnamemodify(fn, ":~")
    end
    local file_button_el =
      file_button(fn, tostring(i + start - 1), short_fn, opts.autocd)
    longest = math.max(longest, #file_button_el.val)
    tbl[i] = file_button_el
  end

  for _, el in ipairs(tbl) do
    el.val = string.rep(" ", longest - #el.val) .. el.val
  end

  if cwd and #tbl > 0 then
    mru_cache[cwd] = tbl
  elseif #tbl > 0 then
    mru_cache[true] = tbl
  end
  return {
    type = "group",
    val = tbl,
    opts = {},
  }
end

local function mru_title()
  return "MRU " .. vim.fn.getcwd()
end

local function wrap_text(text, width)
  local lines = {}
  local line = ""
  for word in text:gmatch("%S+") do
    if #line + #word + 1 > width then
      table.insert(lines, line)
      line = ""
    end
    line = line .. " " .. word
  end
  table.insert(lines, line)
  return lines
end

local alpha_buf

local find_alpha_buf = function()
  if alpha_buf and vim.api.nvim_buf_is_valid(alpha_buf) then
    return alpha_buf
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].filetype == "alpha" then
      alpha_buf = buf
      return buf
    end
  end
  return nil
end

local tip

local tip_val
tip = {
  type = "group",
  position = "center",
  shrink_margin = true,
  val = function()
    if tip_val then
      return tip_val
    end
    vim.system(
      { "curl", "https://vtip.43z.one" },
      { text = true },
      vim.schedule_wrap(function(obj)
        tip_val = {
          { type = "padding", val = 1 },
          unpack(vim
            .iter(wrap_text(obj.stdout, 50))
            :map(function(line)
              return {
                type = "text",
                val = line,
                opts = {
                  hl = "SpecialComment",
                  shrink_margin = true,
                  position = "center",
                },
              }
            end)
            :totable()),
        }
        if find_alpha_buf() then
          vim.api.nvim_buf_call(alpha_buf, function()
            require("alpha").redraw()
          end)
        end
      end)
    )
    return { { val = "", type = "text" } }
  end,
}

local section = {
  header = default_header,
  top_buttons = {
    type = "group",
    val = {
      button("e", "New file", "<cmd>ene <CR>"),
    },
    shrink_margin = true,
  },
  mru_cwd = {
    type = "group",
    opts = {
      margin = 0,
      shrink_margin = true,
    },
    val = {
      {
        type = "padding",
        val = 1,
        opts = {
          shrink_margin = true,
        },
      },
      {
        type = "text",
        val = mru_title,
        opts = {
          hl = "SpecialComment",
          shrink_margin = true,
          position = "center",
        },
      },
      {
        type = "padding",
        val = 1,
        opts = {
          shrink_margin = true,
        },
      },
      {
        type = "group",
        val = function()
          return { mru(0, vim.fn.getcwd(), 5) }
        end,
        opts = {
          shrink_margin = true,
        },
      },
    },
  },
  footer = tip,
}

local term = require("alpha.term")

term.calc_position = function(parent_id, el, state, line)
  vim.wo[parent_id].number = false
  vim.wo[parent_id].relativenumber = false
  local parent_win_width = state.win_width
  local position = vim.api.nvim_win_get_position(parent_id)
  local res = {}
  res.row = math.floor(position[1] + line)
  res.col = math.floor(
    ((parent_win_width - el.width) / 2)
      + (position[2] * 2)
      + vim.api.nvim_eval_statusline(vim.wo[parent_id].statuscolumn, {
        use_statuscol_lnum = vim.api.nvim_buf_line_count(
          vim.api.nvim_win_get_buf(parent_id)
        ),
        winid = parent_id,
      }).width
  )
  return res
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "alpha",
  callback = function(ev)
    local win
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if
        vim.api.nvim_get_option_value(
          "filetype",
          { buf = vim.api.nvim_win_get_buf(w) }
        ) == "alpha"
      then
        win = w
        break
      end
    end
    if win then
      vim.wo[win].number = false
      vim.wo[win].relativenumber = false
    end
    vim.b[ev.buf].miniindentscope_disable = true
  end,
})

local layout = {
  {
    type = "padding",
    val = math.floor((vim.o.lines - #default_header.val - 20) / 2),
  },
  -- {
  --   type = "terminal",
  --   val = 0,
  --   width = 60,
  --   height = 10,
  --   command = "btm --basic",
  --   opts = {},
  -- },
  section.header,
  { type = "padding", val = 2 },
  section.top_buttons,
  section.mru_cwd,
  section.footer,
}

local function recalculate_layout()
  local top_padding = vim.o.lines
  local function val(x)
    if type(x) == "table" then
      return #x
    end
    if type(x) == "function" then
      return #x()
    end
    return x
  end
  for _, el in ipairs(layout) do
    top_padding = math.max(0, top_padding - (el.height or val(el.val)))
  end
  top_padding = math.floor(top_padding / 2)
  layout[1].val = top_padding
end

recalculate_layout()

local config = {
  layout = layout,
  opts = {
    margin = 0,
    redraw_on_resize = true,
    setup = function()
      vim.api.nvim_create_autocmd("DirChanged", {
        pattern = "*",
        group = "alpha_temp",
        callback = function()
          if find_alpha_buf() then
            vim.api.nvim_buf_call(alpha_buf, function()
              require("alpha").redraw()
              vim.cmd("AlphaRemap")
            end)
          end
        end,
      })
    end,
  },
}

-- {
--   '                     .:::!~!!!!!:.',
--   '                  .xUHWH!! !!?M88WHX:.',
--   '                .X*#M@$!!  !X!M$$$$$$WWx:.',
--   '               :!!!!!!?H! :!$!$$$$$$$$$$8X:',
--   '              !!~  ~:~!! :~!$!#$$$$$$$$$$8X:',
--   '             :!~::!H!<   ~.U$X!?R$$$$$$$$MM!',
--   '             ~!~!!!!~~ .:XW$$$U!!?$$$$$$RMM!',
--   '               !:~~~ .:!M"T#$$$$WX??#MRRMMM!',
--   '               ~?WuxiW*`   `"#$$$$8!!!!??!!!',
--   '             :X- M$$$$       `"T#$T~!8$WUXU~',
--   '            :%`  ~#$$$m:        ~!~ ?$$$$$$',
--   '          :!`.-   ~T$$$$8xx.  .xWW- ~""##*"',
--   '.....   -~~:<` !    ~?T#$$@@W@*?$$      /`',
--   'W$@@M!!! .!~~ !!     .:XUW$W!~ `"~:    :',
--   '#"~~`.:x%`!!  !H:   !WM$$$$Ti.: .!WUn+!`',
--   ':::~:!!`:X~ .: ?H.!u "$$$B$$$!W:U!T$$M~',
--   '.~~   :X@!.-~   ?@WTWo("*$$$W$TH$! `',
--   'Wi.~!X$?!-~   :: ?$$$B$Wu("**$RM!',
--   '$R@i.~~ !    ::   ~$$$$$B$$en:``',
--   '?MXT@Wx.~   ::     ~"##*$$$$M'
-- }

require("alpha").setup(config)
