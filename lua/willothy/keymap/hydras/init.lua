local set = vim.keymap.set

set("n", "<leader>bh", function() -- buffers
  require("willothy.keymap.hydras.buffers"):activate()
end, { desc = "hydra" })

set({ "n", "x" }, "<leader>gh", function() -- git
  require("willothy.keymap.hydras.git"):activate()
end, { desc = "hydra" })

set({ "n", "x" }, "<leader>o", function() -- options
  require("willothy.keymap.hydras.git"):activate()
end, { desc = "options" })

set({ "n", "x" }, "gs", function() -- swap
  require("willothy.keymap.hydras.swap"):activate()
end, { desc = "swap" })

set("n", "<leader>vt", function() -- telescope
  require("willothy.keymap.hydras.telescope"):activate()
end, { desc = "telescope" })

set("n", "<C-w>w", function() -- telescope
  require("willothy.keymap.hydras.windows"):activate()
end, { desc = "hydra" })
