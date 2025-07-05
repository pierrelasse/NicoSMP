local ScriptStoppingEvent = import("net.bluept.scripting.ScriptStoppingEvent")
local PlayerCommandPreprocessEvent = import("org.bukkit.event.player.PlayerCommandPreprocessEvent")


local statesCommand = makeSet()
statesCommand.add("d1afbcf2-15df-43ec-90cb-2fa94924ddd9")

addCommand("spycommand", function(sender, args)
    local playerId = bukkit.uuid(sender)

    if statesCommand.contains(playerId) then
        statesCommand.remove(playerId)
        bukkit.send(sender, "§7Command spy: §cdeaktiviert")
    else
        statesCommand.add(playerId)
        bukkit.send(sender, "§7Command spy: §aaktiviert")
    end
end)
    .permission("!.staff.spycommand")

addEvent(ScriptStoppingEvent, function()
    for player in bukkit.playersLoop() do
        local playerId = bukkit.uuid(player)
        if statesCommand.contains(playerId) then
            bukkit.send(player, "§7Command spy: §#7F4F60deaktiviert")
        end
    end
end)

addEvent(PlayerCommandPreprocessEvent, function(event)
    local player = event.getPlayer()
    local message = event.getMessage()

    local comp = bukkit.components.parse("§#626C6B§l[CMD] §#6D7A79"..player.getName()..": §#888F8F"..message)
    for p in bukkit.playersLoop() do
        local playerId = bukkit.uuid(p)
        if statesCommand.contains(playerId) then
            bukkit.sendComponent(p, comp)
        end
    end
end)
