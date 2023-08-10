local bar = require("willothy.util.icons").git.signs.bar
require("gitsigns").setup({
  signs = {
    untracked = { text = bar },
    add = { text = bar },
    change = { text = bar },
    delete = { text = bar },
    topdelete = { text = bar },
    changedelete = { text = bar },
  },
  trouble = false,
  signcolumn = true,
})
