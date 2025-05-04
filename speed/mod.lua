--[[
"speed" mod
by Jeremy W. Sherman
2025-05-04

Loosely based off of DinoMC's "Run Faster Mod" for Mudborne.

* Move twice as fast.
* Press Shift while walking to toggle extra-fast move on and off.
* Wading is slower than walking, except when in extra-fast mode.
--]]
--[[
References:

* Modding Guide: https://wiki.apico.buzz/wiki/Modding_Guide
  * Ctrl-Shift-r to reload while playing
  * Ctrl-. to show logs
  * / to begin entering dev mode command.
* Modding API: https://wiki.apico.buzz/wiki/Modding_API
* Player properties: https://wiki.apico.buzz/wiki/Instance_Properties#Player_(ob_player)
* OID Reference: https://wiki.apico.buzz/wiki/OID_Reference
]]

MOD_NAME = "speed"
FAST_MODE = 0

function register()
  return {
    name = "speed",
    hooks = {
      "key",
      "step",
      "save"
    }
  }
end

function init()
  --api_set_devmode(true)
  api_create_log("init", "You are off to the races!")
  api_get_data()
  return "Success"
end

function data(ev, data)
  if ev == "LOAD" then
    if data == nil then
      FAST_MODE = 0
    else
      FAST_MODE = data.fast_mode
    end
    api_create_log("loaded fast_mode", FAST_MODE)
  end
end

function ready()
  -- total_health vs current_health
  --player.props.speed = 120
end

function move(pos, speed)
  local dir = { x = 0, y = 0 }
  if api_get_key_down("W") == 1 then
    dir.y = dir.y - 1
  elseif api_get_key_down("A") == 1 then
    dir.x = dir.x - 1
  elseif api_get_key_down("S") == 1 then
    dir.y = dir.y + 1
  elseif api_get_key_down("D") == 1 then
    dir.x = dir.x + 1
  end
  local delta = { x = speed * dir.x, y = speed * dir.y }
  local new_pos = { x = pos.x + delta.x, y = pos.y + delta.y }
  return new_pos
end

function fastwalk()
  local player = api_get_player_instance()
  local is_walking = api_get_property(player, "walking")
  local is_wading = api_get_property(player, "wading")

  local speed = 2
  local should_go_faster = FAST_MODE == 1
  if is_wading and not should_go_faster then
    speed = 1
  end
  if should_go_faster then
    speed = 2 * speed
  end

  local pos = api_get_player_position()
  local new_pos = move(pos, speed)
  if new_pos.x ~= pos.x or new_pos.y ~= pos.y then
    api_set_player_position(new_pos.x, new_pos.y)
  end
end

function key(key_code)
  if api_get_key_down("SHFT") == 1 then
    local player = api_get_player_instance()
    local is_walking = api_get_property(player, "walking")
    local is_wading = api_get_property(player, "wading")
    if is_walking or is_wading then
      FAST_MODE = 1 - FAST_MODE
      api_create_log("key", "fast mode toggled")
      api_create_log("fast_mode", FAST_MODE)
    end
  end
  fastwalk()
end

function step()
  local player = api_get_player_instance()
  local is_walking = api_get_property(player, "walking")
  local is_wading = api_get_property(player, "wading")
  if is_walking or is_wading then
    fastwalk(is_wading)
  end
end

function save()
  api_set_data({ fast_mode = FAST_MODE })
  api_create_log("saving fast_mode", FAST_MODE)
end
