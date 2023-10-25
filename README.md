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

![startuptime](https://github.com/willothy/nvim-config/assets/38540736/43c942d4-e6ec-4c15-ae52-463cd9eb896e)
![n_plugins](https://github.com/willothy/nvim-config/assets/38540736/e2902140-76fb-4291-b1d3-2f8f5d007889)<br>
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
