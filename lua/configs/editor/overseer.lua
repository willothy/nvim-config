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

require("overseer").setup(opts)
