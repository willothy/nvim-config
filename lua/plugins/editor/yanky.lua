local before = "󱞽"
local after = "󱞣"

local function fmt(name, is_after)
  return string.format("%s %s", name, is_after and after or before)
end

return {
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    opts = {
      ring = {
        storage = "sqlite",
      },
    },
    keys = {
      {
        "p",
        "<Plug>(YankyPutAfter)",
        mode = { "n", "x", "v" },
        desc = fmt("Put", true),
      },
      {
        "P",
        "<Plug>(YankyPutBefore)",
        mode = { "n", "x" },
        desc = fmt("Put"),
      },
      {
        "gp",
        "<Plug>(YankyGPutAfter)",
        mode = { "n", "x" },
        desc = fmt("GPut", true),
      },
      {
        "gP",
        "<Plug>(YankyGPutBefore)",
        mode = { "n", "x" },
        desc = fmt("GPut"),
      },
      {
        "]y",
        "<Plug>(YankyCycleForward)",
        mode = { "n", "x" },
        desc = fmt("Yanky: cycle", true),
      },
      {
        "[y",
        "<Plug>(YankyCycleBackward)",
        mode = { "n", "x" },
        desc = fmt("Yanky: cycle"),
      },
    },
  },
}
