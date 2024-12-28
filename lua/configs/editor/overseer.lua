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

local win
vim.api.nvim_create_user_command("OverseerFloat", function(args)
  overseer.list_tasks()
  local width, height, offset = 30, 30, 3
  local buf = require("overseer.task_list").get_or_create_bufnr()
  vim.bo[buf].filetype = "OverseerList"
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
    win = nil
    return
  end
  win = willothy.win.open(buf, {
    relative = "editor",
    width = width,
    height = height,
    row = 2,
    col = vim.o.columns - width - offset,
    border = "solid",
    noautocmd = true,
  }, true)
  vim.api.nvim_set_hl(0, "EdgyFloatTitle", {
    fg = require("willothy.lib.hl").get("EdgyTitle", "fg"),
    bg = require("willothy.lib.hl").get("NormalFloat", "bg"),
  })
  vim.wo[win].winhl = vim
    .iter({
      FloatBorder = "NormalFloat",
      WinBar = "NormalFloat",
    })
    :fold("", function(acc, name, hl)
      return acc .. name .. ":" .. hl .. ","
    end)
    :sub(1, -2)
  vim.wo[win].winbar = "%#EdgyFloatTitle#Overseer "
    .. require("willothy.lib.fn").make_clickable(
      require("willothy.lib.fn").debounce_leading(function()
        require("overseer").run_template()
      end, 200),
      "󰒐"
    )

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(vim.api.nvim_get_current_win(), true)
  end, { buffer = buf })
  local group = vim.api.nvim_create_augroup("OverseerFloat", { clear = true })
  vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    buffer = buf,
    callback = function()
      if win and vim.api.nvim_win_is_valid(win) then
        local config = vim.api.nvim_win_get_config(win)
        config.row = 2
        config.col = vim.o.columns - width - offset
        vim.api.nvim_win_set_config(win, config)
      end
    end,
  })
  vim.api.nvim_create_autocmd("BufWinLeave", {
    buffer = buf,
    group = group,
    callback = function()
      vim.schedule(function()
        if
          win
          and vim.api.nvim_win_is_valid(win)
          and vim.api.nvim_buf_is_valid(buf)
        then
          vim.api.nvim_win_set_buf(win, buf)
          win = nil
        end
      end)
    end,
  })
  if args.bang then
    vim.api.nvim_create_autocmd("BufLeave", {
      group = group,
      buffer = buf,
      callback = function()
        if win and vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end,
    })
  end
  if #args.fargs > 0 then
    overseer
      .new_task({
        cmd = args.fargs,
      })
      :start()
  end
end, {
  nargs = "*",
  bang = true,
})
