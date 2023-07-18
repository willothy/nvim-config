local M = {}

M.clones = {}

---@param repo string
---@return string name
function M.gen_name(repo)
  local name = repo
    :gsub("https", "")
    :gsub("://", "")
    :gsub("git@", "")
    :gsub("%.git", "")
    :gsub("%w+.%w+/", "")
    :gsub("/", "--")
  return name
end

function M.tempclone(repo)
  if not repo then return end
  local name = M.gen_name(repo)
  local tmpdir = vim.loop.os_tmpdir()
    .. ("/nvim.%s/%s"):format(os.getenv("USER"), name)

  local args = { "repo", "clone", name, tmpdir }
  _G.executor:spawn("gh", {
    args = args,
    callback = function(ok, out, err)
      if ok then
        M.clones[name] = tmpdir
        vim.notify(
          "cloned " .. repo .. " to " .. tmpdir .. ": " .. out,
          vim.log.levels.DEBUG
        )
      else
        vim.notify(string.gsub(err, "%s+$", ""), vim.log.levels.ERROR)
      end
    end,
  })
end

function M.tempdel(repo)
  if not repo then return end
  for name, path in pairs(M.clones) do
    path = vim.loop.os_tmpdir()
      .. ("/nvim.%s/%s"):format(os.getenv("USER"), repo)

    local args = { "-rf", path }
    _G.executor:spawn("rm", {
      args = args,
      callback = function(ok)
        if ok then
          vim.notify(
            "deleted " .. repo .. " from " .. path,
            vim.log.levels.DEBUG
          )
          M.clones[name] = nil
        else
          vim.notify("failed to delete folder", vim.log.levels.ERROR)
        end
      end,
    })
  end
end

function M.clone(repo)
  if not repo then
    local prompt = "repo: github.com/"
    vim.ui.input({ prompt = prompt }, M.tempclone)
  else
    M.tempclone(repo)
  end
end

function M.delete(repo)
  if not repo then
    local prompt = "repo: github.com/"
    vim.ui.input({ prompt = prompt }, M.tempdel)
  else
    M.tempdel(repo)
  end
end

return M
