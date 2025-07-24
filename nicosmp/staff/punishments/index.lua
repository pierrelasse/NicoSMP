local Bukkit = import("org.bukkit.Bukkit")
local Player = import("org.bukkit.entity.Player")
local BlockCommandSender = import("org.bukkit.command.BlockCommandSender")


local Storage = require("@bukkit/Storage")

local this = {}
this.MSG_PREFIX = "§8[§6Punishments§8] §7"
this.MSG_INVALID_TARGET = "§cTarget not found"
this.MSG_NO_REASON = "No reason specified"


this.storage = Storage.new("nicosmp", "punishments")
this.storage:loadSave(function()
    local keys = this.storage:getKeys("ent")
    if keys ~= nil then
        for key in forEach(keys) do
            this.storage:clearIfEmpty("ent."..key)
        end
    end
end)


---@param input? string
---@return JavaObject?
---@return string
function this.getTarget(input)
    if input == nil then return nil, "" end
    local target
    if #input > 16 then
        local uuid = bukkit.uuidFromString(input)
        if uuid == nil then return nil, "" end
        target = bukkit.getOfflinePlayerByUUID(uuid)
    else
        target = bukkit.getOfflinePlayer(input)
    end
    if target == nil then return nil, "" end
    return target, bukkit.uuid(target)
end

---@param args table<integer, string>
---@param startIndex integer
---@return table
function this.parseOptions(args, startIndex)
    local result = {}
    local currentKey = ""
    local currentValue

    for i = startIndex, #args do
        local arg = args[i]
        local delIndex = string.find(arg, ":")
        if delIndex ~= nil then
            if string.at(arg, delIndex - 1) == "\\" then
                arg = string.sub(arg, 1, delIndex - 2)..string.sub(arg, delIndex)
            else
                result[currentKey] = currentValue
                currentKey = string.sub(arg, 0, delIndex - 1)
                currentValue = string.sub(arg, delIndex + 1)
                if currentValue == "" then currentValue = nil end
                goto continue
            end
        end
        if currentValue == nil then
            currentValue = arg
        else
            currentValue = currentValue.." "..arg
        end

        ::continue::
    end
    result[currentKey] = currentValue

    return result
end

function this.send(player, message)
    bukkit.send(player, this.MSG_PREFIX..message)
end

function this.broadcastStaff(message)
    message = this.MSG_PREFIX..message
    for player in forEach(Bukkit.getOnlinePlayers()) do
        if player.isOp() then
            player.sendMessage(message)
        end
    end
end

function this.formatSeconds(secs)
    if secs == nil then return "0s" end

    local years = math.floor(secs / 31536000)
    local days = math.floor((secs % 31536000) / 86400)
    local hours = math.floor((secs % 86400) / 3600)
    local minutes = math.floor((secs % 3600) / 60)
    local seconds = secs % 60

    local parts = {}
    if years > 0 then table.insert(parts, string.format("%dy", years)) end
    if days > 0 then table.insert(parts, string.format("%dd", days)) end
    if hours > 0 then table.insert(parts, string.format("%dh", hours)) end
    if minutes > 0 then table.insert(parts, string.format("%dm", minutes)) end
    if seconds > 0 or #parts == 0 then table.insert(parts, string.format("%ds", seconds)) end

    return table.concat(parts, " ")
end

-- function this.formatSeconds(secs)
--     if secs == nil then return "0s" end

--     local days = math.floor(secs / 86400)
--     local hours = math.floor((secs % 86400) / 3600)
--     local minutes = math.floor((secs % 3600) / 60)
--     local seconds = secs % 60

--     local parts = {}
--     if days > 0 then table.insert(parts, string.format("%dd", days)) end
--     if hours > 0 or #parts > 0 then table.insert(parts, string.format("%dh", hours)) end
--     if minutes > 0 or #parts > 0 then table.insert(parts, string.format("%dm", minutes)) end
--     table.insert(parts, string.format("%ds", seconds))

--     return table.concat(parts, " ")
-- end

function this.parseSeconds(s)
    local secs
    for part in string.gmatch(s, "%S+") do
        local value = tonumber(part:match("^(%d+)"))
        local unit = part:match("(%a+)$")
        if value then
            local seconds
            if unit == "s" or unit == nil then
                seconds = value
            elseif unit == "m" then
                seconds = value * 60
            elseif unit == "h" then
                seconds = value * (60 * 60)
            elseif unit == "d" then
                seconds = value * (60 * 60 * 24)
            elseif unit == "w" then
                seconds = value * (60 * 60 * 24 * 7)
            elseif unit == "mo" then
                seconds = value * (60 * 60 * 24 * 30)
            elseif unit == "y" then
                seconds = value * (60 * 60 * 24 * 365)
            else
                return
            end
            secs = (secs or 0) + seconds
        end
    end
    return secs
end

---@param sender JavaObject
---@return string
function this.getSenderName(sender)
    if instanceof(sender, Player) then return sender.getName() end
    if instanceof(sender, BlockCommandSender) then
        local loc = sender.getBlock().getLocation()
        return "@("..loc.getWorld().getName()..","..loc.getX()..","..loc.getY()..","..loc.getZ()..")"
    end
    return "@"
end

---@param data { duration: integer, creation: integer }
---@return integer?
function this.getRemaningTimeFromDuration(data)
    if data.duration == nil then return nil end
    local passed = (Time.now() / 1000) - data.creation
    local remaining = data.duration - passed
    if remaining > 0 then return remaining end
    return -1
end

function this.getPath(uuid) return "ent."..uuid end

this.now = Time.now

return this
