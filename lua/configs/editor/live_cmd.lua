require("live-command").setup({
  commands = {
    Norm = { cmd = "norm" },
    Visual = {
      cmd = "norm",
      args = function(opts)
        return "v" .. opts.args
      end,
    },
    Reg = {
      cmd = "norm",
      args = function(opts)
        return (opts.count == -1 and "" or opts.count) .. "@" .. opts.args
      end,
      range = "",
    },
  },
})
