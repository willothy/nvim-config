local git_hydra_hint = [[
 _J_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
 _K_: prev hunk   _u_: undo last stage   _p_: preview hunk   _B_: blame show full
 ^ ^              _S_: stage buffer      ^ ^                 _/_: show base file
 ^
 ^ ^              _<Enter>_: Neogit           _q_, _<Esc>_: exit
]]

local Git = require("hydra")({
  name = "Git",
  hint = git_hydra_hint,
  short_name = "G󰊢",
  config = {
    desc = "hydra",
    color = "pink",
    invoke_on_body = true,
    hint = {
      border = "single",
      position = "bottom-left",
    },
    on_enter = function()
      local gitsigns = require("gitsigns")
      gitsigns.toggle_linehl(true)
    end,
    on_exit = function()
      local gitsigns = require("gitsigns")
      gitsigns.toggle_linehl(false)
    end,
  },
  mode = { "n", "x" },
  body = "<leader>gh",
  heads = {
    {
      "J",
      function()
        if vim.wo.diff then
          return "]c"
        end
        local gitsigns = require("gitsigns")
        vim.schedule(function()
          gitsigns.next_hunk()
        end)
        return "<Ignore>"
      end,
      { expr = true, desc = "next hunk" },
    },
    {
      "K",
      function()
        if vim.wo.diff then
          return "[c"
        end
        local gitsigns = require("gitsigns")
        vim.schedule(function()
          gitsigns.prev_hunk()
        end)
        return "<Ignore>"
      end,
      { expr = true, desc = "prev hunk" },
    },
    {
      "s",
      ":Gitsigns stage_hunk<CR>",
      { silent = true, desc = "stage hunk" },
    },
    {
      "u",
      function()
        local gitsigns = require("gitsigns")
        gitsigns.undo_stage_hunk()
      end,
      { desc = "undo last stage" },
    },
    {
      "S",
      function()
        local gitsigns = require("gitsigns")
        gitsigns.stage_buffer()
      end,
      { desc = "stage buffer" },
    },
    {
      "p",
      function()
        local gitsigns = require("gitsigns")
        gitsigns.preview_hunk()
      end,
      { desc = "preview hunk" },
    },
    {
      "d",
      function()
        local gitsigns = require("gitsigns")
        gitsigns.toggle_deleted()
      end,
      { nowait = true, desc = "toggle deleted" },
    },
    {
      "b",
      function()
        local gitsigns = require("gitsigns")
        gitsigns.blame_line()
      end,
      { desc = "blame" },
    },
    {
      "B",
      function()
        local gitsigns = require("gitsigns")
        gitsigns.blame_line({ full = true })
      end,
      { desc = "blame show full" },
    },
    {
      "/",
      function()
        local gitsigns = require("gitsigns")
        pcall(gitsigns.show)
      end,
      { exit = true, desc = "show base file" },
    }, -- show the base of the file
    {
      "<Enter>",
      vim.cmd.Neogit,
      { exit = true, desc = "Neogit" },
    },
    { "q", nil, { exit = true, nowait = true, desc = "exit" } },
    { "<Esc>", nil, { exit = true, nowait = true, desc = "exit" } },
  },
})

return Git
