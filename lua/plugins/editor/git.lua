local neogit = function(popup)
  return function()
    require("neogit").open({ popup })
  end
end

return {
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "akinsho/git-conflict.nvim",
    opts = {
      default_mappings = true, -- disable buffer local mapping created by this plugin
      default_commands = true, -- disable commands created by this plugin
      disable_diagnostics = false, -- This will disable the diagnostics in a buffer whilst it is conflicted
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
    },
    event = "User ExtraLazy",
  },
  {
    "NeogitOrg/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    event = "VeryLazy",
    opts = {
      kind = "auto",
      disable_builtin_notifications = true,
      integrations = {
        telescope = true,
        diffview = true,
      },
      log_view = {
        kind = "split",
      },
      reflog_view = {
        kind = "split",
      },
    },
    keys = {
      {
        "<leader>gc",
        neogit("commit"),
        desc = "commit",
      },
      {
        "<leader>gb",
        neogit("branch"),
        desc = "branch",
      },
      {
        "<leader>gl",
        neogit("log"),
        desc = "log",
      },
      {
        "<leader>gp",
        neogit("push"),
        desc = "push",
      },
      {
        "<leader>gd",
        neogit("diff"),
        desc = "diff",
      },
      {
        "<leader>gr",
        neogit("rebase"),
        desc = "rebase",
      },
      {
        "<leader>gS",
        neogit("stash"),
        desc = "stash",
      },
      {
        "<leader>gs",
        neogit(),
        desc = "status",
      },
    },
  },
}
