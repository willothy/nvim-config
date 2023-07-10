local icons = require("willothy.icons")

return {
  {
    "lewis6991/gitsigns.nvim",
    lazy = false,
    opts = {
      signs = {
        untracked = { text = icons.git.signs.bar },
        add = { text = icons.git.signs.bar },
        change = { text = icons.git.signs.bar },
        delete = { text = icons.git.signs.bar },
        topdelete = { text = icons.git.signs.bar },
        changedelete = { text = icons.git.signs.bar },
      },
      trouble = false,
      signcolumn = true,
    },
  },
  {
    "luukvbaal/statuscol.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",
    },
    lazy = false,
    config = function()
      local peek = require("blam").peek
      local blame = function(args)
        local line = args.mousepos.line
        peek(line)
        return false
      end

      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        relculright = true,
        segments = {
          {
            sign = {
              name = { "GitSigns*" },
              maxwidth = 1,
              colwidth = 1,
            },
            click = "v:lua.ScSa",
          },
          {
            sign = {
              name = { ".*" },
              maxwidth = 1,
              colwidth = 1,
            },
            click = "v:lua.ScSa",
          },
          {
            text = { builtin.lnumfunc, " " },
            condition = { builtin.not_empty },
            click = "v:lua.ScLa",
          },
          {
            text = { builtin.foldfunc, " " },
            click = "v:lua.ScFa",
          },
        },
        clickhandlers = {
          Lnum = builtin.lnum_click,
          FoldClose = builtin.foldclose_click,
          FoldOpen = builtin.foldopen_click,
          FoldOther = false, --builtin.foldother_click,
          DapBreakpointRejected = builtin.toggle_breakpoint,
          DapBreakpoint = builtin.toggle_breakpoint,
          DapBreakpointCondition = builtin.toggle_breakpoint,
          DiagnosticSignError = builtin.diagnostic_click,
          DiagnosticSignHint = builtin.diagnostic_click,
          DiagnosticSignInfo = builtin.diagnostic_click,
          DiagnosticSignWarn = builtin.diagnostic_click,
          GitSignsTopdelete = blame,
          GitSignsUntracked = blame,
          GitSignsAdd = blame,
          GitSignsChange = blame,
          GitSignsChangedelete = blame,
          GitSignsDelete = blame,
          gitsigns_extmark_signs_ = builtin.gitsigns_click,
          -- FoldOther = false, -- Disable builtin clickhandler
          -- Lnum = function(args)
          -- 	if args.button == "l" and args.mods:find("c") then
          -- 		print("I Ctrl-left clicked on line " .. args.mousepos.line)
          -- 	end
          -- end,
        },
      })

      -- local ScSa = _G.ScSa
      -- _G.ScSa = function(...)
      -- 	ScSa(...)
      -- end
      --
      -- local ScLa = _G.ScLa
      -- _G.ScLa = function(...)
      -- 	vim.o.mousemodel = ""
      -- 	ScLa(...)
      -- 	vim.o.mousemodel = "extend"
      -- end
      --
      -- local ScFa = _G.ScFa
      -- _G.ScFa = function(...)
      -- 	ScFa(...)
      -- 	vim.o.mousemodel = "extend"
      -- end
    end,
  },
}
