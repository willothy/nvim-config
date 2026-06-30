-- nvim-treesitter community fork (neovim-treesitter/*): the classic
-- `require("nvim-treesitter.configs").setup{}` module system no longer
-- exists. Parsers are installed explicitly here; highlight / indent / fold
-- are enabled per-buffer in the FileType autocmd (see willothy/autocmds.lua).
-- Context-aware commentstrings are handled by ts-comments.nvim (the Comment.nvim
-- spec), so the old `context_commentstring` module config is dropped.
-- Textobjects moved to the nvim-treesitter-textobjects plugin.

local ts = require("nvim-treesitter")

-- The fork installs each language's queries into the data dir, but shared base
-- queries that have no parser of their own (e.g. `ecma`, which typescript and
-- javascript `; inherits:`) only ship in the plugin's bundled `runtime/queries`.
-- That dir isn't on the runtimepath, so the inherited bases resolve to nothing
-- and dependent languages lose most of their highlights. Add it to the rtp.
for _, dir in ipairs(vim.api.nvim_list_runtime_paths()) do
  if dir:match("[/\\]nvim%-treesitter$") then
    vim.opt.rtp:prepend(dir .. "/runtime")
    break
  end
end

-- ft -> parser-language mappings that don't match by name. Core does not
-- register these; the classic plugin used to.
vim.treesitter.language.register("bash", "sh")
vim.treesitter.language.register("git_config", "gitconfig")
vim.treesitter.language.register("git_rebase", "gitrebase")
vim.treesitter.language.register("javascript", "javascriptreact")
vim.treesitter.language.register("typescript", "typescriptreact")
-- the fork registry has no `jsonc` parser; reuse the `json` parser for it
vim.treesitter.language.register("json", "jsonc")

ts.install({
  "query",
  "javascript",
  "typescript",
  "c",
  "go",
  "cpp",
  "lua",
  "rust",
  "bash",
  "markdown",
  "markdown_inline",
  "gitcommit",
  "gitignore",
  "git_rebase",
  "git_config",
  "json",
})

-- local M = {}
--
-- -- Compare (row,col) defensively
-- local function lt(a, b)
--   local ar, ac = tonumber(a and a[1]) or 0, tonumber(a and a[2]) or 0
--   local br, bc = tonumber(b and b[1]) or 0, tonumber(b and b[2]) or 0
--   if ar ~= br then
--     return ar < br
--   end
--   return ac < bc
-- end
--
-- -- range overlap: [a0,a1) intersects [b0,b1)
-- local function ranges_overlap(a0, a1, b0, b1)
--   return lt(a0, b1) and lt(b0, a1)
-- end
--
-- -- Normalize included_regions() output into { {srow,scol,erow,ecol}, ... }
-- local function normalize_regions(regs)
--   local out = {}
--   for _, r in ipairs(regs or {}) do
--     if type(r) == "table" then
--       -- Shape A: {srow, scol, erow, ecol}
--       if type(r[1]) == "number" then
--         local srow, scol, erow, ecol = r[1], r[2], r[3], r[4]
--         if srow and scol and erow and ecol then
--           out[#out + 1] = { srow, scol, erow, ecol }
--         end
--
--       -- Shape B: { {srow,scol}, {erow,ecol} }
--       elseif type(r[1]) == "table" and type(r[2]) == "table" then
--         local srow, scol = r[1][1], r[1][2]
--         local erow, ecol = r[2][1], r[2][2]
--         if srow and scol and erow and ecol then
--           out[#out + 1] = { srow, scol, erow, ecol }
--         end
--       end
--     end
--   end
--   return out
-- end
--
-- local function get_injection_regions(bufnr)
--   local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
--   if not ok or not parser then
--     return {}
--   end
--
--   local regions = {}
--
--   for _, child in pairs(parser:children() or {}) do
--     local ok_regions, child_regions = pcall(function()
--       return child:included_regions()
--     end)
--
--     if ok_regions and type(child_regions) == "table" then
--       local norm = normalize_regions(child_regions)
--       for _, r in ipairs(norm) do
--         regions[#regions + 1] = r
--       end
--     end
--   end
--
--   return regions
-- end
--
-- function M.clear_semantic_tokens_in_injections(bufnr)
--   bufnr = bufnr or vim.api.nvim_get_current_buf()
--   if not vim.api.nvim_buf_is_valid(bufnr) then
--     return
--   end
--
--   local inj = get_injection_regions(bufnr)
--   if #inj == 0 then
--     return
--   end
--
--   local sem_ns_list = get_semantic_token_namespaces()
--   if #sem_ns_list == 0 then
--     return
--   end
--
--   for _, ns in ipairs(sem_ns_list) do
--     local marks = vim.api.nvim_buf_get_extmarks(
--       bufnr,
--       ns,
--       { 0, 0 },
--       { -1, -1 },
--       { details = true }
--     )
--
--     for _, m in ipairs(marks) do
--       local id, row, col, details = m[1], m[2], m[3], m[4] or {}
--
--       -- Semantic-token marks usually have an end; if not, treat as 1-column.
--       local er = details.end_row or row
--       local ec = details.end_col or (col + 1)
--
--       local m0 = { row, col }
--       local m1 = { er, ec }
--
--       for _, r in ipairs(inj) do
--         local r0 = { r[1], r[2] }
--         local r1 = { r[3], r[4] }
--
--         if ranges_overlap(m0, m1, r0, r1) then
--           -- Delete the semantic-token extmark
--           pcall(vim.api.nvim_buf_del_extmark, bufnr, ns, id)
--           break
--         end
--       end
--     end
--   end
-- end
--
-- local clear = M
--
-- -- Debounce so we don't thrash extmarks while typing.
-- local timer = vim.uv.new_timer()
-- local function schedule(buf)
--   timer:stop()
--   timer:start(40, 0, function()
--     vim.schedule(function()
--       clear.clear_semantic_tokens_in_injections(buf)
--     end)
--   end)
-- end
--
-- vim.api.nvim_create_autocmd(
--   { "TextChanged", "TextChangedI", "InsertLeave", "BufEnter", "LspAttach" },
--   {
--     callback = function(args)
--       schedule(args.buf)
--     end,
--   }
-- )
