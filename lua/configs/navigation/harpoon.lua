local harpoon = require("harpoon")

local List = require("harpoon.list")

---@param items any[]
---@param element any
---@param config HarpoonPartialConfigItem?
local function index_of(items, element, config)
  local equals = config and config.equals
    or function(a, b)
      return a == b
    end
  local index = -1
  for i, item in ipairs(items) do
    if equals(element, item) then
      index = i
      break
    end
  end

  return index
end

--- Resolve the displayed items with the current list
---@param displayed string[] The list of items to be displayed
---@param length number The length of the displayed list
function List:resolve_displayed(displayed, length)
  local Extensions = require("harpoon.extensions")
  local new_list = {}
  local current_display = self:display()

  -- Track items to be removed
  local to_remove = {}
  for i = 1, self._length do
    local current_item = self.items[i]
    if index_of(displayed, current_item) == -1 then
      table.insert(to_remove, { item = current_item, idx = i })
    end
  end

  -- Process removals
  for _, removal in ipairs(to_remove) do
    Extensions.extensions:emit(
      Extensions.event_names.REMOVE,
      { list = self, item = removal.item, idx = removal.idx }
    )
  end

  -- Process new list
  for i = 1, length do
    local display_item = displayed[i]
    if display_item == "" then
      new_list[i] = nil
    else
      local current_index = index_of(current_display, display_item)

      if current_index == -1 then
        -- New item
        new_list[i] = self.config.create_list_item(self.config, display_item)
        Extensions.extensions:emit(
          Extensions.event_names.ADD,
          { list = self, item = new_list[i], idx = i }
        )
      else
        -- Existing item
        if current_index ~= i then
          Extensions.extensions:emit(
            Extensions.event_names.REORDER,
            { list = self, item = self.items[current_index], idx = i }
          )
        end
        new_list[i] = self.items[current_index]
      end
    end
  end

  self.items = new_list
  self._length = length
end

local Extensions = require("harpoon.extensions")

local tmux = {
  automated = true,
  encode = false,
  prepopulate = function(cb)
    vim.system({
      "tmux",
      "list-sessions",
    }, { text = true }, function(out)
      if out.code ~= 0 then
        return
      end
      local sessions = out.stdout or ""
      local lines = {}
      for s in sessions:gmatch("[^\r\n]+") do
        table.insert(lines, { value = s, context = { row = 1, col = 1 } })
      end
      cb(lines)
    end)
  end,
  select = function(list_item, _list, _option)
    local sessionName = string.match(list_item.value, "([^:]+)")
    vim.system(
      { "tmux", "switch-client", "-t", sessionName },
      {},
      function() end
    )
  end,
  remove = function(list_item, _list)
    local sessionName = string.match(list_item.value, "([^:]+)")
    vim.system(
      { "tmux", "kill-session", "-t", sessionName },
      {},
      function() end
    )
  end,
}

local terminals = {
  automated = true,
  encode = false,
  select_with_nil = true,
  -- TODO: merge list to maintain user-defined order and allow removal via buffer
  prepopulate = function()
    local bufs = vim.api.nvim_list_bufs()
    return vim
      .iter(bufs)
      :filter(function(buf)
        return vim.bo[buf].buftype == "terminal"
      end)
      :map(function(buf)
        local term = require("toggleterm.terminal").find(function(t)
          return t.bufnr == buf
        end)
        local bufname = vim.api.nvim_buf_get_name(buf)
        if term then
          if
            term.display_name
            and (#bufname == 0 or #bufname > #term.display_name)
          then
            bufname = term.display_name
          else
            bufname = string.format("%s [%d]", term:_display_name(), term.id)
          end
        end
        return {
          value = bufname,
          context = {
            bufnr = buf,
          },
        }
      end)
      :totable()
  end,
  remove = function(list_item, _list)
    local bufnr = list_item.context.bufnr
    vim.schedule(function()
      if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        require("bufdelete").bufdelete(bufnr, true)
      end
    end)
  end,
  select = function(list_item, _list, _opts)
    if
      list_item.context.bufnr == nil
      or not vim.api.nvim_buf_is_valid(list_item.context.bufnr)
    then
      -- create a new terminal if the buffer is invalid
      local Terminal = require("toggleterm.terminal").Terminal
      local term = Terminal:new({
        display_name = list_item.value,
      })
      term:open()
      list_item.context.bufnr = term.bufnr
    else
      -- jump to existing window containing the buffer
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        if buf == list_item.context.bufnr then
          vim.api.nvim_set_current_win(win)
          return
        end
      end
    end

    -- switch to the buffer if no window was found
    vim.api.nvim_set_current_buf(list_item.context.bufnr)

    Extensions.extensions:emit(Extensions.event_names.NAVIGATE, {
      list = _list,
      item = list_item,
      buffer = list_item.context.bufnr,
    })
  end,
}

local files = {
  prepopulate = function()
    local Path = require("plenary.path")
    local cwd = vim.uv.cwd()
    local limit = 3
    return vim
      .iter(require("mini.visits").list_paths())
      :enumerate()
      :filter(function(i)
        return i <= limit
      end)
      :map(function(_, path)
        local p = Path:new(path):make_relative(cwd)
        local buf = vim.fn.bufnr(p, false)
        local row, col = 1, 1
        if buf and vim.api.nvim_buf_is_valid(buf) then
          if not vim.api.nvim_buf_is_loaded(buf) then
            vim.fn.bufload(buf)
          end
          row, col = unpack(vim.api.nvim_buf_get_mark(buf, '"'))
        end
        return {
          value = p,
          context = {
            row = row,
            col = col,
          },
        }
      end)
      :totable()
  end,
}

local wezterm = require("wezterm")

local harpoon_wezterm = {
  -- automated = true,
  -- encode = false,
  -- select_with_nil = true,
  prepopulate = function(cb)
    local tabs = wezterm.list_tabs()

    local current_pane = wezterm.get_current_pane()

    return vim
      .iter(tabs)
      ---@param t Wezterm.Tab
      :map(function(t)
        local active_pane = vim
          .iter(t.panes)
          ---@param p Wezterm.Pane
          :find(function(p)
            return p.is_active
          end) --[[@as Wezterm.Pane]]

        local cwd = active_pane.cwd
        local _scheme, _host = cwd:match("^%s*(%w+)://(%w+)")

        cwd = cwd:gsub("^%s*(%w+)://(%w+)", "")

        cwd = cwd:gsub(vim.env.HOME, "~")

        return {
          value = string.format(
            "%s (%d, %d pane%s) %s",
            t.tab_title == "" and cwd or t.tab_title,
            t.tab_id,
            #t.panes,
            #t.panes == 1 and "" or "s",
            active_pane.pane_id == current_pane and "(active)" or ""
          ),
          context = {
            tab_id = t.tab_id,
          },
        }
      end)
      :totable()
  end,
  remove = function(list_item, _list)
    local panes = wezterm.list_panes()
    vim
      .iter(panes)
      ---@param p Wezterm.Pane
      :filter(function(p)
        return tostring(p.tab_id) == tostring(list_item.context.tab_id)
      end)
      ---@param p Wezterm.Pane
      :each(function(p)
        wezterm.exec({
          "cli",
          "kill-pane",
          "--pane-id",
          tostring(p.pane_id),
        }, function() end)
      end)
  end,
  select = function(list_item, _list, _opts)
    wezterm.switch_tab.id(list_item.context.tab_id)
  end,
}

require("harpoon.config").DEFAULT_LIST = "files"

harpoon:setup({
  settings = {
    save_on_toggle = true,
    key = function()
      return vim.uv.cwd() --[[@as string]]
    end,
  },
  tmux = tmux,
  terminals = terminals,
  files = files,
  wezterm = harpoon_wezterm,
  default = {},
})

local Path = require("plenary.path")
local fidget = require("fidget")

local titles = {
  ADD = "added",
  REMOVE = "removed",
}

local function notify(event, cx)
  if cx == nil or cx.item == nil then
    return
  end

  if cx.list and cx.list.config.automated then
    return
  end
  local path = Path:new(cx.item.value) --[[@as Path]]

  local display = path:make_relative(vim.uv.cwd())
    or path:make_relative(vim.env.HOME)
    or path:normalize()

  local handle = fidget.progress.handle.create({
    lsp_client = {
      name = "harpoon",
    },
    title = titles[event],
    message = display,
    level = vim.log.levels.ERROR,
  })

  vim.defer_fn(function()
    handle:finish()
  end, 500)
end

local function handler(evt)
  return function(...)
    notify(evt, ...)
  end
end

---@param list HarpoonList
---@param items HarpoonListItem[]
local function add_items(list, items)
  for _, item in ipairs(items) do
    local exists = false
    for _, list_item in ipairs(list.items) do
      if list.config.equals(item, list_item) then
        exists = true
        break
      end
    end
    if not exists then
      list:add(item)
    end
  end
end

---@param list HarpoonList
local function add_new_entries(list)
  ---@diagnostic disable-next-line: undefined-field
  if not list.config.prepopulate then
    return
  end

  local sync_items =
    ---@diagnostic disable-next-line: undefined-field
    list.config.prepopulate(function(items)
      if type(items) ~= "table" then
        return
      end
      add_items(list, items)
      -- if ui is open, buffer needs to be updated
      -- so that items aren't removed immediately after being added
      vim.schedule(function()
        local ui_buf = harpoon.ui.bufnr
        if ui_buf and vim.api.nvim_buf_is_valid(ui_buf) then
          local lines = list:display()
          vim.api.nvim_buf_set_lines(ui_buf, 0, -1, false, lines)
        end
      end)
    end)
  if sync_items and type(sync_items) == "table" then
    add_items(list, sync_items)
  end
end

---@param list HarpoonList
local function prepopulate(list)
  ---@diagnostic disable-next-line: undefined-field
  if
    list.config.prepopulate and (list:length() == 0 or list.config.automated)
  then
    -- async via callback, or sync via return value
    local sync_items =
      ---@diagnostic disable-next-line: undefined-field
      list.config.prepopulate(function(items)
        if type(items) ~= "table" then
          return
        end
        for _, item in ipairs(items) do
          list:add(item)
        end
        -- if ui is open, buffer needs to be updated
        -- so that items aren't removed immediately after being added
        vim.schedule(function()
          local ui_buf = harpoon.ui.bufnr
          if ui_buf and vim.api.nvim_buf_is_valid(ui_buf) then
            local lines = list:display()
            vim.api.nvim_buf_set_lines(ui_buf, 0, -1, false, lines)
          end
        end)
      end)
    if sync_items and type(sync_items) == "table" then
      for _, item in ipairs(sync_items) do
        list:add(item)
      end
    end
  end
end

harpoon:extend({
  ADD = handler("ADD"),
  REMOVE = function(cx)
    notify("REMOVE", cx)
    if cx.list.config.remove then
      cx.list.config.remove(cx.item, cx.list)
    end
  end,
  -- LIST_CHANGE = function(...)
  --
  -- end,
  UI_CREATE = function(cx)
    local win = cx.win_id
    vim.wo[win].cursorline = true
    vim.wo[win].signcolumn = "no"

    willothy.win.update_config(win, function(config)
      config.footer = harpoon.ui.active_list.name
      config.footer_pos = "center"
      config.width = math.floor(math.max(math.min(120, vim.o.columns / 2), 40))
      config.col = math.floor(vim.o.columns / 2 - config.width / 2)
      config.row = math.floor(vim.o.lines / 2 - config.height / 2)
      return config
    end)

    vim.keymap.set("n", "<C-v>", function()
      harpoon.ui:select_menu_item({ vsplit = true })
    end, { buffer = cx.bufnr })
    vim.keymap.set("n", "<C-s>", function()
      harpoon.ui:select_menu_item({ split = true })
    end, { buffer = cx.bufnr })
  end,
  ---@param list HarpoonList
  LIST_READ = function(list)
    ---@diagnostic disable-next-line: undefined-field
    if list.config.automated then
      add_new_entries(list)
    end
  end,
  LIST_CREATED = prepopulate,
})
