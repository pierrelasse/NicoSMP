local PlayerDeathEvent = import("org.bukkit.event.entity.PlayerDeathEvent")

local staff = require("nicosmp/staff/index")


addEvent(PlayerDeathEvent, function(event)
    local player = event.getPlayer()
    local loc = player.getLocation()
    bukkit.printConsole(player.getName()..
        " died at "..loc.getWorld().getName().." "..loc.getX().." "..loc.getY().." "..loc.getZ())

    ---@type bukkit.components.HoverEvent
    local hoverEvent = {
        action = "show_text",
        value = { {
            text = "§7"..loc.getWorld().getName().." "..loc.getX().." "..loc.getY().." "..loc.getZ(),
        } }
    }
    staff.notify(
        nil,
        {
            text = player.getName(),
            color = staff.COLOR_TARGET,
            hoverEvent = hoverEvent
        },
        {
            text = " died",
            color = staff.COLOR_MSG_GENERIC,
            hoverEvent = hoverEvent
        }
    )
end)
    .priority("HIGH")
