local bind = require("willothy.util.func").bind
local setmap = vim.keymap.set
local buf = vim.lsp.buf
local diagnostic = vim.diagnostic
local fn = vim.fn

---@param client lsp.Client
---@param bufnr integer
local function lsp_attach(client, bufnr)
  local opts = { remap = false, silent = true, buffer = bufnr }

  local function map(m, lhs, rhs, desc)
    setmap(m, lhs, rhs, vim.tbl_deep_extend("keep", opts, { desc = desc }))
  end

  map("n", "gd", buf.definition, "definition")
  map("n", "gD", buf.declaration, "declaration")
  map("n", "gT", buf.type_definition, "type definition")
  map("n", "gi", buf.implementation, "implementation")
  map("n", "K", function()
    vim.cmd.MurmurToggle()
    require("rust-tools").hover_actions.hover_actions()
    local function await_close()
      local state = require("rust-tools").hover_actions._state
      local count = 0
      for _ in pairs(state) do
        count = count + 1
      end
      if count == 0 then
        vim.cmd.MurmurToggle()
      else
        vim.defer_fn(await_close, 250)
      end
    end
    vim.defer_fn(await_close, 250)
  end, "hover")
  map("n", "[d", diagnostic.goto_next, "diagnostic 󰞘")
  map("n", "]d", diagnostic.goto_prev, "󰞗 diagnostic")
  map("n", "<leader>ca", function()
    require("actions-preview").code_actions()
    -- local win = vim.api.nvim_get_current_win()
    -- require("rust-tools").code_action_group.code_action_group()
    -- vim.api.nvim_set_current_win(win)
    -- require("hollywood").code_actions()
  end, "code actions")

  local trouble = function(list)
    return function()
      require("trouble").open(list)
    end
  end
  map("n", "<leader>cr", trouble("lsp_references"), "references")
  map("n", "<leader>cd", trouble("lsp_definitions"), "definitions")
  map(
    "n",
    "<leader>cd",
    bind(trouble, "lsp_type_definitions"),
    "type definitions"
  )
  map("n", "<leader>vq", trouble("quickfix"), "quickfix")
  map("n", "<leader>vL", trouble("loclist"), "loclist")

  local increname = function()
    vim.api.nvim_feedkeys(":IncRename " .. fn.expand("<cword>"), "n", false)
  end
  setmap("n", "<leader>cn", increname, { expr = true, desc = "rename" })
  setmap("n", "<F2>", increname, { expr = true, desc = "rename" })

  require("lsp-format").on_attach(client)

  if client.supports_method("textDocument/inlayHints") then
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
