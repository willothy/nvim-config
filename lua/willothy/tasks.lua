local opts = {
  strategy = {
    "toggleterm",
    use_shell = false,
    direction = "horizontal",
    open_on_start = false,
    close_on_exit = false,
    quit_on_exit = "success",
  },
  form = {
    border = "solid",
    win_opts = {
      winblend = 0,
      winhl = "FloatBorder:NormalFloat",
    },
  },
  confirm = {
    border = "solid",
    win_opts = {
      winblend = 0,
      winhl = "FloatBorder:NormalFloat",
    },
  },
  task_win = {
    border = "solid",
    win_opts = {
      winblend = 0,
      winhl = "FloatBorder:NormalFloat",
    },
  },
  help_win = {
    border = "solid",
    win_opts = {
      winblend = 0,
      winhl = "FloatBorder:NormalFloat",
    },
  },
  task_list = {
    direction = "right",
    win_opts = {
      winblend = 0,
      winhl = "FloatBorder:NormalFloat,WinBar:EdgyWinBar",
    },
  },
}

local overseer = require("overseer")

overseer.setup(opts)

vim.api.nvim_create_user_command("OverseerFloatLast", function()
  local tasks = overseer.list_tasks({ recent_first = true })
  if vim.tbl_isempty(tasks) then
    vim.notify("No tasks found", vim.log.levels.WARN)
  else
    overseer.run_action(tasks[1], "open float")
  end
end, {})

local float = require("snacks").win.new({
  border = "solid",
  relative = "editor",
  width = 30,
  height = function(self)
    if self:buf_valid() then
      local buf_height = vim.api.nvim_buf_line_count(self.buf)
      return math.min(buf_height, 30)
    end
    return 0
  end,
  row = 2,
  col = function()
    return vim.o.columns - 30 - 3
  end,

  show = false,
  backdrop = false,

  title_pos = "center",
  title = { { "  Tasks ", "OverseerTitle" } },
  fixbuf = true,

  on_buf = function(self)
    overseer.list_tasks()
    local buf = require("overseer.task_list").get_or_create_bufnr()
    vim.bo[buf].filetype = "OverseerList"
    self.buf = buf

    vim.api.nvim_create_autocmd("User", {
      pattern = "OverseerListUpdate",
      callback = vim.schedule_wrap(function()
        if self.buf and vim.api.nvim_buf_is_valid(self.buf) then
          self:update()
        end
      end),
    })
  end,

  on_win = function(self)
    self:on(
      "VimResized",
      vim.schedule_wrap(function()
        self:update()
      end),
      {
        buffer = self.buf,
      }
    )

    local error = vim.api.nvim_get_hl(0, {
      name = "DiagnosticInfo",
      link = false,
    })
    local title = vim.api.nvim_get_hl(0, {
      name = "Normal",
      link = false,
    })
    vim.api.nvim_set_hl(0, "OverseerTitle", {
      bg = error.fg,
      fg = title.bg,
    })
  end,
})

local toggle = require("snacks").toggle.new({
  name = "Overseer Menu",
  notify = false,
  get = function()
    return float:valid()
      and float.win == require("overseer.window").get_win_id()
  end,
  set = vim.schedule_wrap(function(open)
    if open == false then
      float:hide()
    else
      float:show()
    end
  end),
})

toggle:map("<leader>uo")

return toggle
