local api = vim.api
local buf_set_extmark = api.nvim_buf_set_extmark
local buf_clear_ns = api.nvim_buf_clear_namespace

local ns = vim.api.nvim_create_namespace("willothy/progress")

local buf = vim.api.nvim_get_current_buf()
local win = vim.api.nvim_get_current_win()

buf_clear_ns(buf, ns, 0, -1)

local progress = function(timeout, message)
  timeout = timeout or 1000
  message = message or ""
  local function make_progressbar(percent)
    local width = 20

    local chars = {
      eighth = "▏",
      quarter = "▎",
      three_eighths = "▍",
      half = "▌",
      five_eighths = "▋",
      three_quarters = "▊",
      seven_eighths = "▉",
      full = "█",
    }

    local res = {}
    local full = (percent / 100) * width
    local remainder = (full - math.floor(full)) * 100
    full = math.floor(full)
    table.insert(
      res,
      { string.rep(chars.full, full), "NoiceLspProgressSpinner" }
    )
    local remainder_char = ""
    if remainder > 0 then
      if remainder < 13 then
        remainder_char = chars.eighth
      elseif remainder < 25 then
        remainder_char = chars.quarter
      elseif remainder < 38 then
        remainder_char = chars.three_eighths
      elseif remainder < 50 then
        remainder_char = chars.half
      elseif remainder < 63 then
        remainder_char = chars.five_eighths
      elseif remainder < 75 then
        remainder_char = chars.three_quarters
      elseif remainder < 88 then
        remainder_char = chars.seven_eighths
      else
        remainder_char = chars.full
      end
    end
    if remainder_char ~= "" then
      table.insert(res, { remainder_char, "NoiceLspProgressSpinner" })
    end
    local actual_width = 0
    for _, v in ipairs(res) do
      actual_width = actual_width + vim.fn.strcharlen(v[1])
    end
    table.insert(
      res,
      { string.rep(" ", width - actual_width), "NoiceLspProgressSpinner" }
    )
    return res
  end
  local function update_extmark(percent)
    local wininfo = vim.api.nvim_win_call(win, vim.fn.winsaveview)
    local text = {
      {
        require("noice.util.spinners").spin("dots13") .. " ",
        "Comment",
      },
      unpack(make_progressbar(percent)),
    }
    table.insert(text, {
      message,
      "Comment",
    })
    table.insert(text, {
      (" %2.d%% "):format(percent),
      "Comment",
    })
    buf_set_extmark(buf, ns, wininfo.topline - 1, 0, {
      id = 1,
      virt_text_pos = "right_align",
      virt_text = text,
    })
  end

  update_extmark(0)

  local timer = vim.loop.new_timer()
  local start = vim.uv.now()
  timer:start(
    0,
    50,
    vim.schedule_wrap(function()
      local elapsed = vim.uv.now() - start
      local percent = math.floor((elapsed / timeout) * 100)
      update_extmark(percent)
      if elapsed >= timeout then
        update_extmark(100)
        vim.api.nvim_buf_del_extmark(buf, ns, 1)
        if not timer:is_closing() then
          timer:close()
        end
      end
    end)
  )
end

progress(2000)
