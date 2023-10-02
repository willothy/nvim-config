# nvim-config

My personal Neovim config. I would not recommend using this - It's setup for me,
I cannot guarantee that it will work for you, and I will not fix issues that
do not occur on my computers. However, feel free to copy paste snippets
to add to your own config :)

## Bloated AND Blazingly Fast™

- Over 150 plugins
- ~15ms startup on both my desktop and laptop
- Lazy load EVERYTHING. Only a few plugins load before UiEnter.
- I've spent a stupid amount of time optimizing

![eeeeeeeeeeeeeeeeee](https://github.com/willothy/nvim-config/assets/38540736/7c7b5756-bc8b-4a07-a140-b36f9da30ac2)
![startuptime](https://github.com/willothy/nvim-config/assets/38540736/7713eadd-0b2a-4ab2-9188-cbd0eb1f24aa)<br>
*fastest recorded startup time with this config*

## Some things I'm working on in this repo

- `rx.lua`: Reactive extensions for Neovim
  - [x] signals and effects
  - [x] automatic dependency tracking
  - [ ] automatic cleanup (wip)
  - [ ] scoping & signal ownership
- `player.lua`: Playerctl UI for Neovim
  - [x] playerctl wrapper
  - [ ] nui UI (wip)

## Directory Structure

```txt
 init.lua                       # lazy.nvim bootstrap
 lua
├───  configs                   # plugin configs
├───  plugins                   # plugin lazy specs
├───  resession                 # plugin manager extensions
│    └──  extensions
│        └──  scope.lua         # scope.nvim extension
│
└───  willothy
     ├──  _meta.lua             # meta info for `willothy.*` completion
     ├──  init.lua              # main config entry point
     ├──  lazy.lua              # lazy-loaded initialization steps
     ├──  autocmds.lua
     ├──  commands.lua
     ├──  settings.lua
     │
     ├──  keymap
     │   ├──  buffer.lua        # <leader>b buffer related
     │   ├──  cycle.lua         # next/prev mappings with []
     │   ├──  editor.lua        # misc editor mappings (needs cleanup)
     │   ├──  find.lua          # <leader>f mappings
     │   ├──  git.lua           # <leader>g git / neogit
     │   ├──  init.lua
     │   ├──  jump.lua          # <leader>j portal
     │   ├──  lsp.lua           # <leader>c lsp/codelens
     │   ├──  projects.lua      # <leader>p projects
     │   ├──  terminal.lua      # terminal related bindings
     │   ├──  view.lua          # <leader>v view mappings
     │   └──  window.lua        # <C-w> mappings
     │
     ├──  modules               # Access from the global willothy.*
     │   ├──  fn.lua            # misc functions
     │   ├──  fs.lua            # filesystem stuff
     │   ├──  hl.lua            # highlight stuff
     │   ├──  icons.lua         # categorized icons
     │   ├──  keymap.lua        # keymap utilities
     │   ├──  player.lua        # custom playerctl wrapper / Nui-based UI (wip)
     │   ├──  rx.lua            # reactive runtime (wip)
     │   ├──  terminals.lua     # customized toggleterm terminals
     │   │
     │   ├──  hydras            # hydras (willothy.hydras)
     │   │   ├──  buffers.lua
     │   │   ├──  diagrams.lua
     │   │   ├──  git.lua
     │   │   ├──  init.lua
     │   │   ├──  options.lua
     │   │   ├──  swap.lua
     │   │   ├──  telescope.lua
     │   │   └──  windows.lua
     │   │
     │   ├──  ui                # ui (willothy.ui)
     │   │   ├──  float_drag.lua# float dragging
     │   │   ├──  scrolleof.lua # scroll past end of file (wip, using scrollEOF instead)
     │   │   ├──  scrollbar.lua # custom scrollbars based on noice.nvim
     │   │   └──  select.lua    # vim.ui.select powered by dropbar.nvim
     │   │
     │   └──  utils             # utilities (willothy.utils)
     │       ├──  buf.lua       # buffer utilities
     │       ├──  cursor.lua    # hide and show noice cursor
     │       ├──  debug.lua     # get upvalues, func info etc.
     │       ├──  mode.lua      # get current mode name / color, incl. hydra
     │       ├──  plugins.lua   # plugin / github utilities
     │       ├──  progress.lua  # custom lsp progress messages
     │       ├──  table.lua     # table utilities
     │       ├──  tabpage.lua   # tabpage utilities
     │       ├──  templates.lua # filetype templates
     │       └──  window.lua    # window utilities
     │
     ├──  lines        # (bad) ascii canvas library
     └──  scratchpads  # place for me to mess around with random Lua stuff
```
