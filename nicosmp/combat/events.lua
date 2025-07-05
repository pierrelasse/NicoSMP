local Player = classFor("org.bukkit.entity.Player")
local EntityDamageEvent = classFor("org.bukkit.event.entity.EntityDamageEvent")
local EntityDamageByEntityEvent = classFor("org.bukkit.event.entity.EntityDamageByEntityEvent")
local PlayerQuitEvent = classFor("org.bukkit.event.player.PlayerQuitEvent")

local combat = require("nicosmp/combat/index")


local function tickPlayer(player)
    local playerId = player.getUniqueId().toString()

    local time = combat.times[playerId]
    if time == nil then return end
    if time <= 0 then
        combat.exitCombat(player)
        return
    end
    combat.times[playerId] = time - 1
    combat.displayUpdateCb(player)
end

every(1, function()
    async(function()
        for player in bukkit.playersLoop() do
            tickPlayer(player)
        end
    end)
end)

addEvent(EntityDamageEvent, function(event)
    local player = event.getEntity()
    if not instanceof(player, Player) then return end

    if instanceof(event, EntityDamageByEntityEvent) then
        local attacker = event.getDamager()
        if not instanceof(attacker, Player) then return end

        combat.enterCombat(player)
        if attacker.getGameMode().name() == "SURVIVAL" then
            combat.enterCombat(attacker)
        end
    end

    local finalDamage = event.getFinalDamage()
    if player.getHealth() - finalDamage > 0 then return end
    combat.exitCombat(player)
end).priority("HIGH")

addEvent(PlayerQuitEvent, function(event)
    local player = event.getPlayer()

    local time = combat.getCombatTime(player)
    combat.clearCombat(player)
    if time == nil or time <= 0 then return end

    player.setHealth(0)
end)
