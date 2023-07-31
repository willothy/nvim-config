return {
  {
    "ellisonleao/glow.nvim",
    config = true,
    cmd = "Glow",
  },
  {
    "eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
  },
  {
    "rafcamlet/nvim-luapad",
    cmd = "Luapad",
    config = true,
  },
  {
    "Aasim-A/scrollEOF.nvim",
    -- enabled = false,
    config = true,
    event = "User ExtraLazy",
  },
  {
    "lambdalisue/suda.vim",
    cmd = { "SudaRead", "SudaWrite" },
  },
  {
    "jackMort/ChatGPT.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = {
      "ChatGPT",
      "ChatGPTActAs",
      "ChatGPTEditWithInstructions",
      "ChatGPTRun",
    },
    opts = {
      async_api_key_cmd = "lpass show --password openai_key",
    },
  },
  { "mbbill/undotree", event = "VeryLazy" },
  { "famiu/bufdelete.nvim" },
  {
    "ecthelionvi/NeoComposer.nvim",
    requires = { "kkharji/sqlite.lua" },
    event = "User ExtraLazy",
    opts = {
      colors = {
        bg = "#26283f",
      },
    },
  },
  {
    "nmac427/guess-indent.nvim",
    opts = {
      auto_cmd = true,
    },
    cmd = "GuessIndent",
  },
  {
    "Dhanus3133/LeetBuddy.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = {
      "LBQuestions",
      "LBQuestion",
      "LBReset",
      "LBTest",
      "LBSubmit",
      "LBChangeLanguage",
    },
    config = true,
  },
  {
    "EtiamNullam/deferred-clipboard.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "kkharji/sqlite.lua",
  },
  {
    "nacro90/numb.nvim",
    config = true,
    event = "User ExtraLazy",
  },
  {
    "willothy/futures.nvim",
  },
  {
    "jbyuki/venn.nvim",
    cmd = { "VBox" },
  },
  {
    "gbprod/substitute.nvim",
    opts = {
      yank_substituted_text = true,
    },
  },
  {
    "ecthelionvi/NeoColumn.nvim",
    event = "User ExtraLazy",
    opts = {
      always_on = false,
    },
  },
  {
    "tamton-aquib/keys.nvim",
    config = true,
    cmd = "KeysToggle",
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = true,
    event = "User ExtraLazy",
  },
  {
    "LunarVim/bigfile.nvim",
    opts = {
      filesize = 4,
      pattern = { "*" },
      features = {
        "treesitter",
      },
    },
    event = "User VeryLazy",
  },
  {
    "m-demare/attempt.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local template = function(lang)
        return function()
          return require("willothy.templates")[lang]
        end
      end
      require("attempt").setup({
        dir = "/tmp/attempt.nvim/",
        autosave = false,
        list_buffers = true,
        ext_options = { "lua", "rs", "cpp", "c", "html", "js", "py", "" },
        initial_content = {
          py = template("py"),
          lua = template("lua"),
          rs = template("rust"),
          c = template("c"),
          cpp = template("cpp"),
          html = template("html"),
        },
      })
      vim.api.nvim_create_user_command("Attempt", function(e)
        local a = require("attempt")
        local args = vim.split(e.args, " ")
        local subcmd = args[1]
        if subcmd == "new" then
          if args[2] then
            a.new({
              ext = args[2],
              initial_content = template(args[2]) or "",
            })
          end
        elseif subcmd == "open" then
          a.open_select()
        elseif subcmd == "rename" then
          a.rename_buf(nil)
        end
      end, {
        nargs = "?",
      })
    end,
    cmd = "Attempt",
  },
  {
    "rawnly/gist.nvim",
    cmd = { "GistCreate", "GistCreateFromFile", "GistsList" },
    config = true,
  },
  {
    "Saecki/crates.nvim",
    config = function()
      require("crates").setup({
        null_ls = {
          enabled = true,
          name = "crates.nvim",
        },
      })
      require("cmp").setup.buffer({ sources = { { name = "crates" } } })
    end,
    event = "BufRead Cargo.toml",
  },
  {
    "tomiis4/Hypersonic.nvim",
    event = "CmdlineEnter",
    cmd = "Hypersonic",
    config = true,
  },
  {
    "creativenull/dotfyle-metadata.nvim",
  },
  -- TODO: This is cool. Figure out what is does.
  -- {
  --   "notomo/thetto.nvim",
  --   config = true,
  --   event = "User ExtraLazy",
  -- },
}
