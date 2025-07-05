local ScriptStoppingEvent = import("net.bluept.scripting.ScriptStoppingEvent")
local PlayerQuitEvent = import("org.bukkit.event.player.PlayerQuitEvent")
local BlockPlaceEvent = import("org.bukkit.event.block.BlockPlaceEvent")
local BlockBreakEvent = import("org.bukkit.event.block.BlockBreakEvent")

local worldmanager = require("@bukkit/worldmanager/worldmanager")
local spawn = require("nicosmp/features/spawn")


local this = {}

this.world = bukkit.world("void")
---uuid -> location
this.locations = makeMap()

local function ensureWorld()
    local creator = worldmanager.create("void")
    creator:setupVoid()
    this.world = creator:create()
end

addCommand("void", function(sender, args)
    local function send(message)
        bukkit.send(sender, "§8[§6Void§8] §7"..message)
    end

    if this.world == nil then
        send("Welt wird geladen...")
        ensureWorld()
        if this.world == nil then
            send("§cFehler beim laden der Welt!")
            return
        end
    end

    if args[1] == nil then
        send("Teleportiere...")
        sender.teleport(this.world.getSpawnLocation())
    else
        local target = bukkit.getPlayer(args[1])
        if target == nil then
            send("§cSpieler nicht gefunden!")
            return
        end
        local targetId = bukkit.uuid(target)

        local isTargetInWorld = target.getWorld() == this.world
        if isTargetInWorld then
            send("§aTeleportiere §2"..target.getName().."§a zurück")
            target.teleport(this.locations.get(targetId) or spawn)
            this.locations.remove(targetId)
        else
            if sender.getWorld() ~= this.world then
                send("§cDu must in der Void World sein!")
                return
            end

            local prevLoc = target.getLocation()
            this.locations.put(targetId, prevLoc)
            target.teleport(sender.getLocation())
            send("§2"..
                target.getName()..
                "§a wurde teleportiert §7(von "..
                prevLoc.getWorld().getName()..","..prevLoc.getX()..","..prevLoc.getY()..","..prevLoc.getZ()..")")
        end
    end
end)
    .complete(function(completions, sender, args)
        if #args == 1 then
            ---@type string?
            local input
            if args[1] ~= nil then input = string.lower(args[1]) end
            for player in bukkit.playersLoop() do
                ---@type string
                local name = player.getName()
                if input == nil or name:lower():startsWith(input) and sender.canSee(player) then
                    completions.add(name)
                end
            end
        elseif #args == 2 then
            completions.add("back")
        end
    end)
    .permission("!.staff.void")

addEvent(ScriptStoppingEvent, function()
    for playerId in forEach(this.locations.keySet()) do
        local player = bukkit.playerByUUID(playerId)
        if player ~= nil then
            local loc = this.locations.get(playerId)
            player.teleport(loc)
        end
    end
end)

addEvent(PlayerQuitEvent, function(event)
    local player = event.getPlayer()
    local playerId = bukkit.uuid(player)
    if this.locations.containsKey(playerId) then
        player.teleport(this.locations.get(playerId))
        this.locations.remove(playerId)
        for p in bukkit.playersLoop() do
            if p.hasPermission("!.staff.void") then
                bukkit.send(p, "§8[§6Void§8] §4"..player.getName().."§c hat den Server verlassen")
            end
        end
    end
end)

addEvent(BlockPlaceEvent, function(event)
    local block = event.getBlock()
    if block.getWorld() ~= this.world then return end
    if NicoSMP.isCreativeOrSpec(event.getPlayer()) then return end
    event.setCancelled(true)
end)

addEvent(BlockBreakEvent, function(event)
    local block = event.getBlock()
    if block.getWorld() ~= this.world then return end
    if NicoSMP.isCreativeOrSpec(event.getPlayer()) then return end
    event.setCancelled(true)
end)

return this
