local ns = vim.api.nvim_create_namespace("conceal_ns")

local function conceal(pat, sub, hl)
  vim
    .iter(vim.api.nvim_buf_get_lines(0, 0, -1, true))
    :enumerate()
    :each(function(lnr, line)
      local offset = 1
      while offset < #line do
        local start, finish = string.find(line, pat, offset)
        if start == nil then break end
        vim.api.nvim_buf_set_extmark(0, ns, lnr - 1, start - 1, {
          end_line = lnr - 1,
          end_col = finish - #sub,
          conceal = "",
        })
        vim.api.nvim_buf_set_extmark(0, ns, lnr - 1, start - 1, {
          end_line = lnr - 1,
          end_col = finish,
          virt_text = { { sub, hl or "Comment" } },
          -- virt_text_pos = "inline",
          virt_text_pos = "overlay",
        })
        offset = finish
      end
    end)
end

conceal("local", "loc", "Keyword")
conceal("function", "fun", "Keyword")
conceal(" do", ":", "Normal")
conceal(" then", ":", "Normal")
conceal("end", "")
