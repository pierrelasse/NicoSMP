local ScriptStoppingEvent = import("net.bluept.scripting.ScriptStoppingEvent")
local PlayerQuitEvent = import("org.bukkit.event.player.PlayerQuitEvent")


-- uuid -> location
local locations = makeMap()


addCommand("spec", function(sender, args)
    local playerId = bukkit.uuid(sender)

    local function turnOn(target)
        bukkit.setGameMode(sender, "SPECTATOR")

        if not locations.containsKey(playerId) then
            locations.put(playerId, sender.getLocation())

            bukkit.sendComponent(sender, bukkit.components.deserialize({
                {
                    text = "§aSpectator aktiviert!",
                    clickEvent = { action = "run_command", value = "/spec *off" },
                    hoverEvent = { action = "show_text", value = { { text = "§eKlicke um den Spectator Modus zu deaktivieren!" } } }
                }
            }))
        end

        if target ~= nil then
            sender.teleport(target.getLocation())
        end
    end

    local function turnOff()
        local loc = locations.get(playerId)
        if loc == nil then return end
        sender.teleport(loc)
        locations.remove(playerId)
        bukkit.setGameMode(sender, "SURVIVAL")
        bukkit.send(sender, "§aSpectator deaktiviert!")
    end

    local function toggle()
        if locations.containsKey(playerId) then
            turnOff()
        else
            turnOn(nil)
        end
    end

    if args[1] == nil then
        toggle()
        return
    end

    if args[1] == "*off" then
        turnOff()
        return
    end

    local target = bukkit.getPlayer(args[1])
    if target == nil or not sender.canSee(target) then
        bukkit.send(sender, "§cSpieler nicht gefunden!")
        return
    end

    turnOn(target)
end)
    .permission("!.staff.spec")
    .complete(function(completions, sender, args)
        ---@type string?
        local input
        if args[1] ~= nil then input = string.lower(args[1]) end
        for p in bukkit.playersLoop() do
            ---@type string
            local name = p.getName()
            if input == nil or name:lower():startsWith(input) and sender.canSee(p) then
                completions.add(name)
            end
        end
    end)

addEvent(PlayerQuitEvent, function(event)
    local player = event.getPlayer()
    local playerId = bukkit.uuid(player)

    local loc = locations.get(playerId)
    if loc == nil then return end

    player.teleport(loc)
    bukkit.setGameMode(player, "SURVIVAL")
    locations.remove(playerId)
end)
    .priority("LOW")

addEvent(ScriptStoppingEvent, function()
    for playerId in forEach(locations.keySet()) do
        local player = bukkit.playerByUUID(playerId)
        if player ~= nil then
            local loc = locations.get(playerId)
            player.teleport(loc)
            bukkit.setGameMode(player, "SURVIVAL")
        end
    end
end)
