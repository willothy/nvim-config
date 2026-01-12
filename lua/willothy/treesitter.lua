---@diagnostic disable: missing-fields
-- require("tree-sitter-just").setup({})

require("nvim-treesitter.configs").setup({
  -- A list of parser names, or "all"
  ensure_installed = {
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
    "jsonc",
    "json",
  },
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    -- disable = {
    --   "css",
    --   "scss",
    -- },
    -- additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
  injections = { enable = true },
  context_commentstring = {
    config = {
      javascript = {
        __default = "// %s",
        jsx_element = "{/* %s */}",
        jsx_fragment = "{/* %s */}",
        jsx_attribute = "// %s",
        comment = "// %s",
      },
      typescript = { __default = "// %s", __multiline = "/* %s */" },
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["is"] = { query = "@statement.inner", desc = "statement" },
        ["as"] = { query = "@statement.outer", desc = "statement" },
        ["ic"] = { query = "@class.inner", desc = "class" },
        ["ac"] = { query = "@class.outer", desc = "class" },
        ["iF"] = { query = "@function.inner", desc = "function" },
        ["aF"] = { query = "@function.outer", desc = "function" },
      },
      selection_modes = {
        ["@parameter.outer"] = "v",
        -- ["@function.outer"] = "V",
        ["@class.outer"] = "<c-v>",
      },
    },
    swap = {
      enable = true,
    },
    move = {
      enable = true,
      goto_next_start = {
        ["]f"] = { query = "@function.outer", desc = "function" },
        ["]c"] = { query = "@call.outer", desc = "call" },
      },
      goto_previous_start = {
        ["[f"] = { query = "@function.outer", desc = "function" },
        ["[c"] = { query = "@call.outer", desc = "call" },
      },
    },
  },
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
