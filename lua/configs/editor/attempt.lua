local template = function(lang)
  return function()
    return willothy.utils.templates[lang]
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
