local M = {}

local Graph = {}
Graph.__index = Graph

function Graph.new(opts)
  opts = opts or {}
  return setmetatable({
    identity_fn = opts.identity_fn or function(node)
      return node
    end,
    modules = {},
    imports = {},
  }, Graph)
end

function Graph:add_module(node)
  local identity = self.identity_fn(node)
  if not self.modules[identity] then
    self.modules[identity] = node
  end
end

function Graph:add_import(module, imported)
  local module_id = self.identity_fn(module)
  local import_module_id = self.identity_fn(imported)

  if not self.imports[module_id] then
    self.imports[module_id] = {}
  end

  self.imports[module_id][import_module_id] = true
end

function Graph:to_text()
  local lines = {}

  for module_id, imports in pairs(self.imports) do
    table.insert(lines, module_id)
    for import_id in pairs(imports) do
      table.insert(lines, "  └─ " .. import_id)
    end
    table.insert(lines, "")
  end

  return table.concat(lines, "\n")
end

function Graph:to_graphviz()
  local lines = { "digraph G {", "  node [shape=box];" }

  for module_id, imports in pairs(self.imports) do
    for import_id, _ in pairs(imports) do
      table.insert(
        lines,
        string.format('  "%s" -> "%s";', module_id, import_id)
      )
    end
  end

  table.insert(lines, "}")
  return table.concat(lines, "\n")
end

function M.patch_require()
  local original_require = _G.require

  local imports = Graph.new()

  _G.import_graph = imports

  ---@diagnostic disable-next-line: duplicate-set-field
  _G.require = function(module)
    local info = debug.getinfo(2, "S")
    local current = info.source

    imports:add_module(module)
    imports:add_module(current)

    imports:add_import(current, module)

    return original_require(module)
  end
end

return M
