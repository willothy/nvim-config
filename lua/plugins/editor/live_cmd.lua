return {
  {
    "smjonas/live-command.nvim",
    cmd = { "Norm", "Reg" },
    config = function()
      require("live-command").setup({
        commands = {
          Norm = { cmd = "norm" },
          Reg = {
            cmd = "norm",
            args = function(opts)
              return (opts.count == -1 and "" or opts.count) .. "@" .. opts.args
            end,
            range = "",
          },
        },
      })
    end,
  },
}
