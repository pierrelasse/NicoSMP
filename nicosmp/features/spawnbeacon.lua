local BlockBreakEvent = import("org.bukkit.event.block.BlockBreakEvent")
local BlockPlaceEvent = import("org.bukkit.event.block.BlockPlaceEvent")


local function listener(event)
    local block = event.getBlock()
    if block.getWorld() ~= bukkit.defaultWorld() then return end
    if block.getY() ~= 191 then return end
    if not numbers.between(block.getX(), -3, -2) then return end
    if block.getZ() ~= -206 then return end
    if event.getPlayer().getGameMode().name() == "CREATIVE" then return end
    event.setCancelled(true)
end

addEvent(BlockBreakEvent, listener)
addEvent(BlockPlaceEvent, listener)
