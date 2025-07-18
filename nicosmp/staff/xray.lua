local ArrayDeque = import("java.util.ArrayDeque")
local BlockBreakEvent = import("org.bukkit.event.block.BlockBreakEvent")

local staff = require("nicosmp/staff/index")

local MONITORED_BLOCKS = {
    "DIAMOND_ORE",
    "DEEPSLATE_DIAMOND_ORE",

    "ANCIENT_DEBRIS",

    "EMERALD_ORE",
    "DEEPSLATE_EMERALD_ORE",

    "GOLD_ORE",
    "DEEPSLATE_GOLD_ORE"
}

local processedBlocks = makeMap()

every(20 * 60, function()
    processedBlocks.clear()
end)

local function getAdjacentBlocks(block)
    local adjacent = makeSet()
    adjacent.add(block.getRelative(1, 0, 0))
    adjacent.add(block.getRelative(-1, 0, 0))
    adjacent.add(block.getRelative(0, 1, 0))
    adjacent.add(block.getRelative(0, -1, 0))
    adjacent.add(block.getRelative(0, 0, 1))
    adjacent.add(block.getRelative(0, 0, -1))
    return adjacent
end

---@param startBlock JavaObject
---@param material JavaObject
---@return java.Set
local function findVein(startBlock, material)
    local vein = makeSet()

    local toCheck = ArrayDeque(7)
    toCheck.add(startBlock)
    while not toCheck.isEmpty() do
        local block = toCheck.poll()
        toCheck.remove(block)

        if block.getType() == material and vein.add(block) then
            for relative in forEach(getAdjacentBlocks(block)) do
                if not vein.contains(relative) and not processedBlocks.containsKey(relative) then
                    toCheck.add(relative)
                end
            end
        end
    end

    return vein
end

addEvent(BlockBreakEvent, function(event)
    local block = event.getBlock()
    local blockMaterial = block.getType()
    if table.key(MONITORED_BLOCKS, blockMaterial.name()) == nil then return end

    local player = event.getPlayer()
    if NicoSMP.isCreativeOrSpec(player) then return end

    if processedBlocks.containsKey(block) then return end

    local vein = findVein(block, blockMaterial)
    local count = vein.size()

    local now = time.unixMs()
    for b in forEach(vein) do
        processedBlocks.put(b, now)
    end

    local clickEvent = { action = "run_command", value = "/spec "..player.getName() }
    staff.notify(
        "!.staff.xray",
        {
            color = staff.COLOR_TARGET,
            text = player.getName(),
            clickEvent = clickEvent,
            hoverEvent = { action = "show_text", value = { "§eKlicke um diesen Spieler zu beobachten!" } }
        },
        {
            color = staff.COLOR_MSG_YELLOW,
            text = " found x"..count.." "..blockMaterial.name():lower(),
            clickEvent = clickEvent,
            hoverEvent = { action = "show_text", value = { "§7"..block.getWorld().getName()..", "..block.getX()..","..block.getY()..","..block.getZ().."\n\n§eKlicke um diesen Spieler zu beobachten!" } }
        }
    )
end)
