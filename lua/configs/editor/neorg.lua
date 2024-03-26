require("neorg").setup({
  lazy_loading = false,
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
    ["core.neorgcmd"] = {},
    ["core.keybinds"] = {
      config = {
        default_keybinds = true,
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

vim.api.nvim_create_autocmd("FileType", {
  pattern = "norg",
  callback = function(ev)
    vim.bo[ev.buf].shiftwidth = 4
    vim.bo[ev.buf].tabstop = 4
    vim.bo[ev.buf].softtabstop = 4
    vim.bo[ev.buf].expandtab = true
  end,
})
