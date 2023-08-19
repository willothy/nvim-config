# nvim-config

My personal Neovim config. Over 10000LOC (I have no life). I would
not recommend using this - It's setup for me, I cannot guarantee that it will work for you, and I will
not fix issues that do not occur on my computers. However, feel free
to copy paste snippets to add to your own config :)

## Bloated AND Blazingly Fast™

- Over 150 plugins
- Under 15ms startup on my desktop
- 20-40ms startup time on my laptop
- Lazy load EVERYTHING. Only a few plugins load before UiEnter.
- I've spent a stupid amount of time optimizing

## Directory Structure

```
 init.lua                       # main entry - only lazy.nvim bootstrap
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
     │   ├──  floats.lua        # float dragging (disabled by default)
     │   ├──  fn.lua            # misc functions
     │   ├──  fs.lua            # filesystem stuff
     │   ├──  hl.lua            # highlight stuff
     │   ├──  icons.lua         # categorized icons
     │   ├──  keymap.lua        # keymap utilities
     │   ├──  marks.lua         # custom sqlite-powered marks (wip)
     │   ├──  player.lua        # custom media controller / UI (wip)
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
     │   │   └──  scrollbar.lua # custom scrollbars based on noice.nvim
     │   │
     │   └──  utils             # utilities (willothy.utils)
     │       ├──  cursor.lua    # hide and show noice cursor
     │       ├──  debug.lua     # get upvalues, func info etc.
     │       ├──  mode.lua      # get current mode name / color, incl. hydra
     │       ├──  plugins.lua   # list and filter installed plugins
     │       ├──  tabpage.lua   # tabpage utilities
     │       ├──  window.lua    # window utilities
     │       └──  templates.lua # filetype templates
     │
     ├──  lines        # (bad) ascii canvas library
     ├──  lsp_settings # lspconfig settings
     └──  scratchpads  # place for me to mess around with random Lua stuff
```
