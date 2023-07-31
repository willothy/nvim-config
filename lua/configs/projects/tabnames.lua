local tabnames = require("tabnames")
tabnames.setup({
  auto_suggest_names = true,
  default_tab_name = tabnames.tab_name_presets.tab_cwd,
  experimental = {
    session_support = true,
  },
})
