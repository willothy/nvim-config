local group = vim.api.nvim_create_augroup("piemenu_setting", {})
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = group,
  pattern = { "piemenu" },
  callback = function(ev)
    vim.keymap.set("n", "<MouseMove>", function()
      require("piemenu").highlight()
    end, { buffer = ev.buf })
    vim.keymap.set("n", "<LeftDrag>", function()
      require("piemenu").highlight()
    end, { buffer = ev.buf })
    vim.keymap.set("n", "<LeftRelease>", function()
      require("piemenu").finish()
    end, { buffer = ev.buf })
    vim.keymap.set("n", "<RightMouse>", function()
      require("piemenu").cancel()
    end, { buffer = ev.buf })
    vim.keymap.set("n", "<Esc>", function()
      require("piemenu").cancel()
    end, { buffer = ev.buf })
  end,
})

local ts = require("nvim-treesitter.ts_utils")

ts.get_node_at_cursor(0)

require("piemenu").register("main", {
  menus = {
    {
      text = "📋 copy",
      action = function()
        vim.cmd.normal({ args = { "yy" }, bang = true })
      end,
    },
    {
      text = "📝 paste",
      action = function()
        vim.cmd.normal({ args = { "p" }, bang = true })
      end,
    },
    {
      text = "✅ save",
      action = function()
        vim.cmd.write()
      end,
    },
    {
      text = "👉 goto file",
      action = function()
        vim.cmd.normal({ args = { "gF" }, bang = true })
      end,
    },
    {
      text = "📚 help",
      action = function()
        vim.cmd.help(vim.fn.expand("<cword>"))
      end,
    },
  },
})
