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
  task_list = {
    direction = "left",
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

vim.api.nvim_create_user_command("OverseerFloat", function(args)
  local width, height, offset = 30, 30, 3
  local buf = require("overseer.task_list").get_or_create_bufnr()
  local win = willothy.utils.window.open(buf, {
    relative = "editor",
    width = width,
    height = height,
    row = 2,
    col = vim.o.columns - width - offset,
    border = "solid",
  }, true)
  vim.wo[win].winhl = vim
    .iter({
      FloatBorder = "NormalFloat",
      WinBar = "NormalFloat",
    })
    :fold("", function(acc, name, hl)
      return acc .. name .. ":" .. hl .. ","
    end)
    :sub(1, -2)
  vim.wo[win].winbar = "%#EdgyTitle#Overseer "
    .. willothy.fn.make_clickable(function()
      require("overseer").run_template({
        name = "shell",
      })
    end, "+")

  vim.keymap.set("n", "q", function()
    if win and vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf })
  vim.api.nvim_create_autocmd("VimResized", {
    group = vim.api.nvim_create_augroup("OverseerFloat", { clear = true }),
    callback = function()
      local config = vim.api.nvim_win_get_config(win)
      config.row = 2
      config.col = vim.o.columns - width - offset
      vim.api.nvim_win_set_config(win, config)
    end,
  })
  if args.bang then
    vim.api.nvim_create_autocmd("BufLeave", {
      buffer = buf,
      callback = function()
        if win and vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end,
    })
  end
  vim.print(args)
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
