<div align="center">
  <h1>nvim-config</h1>
  <p>My personal Neovim config</p>
</div>

I would not recommend using this - It's setup for me,
I cannot guarantee that it will work for you, and I will not fix issues that
do not occur on my computers. However, feel free to copy paste snippets
to add to your own config :)

> **Note**<br>
> Requires Neovim Nightly

## Bloated AND Blazingly Fast™

- Over 150 plugins
- ~15ms startup on both my desktop and laptop
- Lazy load EVERYTHING. Only a few plugins load before UiEnter.
- I've spent a stupid amount of time optimizing

![startuptime](https://github.com/willothy/nvim-config/assets/38540736/43c942d4-e6ec-4c15-ae52-463cd9eb896e)
![n_plugins](https://github.com/willothy/nvim-config/assets/38540736/e2902140-76fb-4291-b1d3-2f8f5d007889)<br>
*fastest recorded startup time with this config*

## Some things I'm working on in this repo

- Custom UI elements
  - Simple floating scrollbars for split windows
  - Custom foldexpr <strike>and foldtext</strike>
    - Foldexpr
      - Shows both the last line of the fold
    - Foldtext
      - Removed as [neovim/neovim#20750](https://github.com/neovim/neovim/pull/20750) renders this redundant,
        see commit 1a93bd9 for my implementation.
      - Preserves, extmarks, semantic highlights, and inlay hints.
  - `ui.select` based on [`dropbar.nvim`](https://github.com/Bekaboo/dropbar.nvim)
    - This has now been merged into [`dropbar.nvim`](https://github.com/Bekaboo/dropbar.nvim), see the implementation there.
  - Code action menu with preview, based on dropbar.nvim's ui-select
    - Preview functionality for ui-select is not upstreamed in dropbar
      so a fork is used, but should be upstreamed soon.
  - Simple but featureful bars and lines:
    - Statusline: [`heirline.nvim`](https://github.com/rebelot/heirline.nvim)
    - Winbar: [`dropbar.nvim`](https://github.com/Bekaboo/dropbar.nvim)
    - Bufferline: [`nvim-cokeline`](https://github.com/willothy/nvim-cokeline).
    - Floating window indicator: [`incline.nvim`](https://github.com/b0o/incline.nvim).

- `rx.lua`: Reactive extensions for Neovim (very WIP, kinda abandoned)
  - [x] signals and effects
  - [x] automatic dependency tracking
  - [ ] automatic cleanup (wip)
  - [ ] scoping & signal ownership
- `player.lua`: Playerctl UI for Neovim
  - [x] playerctl wrapper
  - [ ] nui UI (wip)
