local playerctl = {}

function playerctl.track(fn)
  local fmt = vim.json.encode({
    artist = "{{ artist }}",
    album = "{{ album }}",
    title = "{{ title }}",
    length = "{{ mpris:length }}",
    id = "{{ mpris:track }}",
  })
  vim.system(
    { "playerctl", "metadata", "--format", fmt },
    { text = true },
    vim.schedule_wrap(function(res)
      local code, out, err = res.code, res.stdout, res.stderr

      if code == 0 and out then
        local ok, decoded = pcall(vim.json.decode, out)
        decoded.length = tonumber(decoded.length)
        if ok then
          fn(decoded)
        end
      elseif code ~= 0 then
        vim.notify(err, "error")
      end
    end)
  )
end

function playerctl.status(fn)
  vim.system(
    { "playerctl", "status" },
    { text = true },
    vim.schedule_wrap(function(res)
      local code, out, err = res.code, res.stdout, res.stderr

      if code == 0 and out then
        fn(out)
      elseif code ~= 0 then
        vim.notify(err, "error")
      end
    end)
  )
end

function playerctl.position(fn)
  vim.system(
    { "playerctl", "position" },
    { text = true },
    vim.schedule_wrap(function(res)
      local code, out, err = res.code, res.stdout, res.stderr

      if code == 0 and out then
        out = out:gsub("%s+$", ""):gsub("%..*$", "")
        fn(tonumber(out))
      elseif code ~= 0 then
        vim.notify(err, "error")
      end
    end)
  )
end

function playerctl.play()
  vim.system({ "playerctl", "play" }, {})
end

function playerctl.pause()
  vim.system({ "playerctl", "pause" }, {})
end

function playerctl.stop()
  vim.system({ "playerctl", "stop" }, {})
end

function playerctl.play_pause()
  vim.system({ "playerctl", "play-pause" }, {})
end

function playerctl.next()
  vim.system({ "playerctl", "next" }, {})
end

function playerctl.previous()
  vim.system({ "playerctl", "previous" }, {})
end

return playerctl
