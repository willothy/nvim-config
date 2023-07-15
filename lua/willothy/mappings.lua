if vim.g.minimal then return end

local cache = {}
local function memo(module)
  if cache[module] then return cache[module] end
  local mod = require(module)
  cache[module] = mod
  return mod
end

local function register(modes, mappings, opts)
  if type(modes) == "table" then
    vim.iter(modes):each(
      function(mode)
        memo("which-key").register(
          mappings,
          vim.tbl_deep_extend("keep", { mode = mode }, opts or {})
        )
      end
    )
  else
    memo("which-key").register(
      mappings,
      vim.tbl_deep_extend("keep", { mode = modes }, opts or {})
    )
  end
end

local function mkportal(title, items, callback, opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, {
    max_results = 4,
  })
  local Content = memo("portal.content")
  local Iterator = memo("portal.iterator")
  local Portal = memo("portal")

  local iter = Iterator:new(items)
  if opts.filter then iter = iter:filter(opts.filter) end
  if opts.map then iter = iter:map(opts.map) end
  iter = iter
    :map(
      function(v, _i)
        return Content:new({
          type = v.title or title,
          buffer = v.bufnr,
          cursor = { row = v.lnum, col = v.col },
          callback = callback,
        })
      end
    )
    :take(opts.max_results)

  local res = {
    source = iter,
    slots = opts.slots,
  }
  Portal.tunnel(res)
end

local function portal_diagnostics(opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, {
    max_results = 4,
  })
  local diagnostics = vim.diagnostic.get(opts.buffer or nil)
  local Content = memo("portal.content")
  local Iterator = memo("portal.iterator")
  local Portal = memo("portal")

  local iter = Iterator:new(diagnostics)
    :take(4)
    :map(function(v, _i)
      return Content:new({
        type = "diagnostics",
        buffer = v.bufnr,
        cursor = { row = v.lnum, col = 1 },
        extra = v.col,
        callback = function(content)
          local buf = content.buffer
          local cursor = content.cursor
          local win = vim.api.nvim_get_current_win()
          local bufnr = vim.api.nvim_win_get_buf(win)
          if buf ~= bufnr then vim.api.nvim_set_current_buf(buf) end
          vim.api.nvim_win_set_cursor(win, { cursor.row, content.extra })
        end,
      })
    end)
    :take(opts.max_results)
  local res = {
    source = iter,
    slots = nil,
  }
  Portal.tunnel(res)
end

local function portal_references(context)
  local params = vim.lsp.util.make_position_params()
  params.context = context or {
    includeDeclaration = true,
  }
  vim.lsp.buf_request(
    0,
    "textDocument/references",
    params,
    function(err, result)
      if err then
        vim.notify(err.message)
        return
      end
      if not result then
        vim.notify("no references found")
        return
      end
      local references = result
      mkportal("references", references, function(content)
        local buf = content.buffer
        local cursor = content.cursor
        local win = vim.api.nvim_get_current_win()
        local bufnr = vim.api.nvim_win_get_buf(win)
        if buf ~= bufnr then vim.api.nvim_set_current_buf(buf) end
        vim.api.nvim_win_set_cursor(win, { cursor.row + 1, cursor.col })
      end, {
        map = function(v)
          return {
            title = "references",
            bufnr = vim.uri_to_bufnr(v.uri),
            lnum = v.range.start.line,
            col = v.range.start.character,
          }
        end,
      })
    end
  )
end

vim.keymap.set(
  { "n", "i", "t" },
  "<C-Enter>",
  function() memo("willothy.terminals").toggle() end
)

-- Dap
register({ "n" }, {})

-- Spider
register({ "n", "o", "x" }, {
  name = "spider",
  w = {
    function() memo("spider").motion("w") end,
    "Spider-w",
  },
  e = {
    function() memo("spider").motion("e") end,
    "Spider-e",
  },
  b = {
    function() memo("spider").motion("b") end,
    "Spider-b",
  },
  ge = {
    function() memo("spider").motion("ge") end,
    "Spider-ge",
  },
})

register({ "n", "i" }, {
  ["<C-e>"] = {
    function() memo("harpoon.ui").toggle_quick_menu() end,
    "Toggle harpoon quick menu",
  },
  ["<M-k>"] = {
    function() memo("moveline").up() end,
    "Move line up",
  },
  ["<M-j>"] = {
    function() memo("moveline").down() end,
    "Move line down",
  },
  ["<F1>"] = {
    function() memo("cokeline.mappings").pick("focus") end,
    "Pick buffer",
  },
  ["<C-s>"] = {
    function() vim.cmd("write") end,
    "Save",
  },
})

register("n", {
  ["<Tab>"] = { "V>", "Indent line" },
  ["<S-Tab>"] = { "V<", "Unindent line" },
})

register({ "n", "t" }, {
  ["<C-Up>"] = {
    function() memo("smart-splits").move_cursor_up() end,
    "Move to window up",
  },
  ["<C-Down>"] = {
    function() memo("smart-splits").move_cursor_down() end,
    "Move to window down",
  },
  ["<C-Left>"] = {
    function() memo("smart-splits").move_cursor_left() end,
    "Move to window left",
  },
  ["<C-Right>"] = {
    function() memo("smart-splits").move_cursor_right() end,
    "Move to window right",
  },
  ["<M-Up>"] = {
    function() memo("smart-splits").resize_up() end,
    "Resize to window up",
  },
  ["<M-Down>"] = {
    function() memo("smart-splits").resize_down() end,
    "Resize to window down",
  },
  ["<M-Left>"] = {
    function() memo("smart-splits").resize_left() end,

    "Resize to window left",
  },
  ["<M-Right>"] = {
    function() memo("smart-splits").resize_right() end,
    "Resize to window right",
  },
  ["<C-w>"] = {
    name = "window",
    ["<Up>"] = {
      function() memo("smart-splits").move_cursor_up() end,
      "Move to window above",
    },
    ["<Down>"] = {
      function() memo("smart-splits").move_cursor_down() end,
      "Move to window below",
    },
    ["<Left>"] = {
      function() memo("smart-splits").move_cursor_left() end,
      "Move to window left",
    },
    ["<Right>"] = {
      function() memo("smart-splits").move_cursor_right() end,
      "Move to window right",
    },
    ["k"] = {
      function() memo("smart-splits").move_cursor_up() end,
      "Move to window abovw",
    },
    ["j"] = {
      function() memo("smart-splits").move_cursor_down() end,
      "Move to window below",
    },
    ["h"] = {
      function() memo("smart-splits").move_cursor_left() end,
      "Move to window left",
    },
    ["l"] = {
      function() memo("smart-splits").move_cursor_right() end,
      "Move to window right",
    },
    ["="] = {
      function() memo("focus").focus_equalise() end,
      "Equalize window sizes",
    },
    ["g"] = {
      function() memo("focus").resize() end,
      "Autoresize based on golden ratio",
    },
    ["m"] = {
      function() memo("focus").focus_maximise() end,
      "Maximize focused window",
    },
    ["f"] = {
      function() memo("nvim-window").pick() end,
      "Pick window",
    },
    x = {
      function()
        memo("winshift")
        vim.api.nvim_exec("WinShift swap", true)
      end,
      "Swap windows",
    },
    ["<C-w>"] = {
      function()
        memo("winshift")
        vim.api.nvim_exec("WinShift", true)
      end,
      "Enter WinShift mode",
    },
  },
})

register("t", {
  ["<Esc>"] = { "<C-\\><C-n>", "Exit terminal" },
})

memo("which-key").register({
  ["["] = {
    name = "prev",
    b = {
      function() memo("cokeline.mappings").by_step("focus", -1) end,
      "Focus previous buffer",
    },
    B = {
      function() memo("cokeline.mappings").by_step("switch", -1) end,
      "Move previous buffer",
    },
  },
  ["]"] = {
    name = "next",
    b = {
      function() memo("cokeline.mappings").by_step("focus", 1) end,
      "Focus next buffer",
    },
    B = {
      function() memo("cokeline.mappings").by_step("switch", 1) end,
      "Move next buffer",
    },
  },
})

register({ "n", "t" }, {
  ["<S-Esc>"] = {
    "<Cmd>TroubleToggle document_diagnostics<CR>",
    "Diagnostics",
  },
  ["<S-CR>"] = {
    function() memo("willothy.terminals").toggle() end,
    "Toggle terminal",
  },
})

register({ "n", "x" }, {
  ["<C-F>"] = {
    function() memo("ssr").open() end,
    "Structural Search/Replace",
  },
  ["<C-CR>"] = {
    function() memo("cokeline.mappings").pick("focus") end,
    "Pick buffer",
  },
})

memo("which-key").register({
  v = "view",
  r = "misc",
  a = {
    function() memo("harpoon.mark").add_file() end,
    "Add file to harpoon",
  },
  t = {
    name = "toggle",
    u = { vim.cmd.UndotreeToggle, "Toggle undotree" },
    t = {
      function() memo("willothy.terminals").toggle() end,
      "Toggle terminal",
    },
    f = {
      function() memo("willothy.terminals").toggle_float() end,
      "Toggle floating terminal",
    },
    h = {
      function()
        local h = memo("harpoon.mark")
        local buf = vim.api.nvim_buf_get_name(0)
        if not h.get_current_index() then
          h.add_file(buf) -- mark is not in list
        else
          h.rm_file(buf) -- mark is in list
        end
      end,
      "Toggle current harpoon mark",
    },
    s = {
      function()
        vim.ui.input({
          prompt = "$ ",
          completion = "shellcmd",
        }, function(v)
          if v and type(v) == "string" then
            memo("willothy.terminals").with():send(v)
          end
        end)
      end,
      "Send to terminal",
    },
    p = {
      function() memo("willothy.terminals").py:toggle() end,
      "Python repl",
    },
    l = {
      function() memo("willothy.terminals").lua:toggle() end,
      "Lua repl",
    },
    c = {
      name = "Actions",
      a = "Code actions",
      o = {
        function() memo("telescope.builtin").oldfiles() end,
        "Telescope oldfiles",
      },
      r = {
        function() memo("telescope.builtin").registers() end,
        "Telescope registers",
      },
      s = {
        function() memo("telescope.builtin").lsp_document_symbols() end,
        "Telescope LSP document symbols",
      },
    },
  },
  b = {
    name = "buffer",
    p = {
      function() memo("cokeline.mappings").pick("focus") end,
      "Pick buffer",
    },
    x = {
      function() memo("cokeline.mappings").pick("close") end,
      "Delete buffer",
    },
  },
  -- f = {
  --   name = "file",
  --   f = {
  --     function() memo("telescope").extensions.menufacture.find_files() end,
  --     "Find files",
  --   },
  --   g = {
  --     function() memo("telescope").extensions.menufacture.git_files() end,
  --     "Find git files",
  --   },
  --   s = {
  --     function() memo("telescope").extensions.menufacture.grep_string() end,
  --     "Grep string",
  --   },
  --   b = {
  --     function() memo("telescope").extensions.scope.buffers() end,
  --     "Find buffers",
  --   },
  --   n = { vim.cmd.enew, "Create a new buffer" },
  --   v = {
  --     function() memo("willothy.util").browse(vim.fn.expand("%:p:h")) end,
  --     "Browse current file's directory",
  --   },
  --   p = {
  --     function()
  --       vim.ui.input(
  --         { prompt = "Path: " },
  --         function(input) memo("willothy.util").browse(input) end
  --       )
  --     end,
  --     "Browse path from input",
  --   },
  -- },
  p = {
    name = "project",
    f = {
      function() memo("willothy.util").browse("~/projects/") end,
      "Browse projects",
    },
    v = {
      function() memo("willothy.util").browse() end,
      "Browse current directory",
    },
    r = {
      function()
        memo("willothy.util").browse(memo("willothy.util").project_root())
      end,
      "Browse project root",
    },
    h = {
      function() memo("willothy.util").browse(vim.loop.os_homedir()) end,
      "Browse home directory",
    },
    cr = {
      function()
        memo("willothy.util").browse(memo("willothy.util").crate_root())
      end,
      "Browse crate root",
    },
    pc = {
      function()
        memo("willothy.util").browse(memo("willothy.util").parent_crate())
      end,
      "Browse parent crate",
    },
  },
  c = {
    name = "comment",
    c = "Comment current line",
    b = "Block comment current line",
  },
  g = {
    name = "git",
    f = { vim.cmd.Git, "Open fugitive" },
    b = {
      function() memo("blam").peek() end,
      "Peek line blame",
    },
    g = {
      function()
        -- hacky way of toggling diffview
        local diffview = memo("diffview")
        local lib = memo("diffview.lib")
        if lib.get_current_view() then
          diffview.close()
        else
          diffview.open()
        end
      end,
      "Diffview",
    },
  },
  d = {
    name = "Debugging",
    t = {
      function() memo("dapui").toggle() end,
      "Toggle DAP UI",
    },
  },
  ["l$"] = "Add comment at end of line",
  n = {
    name = "neovim",
    v = {
      function() memo("willothy.util").browse(vim.fn.stdpath("config")) end,
      "Browse nvim config",
    },
  },
  j = {
    name = "portal",
    gd = { portal_diagnostics, "global diagnostics" },
    d = {
      function() portal_diagnostics({ buffer = 0 }) end,
      "diagnostics",
    },
    r = { portal_references, "references" },
    j = { function() memo("portal.builtin").jumplist.tunnel() end, "jumplist" },
    h = { function() memo("portal.builtin").harpoon.tunnel() end, "harpoon" },
    q = { function() memo("portal.builtin").quickfix.tunnel() end, "quickfix" },
    c = {
      function() memo("portal.builtin").changelist.tunnel() end,
      "changelist",
    },
  },
}, { prefix = "<leader>" })

memo("which-key").register({
  ["<M-k>"] = {
    function() memo("moveline").block_up() end,
    "Move block up",
  },
  ["<M-j>"] = {
    function() memo("moveline").block_down() end,
    "Move block down",
  },
  ["<Tab>"] = { ">gv", "Indent line" },
  ["<S-Tab>"] = { "<gv", "Unindent line" },
  ["<C-c>"] = { '"+y', "Copy selection" },
}, {
  mode = "v",
})

local Hydra = memo("hydra")
local cmd = memo("hydra.keymap-util").cmd

local function escape(str) return str:gsub("\\", "\\\\") end

local function mkheader(str) return escape(str) end

---@class Lines
---@field dimensions integer[]
local Lines = {}
Lines.__index = Lines

function Lines:new(data)
  local o
  if type(data) == "string" then
    o = setmetatable(vim.split(data, "\n", { trimempty = true }), Lines)
  elseif type(data) == "table" then
    o = setmetatable(data, Lines)
  else
    error("invalid data type")
  end
  local dimensions = { #o, 0 }
  for _, line in ipairs(o) do
    dimensions[2] = math.max(dimensions[2], vim.fn.strdisplaywidth(line))
  end
  o.dimensions = dimensions
  return o
end

function Lines:width() return self.dimensions[2] end

function Lines:height() return self.dimensions[1] end

function Lines:truncate_width(width)
  local lines = {}
  for _, line in ipairs(self) do
    table.insert(lines, line:sub(1, width))
  end
  return Lines:new(lines)
end

function Lines:truncate_height(height, start)
  local lines = {}
  for i = start, height + start do
    table.insert(lines, self[i])
  end
  return Lines:new(lines)
end

---@param dimensions Lines | integer[]
function Lines:empty(dimensions)
  local dims
  if getmetatable(dimensions) == Lines then
    dims = dimensions.dimensions
  else
    dims = dimensions
  end
  local lines = {}
  for _ = 1, dims[1] do
    table.insert(lines, string.rep(" ", dims[2]))
  end
  return Lines:new(lines)
end

function Lines:escape()
  for i, line in ipairs(self) do
    self[i] = escape(line)
  end
  return self
end

function Lines:overlay(other, row, col)
  if not row then row = 1 end
  if not col then col = 1 end
  if #other + row - 1 > #self then
    error("lines2 is longer than lines1")
    return self
  end

  local i = 0
  self = setmetatable(
    vim.list_extend(
      vim.list_slice(self, 1, row - 1),
      vim
        .iter(self)
        :skip(row - 1)
        :map(function(line, e)
          if type(line) ~= "string" then line = e end
          i = i + 1
          local other_line = other[i]
          if not other_line then return line end
          local new = col > 1 and line:sub(1, col - 1) or ""
          for j = col, #line do
            local l1_char = line:sub(j, j)
            local l2_char = other_line:sub(j - col + 1, j - col + 1)

            if
              j < col
              or j > (col + #other_line)
              or l2_char == nil
              or l2_char == ""
              or (
                string.match(l2_char, "%s+") ~= nil
                and other_line:sub(j - col, j - col) == " "
              )
            then
              new = new .. l1_char
            -- elseif other_line:sub(j - col + 2, j - col + 2) == " " then
            --   new = new .. l1_char
            else
              new = new .. l2_char
            end
          end
          return new
        end)
        :totable()
    ),
    Lines
  )

  return self
end

function Lines:render() return table.concat(self, "\n") end

local hint = mkheader(
  [[
.   * .    * .  ' -+-    ' *     .  `     .     -*-     .    ` 
     . .-.     `    .  * .  _f_: files . -+- _s_: live grep  . -+-
* .   {}``; |==|████████| * _p_: projects  * _g_: git files   *
      / ('   .    /|\       _r_: resume   *  _u_: undotree '    .
  (  /  \  .  *  / | \   ' .  .      * .  ' . * -+-  * .  '  .
   \( )  ]   .  /  |  \ .   _<Enter>_: pickers    _<Esc>_ _q_
█████████████████████████▇▆▅▄▂▁ +-    ' *     -*- `   .     ]]
)

local backgrounds = {
  stars = Lines:new([[
 .              +   .                .   . .     .  .
                   .                    .       .     *
  .       *               -*-       . . . .  .   .  + .
                     `                .   `  +  . . .
.          *                    .  .   .    .    . `
     +         .              .     .     . +.    +  .
                                .       .   . .
        . .           `      .    * . ` .  .  +   .
  -+-      +      .           .   .      +
                            .       . +  .+. .
  .                      .     . + .  . .     .      .
           .      .    .   ` . .   . . .        ! /
      *             .    . .  +    .  .       - O -
          .     .    .  +   ` .  *  .       . / |
               . + .  .  .  .. +  .
.      .  .  .  *   .  *  . +..  .            *
 .      .   . .   .   .   . .  +   .    .            +
  ]]),
  aurora = Lines:new([[
    ` : | | |:  ||  :     `  :  |  |+|: | : : :|   .        `              .
      ` : | :|  ||  |:  :    `  |  | :| : | : |:   |  .                    :
         .' ':  ||  |:  |  '       ` || | : | |: : |   .  `           .   :.
                `'  ||  |  ' |   *    ` : | | :| |*|  :   :               :|
        *    *       `  |  : :  |  .      ` ' :| | :| . : :         *   :.||
             .`            | |  |  : .:|       ` | || | : |: |          | ||
      '          .         + `  |  :  .: .         '| | : :| :    .   |:| ||
         .                 .    ` *|  || :       `    | | :| | :      |:| |
 .                .          .        || |.: *          | || : :     :|||
        .            .   . *    .   .  ` |||.  +        + '| |||  .  ||`
     .             *              .     +:`|!             . ||||  :.||`
 +                      .                ..!|*          . | :`||+ |||`
     .                         +      : |||`        .| :| | | |.| ||`     .
       *     +   '               +  :|| |`     :.+. || || | |:`|| `
                            .      .||` .    ..|| | |: '` `| | |`  +
  .       +++                      ||        !|!: `       :| |
              +         .      .    | .      `|||.:      .||    .      .   
          '                           `|.   .  `:|||   + ||'     `
  __    +      *                         `'       `'|.    `:
"'  `---"""----....____,..^---`^``----.,.___          `.    `.  .    ____,.
    ___,--'""`---"'   ^  ^ ^        ^       """'---,..___ __,..---""'
--"'                                 ^                         ``--..,__
  ]]),
  space2 = Lines:new([[
                    .                                            .
     *   .                  .              .        .   *          .
  .         .                     .       .           .      .        .
        o                             .                   .
         .              .                  .           .
          0     .
                 .          .                 ,                ,    ,
 .          \          .                         .
      .      \   ,
   .          o     .                 .                   .            .
     .         \                 ,             .                .
               #\##\#      .                              .        .
             #  #O##\###                .                        .
   .        #*#  #\##\###                       .                     ,
        .   ##*#  #\##\##               .                     .
      .      ##*#  #o##\#         .                             ,       .
          .     *#  #\#     .                    .             .          ,
                      \          .                         .
____^/\---^--__________O______________/\/\---/\___________---______________
   /\^   ^  ^    ^                  ^^ ^  '\ ^          ^       ---
         --           -            --  -      -         ---  __       ^
   --  __                      ___--  ^  ^                         --  __
  ]]),
  space = Lines:new([[
                    .                                            .
     *   .                  .              .        .   *          .
  .         .                     .       .           .      .        .
        o                             .                   .
         .              .                  .           .
          0     .
                 .          .                 ,                ,    ,
 .                     .                         .
      .    .     ,
   .                .       -*-       .                   .            .
     .                           ,             .                .
           .               .                              .        .
                     .                  .                        .
   .                                            .                     ,
        .                               .                     .
      .           .               .                             ,       .
          .                 .                    .             .          ,
                                 .                         .
-------^----------------^-----------------------v--------------------------
     ^   ^  ^    ^                  ^^ ^  '\ ^          ^       ---
         --           -            --  -      -         ---  __       ^
   --  __                      ___--  ^  ^                         --  __
  ]]),
  mountains = Lines:new([[
          _    .  ,   .           .
    *  / \_ *  / \_      _  *        *   /\'__        *
      /    \  /    \,   ((        .    _/  /  \  *'.
 .   /\/\  /\/ :' __ \_  `          _^/  ^/    `--.
    /    \/  \  _/  \-'\      *    /.' ^_   \_   .'\  *
  /\  .-   `. \/     \ /==~=-=~=-=-;.  _/ \ -. `_/   \
 /  `-.__ ^   / .-'.--\ =-=~_=-=~=^/  _ `--./ .-'  `-
/        `.  / /       `.~-^=-=~=^=.-'      '-._ `._
  ]]),
  sunset = Lines:new([[
                                @@@@@@@@@
       ^^      ^^            @@@@@@@@@@@@@@@
          ^^               @@@@@@@@@@@@@@@@@@              ^^
                          @@@@@@@@@@@@@@@@@@@@
~~~~ ~~ ~~~~~ ~~~~~~~~ ~~ &&&&&&&&&&&&&&&&&&&& ~~~~~~~ ~~~~~~~~~~~ ~~~
~         ~~   ~  ~       ~~~~~~~~~~~~~~~~~~~~ ~       ~~     ~~ ~
  ~      ~~      ~~ ~~ ~~  ~~~~~~~~~~~~~ ~~~~  ~     ~~~    ~ ~~~  ~ ~~ 
  ~  ~~     ~         ~      ~~~~~~  ~~ ~~~       ~~ ~ ~~  ~~ ~ 
~  ~       ~ ~      ~           ~~ ~~~~~~  ~      ~~  ~             ~~
      ~             ~        ~      ~      ~~   ~             ~
  ]]),
  clouds1 = Lines:new([[
            _                                  
          (`  ).                   _           
         (     ).              .:(`  )`.       
        _(       '`.          :(   .    )      
    .=(`(      .   )     .--  `.  (    ) )      
   ((    (..__.:'-'   .+(   )   ` _`  ) )                 
   `(       ) )       (   .  )     (   )  ._   
     ` __.:'   )     (   (   ))     `-'.-(`  ) 
  ( )       --'       `- __.'         :(      )) 
 (_.'          .')                    `(    )  ))
              (_  )                     ` __.:'          
  ]]),
  clouds2 = Lines:new([[
      \       I     				
                  /
        \  ,g88R_
          d888(`  ).                   _
 -  --==  888(     ).=--           .+(`  )`.
)         Y8P(       '`.          :(   .    )
        .+(`(      .   )     .--  `.  (    ) )
       ((    (..__.:'-'   .=(   )   ` _`  ) )
`.     `(       ) )       (   .  )     (   )  ._
  )      ` __.:'   )     (   (   ))     `-'.:(`  )
)  )  ( )       --'       `- __.'         :(      ))
.-'  (_.'          .')                    `(    )  ))
                  (_  )                     ` __.:'
  ]]),
}

local elements = {
  planets = {
    earth = Lines:new([[
    .-:::'-':-.
  .''::::.:    '.
 /   :::::'     :\
;.    ':' `      :;
|       '..      ;|
; '      ::::.    ;
 \       '::::   /
  '.      :::  .'
    '-.___'_.-'
    ]]),
    earth_large = Lines:new([[
              _-o#&&*''''?d:>o-_
          _o/"`''  '',, dMF9MMMMMHo_
       .o&#'        `"MbHMMMMMMMMMMMHo.
     .o"" '         vodM*$&&HMMMMMMMMMM?.
    ,'              $M&ood,~'`(&##MMMMMMH\
   /               ,MMMMMMM#b?#bobMMMMHMMML
  &              ?MMMMMMMMMMMMMMMMM7MMM$R*Hk
 ?$.            :MMMMMMMMMMMMMMMMMMM/HMMM|`*L
|               |MMMMMMMMMMMMMMMMMMMMbMH'   T,
$H#:            `*MMMMMMMMMMMMMMMMMMMMb#}'  `?
]MMH#             ""*""""*#MMMMMMMMMMMMM'    -
MMMMMb_                   |MMMMMMMMMMMP'     :
HMMMMMMMHo                 `MMMMMMMMMT       .
?MMMMMMMMP                  9MMMMMMMM}       -
-?MMMMMMM                  |MMMMMMMMM?,d-    '
 :|MMMMMM-                 `MMMMMMMT .M|.   :
  .9MMM[                    &MMMMM*' `'    .
   :9MMk                    `MMM#"        -
     &M}                     `          .-
      `&.                             .
        `~,   .                     ./
            . _                  .-
              '`--._,dd###pp=""'
    ]]),
  },
  telescope_dog = Lines:new([[
       .-.              
      {}``; |==|████████|  
      / ('        /|\       
  (  /  \        / | \    
   \( )  ]      /  |  \    
  ]]),
  telescope = Lines:new([[
            // 
           //
  ___o |==// 
 /\  \/  //|\ 
/ /        | \ 
` `        '  '
  ]]),
}

-- █████████████████████████▇▆▅▄▂▁

vim.api.nvim_create_user_command("Testthething", function()
  local bg = backgrounds.space
  local planet = elements.planets.earth
  local dog = elements.telescope_dog
  local person = elements.telescope

  local backdrop = Lines:empty(bg.dimensions)
  local test = backdrop
    :overlay(bg)
    :overlay(planet, 4, bg.dimensions[2] - planet.dimensions[2] - 10)
    :overlay(person, bg.dimensions[1] - person.dimensions[1] + 1, 15)
    -- :escape()
    :render()
  vim.print(test)
end, {})

local function telescope(picker, menufacture)
  if menufacture then
    return function() memo("telescope").extensions.menufacture[picker]() end
  else
    return function() memo("telescope.builtin")[picker]() end
  end
end

Hydra({
  name = "Telescope",
  hint = hint,
  config = {
    color = "blue",
    invoke_on_body = true,
    hint = {
      position = "middle",
      border = "rounded",
    },
  },
  mode = "n",
  body = "<leader>f",
  heads = {
    {
      "s",
      telescope("live_grep", true),
      { desc = "Telescope: live grep" },
    },
    {
      "f",
      telescope("find_files", true),
      { desc = "Telescope: find files" },
    },
    {
      "g",
      telescope("git_files", true),
      { desc = "Telescope: git files" },
    },
    { "r", telescope("resume") },
    { "p", telescope("projects"), { desc = "Telescope: projects" } },
    {
      "u",
      cmd("silent! %foldopen! | UndotreeToggle"),
      { desc = "undotree" },
    },
    {
      "<Enter>",
      telescope("builtin"),
      { desc = "Telescope: list pickers" },
    },
    { "<Esc>", nil, { exit = true, nowait = true } },
    { "q", nil, { exit = true, nowait = true } },
  },
})
