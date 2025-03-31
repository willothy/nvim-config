local function setup(key)
  vim.env["ANTHROPIC_API_KEY"] = key
  ---@diagnostic disable-next-line: missing-fields
  require("avante").setup({
    provider = "claude",
    disabled_tools = { "python" },
    claude = {
      -- model = "claude-3-7-sonnet-20250219",
      -- model = "claude-3-5-sonnet-20241022",
    },
    behaviour = {
      -- Whether to enable Claude Text Editor Tool Mode. Default false.
      -- enable_claude_text_editor_tool_mode = true,
    },
    windows = {
      sidebar_header = {
        rounded = false,
      },
      edit = {
        border = "solid",
      },
      ask = {
        border = "solid",
      },
    },
  })
  vim.cmd("highlight default link AvanteSuggestion PmenuSel")
end

local key = require("durable").kv.get("anthropic-api-key")
if key ~= nil then
  setup(key)
  return
end

require("willothy.lib.1password").read(
  "op://Personal/Anthropic API Key/credential",
  vim.schedule_wrap(function(res)
    res = vim.trim(res)
    setup(res)
    require("durable").kv.set("anthropic-api-key", res)
  end)
)
