-- {"order":1,"arguments":[]}
mympd.init()

local lastfm_lib = require "scripts/lastfm_lib"

-- main
local play_state = mympd_state.play_state
local elapsed_time = mympd_state.elapsed_time

if play_state ~= 2 or elapsed_time > 5 then
  return "not now playing"
end

local rc, result = mympd.api("MYMPD_API_PLAYER_CURRENT_SONG")
if rc ~= 0 then
  return "Now Playing: Not Playing"
end

if result.webradio then
  return "web radio"
end

if string.sub(result.uri, 1, 8) == "https://" or
   string.sub(result.uri, 1, 7) == "http://" then
  return "web radio"
end

local artist = result.Artist[1]
local title = result.Title
local album = result.Album
local albumArtist = result.AlbumArtist[1]

local data = {
  method      = "track.updateNowPlaying",
  api_key     = mympd_env.var_lastfm_api_key,
  track       = title,
  artist      = artist,
  album       = album,
  albumArtist = albumArtist,
  sk          = mympd_env.var_lastfm_session_key,
}

local body
rc, body = lastfm_lib.sendData(data)
if rc ~= 0 then
  return "Now Playing: Error"
end

local ret = json.decode(body)
local code = ret.nowplaying.ignoredMessage.code
if code ~= "0" then
  return "Now Playing: " .. artist .. " - " .. title .. " - ignored code " .. code
end

return "Now Playing: " .. artist .. " - " .. title .. " - OK"
