local wezterm = require("wezterm")

wezterm.setup({})

willothy.fn.create_command("Wezterm", {
  command = function()
    vim.notify("Wezterm {zoom, spawn}", vim.log.levels.INFO, {
      title = "Usage",
    })
  end,
  subcommands = {
    zoom = {
      execute = function()
        wezterm.zoom_pane(wezterm.get_current_pane(), {
          toggle = true,
        })
      end,
    },
    spawn = {
      execute = function(...)
        vim.cmd(string.format("WeztermSpawn %s", table.concat({ ... }, " ")))
      end,
    },
  },
})
