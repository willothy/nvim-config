---@diagnostic disable-next-line: missing-fields
require("flash").setup({
  modes = {
    char = {
      enabled = true,
      jump_labels = true,
      label = { exclude = "hjkliardc" },
      keys = {
        "f",
        "F",
        "t",
        "T",
        -- remove ; and , and use clever-f style repeat
      },
      config = function(opts)
        opts.autohide = vim.fn.mode(true):find("no") and vim.v.operator == "y"

        opts.jump_labels = opts.jump_labels
          and vim.v.count == 0
          and vim.fn.reg_executing() == ""
          and vim.fn.reg_recording() == ""
      end,
    },
  },
})
