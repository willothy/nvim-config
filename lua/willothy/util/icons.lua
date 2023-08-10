local Icons = {}

Icons.kinds = {
  Method = " ",
  Function = "󰡱 ",
  Constructor = " ",
  Field = " ",
  Variable = " ",
  Class = " ",
  Property = " ",
  Interface = " ",
  Enum = " ",
  EnumMember = " ",
  Reference = " ",
  Struct = " ",
  Event = " ",
  Constant = " ",
  Keyword = " ",

  Module = " ",
  Package = " ",
  Namespace = " ",

  Unit = " ",
  Value = " ",
  String = " ",
  Number = " ",
  Boolean = " ",
  Array = " ",
  Object = " ",
  Key = " ",
  Null = " ",

  Text = " ",
  Snippet = " ",
  Color = " ",
  File = " ",
  Folder = " ",
  Operator = " ",
  TypeParameter = " ",
}

Icons.diagnostics = {
  errors = "󰞏", --
  warnings = "", -- "",--
  hints = "", --"󰮔",
  info = "",
}
Icons.diagnostics.Error = Icons.diagnostics.errors
Icons.diagnostics.Warn = Icons.diagnostics.warnings
Icons.diagnostics.Hint = Icons.diagnostics.hints
Icons.diagnostics.Info = Icons.diagnostics.info

Icons.lsp = {
  action_hint = "",
}

Icons.git = {
  diff = {
    added = "",
    modified = "󰆗",
    removed = "",
  },
  signs = {
    bar = "┃",
    untracked = "•",
  },
  branch = "",
  copilot = "",
  copilot_err = "",
  copilot_warn = "",
}

Icons.dap = {
  breakpoint = {
    conditional = "",
    data = "",
    func = "",
    log = "",
    unsupported = "",
  },
  action = {
    continue = "",
    coverage = "",
    disconnect = "",
    line_by_line = "",
    pause = "",
    rerun = "",
    restart = "",
    restart_frame = "",
    reverse_continue = "",
    start = "",
    step_back = "",
    step_into = "",
    step_out = "",
    step_over = "",
    stop = "",
  },
  stackframe = "",
  stackframe_active = "",
  console = "",
}

Icons.actions = {
  close_hexagon = "󰅜",
  close2 = "⌧",
  close_round = "󰅙",
  close_outline = "󰅚",
  close = "🞫",
  close_box = "󰅗",
}

Icons.fold = {
  open = "",
  closed = "",
}

Icons.separators = {
  angle_quote = {
    left = "«",
    right = "»",
  },
  chevron = {
    left = "",
    right = "",
    down = "",
  },
  circle = {
    left = "",
    right = "",
  },
  arrow = {
    left = "",
    right = "",
  },
  slant = {
    left = "",
    right = "",
  },
  bar = {
    left = "⎸",
    right = "⎹",
  },
}

Icons.blocks = {
  left = {
    "▏",
    "▎",
    "▍",
    "▌",
    "▋",
    "▊",
    "▉",
    "█",
  },
  right = {
    eighth = "▕",
    half = "▐",
    full = "█",
  },
}

Icons.misc = {
  datetime = "󱛡 ",
  modified = "●",
  fold = "⮓",
  newline = "",
  circle = "",
  circle_filled = "",
  circle_slash = "",
  ellipse = "…",
  ellipse_dbl = "",
  kebab = "",
  tent = "⛺",
  comma = "󰸣",
  hook = "󰛢",
  hook_disabled = "󰛣",
}

return Icons
