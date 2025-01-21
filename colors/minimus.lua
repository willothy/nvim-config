local palette = {
  turquoise = "#5de4c7",
  tiffany_blue = "#85e2da",
  pale_azure = "#89ddff",
  uranian_blue = "#add7ff",
  powder_blue = "#91b4d5",
  cadet_gray = "#8da3bf",
  cool_gray = "#7f92aa",
  purple_gray = "#8f94c1",
  raisin_black = "#1b1e28",
  colombia_blue = "#c5d2df",
  persian_red = "#be3937",
  lemon_chiffon = "#fffac2",
  tea_rose = "#e8b1b0",
  lavender_pink = "#fcc5e9",
  pale_purple = "#fee4fc",
  pale_turquoise = "#baf5e8",
  white = "#f1f1f1",
  black = "#1f1f1f",
  ----------------------
  gunmetal = "#303340",
  dark_blue = "#26283f",
  darker_blue = "#222439",
  github_dark = "#0d1117",
  ----------------------
  rosewater = "#F5E0DC",
  flamingo = "#F2CDCD",
  pink = "#F5C2E7",
  mauve = "#CBA6F7",
  red = "#F38BA8",
  maroon = "#EBA0AC",
  peach = "#FAB387",
  yellow = "#F9E2AF",
  green = "#A6E3A1",
  teal = "#94E2D5",
  sky = "#89DCEB",
  sapphire = "#74C7EC",
  blue = "#89B4FA",
  lavender = "#B4BEFE",
  ---------------------
  text = "#bcdaf5",
  none = "none",
}

local spec = {
  background = palette.dark_blue,
  background_dark = palette.darker_blue,
  background_light = "#3d4151",

  text = palette.text, -- regular text
  -- text_semilight = "#bcdaf5",
  text_light = palette.cadet_gray, -- statusline, comments, etc.

  -- separator = "#2c3354",
  separator = "#363655",

  line_nr = "#9196c2",
  inline = "#7dacd9",

  property = "#f8bacb",
  func = "#4dccff",
  keyword = "#629cf8",
  operator = "#b4c2d5",
  special = "#a0acfe",

  diagnostic = {
    error = "#d74947",
    warn = "#fff694",
    info = palette.sapphire,
    hint = palette.sky,
  },

  diff = {
    add = palette.turquoise,
    change = palette.lemon_chiffon,
    delete = palette.red,
  },
}

require("mini.colors")
  .as_colorscheme({
    name = "minimus2",
    groups = {
      Normal = {
        bg = spec.background,
        fg = spec.text,
      },
      NormalNC = {
        link = "Normal",
      },

      Visual = {
        bg = spec.background_light,
      },

      NormalFloat = {
        fg = spec.text,
        bg = spec.background_dark,
      },
      NormalFloatNC = {
        link = "NormalFloat",
      },
      FloatBorder = {
        fg = spec.separator,
        bg = spec.background_dark,
      },
      FloatTitle = {
        fg = spec.text_light,
        bg = spec.background_dark,
      },
      FloatFooter = {
        fg = spec.text_light,
        bg = spec.background_dark,
      },

      Title = {
        fg = spec.text_light,
      },

      -- test
      WinSeparator = {
        fg = spec.separator,
      },

      -- Cursor = {},
      -- iCursor = {},
      -- TermCursor = {},

      Pmenu = {
        link = "NormalFloat",
      },
      PmenuSel = {
        bg = spec.separator,
      },
      PmenuSbar = {
        bg = spec.background_dark,
      },
      PmenuThumb = {
        bg = spec.background_light,
      },

      Scrollbar = {
        bg = spec.background_dark,
      },
      ColorColumn = {
        bg = spec.background_dark,
      },

      IncSearch = {
        -- link = "PmenuSel",
        bg = palette.lemon_chiffon,
        fg = palette.raisin_black,
      },
      Search = {
        bg = palette.lemon_chiffon,
        fg = palette.raisin_black,
      },
      MatchParen = {
        fg = palette.pale_azure,
      },
      Substitute = {
        fg = palette.raisin_black,
        bg = palette.lemon_chiffon,
      },

      DiffAdd = {
        fg = spec.diff.add,
      },
      DiffChange = {
        fg = spec.diff.change,
      },
      DiffDelete = {
        fg = spec.diff.delete,
      },
      DiffText = {
        fg = spec.text,
      },

      DiagnoticInfo = {
        fg = spec.diagnostic.info,
        sp = spec.diagnostic.info,
      },
      DiagnosticHint = {
        fg = spec.diagnostic.hint,
        sp = spec.diagnostic.hint,
      },
      DiagnosticWarn = {
        fg = spec.diagnostic.warn,
        sp = spec.diagnostic.warn,
      },
      DiagnosticError = {
        fg = spec.diagnostic.error,
        sp = spec.diagnostic.error,
      },
      DiagnoticUnderlineInfo = {
        sp = spec.diagnostic.info,
        underline = true,
      },
      DiagnosticUnderlineHint = {
        sp = spec.diagnostic.hint,
        underline = true,
      },
      DiagnosticUnderlineWarn = {
        sp = spec.diagnostic.warn,
        underline = true,
      },
      DiagnosticUnderlineError = {
        sp = spec.diagnostic.error,
        underline = true,
      },

      Directory = {
        fg = palette.blue,
      },

      WildMenu = {},

      Folded = {
        fg = spec.text_light,
      },
      FoldColumn = {
        fg = spec.text_light,
      },

      SignColumn = {
        bg = "none",
      },
      LineNr = {
        fg = spec.line_nr,
        bold = true,
      },
      CursorLineNr = {
        link = "CurrentMode",
      },

      TabLine = {
        bg = spec.background_dark,
        fg = spec.text_light,
      },
      TabLineSel = {
        bg = spec.background_dark,
        fg = spec.text_light,
      },
      TabLineFill = {
        bg = "none",
      },

      StatusLine = {
        bg = spec.background_dark,
        fg = spec.text_light,
      },
      StatusLineNC = {
        bg = spec.background_dark,
        fg = spec.text_light,
      },

      WinBar = {
        fg = spec.text,
        bg = spec.background,
      },
      WinBarNC = {
        link = "WinBar",
      },

      CursorLine = {},
      CursorColumn = {
        bg = spec.background,
      },

      ModeMsg = {
        fg = spec.text_light,
      },
      MoreMsg = {
        fg = spec.text_light,
      },
      MsgArea = {
        fg = spec.text_light,
      },

      Underlined = {
        underline = true,
      },

      NonText = {
        fg = spec.text_light,
      },
      EndOfBuffer = {
        bg = "none",
      },
      Whitespace = {
        bg = "none",
      },

      Special = {
        fg = spec.special,
      },
      SpecialChar = {
        fg = spec.special,
      },
      Tag = {
        fg = spec.special,
      },
      Delimiter = {
        fg = spec.text,
      },
      SpecialComment = {
        fg = palette.lavender,
      },

      Debug = {
        fg = palette.red,
      },
      Error = {
        fg = palette.red,
      },
      Todo = {
        fg = palette.lemon_chiffon,
      },

      SpecialKey = {
        fg = palette.red,
      },
      SpellBad = {
        fg = palette.red,
        underline = true,
      },
      SpellCap = {
        fg = palette.red,
        underline = true,
      },
      SpellLocal = {
        fg = palette.red,
        underline = true,
      },
      SpellRare = {
        fg = palette.pale_azure,
        underline = true,
      },

      Comment = {
        fg = spec.inline,
      },

      Constant = { fg = palette.tea_rose },
      String = { fg = palette.flamingo },
      Character = { fg = palette.pale_azure },
      Number = { fg = palette.maroon },
      Boolean = { fg = palette.maroon },
      Float = { fg = palette.maroon },

      Identifier = { fg = palette.uranian_blue },
      Function = { fg = spec.func },

      Statement = { fg = spec.keyword },
      Conditional = { fg = spec.keyword },
      Repeat = { fg = spec.keyword },
      Label = { fg = spec.keyword },
      Exception = { fg = spec.keyword },
      Operator = { fg = palette.cadet_gray },
      Keyword = { fg = spec.keyword },
      StorageClass = { fg = spec.keyword },

      Macro = {
        fg = palette.red,
      },
      PreProc = {
        link = "Macro",
      },
      Include = {
        link = "Macro",
      },
      Define = {
        link = "Macro",
      },

      Structure = {
        fg = palette.lemon_chiffon,
      },
      Type = {
        fg = palette.lemon_chiffon,
      },
      TypeDef = {
        fg = palette.lemon_chiffon,
      },
      Typedef = {
        fg = palette.lemon_chiffon,
      },

      LspReferenceRead = { bg = palette.dark_blue },
      LspReferenceWrite = { bg = palette.dark_blue },
      LspCodeLens = { bg = "none", fg = palette.text },
      LspCodeLensSeparator = { bg = "none", fg = palette.cadet_gray },
      LspSignatureActiveParameter = { bg = "none", fg = palette.blue },
      LspInlayHint = {
        fg = palette.cool_gray,
      },

      -- Treesitter
      ["@text.literal"] = {},
      ["@string.special"] = { fg = palette.lavender },
      ["@string.escape"] = { fg = palette.lavender },

      ["@text.title"] = { fg = palette.turquoise },
      ["@text.strike"] = { strikethrough = true },
      ["@text.strong"] = { bold = true },
      ["@text.underline"] = { underline = true },
      ["@text.emphasis"] = { italic = true },

      -- syn '@text.warning' { DiagnosticWarn },
      ["@text.todo"] = { link = "Todo" },
      ["@text.uri"] = { underline = true },
      ["@text.reference"] = { fg = spec.ident },

      ["@constant.macro"] = { link = "Macro" }, -- Define
      ["@define"] = { link = "Macro" }, -- Define
      ["@include"] = { link = "Macro" }, -- Include
      ["@preproc"] = { link = "Macro" }, -- PreProc
      ["@function.macro"] = { link = "Macro" }, -- Macro
      ["@punctuation"] = { link = "Delimiter" }, -- Delimiter
      ["@function"] = { link = "Function" }, -- Function
      -- ["@method"] = { fg = p.pale_azure.mix(Function.fg, 50) }, -- Function
      ["@method"] = { link = "Function" }, -- Function
      ["@namespace"] = { link = "Identifier" }, -- Identifier
      ["@structure"] = { link = "Stucture" }, -- Structure
      ["@parameter"] = { fg = spec.ident }, -- Identifier
      ["@field"] = { link = "Identifier" }, -- Identifier
      ["@property"] = { link = "Identifier" }, -- Identifier
      ["@variable"] = { link = "Identifier" }, -- Identifier
      ["@macro"] = { link = "Macro" }, -- Macro
      ["@string"] = { link = "String" }, -- String
      ["@character"] = { link = "Character" }, -- Character
      ["@character.special"] = { link = "SpecialChar" }, -- SpecialChar
      ["@number"] = { link = "Number" }, -- Number
      ["@boolean"] = { link = "Boolean" }, -- Boolean
      ["@float"] = { link = "Float" }, -- Float

      ["@type.builtin"] = { link = "Type" },
      ["@type.builtin.typescript"] = { link = "Type" },

      ["@keyword"] = { link = "Keyword" }, -- Keyword
      -- Rust
      ["@lsp.type.formatSpecifier"] = { link = "SpecialChar" },
      ["@lsp.type.escapeSequence"] = { link = "SpecialChar" },
      ["@lsp.type.selfKeyword"] = { fg = palette.blue },
      ["@lsp.type.selfTypeKeyword"] = { link = "Keyword" },

      -- ['@lsp.type.trait'] = { fg = p.peach },
      ["@lsp.type.typeParameter"] = { fg = palette.lemon_chiffon },

      ["@lsp.type.macro"] = { link = "Macro" },
      ["@lsp.type.attribute"] = { link = "Macro" },
      ["@lsp.type.keyword"] = { link = "Keyword" },
      ["@lsp.type.variable"] = { link = "Identifier" },

      -- symbols
      ["@lsp.type.punctuation"] = { link = "Delimiter" },
      ["@lsp.type.macroBang"] = { link = "Operator" },

      -- operators                                    .
      ["@lsp.type.operator"] = { link = "Operator" },
      ["@lsp.type.property"] = { fg = spec.property },
      ["@lsp.type.enumMember"] = { fg = palette.mauve },
      ["@lsp.type.typeAlias"] = { fg = palette.lemon_chiffon },
      ["@lsp.type.union"] = { fg = palette.lemon_chiffon },

      ["@lsp.type.builtinAttribute"] = { link = "Macro" },

      ["@lsp.mod.keyword"] = { link = "Keyword" },
      ["@lsp.mod.async"] = { link = "Keyword" },
      ["@lsp.mod.callable"] = { link = "Function" },
      -- ['@lsp.mod.trait'] = { Keyword },
      ["@lsp.typemod.variable.static"] = { fg = palette.tea_rose },

      -- sym('@comment')           { }, -- Comment
      ["@constant.builtin"] = { fg = palette.tea_rose }, -- Special
      -- ['@storageclass'] = { fg = p.tea_rose }, -- StorageClass
      -- sym('@function.builtin')  { }, -- Special
      -- sym('@constructor')       { }, -- Special
      -- sym('@conditional')       { }, -- Conditional
      -- sym('@repeat')            { }, -- Repeat
      -- ['@label'] = { Keyword }, -- Label
      -- sym('@operator')          { }, -- Operator
      -- sym('@exception')         { }, -- Exception
      -- ['@type'] = { fg = p.cool_gray }, -- Type
      -- sym('@debug')             { }, -- Debug
      -- sym('@tag')               { }, -- Tag

      BlinkCmpKindSnippet = { fg = palette.mauve },
      BlinkCmpKindKeyword = { fg = palette.red },
      BlinkCmpKindText = { fg = palette.teal },
      BlinkCmpKindMethod = { fg = palette.blue },
      BlinkCmpKindConstructor = { fg = palette.blue },
      BlinkCmpKindFunction = { fg = palette.blue },
      BlinkCmpKindFolder = { fg = palette.blue },
      BlinkCmpKindModule = { fg = palette.blue },
      BlinkCmpKindConstant = { fg = palette.peach },
      BlinkCmpKindField = { fg = palette.lemon_chiffon },
      BlinkCmpKindProperty = { fg = palette.lemon_chiffon },
      BlinkCmpKindEnum = { fg = palette.lemon_chiffon },
      BlinkCmpKindUnit = { fg = palette.lemon_chiffon },
      BlinkCmpKindClass = { fg = palette.yellow },
      BlinkCmpKindVariable = { fg = palette.flamingo },
      BlinkCmpKindFile = { fg = palette.blue },
      BlinkCmpKindInterface = { fg = palette.lemon_chiffon },
      BlinkCmpKindColor = { fg = palette.red },
      BlinkCmpKindReference = { fg = palette.red },
      BlinkCmpKindEnumMember = { fg = palette.red },
      BlinkCmpKindStruct = { fg = palette.blue },
      BlinkCmpKindValue = { fg = palette.peach },
      BlinkCmpKindEvent = { fg = palette.blue },
      BlinkCmpKindOperator = { fg = palette.blue },
      BlinkCmpKindTypeParameter = { fg = palette.blue },
      BlinkCmpKindCopilot = { fg = palette.turquoise },

      DropBarMenuHoverEntry = { link = "PmenuSel" },
    },
    terminal = {},
  })
  :apply()
