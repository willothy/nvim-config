require("neorg").setup({
  load = {
    ["core.defaults"] = {},
    ["core.concealer"] = {},
    ["core.dirman"] = {
      config = {
        workspaces = {
          notes = "~/notes",
        },
        default_workspace = "notes",
      },
    },
    ["core.integrations.treesitter"] = {
      config = {
        configure_parsers = true,
        install_parsers = true,
      },
    },
    ["core.completion"] = {
      config = {
        engine = "nvim-cmp",
        name = "Neorg",
      },
    },
    ["core.highlights"] = {},
    ["core.mode"] = {},
    ["core.export"] = {},
    ["core.export.markdown"] = {},
    ["core.summary"] = {},
    ["core.ui"] = {},
    ["core.ui.calendar"] = {},
  },
})
