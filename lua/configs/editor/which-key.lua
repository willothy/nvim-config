require("which-key").setup({
  plugins = {
    presets = {
      operators = false,
      windows = false,
      nav = true,
      z = true,
      g = false,
      text_objects = false,
    },
  },
  operators = {
    gc = "comment",

    --text-case.nvim
    gau = "uppercase",
    gal = "uppercase",
    gas = "snake case",
    gak = "kebab case",
    gac = "camel case",
    gap = "pascal case",
    gad = "dot case",
    gat = "title case",
    ["ga/"] = "path case",

    v = "visual",
    [">"] = "indent",
    ["<lt>"] = "unindent",
    gu = "lowercase",
    gU = "uppercase",
    ["g~"] = "toggle case",
    ["!"] = "ext. filter",
    y = "yank",
    d = "delete",
    c = "change",
    ["="] = "indent",
  },
  -- triggers = "auto",
  triggers_nowait = {
    -- marks
    "`",
    "'",
    "g`",
    "g'",
    -- registers
    '"',
    "<c-r>",
    -- spelling
    "z=",
    -- [">"] = "indent",
    -- ["<lt>"] = "unindent",
  },
  motions = {
    count = true,
  },
  key_labels = {
    ["<leader>"] = "",
    ["<space>"] = "SPC",
    ["<cr>"] = "RET",
    ["<tab>"] = "TAB",
  },
  window = {
    position = "bottom",
    border = "single",
    title = "test",
    winblend = 0,
    margin = {
      0,
      0,
      1,
      function()
        return math.max(
          vim.o.columns - 32,
          (math.floor(vim.o.columns / 4) * 3)
        )
      end,
    },
    padding = { 1, 0, 1, 0 },
    padding = { 0, 0, 0, 0 },
    zindex = 200,
  },
  layout = {
    height = { min = 4, max = 30 }, -- min and max height of the columns
    width = { min = 20, max = 30 }, -- min and max width of the columns
    spacing = 1, -- spacing between columns
    align = "left", -- align columns left, center or right
  },
  show_help = false,
  icons = {
    group = "",
  },
  sort_by_description = true,
  ignore_missing = false,
})
