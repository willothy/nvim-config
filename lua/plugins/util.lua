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
}
