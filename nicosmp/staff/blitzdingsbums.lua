local Particle = import("org.bukkit.Particle")
local PlayerInteractEvent = import("org.bukkit.event.player.PlayerInteractEvent")

local function listener(event)
    local itemStack = event.getItem()
    if itemStack == nil then return end
    local itemMeta = itemStack.getItemMeta()
    if itemMeta == nil then return end
    if itemMeta.getDisplayName() ~= "Blitz dings bums" then return end

    local player = event.getPlayer()
    local loc = player.getLocation()
    local world = loc.getWorld()

    event.setCancelled(true)

    bukkit.send(player, "§eMemory deletion in progress...")

    for i = 1, 20 * 2 do
        wait(i, function()
            world.spawnParticle(Particle.FLASH, loc, 5)
            bukkit.playSound(loc, "block.lava.extinguish", math.random(), math.random())
        end)
    end
end


addEvent(PlayerInteractEvent, function(event)
    if not event.isCancelled() then return end
    listener(event)
end)
.priority(3)
.ignoreCancelled = true

addEvent(PlayerInteractEvent, listener)
