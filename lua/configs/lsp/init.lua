local setmap = vim.keymap.set
local fn = vim.fn

---@param client lsp.Client
---@param bufnr integer
local function lsp_attach(client, bufnr)
  local increname = function()
    vim.api.nvim_feedkeys(":IncRename " .. fn.expand("<cword>"), "n", false)
  end
  setmap("n", "<leader>cn", increname, { expr = true, desc = "rename" })
  setmap("n", "<F2>", increname, { expr = true, desc = "rename" })

  require("lsp-format").on_attach(client)

  local ufo = require("ufo")
  if vim.api.nvim_buf_is_valid(bufnr) and not ufo.hasAttached(bufnr) then
    ufo.attach(bufnr)
  end

  if
    client.name ~= "taplo"
    and client.supports_method("textDocument/inlayHints", { bufnr = bufnr })
  then
    vim.lsp.inlay_hint(bufnr, true)
  end
end

return {
  lsp_attach = lsp_attach,
  lsp_settings = setmetatable({}, {
    __index = function(_, k)
      local ok, conf = pcall(require, "willothy.lsp_settings." .. k)
      if ok then
        return conf
      else
        return {}
      end
    end,
  }),
}
