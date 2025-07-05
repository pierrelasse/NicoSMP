local ScriptStoppingEvent = import("net.bluept.scripting.ScriptStoppingEvent")

local combat = require("nicosmp/combat/index")
local movecb = require("nicosmp/utils/movecb")

--- senderId -> targetId
local requests = makeMap()


addCommand("tpa", function(sender, args)
    if args[1] == nil then
        bukkit.send(sender, "§cUsage: /tpa <spieler>")
        return
    end

    local target = bukkit.getPlayer(args[1])
    if target == nil or not sender.canSee(target) or sender == target then
        bukkit.send(sender, "§cSpieler nicht gefunden")
        return
    end

    local playerId = bukkit.uuid(sender)
    local targetId = bukkit.uuid(target)

    if requests.get(playerId) == targetId then
        bukkit.send(sender, "§cDu hast bereits diesem Spieler eine Anfrage gesendet!")
        return
    end
    requests.put(playerId, targetId)

    bukkit.send(target, "§e"..
        sender.getName().."§7 möchte sich zu dir telportieren!\n§7Nutze §6/tpaccept§7 um die Anfrage anzunehmen")
    bukkit.send(sender, "§aTP-Anfrage an §2"..target.getName().."§a gesendet!")
end)
    .complete(function(completions, sender, args)
        if #args == 1 then
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
        end
    end)

addCommand("tpaccept", function(sender, args)
    local playerId = bukkit.uuid(sender)

    local fromId
    for loopFromId in forEach(requests.keySet()) do
        if requests.get(loopFromId) == playerId then
            fromId = loopFromId
            break
        end
    end
    if fromId == nil then
        bukkit.send(sender, "§cDu hast keine Anfragen!")
        return
    end

    local from = bukkit.playerByUUID(fromId)
    if from == nil then
        bukkit.send(sender, "§cSpieler nicht gefunden!")
        return
    end

    if combat.checkCombat(from) then return end

    requests.remove(fromId)

    wait(20 * 2, function()
        movecb.reg(
            from, 20 * 3,
            function()
                bukkit.send(from, "§#EE2550Teleportation abgebrochen")
            end,
            function()
                from.sendMessage("§7Teleportiere zu §f"..sender.getName().."§7...")

                from.teleport(sender.getLocation())
            end
        )
    end)

    bukkit.send(from, "§#EFA341Bitte stehe §#F3951B5 Sekunden§#EFA341 still!")
    bukkit.send(sender, "§aTP-Anfrage von §2"..from.getName().."§a angenommen!")
end)
    .complete(function(completions, sender, args)
        if #args == 1 then
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
        end
    end)

addEvent(ScriptStoppingEvent, function()
    for senderId in forEach(requests.keySet()) do
        local sender = bukkit.playerByUUID(senderId)
        if sender ~= nil then
            bukkit.send(sender, "§cDeine TPA wurde durch einen reload abgebrochen")
        end
    end
end)
