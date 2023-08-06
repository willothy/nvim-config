return {
  -- Core DAP plugins
  {
    "mfussenegger/nvim-dap",
    config = function()
      require("configs.debugging.dap")
      require("nvim-dap-virtual-text")
    end,
    -- event = "LspAttach",
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      clear_on_continue = true,
    },
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("configs.debugging.dap-ui")
    end,
  },
  -- Individual debugger plugins
  {
    "jbyuki/one-small-step-for-vimkind",
  },
}
