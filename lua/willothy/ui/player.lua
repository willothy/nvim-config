local NuiLine = require("nui.line")
local NuiText = require("nui.text")
local Popup = require("nui.popup")
local Layout = require("nui.layout")

local popup_cfg = {
  border = "single",
  focusable = false,
}

local empty_cfg = {
  focusable = false,
  border = "none",
}

local prev_btn = Popup(popup_cfg)
local next_btn = Popup(popup_cfg)

local play_btn = Popup(popup_cfg)

local view = Popup(popup_cfg)

local empty = Popup(empty_cfg)

local layout = Layout(
  {
    relative = "editor",
    position = {
      row = 1,
      col = vim.o.columns - 40,
    },
    size = {
      width = 40,
      height = 10,
    },
  },
  Layout.Box({
    Layout.Box(view, { size = { width = "100%", height = 7 } }),
    Layout.Box({
      Layout.Box(prev_btn, { size = "14%" }),
      Layout.Box(play_btn, { size = "14%" }),
      Layout.Box(next_btn, { size = "14%" }),
      Layout.Box(empty, { grow = 1 }),
    }, { dir = "row", size = { height = 3 } }),
  }, { dir = "col" })
)

local Player = {}

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
        fn(vim.json.decode(out))
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
  if Player.win then
    if vim.api.nvim_win_is_valid(Player.win) then
      vim.api.nvim_win_close(Player.win, true)
    end
    Player.win = nil
  end
  if Player.buf then
    if vim.api.nvim_buf_is_valid(Player.buf) then
      vim.api.nvim_buf_delete(Player.buf, { force = true })
    end
    Player.buf = nil
  end
  Player.position = 0
  Player.playing = false
end

function Player.update()
  local n_done = 0
  local ns = vim.api.nvim_create_namespace("nvim_media_ctrl")
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

      local progress_bar_txt = ""

      local progress_pct = Player.position / (Player.track.length / 1000000)
      local progress_len = math.floor(40 * progress_pct)

      progress_bar_txt = string.rep("=", progress_len - 1) .. ">"

      local progress_bar = NuiLine({
        NuiText("[", "Keyword"),
        NuiText(progress_bar_txt, "Comment"),
        NuiText(string.rep(" ", 40 - progress_len - 4)),
        NuiText("]", "Keyword"),
      })

      local blank = NuiLine({ NuiText("") })

      if Player.buf and vim.api.nvim_buf_is_valid(Player.buf) then
        title:render(Player.buf, ns, 1)
        info:render(Player.buf, ns, 2)

        blank:render(Player.buf, ns, 3)

        progress:render(Player.buf, ns, 4)
        progress_bar:render(Player.buf, ns, 5)
      end
    end
  end

  playerctl.status(function(status)
    Player.playing = status == "Playing"
    n_done = n_done + 1
    done()
  end)
  playerctl.track(function(track)
    track.length = tonumber(track.length)
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
  if Player.buf == nil or not vim.api.nvim_buf_is_valid(Player.buf) then
    -- Player.buf = vim.api.nvim_create_buf(false, true)
    Player.buf = view.bufnr
  end
  Player.update()

  -- local width = 40
  -- local height = 5

  -- local config = {
  --   relative = "editor",
  --   row = 1,
  --   col = vim.o.columns - width,
  --   width = width,
  --   height = height,
  --   style = "minimal",
  --   border = "single",
  -- }
  -- Player.win = layout.winid -- vim.api.nvim_open_win(Player.buf, false, config)
  Player.start_timer()
end

function Player.hide()
  if Player.win and vim.api.nvim_win_is_valid(Player.win) then
    vim.api.nvim_win_close(Player.win, true)
    Player.win = nil
  end
end

return Player
