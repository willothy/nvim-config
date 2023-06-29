return {
  {
    "numToStr/Navigator.nvim",
    config = true,
    enabled = false,
  },
  {
    "mrjones2014/smart-splits.nvim",
    lazy = true,
    opts = {
      multiplexer_integration = "wezterm",
    },
    event = "VimEnter",
  },
}
