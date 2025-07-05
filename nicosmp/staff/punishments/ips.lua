local PlayerJoinEvent = import("org.bukkit.event.player.PlayerJoinEvent")

local Storage = require("@bukkit/Storage")

if Storage.loopKeys == nil then
    --FIXME
    ---@param path string
    function Storage:loopKeys(path)
        ---@type java.Set?
        local keys = self:getKeys(path)
        if keys == nil then return function() return nil end end
        return forEach(keys)
    end
end

local this = {}
this.storage = Storage.new("nicosmp", "ips")
this.storage:loadSave()

---@param s string
function this.sanitizeIp(s)
    return s:replace(".", "_")
end

---@param playerId string
---@param ip string
function this.increaseAddress(playerId, ip)
    local path = "ips."..playerId.."."..this.sanitizeIp(ip)
    this.storage:set(
        path,
        this.storage:get(
            path,
            0
        ) + 1
    )
end

---@param playerId string
function this.getIps(playerId)
    local map = makeMap()
    for key in this.storage:loopKeys("ips."..playerId) do
        map.put(string.replace(key, "_", "."), this.storage:get("ips."..playerId.."."..key))
    end
    return map
end

---@param playerId string
function this.findAlts(playerId)
    local list = makeList()
    local ips = this.getIps(playerId)
    for loopPlayerId in this.storage:loopKeys("ips") do
        for loopIp in this.storage:loopKeys("ips."..loopPlayerId) do
            if ips.containsKey(loopIp) then
                list.add(loopPlayerId)
            end
        end
    end
    return list
end

addEvent(PlayerJoinEvent, function(event)
    local player = event.getPlayer()
    async(function()
        if player.hasPermission("!.staff.admin") then return end
        local addr = player.getAddress().getAddress()
        this.increaseAddress(bukkit.uuid(player), addr.getHostAddress())
    end)
end)

return this
