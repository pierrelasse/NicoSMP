local ArrayList = import("java.util.ArrayList")
local HashSet = import("java.util.HashSet")
local Projectile = import("org.bukkit.entity.Projectile")
local EntityDamageByEntityEvent = import("org.bukkit.event.entity.EntityDamageByEntityEvent")

local combat = require("nicosmp/combat/index")

---@type java.Set
local states

local storage = require("@bukkit/Storage").new("nicosmp", "pvp")
storage:loadSave(function()
    local statesList = ArrayList(states)
    storage:set("states", statesList)
end)
do
    local set = HashSet(storage.config.getStringList("states"))
    ---@cast set java.Set
    states = set
end


addCommand("pvp", function(sender, args)
    if combat.checkCombat(sender) then return end

    local id = bukkit.uuid(sender)
    if states.contains(id) then
        states.remove(id)
        bukkit.send(sender, "§cPVP deaktiviert!")
    else
        states.add(id)
        bukkit.send(sender, "§aPVP aktiviert!")
    end
end)
    .complete(function(completions, sender, args)
        completions.add("man toggelt pvp mit /pvp. es gibt kein on/off :)")
    end)

addEvent(EntityDamageByEntityEvent, function(event)
    local victim = event.getEntity()
    if not bukkit.isPlayer(victim) then return end
    local victimId = bukkit.uuid(victim)

    local attacker = event.getDamager()
    if victim == attacker then return end
    if instanceof(attacker, Projectile) then attacker = attacker.getShooter() end
    if not bukkit.isPlayer(attacker) then return end
    local attackerId = bukkit.uuid(attacker)

    if states.contains(victimId) and states.contains(attackerId) then return end

    event.setCancelled(true)
    bukkit.sendActionBar(attacker, "§#B7768ADieser Spieler hat /pvp deaktiviert!")
end)
    .priority("LOW")
