-- selene: allow(unused_variable)
local function get_search_term(props)
  if not props.focused then return "" end

  local count = vim.fn.searchcount({ recompute = 1, maxcount = -1 })
  local contents = vim.fn.getreg("/")
  if string.len(contents) == 0 then return "" end

  return {
    {
      "? ",
      group = "TabLine",
    },
    {
      (" %s "):format(contents),
      group = "IncSearch",
    },
    {
      (" %d/%d "):format(count.current, count.total),
      group = "TabLine",
    },
  }
end

-- selene: allow(unused_variable)
local function get_diagnostic_label(props)
  local icons = { error = "", warn = "", info = "", hint = "" }
  local label = {}

  for severity, icon in pairs(icons) do
    local n = #vim.diagnostic.get(
      props.buf,
      { severity = vim.diagnostic.severity[string.upper(severity)] }
    )
    if n > 0 then
      table.insert(
        label,
        { icon .. " " .. n .. " ", group = "DiagnosticSign" .. severity }
      )
    end
  end
  if #label > 0 then table.insert(label, { "| " }) end
  return label
end

local function get_git_diff(props)
  local icons = {
    removed = { "", "GitSignsDelete" },
    changed = { "", "GitSignsChange" },
    added = { "", "GitSignsAdd" },
  }
  local labels = {}
  local signs = vim.api.nvim_buf_get_var(props.buf, "gitsigns_status_dict")
  for name, info in pairs(icons) do
    if tonumber(signs[name]) and signs[name] > 0 then
      table.insert(labels, {
        info[1] .. " " .. signs[name] .. " ",
        group = info[2],
      })
    end
  end
  if #labels > 0 then table.insert(labels, { "| " }) end
  return labels
end

return {
  {
    "b0o/incline.nvim",
    event = "User ExtraLazy",
    config = function()
      require("incline").setup({
        window = {
          padding = 1,
          padding_char = " ",
          margin = {
            horizontal = 0,
            vertical = {
              top = 0,
              bottom = 0,
            },
          },
          placement = {
            horizontal = "right",
            vertical = "top",
          },
          options = {},
        },
        highlight = {
          groups = {
            InclineNormal = {
              default = true,
              group = "TabLine",
            },
            InclineNormalNC = {
              default = true,
              group = "TabLine",
            },
          },
        },
        render = function(props)
          local filename =
            vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          local ft_icon, ft_color =
            require("nvim-web-devicons").get_icon_color(filename)
          local modified = vim.api.nvim_buf_get_option(props.buf, "modified")
              and "bold,italic"
            or "bold"

          local buffer = {
            -- get_search_term(props),
            -- get_diagnostic_label(props),
            get_git_diff(props),
            { ft_icon, guifg = ft_color },
            { " " },
            {
              filename,
              gui = modified,
            },
          }
          return buffer
        end,
      })
      vim.schedule(function()
        -- hacky force refresh for incline
        vim.api.nvim_exec_autocmds("BufRead", {
          buffer = vim.api.nvim_get_current_buf(),
        })
      end)
    end,
  },
}
