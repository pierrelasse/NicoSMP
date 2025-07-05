local this = {}

---@type { string: integer }
this.times = {}

---@type fun(player: java.Object)
this.displayUpdateCb = nil

---@param player java.Object
---@return integer ticks
function this.getCombatTime(player)
    local playerId = bukkit.uuid(player)
    return this.times[playerId] or 0
end

---@param player java.Object
function this.isInCombat(player)
    return this.getCombatTime(player) ~= 0
end

---@param player java.Object
function this.enterCombat(player)
    local playerId = bukkit.uuid(player)
    if this.times[playerId] == nil then
        bukkit.send(player, "§#FF0054Du befindest dich nun im Kampf. §lLogge dich nicht aus!")
    end
    this.times[playerId] = 200
    this.displayUpdateCb(player)
end

---@param player java.Object
function this.exitCombat(player)
    this.clearCombat(player)
    this.displayUpdateCb(player)
end

---@param player java.Object
function this.clearCombat(player)
    local playerId = bukkit.uuid(player)
    if this.times[playerId] ~= nil then
        this.times[playerId] = nil
        bukkit.send(player, "§aDu befindest dich nicht mehr im Kampf. §lDu kannst dich nun ausloggen!")
    end
end

---@param player java.Object
function this.checkCombat(player)
    if not this.isInCombat(player) then return end
    bukkit.send(player, "§#FF0054Du befindest dich zurzeit im Kampf. Bitte warte einen Moment!")
    return true
end

return this
