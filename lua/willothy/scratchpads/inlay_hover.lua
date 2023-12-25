function Bruh()
  local nio = require("nio")

  local function unwrap(...)
    if select(1, ...) ~= nil then
      local err = select(1, ...)
      if type(err) == "table" then
        err = err.message
      end
      vim.notify(err, vim.log.levels.ERROR)
      return
    end
    return select(2, ...)
  end

  nio.run(function()
    local range = vim.lsp.util.make_range_params().range

    local hint = vim.lsp.inlay_hint.get({
      range = range,
      bufnr = 0,
    })[1]

    if not hint then
      return
    end

    local client_id, inlay_hint = hint.client_id, hint.inlay_hint --[[@as nio.lsp.types.InlayHint]]

    local client = nio.lsp.get_client_by_id(client_id)
    if not client then
      return
    end

    local resolved = unwrap(client.request.inlayHint_resolve(inlay_hint, 0, {
      timeout = 250,
    }))
    if not resolved then
      return
    end

    local label = resolved.label
    local location
    if type(label) == "table" then
      for _, v in ipairs(label) do
        if v.location then
          location = {
            position = v.location.range.start,
            textDocument = { uri = v.location.uri },
          }
          break
        end
      end
    end

    local res = unwrap(
      client.request.textDocument_hover(
        location or vim.lsp.util.make_position_params(),
        0,
        {
          timeout = 5000,
        }
      )
    )

    vim.lsp.handlers["textDocument/hover"](nil, res, {
      method = "textDocument/hover",
      client_id = client_id,
      bufnr = 0,
    })
  end)
end
