--[[
"Healing Touch" Apico mod
by Jeremy W. Sherman
2025-05-04

Loosely based off of fitzpleasure's "Unbreakable Tools" mod for Mudborne.

Resets the health of all items on the player to full each time you click.
Effectively makes it so axes and such never break.
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

MOD_NAME = "healing_touch"

function register()
  return {
    name = MOD_NAME,
    hooks = {
      "click"
    }
  }
end

function init()
  -- api_set_devmode(true)
  api_create_log("init", "May your axe never fail!")
  return "Success"
end

function click()
  -- Can't work out how to go from OID returned by api_get_equipped() to the instance actually wielded.
  -- So let's just restore all the things the player has on them that are damaged.

  -- Get all the player's items that can break.
  local player = api_get_player_instance()
  local slots = api_get_slots(player)
  local can_break = {}
  for _, slot in ipairs(slots) do
    if slot.total_health ~= 0 then
      table.insert(can_break, slot)
    end
  end

  for _, tool in ipairs(can_break) do
    if tool.current_health < tool.total_health then
      --tool.current_health = tool.total_health -- <--this doesn't persist!
      api_sp(tool.id, "current_health", tool.total_health)
      api_create_log("healed item", tool)
    end
  end
end
