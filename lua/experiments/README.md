# experiments

Parked, **not-loaded** modules. Nothing in the active config `require`s anything
here — these are kept around as a sandbox / reference, not wired into startup.

To try one out, `require("experiments.<name>")` manually.

| Module | What it is | Superseded by |
| --- | --- | --- |
| `statusline` + `statusline_components` | Reactive statusline built on the custom signal system | `configs/status/heirline` |
| `reactive` | Vue/Solid-style reactive signal system | — |
| `state` | Global reactive state store (built on `reactive`) | — |
| `diagnostics_ui` | Custom floating diagnostic display | `diagflow` |
| `diagnostic_dispatcher` | Priority-based diagnostic handler registry | — |
| `code_actions` | Custom code-action UI with diff preview | builtin `vim.lsp.buf.code_action` |
| `incline` | winbar/info-box config (plugin not installed) | `dropbar` |
| `async` | Coroutine async/await helpers | — |
| `command` | OO `Command` builder | `willothy.lib.fn.create_command` |
| `http` | HTTP client helper | — |
| `llm` | LLM client helper | `avante` |
| `import-graph` | Module import-graph visualizer | — |
