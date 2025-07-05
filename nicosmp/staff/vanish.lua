local PlayerJoinEvent = classFor("org.bukkit.event.player.PlayerJoinEvent")

local Storage = require("@bukkit/Storage")


local this = {}
this.HIGHEST_LEVEL = 9

---@type table<string, number>
this.states = {}

this.storage = Storage.new("nicosmp", "vanish")
this.storage:loadSave(function()
    this.storage:set("states", nil)
    for playerId, level in pairs(this.states) do
        this.storage:set("states."..playerId, level)
    end
end)
do
    local keys = this.storage:getKeys("states")
    if keys ~= nil then
        for playerId in forEach(keys) do
            this.states[playerId] = tonumber(this.storage:get("states."..playerId))
        end
    end
end


---@param player JavaObject
---@param highestLevel integer
---@param level? number
---@return boolean
function this.canSee(player, highestLevel, level)
    return level == nil or highestLevel >= level
end

---@param player JavaObject
---@param playerId string
function this.getLVL(player, playerId)
    ---@type integer?
    local level = this.states[playerId]
    if level ~= nil then
        local maxLevel = this.getHighestLVL(player)
        if level > maxLevel then
            if maxLevel == 0 then
                level = nil
            else
                level = maxLevel
            end
            this.states[playerId] = level
        end
    end
    return level
end

---@param otherPlayer JavaObject
---@param highestLevel integer
---@param player JavaObject
---@param level? integer
function this.updateSee(otherPlayer, highestLevel, player, level)
    if this.canSee(otherPlayer, highestLevel, level) then
        otherPlayer.showPlayer(bukkit.platform, player)
    else
        otherPlayer.hidePlayer(bukkit.platform, player)
    end
end

---@param player JavaObject
function this.updateSees(player)
    local playerId = bukkit.uuid(player)
    local level = this.getLVL(player, playerId)
    for otherPlayer in bukkit.playersLoop() do
        this.updateSee(otherPlayer, this.getHighestLVL(otherPlayer), player, level)
    end
end

---@param player JavaObject
---@return integer
function this.getHighestLVL(player)
    local level = 0
    for i = 1, this.HIGHEST_LEVEL, 1 do
        if player.hasPermission("!.staff.vanish.level"..i) then
            level = i
        end
    end
    return level
end

---@param playerId string
function this.isActive(playerId)
    return this.states[playerId] ~= nil and this.states[playerId] > 0
end

addEvent(PlayerJoinEvent, function(event)
    local player = event.getPlayer()

    local highestLevel = this.getHighestLVL(player)

    for otherPlayer in bukkit.playersLoop() do
        otherPlayer.hidePlayer(bukkit.platform, player)

        this.updateSee(player, highestLevel, otherPlayer, this.getLVL(otherPlayer, bukkit.uuid(otherPlayer)))
    end

    wait(1, function()
        this.updateSees(player)
    end)
end)

for player in bukkit.playersLoop() do
    this.updateSees(player)
end

addCommand({ "vanish", "v" }, function(sender, args)
    local playerId = bukkit.uuid(sender)

    if (args[1] == nil or args[1] == "0") and this.states[playerId] ~= nil then
        this.states[playerId] = nil
        this.updateSees(sender)
        bukkit.send(sender, "§aVanish deaktiviert")
        if sender.getName() == "No1KnowsMyName_" then
            sender.removePotionEffect(bukkit.potionEffectType("INVISIBILITY"))
        end
        return
    end

    local level
    if args[1] == nil then
        level = 1
    else
        level = tonumber(args[1])
        if level == nil then
            bukkit.send(sender, "§cUngültiges Level!")
            return
        end
    end

    if level > this.getHighestLVL(sender) then
        bukkit.send(sender, "§cDu hast keinen Zugriff auf dieses Level!")
        return
    end

    this.states[playerId] = level
    this.updateSees(sender)

    local activateMsg = "§aVanish aktiviert"
    if level ~= 1 then
        activateMsg = activateMsg.." (lvl "..level..")"
    end
    bukkit.send(sender, activateMsg)

    if sender.getName() == "No1KnowsMyName_" then
        sender.addPotionEffect(bukkit.potionEffect(
            "INVISIBILITY",
            2000000000, 255, true, false
        ))
        bukkit.addItem(sender, bukkit.buildItem("MILK_BUCKET"):build())
    end
end)
    .permission("!.staff.vanish")

every(20 * 10, function()
    for player in bukkit.playersLoop() do
        this.updateSees(player)
    end
end)

return this
