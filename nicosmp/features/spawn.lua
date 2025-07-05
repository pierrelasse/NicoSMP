local PlayerJoinEvent = import("org.bukkit.event.player.PlayerJoinEvent")

local movecb = require("nicosmp/utils/movecb")


local LOCATION = bukkit.location6(
    bukkit.defaultWorld(),
    -2.5, 197, -205.5,
    0, 0
)


addCommand("spawn", function(sender, args)
    local target = sender

    if target.getWorld().getName() == "void" and not NicoSMP.isCreativeOrSpec(target) then
        return
    end

    local targetId = bukkit.uuid(target)

    local function doTP()
        bukkit.send(target, "§#72B574Teleportiere zum Spawn...")
        target.teleport(LOCATION)
    end

    if NicoSMP.isCreativeOrSpec(target) then
        doTP()
        return
    end

    local tpTask = wait(20 * 3, function()
        movecb.delete(targetId)
        doTP()
    end)

    movecb.register(targetId, function()
        tpTask.cancel()
        bukkit.send(target, "§#EE2550Teleportation abgebrochen")
    end)

    bukkit.send(target, "§#EFA341Bitte stehe für §#F3951B3 Sekunden §#EFA341still!")
end)

addEvent(PlayerJoinEvent, function(event)
    local player = event.getPlayer()
    if not player.hasPlayedBefore() then
        player.teleport(LOCATION)
    end
end)

return LOCATION
