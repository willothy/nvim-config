-- local crates_list = {}
--
-- local crates = {
-- 	title = "Crates",
-- 	icon = "📦",
-- 	update = function(ctx)
-- 		crates_list = require("crates").list()
-- 	end,
-- 	draw = function(ctx)
-- 		local str = ""
-- 		local hl = {}
--
-- 		local idx = 0
-- 		for name, version in pairs(crates_list) do
-- 			str = string.sub(string.format("%s\n%s: %s", str, name, version), 1, ctx.width)
-- 			table.insert(hl, { "SidebarNvimKeyword", idx, 0, string.len(name) - 1 })
-- 			idx = idx + 1
-- 		end
-- 		return {
-- 			lines = str,
-- 			hl = hl,
-- 		}
-- 	end,
-- }

return {
  {
    "sidebar-nvim/sidebar.nvim",
    opts = {
      side = "left",
      -- open = vim.o.columns >= 150, --vim.fn.argc() ~= 0,
      open = false,
      section_separator = { " ", " " },
      sections = {
        -- "git",
        "datetime",
        "files",
        -- "symbols",
        -- "diagnostics",
        -- "todos",
        "containers",
        -- crates,
      },
    },
  },
  -- {
  -- 	"willothy/luacrates",
  -- 	build = "make",
  -- },
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = true,
    cmd = "Neotree",
    opts = {
      source_selector = {
        winbar = true,
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
    },
  },
}
