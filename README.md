# nvim-config

My personal Neovim config. Over 10000LOC (I have no life). Setup for ME - I would
not recommend using this, I cannot guarantee that it will work for you and will
not fix issues that do not occur on my computers. However, feel free to copy paste
parts to add to your own config :)

## Features

### Bloated AND Blazingly Fast™

- Over 150 plugins
- Under 15ms startup on my desktop
- 20-40ms startup time on my laptop
- Lazy load EVERYTHING. Only a few plugins load before UiEnter.
- I've spent a stupid amount of time optimizing

### Tab scoped sessions and buffers

- Lsp-based auto cwd / project management (project.nvim)
- Dir-based session restoration (resession.nvim)
  - Unintrusive, won't autoload unless you open nvim with no args

### Convenient utilities

- Open files from nvim terminals and other Wezterm/Kitty windows (flatten.nvim)
- Window auto-resize and animation (focus.nvim and mini.animate)
- Sidebars and layouts using edgy.nvim

### Lots of custom functionality

- Futures implementation for async tasks (futures.nvim)
- Hydra / which-key integration (hydra bodies show up as groups in which-key)
- Lazy-loaded statusline components with event-based updates

#### Tabline / statusline components

- Harpoon mark position (click to toggle mark)
- Git changes (gitsigns & statuscol.nvim & diff counts in statusline)
- Diagnostic-integrated bufferline (nvim-cokeline)
- Clickable DAP-UI and sidebar toggles
