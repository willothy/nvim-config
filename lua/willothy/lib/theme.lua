---@class willothy.ThemeSpec
---@field background string           -- main editor background
---@field background_dark string      -- floats, popups, sidebar background
---@field background_light string     -- visual selection background
---@field surface string              -- secondary UI surfaces (scrollbars)
---@field surface_light string        -- lighter surface elements (thumbs)
---@field separator string            -- separators and borders
---@field text string                 -- primary text color
---@field text_light string           -- lighter text for comments, status
---@field text_dark string            -- darker text for selected text
---@field line_nr string              -- line number color
---@field inline string               -- inline elements (comments)
---@field property string             -- property names (fields)
---@field variable string             -- variable names
---@field constant string             -- constants and enums
---@field func string                 -- function names
---@field keyword string              -- keywords, statements
---@field operator string             -- operators, punctuation
---@field special string              -- accent color for UI states
---@field type string                 -- type names
---@field comment string              -- comment text
---@field string string               -- string literals
---@field number string               -- numeric literals
---@field diff table                  -- diff colors
---@field diff.add string             -- diff added background
---@field diff.change string          -- diff changed background
---@field diff.delete string          -- diff deleted background
---@field diagnostic table            -- diagnostic colors
---@field diagnostic.error string     -- error highlight
---@field diagnostic.warn string      -- warning highlight
---@field diagnostic.info string      -- info highlight
---@field diagnostic.hint string      -- hint highlight

local M = {}

---Generate and apply a colorscheme from a spec
---@param name string
---@param s willothy.ThemeSpec
function M.generate(name, s)
  local groups = {
    -- Core
    Normal = { fg = s.text, bg = s.background },
    NormalNC = { fg = s.text_light, bg = s.background_dark },
    Visual = { bg = s.background_light },

    -- Floating
    NormalFloat = { fg = s.text, bg = s.background_dark },
    FloatBorder = { fg = s.separator, bg = s.background_dark },
    Pmenu = { fg = s.text, bg = s.background_dark },
    PmenuSel = { fg = s.text_dark, bg = s.surface_light },
    PmenuSbar = { bg = s.surface },
    PmenuThumb = { bg = s.surface_light },

    -- UI Elements
    WinSeparator = { fg = s.separator },
    Title = { fg = s.property, bold = true },
    LineNr = { fg = s.line_nr },
    CursorLineNr = { fg = s.number, bold = true },
    SignColumn = { bg = s.background },
    Folded = { fg = s.text_light, bg = s.background_dark },
    FoldColumn = { fg = s.text_light },
    ColorColumn = { bg = s.background_light },
    CursorLine = { bg = s.background_light },
    CursorColumn = { bg = s.background_light },
    EndOfBuffer = { fg = s.background_dark },
    Whitespace = { fg = s.surface_light },

    -- Status & Tabs
    StatusLine = { fg = s.text, bg = s.surface },
    StatusLineNC = { fg = s.text_light, bg = s.background_dark },
    TabLine = { fg = s.text_light, bg = s.background_dark },
    TabLineSel = { fg = s.number, bg = s.background },
    TabLineFill = { bg = s.background_dark },

    -- WinBar
    WinBar = { fg = s.text_light, bg = s.background_dark },
    WinBarNC = { fg = s.text_light, bg = s.background_dark },

    -- Messages
    ModeMsg = { fg = s.special, bold = true },
    MoreMsg = { fg = s.special },
    MsgArea = { fg = s.text_light, bg = s.background },

    -- Search & Matches using accent
    IncSearch = { fg = s.text_dark, bg = s.special, bold = true },
    Search = { fg = s.text_dark, bg = s.special },
    MatchParen = { fg = s.special, underline = true },
    Substitute = { fg = s.text_dark, bg = s.special },

    -- Diagnostics
    DiagnosticError = { fg = s.diagnostic.error },
    DiagnosticWarn = { fg = s.diagnostic.warn },
    DiagnosticInfo = { fg = s.diagnostic.info },
    DiagnosticHint = { fg = s.diagnostic.hint },
    DiagnosticUnderlineError = { sp = s.diagnostic.error, underline = true },
    DiagnosticUnderlineWarn = { sp = s.diagnostic.warn, underline = true },
    DiagnosticUnderlineInfo = { sp = s.diagnostic.info, underline = true },
    DiagnosticUnderlineHint = { sp = s.diagnostic.hint, underline = true },

    -- Diff
    DiffAdd = { bg = s.diff.add },
    DiffChange = { bg = s.diff.change },
    DiffDelete = { bg = s.diff.delete },

    -- LSP UI
    LspReferenceRead = { bg = s.background_dark },
    LspReferenceWrite = { bg = s.background_dark },
    LspCodeLens = { fg = s.text_light },
    LspCodeLensSeparator = { fg = s.separator },
    LspSignatureActiveParameter = { fg = s.special },
    LspInlayHint = { fg = s.text_light },

    -- Syntax
    Constant = { fg = s.constant },
    Identifier = { fg = s.variable },
    Function = { fg = s.func },
    Statement = { fg = s.keyword },
    Operator = { fg = s.operator },
    Type = { fg = s.type },

    -- Treesitter
    ["@comment"] = { fg = s.comment, italic = true },
    ["@constant"] = { fg = s.constant },
    ["@constant.builtin"] = { fg = s.constant },
    ["@string"] = { fg = s.string },
    ["@number"] = { fg = s.number },
    ["@boolean"] = { fg = s.number },
    ["@float"] = { fg = s.number },
    ["@identifier"] = { fg = s.variable },
    ["@property"] = { fg = s.property },
    ["@parameter"] = { fg = s.variable },
    ["@function"] = { fg = s.func },
    ["@keyword"] = { fg = s.keyword },
    ["@operator"] = { fg = s.operator },
    ["@type"] = { fg = s.type },
    ["@type.builtin"] = { fg = s.type },
    ["@tag"] = { fg = s.special },
    ["@punctuation.delimiter"] = { fg = s.operator },
    ["@punctuation.bracket"] = { fg = s.operator },
    ["@text.literal"] = { fg = s.text },
  }

  require("mini.colors")
    .as_colorscheme({
      name = name,
      groups = groups,
      terminal = {},
    })
    :apply()
end

return M
