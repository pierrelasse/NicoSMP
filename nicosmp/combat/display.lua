local ScriptStoppingEvent = import("net.bluept.scripting.ScriptStoppingEvent")
local BarColor = import("org.bukkit.boss.BarColor")
local BarStyle = import("org.bukkit.boss.BarStyle")
local BarFlag = import("org.bukkit.boss.BarFlag")

local combat = require("nicosmp/combat/index")

---playerId -> BossBar
local bars = makeMap()

---@param player JavaObject
local function update(player)
    local playerId = bukkit.uuid(player)

    local bar = bars.get(playerId)
    local time = combat.getCombatTime(player)

    if time == 0 then
        if bar == nil then return end
        bar.removeAll()
        bars.remove(playerId)
        return
    end

    if bar == nil then
        bar = bukkit.Bukkit.createBossBar(
            nil,
            BarColor.RED,
            BarStyle.SOLID,
            makeArray(BarFlag, 0)
        )
        bars.put(playerId, bar)
        bar.addPlayer(player)
    end

    bar.setTitle(bukkit.hex("§#FF0054§lDu bist im Kampf. Logge dich nicht aus!"))
    local success, result = pcall(function()
        local progress = time / 200
        if progress > 0 then
            bar.setProgress(progress)
        else
            bar.removeAll()
            bars.remove(playerId)
        end
    end)
    if not success then
        print(result)
    end
end
combat.displayUpdateCb = update

every(20 * 4, function()
    for player in bukkit.playersLoop() do
        update(player)
    end
end)

addEvent(ScriptStoppingEvent, function()
    for bar in forEach(bars.values()) do
        bar.removeAll()
    end
end)
