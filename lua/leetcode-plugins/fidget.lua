local M = {}

M.opts = {
  lazy = false,
}

function M.load()
  local spinner = require("leetcode.logger.spinner")

  ---@param msg string?
  ---@param lvl integer?
  ---@param opts table?
  function spinner:set(msg, lvl, opts)
    if msg then
      self:update(msg)
    end
    lvl = lvl or vim.log.levels.INFO

    local config = require("leetcode.config")

    opts = opts or {}
    opts = vim.tbl_deep_extend("force", opts, {
      -- title = config.name,
      message = self.msg,
      -- title = self.,
      lsp_client = {
        name = config.name,
      },
    })

    if self.noti then
      self.noti:report(opts)
    else
      local fidget = require("fidget")
      self.noti = fidget.progress.handle.create(opts)
    end
  end

  ---@param msg string?
  ---@param success boolean?
  ---@param opts table?
  function spinner:stop(msg, success, opts)
    if self.noti then
      self.noti:report({
        message = msg,
      })
      if success then
        self.noti:finish()
      else
        self.noti:cancel()
      end
    end
  end
end

return M
