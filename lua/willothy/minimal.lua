return {
  { "willothy/nvim-cokeline", config = true },
  {
    "glacambre/firenvim",
    lazy = false,
    cond = vim.g.started_by_firenvim ~= nil,
    build = function()
      require("lazy").load({ plugins = "firenvim", wait = true })
      vim.fn["firenvim#install"](0)
    end,
  },
}
