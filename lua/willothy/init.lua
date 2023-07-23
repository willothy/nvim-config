vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.loader.enable()

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  defaults = {
    lazy = true,
    event = "VeryLazy",
  },
  spec = vim.g.minimal and "willothy.minimal" or "plugins",
  -- dev = { path = "~/projects/lua/" },
  ui = {
    size = { width = 0.8, height = 0.8 },
    wrap = false,
    border = "rounded",
  },
  install = {
    missing = true,
    colorscheme = { "minimus" },
  },
  browser = "brave",
  diff = {
    cmd = "diffview.nvim",
  },
  change_detection = {
    notify = false,
  },
  performance = {
    cache = { enabled = true },
    reset_packpath = true,
    rtp = {

      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

if vim.g.minimal then return end

require("willothy.set")

local function initialize()
  -- setup mappings
  require("willothy.mappings")

  -- setup hydras
  require("willothy.hydras")

  vim.defer_fn(
    function() vim.api.nvim_exec_autocmds("User", { pattern = "ExtraLazy" }) end,
    100
  )
end

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = vim.schedule_wrap(function()
    -- require("lazy").load("willothy")

    initialize()

    -- STOP USING THE DAMN ARROW KEYS
    -- local arrows = {
    --   [vim.keycode("<Up>")] = "<Up>",
    --   [vim.keycode("<Down>")] = "<Down>",
    --   [vim.keycode("<Left>")] = "<Left>",
    --   [vim.keycode("<Right>")] = "<Right>",
    -- }

    local modes = {
      "n",
      "i",
      "v",
      "x",
      --wtf else do I do in command mode??
      --[[ , "c" ]]
    }
    local alternates = {
      i = {
        ["<Up>"] = "<C-k>",
        ["<Down>"] = "<C-j>",
        ["<Left>"] = "<C-h>",
        ["<Right>"] = "<C-l>",
      },
      c = {
        ["<Up>"] = "<C-k>",
        ["<Down>"] = "<C-j>",
        ["<Left>"] = "<C-h>",
        ["<Right>"] = "<C-l>",
      },
      n = {
        ["<Up>"] = "k",
        ["<Down>"] = "j",
        ["<Left>"] = "h",
        ["<Right>"] = "l",
      },
      v = {
        ["<Up>"] = "k",
        ["<Down>"] = "j",
        ["<Left>"] = "h",
        ["<Right>"] = "l",
      },
    }
    local message = function(key)
      return key,
        function()
          local mode = vim.api.nvim_get_mode().mode
          local msg = ("use %s !!"):format(
            (alternates[mode] or {})[key] or "hjkl"
          )
          vim.notify(msg, "error")
        end
    end

    local norm = function(cmd)
      return function() vim.cmd.normal(cmd) end
    end
    vim.keymap.set({ "i", "c" }, "<C-j>", norm("j"), { noremap = true })
    vim.keymap.set({ "i", "c" }, "<C-k>", norm("k"), { noremap = true })
    vim.keymap.set({ "i", "c" }, "<C-h>", norm("h"), { noremap = true })
    vim.keymap.set({ "i", "c" }, "<C-l>", norm("l"), { noremap = true })
    vim.keymap.set(modes, message("<Up>"))
    vim.keymap.set(modes, message("<Down>"))
    vim.keymap.set(modes, message("<Left>"))
    vim.keymap.set(modes, message("<Right>"))
  end),
})

vim.api.nvim_create_autocmd("User", {
  pattern = "ExtraLazy",
  once = true,
  callback = function()
    require("willothy.async")

    -- setup commands
    require("willothy.commands")
  end,
})

-- setup float dragging
-- require("willothy.ui").setup({
--   resize = "<S-LeftDrag>",
-- })

-- Hacky way of detaching UI
-- vim.api.nvim_create_user_command("Detach", function()
--   local uis = vim.api.nvim_list_uis()
--   if #uis < 1 then return end
--   local chan = uis[1].chan
--   vim.fn.chanclose(chan)
-- end, {})
