local Layout = require("nui.layout")
local NuiLine = require("nui.line")
local NuiText = require("nui.text")
local Popup = require("nui.popup")

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

local ns = vim.api.nvim_create_namespace("nvim_media_ctrl")

local popup_cfg = {
  border = "single",
  focusable = false,
}

local view = Popup(popup_cfg)

local layout = Layout({
  relative = "editor",
  position = {
    row = 2,
    col = vim.o.columns - 40 - 2,
  },
  size = {
    width = 40,
    height = 10,
  },
  zindex = 100,
}, { Layout.Box(view, { size = { width = "100%", height = 7 } }) })

local Player = {}

Player.playerctl = playerctl

function Player.setup()
  if Player.ready then
    Player.cleanup()
  end

  Player.track = {
    title = "",
    artist = "",
    album = "",
    length = 0,
    id = "",
  }
  Player.position = 0
  Player.playing = false

  local commands = {
    PlayerToggle = {
      function()
        if layout._.mounted then
          Player.hide()
        else
          Player.show()
        end
      end,
      { nargs = 0 },
    },
    PlayerPlayPause = {
      playerctl.play_pause,
      { nargs = 0 },
    },
    PlayerPlay = {
      playerctl.play,
      { nargs = 0 },
    },
    PlayerPause = {
      playerctl.pause,
      { nargs = 0 },
    },
    PlayerNext = {
      playerctl.next,
      { nargs = 0 },
    },
    PlayerPrevious = {
      playerctl.previous,
      { nargs = 0 },
    },
  }

  -- stylua: ignore start
  vim.iter(commands)
    :map(function(name, cmd)
      return name, unpack(cmd)
    end)
    :each(vim.api.nvim_create_user_command)
  -- stylua: ignore end
end

function Player.start_timer()
  if not Player.timer then
    Player.timer = vim.loop.new_timer()
  end
  Player.timer:start(0, 1000, vim.schedule_wrap(Player.update))
end

function Player.stop_timer()
  if Player.timer and Player.timer:is_active() then
    Player.timer:stop()
  end
end

function Player.cleanup()
  if Player.timer then
    if not Player.timer:is_closing() then
      Player.timer:stop()
      Player.timer:close()
    end
    Player.timer = nil
  end
end

function Player.update()
  local n_done = 0
  local function done()
    if n_done == 3 then
      local title = NuiLine({ NuiText(Player.track.title or "", "Special") })

      local info = NuiLine({
        NuiText(Player.track.artist, "Comment"),
        Player.track.album ~= "" and NuiText(" - ") or nil,
        Player.track.album ~= "" and NuiText(Player.track.album, "Comment")
          or nil,
      })

      local len_text = ""
      local pos_text = ""
      if Player.track.length > 0 and Player.position then
        local dt = Player.position
        local seconds = dt % 60
        local minutes = (dt / 60) % 60
        local hours = ((dt / 60) / 60) % 60

        if hours and hours > 0 then
          pos_text = pos_text .. string.format("%02d:", hours)
        end
        if minutes then
          pos_text = pos_text .. string.format("%02d:", minutes)
        end
        if seconds then
          pos_text = pos_text .. string.format("%02d", seconds)
        end

        dt = Player.track.length / 1000000
        seconds = dt % 60
        minutes = (dt / 60) % 60
        hours = ((dt / 60) / 60) % 60

        if hours and hours > 0 then
          len_text = len_text .. string.format("%02d:", hours)
        end
        if minutes then
          len_text = len_text .. string.format("%02d:", minutes)
        end
        if seconds then
          len_text = len_text .. string.format("%02d", seconds)
        end
      end

      local progress = NuiLine({
        NuiText(pos_text, "Comment"),
        NuiText(" / ", "Keyword"),
        NuiText(len_text, "Comment"),
      })

      local PROGRESS_MAX = 40 - 3

      local progress_bar_txt = ""

      local progress_pct = Player.position / (Player.track.length / 1000000)
      local progress_len = math.floor(PROGRESS_MAX * progress_pct)

      if progress_len + 1 >= PROGRESS_MAX then
        progress_bar_txt = string.rep("=", progress_len - 1) .. "|"
      else
        progress_bar_txt = string.rep("=", progress_len - 1) .. ">"
      end

      local progress_bar = NuiLine({
        Player.playing and NuiText("", "Keyword")
          or NuiText("", "Keyword"),
        NuiText(" "),
        NuiText(progress_bar_txt, "Comment"),
        NuiText(string.rep(" ", math.max(0, PROGRESS_MAX - progress_len))),
        NuiText(" "),
      })

      local blank = NuiLine({ NuiText("") })

      title:render(view.bufnr, ns, 1)
      info:render(view.bufnr, ns, 2)

      blank:render(view.bufnr, ns, 3)

      progress:render(view.bufnr, ns, 4)
      progress_bar:render(view.bufnr, ns, 5)
    end
  end

  playerctl.status(function(status)
    status = status:gsub("%s+$", ""):gsub("^%s+", "")
    Player.playing = status == "Playing"
    n_done = n_done + 1
    done()
  end)
  playerctl.track(function(track)
    Player.track = track
    n_done = n_done + 1
    done()
  end)
  playerctl.position(function(position)
    Player.position = position
    n_done = n_done + 1
    done()
  end)
end

function Player.show()
  if Player.win and vim.api.nvim_win_is_valid(Player.win) then
    return
  end
  layout:mount()
  Player.update()
  Player.start_timer()
end

function Player.hide()
  layout:unmount()
  Player.cleanup()
end

return Player
