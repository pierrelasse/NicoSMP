local PlayerJoinEvent = classFor("org.bukkit.event.player.PlayerJoinEvent")

local staff = require("nicosmp/staff/index")
local punishments = require("nicosmp/staff/punishments/index")


addEvent(PlayerJoinEvent, function(event)
    local player = event.getPlayer()
    local playerId = bukkit.uuid(player)
    local name = player.getName()

    local path = "ent."..playerId..".ln"

    if punishments.storage:get(path, name) ~= name then
        staff.notify(
            nil,
            {
                text = punishments.storage:get(path),
                color = staff.COLOR_MSG_RED,
                bold = true
            },
            {
                text = " changed their name to ",
                color = staff.COLOR_MSG_RED,
            },
            {
                text = name,
                color = staff.COLOR_MSG_RED,
                bold = true
            }
        )
    end

    punishments.storage:set(path, name)
end)
