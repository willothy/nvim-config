require("Comment").setup({
  toggler = { -- Normal Mode
    line = "gcc",
    block = "gcb",
  },
  opleader = { -- Visual mode
    block = "gC",
    line = "gc",
  },
  extra = {
    eol = "gc$",
  },
})

-- vim.keymap.set("n", "C", function()
--   --[[   require("which-key").show(":qgC", { mode = "n" }) ]]
--   require("which-key").show_command("gc")
-- end, {})
