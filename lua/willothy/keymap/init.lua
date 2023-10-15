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

    local bind = willothy.keymap.bind

    require("which-key").register({
      ["<leader>"] = {
        t = {
          name = "terminal",
          t = bind(willothy.term.main, "toggle", willothy.term.main):with_desc(
            "main"
          ),
          v = bind(willothy.term.vertical, "toggle", willothy.term.vertical):with_desc(
            "vertical"
          ),
          f = bind(willothy.term.float, "toggle", willothy.term.float):with_desc(
            "float"
          ),
          x = bind(willothy.term.xplr, "toggle", willothy.term.xplr):with_desc(
            "xplr"
          ),
          s = bind(willothy.term, "send_to_main"):with_desc("send"),
          o = { "<cmd>OverseerFloat<cr>", "overseer: show" },
          r = {
            function()
              require("overseer").run_template()
            end,
            "overseer: run",
          },
          p = {
            function()
              willothy.term.py:toggle()
            end,
            "python",
          },
          l = {
            function()
              willothy.term.lua:toggle()
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
  end,
}
