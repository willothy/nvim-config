local ns

return function()
  if ns then
    vim.notify("hjkl already loaded", "warn")
    return
  end

  -- STOP USING THE DAMN ARROW KEYS
  local arrows = {
    [vim.keycode("<Up>")] = "<Up>",
    [vim.keycode("<Down>")] = "<Down>",
    [vim.keycode("<Left>")] = "<Left>",
    [vim.keycode("<Right>")] = "<Right>",
    [vim.keycode("<C-w><Up>")] = "<C-w><Up>",
    [vim.keycode("<C-w><Down>")] = "<C-w><Down>",
    [vim.keycode("<C-w><Left>")] = "<C-w><Left>",
    [vim.keycode("<C-w><Right>")] = "<C-w><Right>",
  }

  local alternates = {
    i = {
      ["<Up>"] = "<C-k>",
      ["<Down>"] = "<C-j>",
      ["<Left>"] = "<C-h>",
      ["<Right>"] = "<C-l>",
    },
    n = {
      ["<Up>"] = "k",
      ["<Down>"] = "j",
      ["<Left>"] = "h",
      ["<Right>"] = "l",
      ["<C-w><Up>"] = "<C-w>k",
      ["<C-w><Down>"] = "<C-w>j",
      ["<C-w><Left>"] = "<C-w>h",
      ["<C-w><Right>"] = "<C-w>l",
    },
    t = {
      ["<Up>"] = "<C-k>",
      ["<Down>"] = "<C-j>",
      ["<Left>"] = "<C-h>",
      ["<Right>"] = "<C-l>",
      ["<C-w><Up>"] = "<C-w>k",
      ["<C-w><Down>"] = "<C-w>j",
      ["<C-w><Left>"] = "<C-w>h",
      ["<C-w><Right>"] = "<C-w>l",
    },
    v = {
      ["<Up>"] = "k",
      ["<Down>"] = "j",
      ["<Left>"] = "h",
      ["<Right>"] = "l",
    },
  }

  local norm = function(cmd)
    return function()
      vim.cmd.normal({ cmd, bang = true })
    end
  end
  vim.keymap.set({ "i" }, "<C-j>", norm("j"), { noremap = true })
  vim.keymap.set({ "i" }, "<C-k>", norm("k"), { noremap = true })
  vim.keymap.set({ "i" }, "<C-h>", norm("h"), { noremap = true })
  vim.keymap.set({ "i" }, "<C-l>", norm("l"), { noremap = true })
  vim.keymap.set("c", "<C-j>", "<Down>", { noremap = true })
  vim.keymap.set("c", "<C-k>", "<Up>", { noremap = true })
  vim.keymap.set("c", "<C-h>", "<Left>", { noremap = true })
  vim.keymap.set("c", "<C-l>", "<Right>", { noremap = true })
  local debounce = vim.loop.new_timer()
  local last

  ns = vim.on_key(function(key)
    if debounce:is_active() and last and last == key then
      return
    end
    if arrows[key] then
      local mode = vim.api.nvim_get_mode().mode
      if alternates[mode] then
        last = key
        local msg = ("use %s !!"):format(
          alternates[mode][arrows[key]] or "h/j/k/l or C-h/j/k/l"
        )
        vim.notify(msg, "error")
        debounce:start(1000, 0, function()
          last = nil
        end)
      end
    end
  end)
end
