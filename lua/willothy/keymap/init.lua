-- remove all mouse mappings
local disable = {
  -- "<2-LeftMouse>",
  -- "<LeftDrag>",
  -- "<LeftRelease>",
  "<3-LeftMouse>",
  "<4-LeftMouse>",
  "<RightMouse>",
  "<2-RightMouse>",
  "<3-RightMouse>",
  "<4-RightMouse>",
}

-- TODO: rewrite all of the keymaps
--
-- this section of config is incredibly messy

return {
  setup = function()
    for _, v in ipairs(disable) do
      vim.keymap.set(
        { "n", "v", "i" },
        v,
        function() end,
        { expr = true, desc = "which_key_ignore" }
      )
    end

    local bind = willothy.map.bind

    require("which-key").register({
      ["<leader>n"] = {
        nil,
        "neorg",
        group = true,
      },
      ["<leader>nn"] = "note",
      ["<leader>nl"] = "list",
      ["<leader>ni"] = "insert",
      ["<leader>nt"] = "task",
      ["<leader>nm"] = "mode",
      ["<leader>o"] = {
        function() end,
        "options",
        group = true,
        _ = "which_key_ignore",
      },
      ["<leader>"] = {
        t = {
          name = "terminal",
          t = bind(willothy.terminal.main, "toggle", willothy.terminal.main):with_desc(
            "main"
          ),
          v = bind(
            willothy.terminal.vertical,
            "toggle",
            willothy.terminal.vertical
          ):with_desc("vertical"),
          f = bind(willothy.terminal.float, "toggle", willothy.terminal.float):with_desc(
            "float"
          ),
          x = bind(willothy.terminal.xplr, "toggle", willothy.terminal.xplr):with_desc(
            "xplr"
          ),
          y = bind(willothy.terminal.yazi, "toggle", willothy.terminal.yazi):with_desc(
            "yazi"
          ),
          s = bind(willothy.terminal, "send_to_main"):with_desc("send"),
          o = { "<cmd>OverseerFloat<cr>", "overseer: show" },
          r = {
            function()
              require("overseer").run_template()
            end,
            "overseer: run",
          },
          p = {
            function()
              willothy.terminal.py:toggle()
            end,
            "python",
          },
          l = {
            function()
              willothy.terminal.lua:toggle()
            end,
            "lua",
          },
        },
      },
    })

    require("willothy.keymap.editor")
    require("willothy.keymap.terminal")
    require("willothy.keymap.cycle")
    require("willothy.keymap.view")
    require("willothy.keymap.find")
    require("willothy.keymap.git")
    require("willothy.keymap.buffer")
    require("willothy.keymap.projects")
    require("willothy.keymap.lsp")
    require("willothy.keymap.jump")
    require("willothy.keymap.window")
    require("willothy.keymap.hydras")
  end,
}
