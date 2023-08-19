---@meta

willothy = {}
willothy.fs = require("willothy.modules.fs")
willothy.hl = require("willothy.modules.hl")
willothy.fn = require("willothy.modules.fn")
willothy.icons = require("willothy.modules.icons")
willothy.keymap = require("willothy.modules.keymap")
willothy.player = require("willothy.modules.player")
willothy.term = require("willothy.modules.terminals")
willothy.marks = require("willothy.modules.marks")

willothy.utils = {}
willothy.utils.cursor = require("willothy.modules.utils.cursor")
willothy.utils.window = require("willothy.modules.utils.window")
willothy.utils.tabpage = require("willothy.modules.utils.tabpage")
willothy.utils.mode = require("willothy.modules.utils.mode")
willothy.utils.plugins = require("willothy.modules.utils.plugins")
willothy.utils.debug = require("willothy.modules.utils.debug")

-- These likely won't be used directly but are exposed for ease of use

willothy.ui = {}
willothy.ui.scrollbar = require("willothy.modules.ui.scrollbar")

willothy.hydras = {}
willothy.hydras.git = require("willothy.modules.hydras.git")
willothy.hydras.options = require("willothy.modules.hydras.options")
willothy.hydras.telescope = require("willothy.modules.hydras.telescope")
willothy.hydras.diagrams = require("willothy.modules.hydras.diagrams")
willothy.hydras.windows = require("willothy.modules.hydras.windows")
willothy.hydras.buffers = require("willothy.modules.hydras.buffers")
willothy.hydras.swap = require("willothy.modules.hydras.swap")
