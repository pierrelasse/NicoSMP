local Storage = require("@bukkit/Storage")


local storage = Storage.new("nicosmp", "fullbright")
storage:loadSave()

local potionEffectType = bukkit.potionEffectType("NIGHT_VISION")
local potionEffect = bukkit.potionEffect(potionEffectType, -1, 0, true, false, false)


every(20 * 10, function()
    for player in bukkit.playersLoop() do
        local playerId = bukkit.uuid(player)
        if storage:get("states."..playerId) == true then
            player.addPotionEffect(potionEffect)
        end
    end
end)

addCommand({ "fullbright", "nightvision", "nv" }, function(sender, args)
    local playerId = bukkit.uuid(sender)

    ---@type boolean
    local state = not storage:get("states."..playerId, false)

    if state then
        bukkit.send(sender, "§#3F27F7Fullbright aktiviert!")
        sender.addPotionEffect(potionEffect)
    else
        bukkit.send(sender, "§#716AA5Fullbright deaktiviert!")
        sender.removePotionEffect(potionEffectType)
    end

    storage:set("states."..playerId, state == true and true or nil)
end)
