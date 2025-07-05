local AsyncPlayerPreLoginEvent = classFor("org.bukkit.event.player.AsyncPlayerPreLoginEvent")
local AsyncPlayerPreLoginEvent_Result = classFor("org.bukkit.event.player.AsyncPlayerPreLoginEvent$Result")

local punishments = require("nicosmp/staff/punishments/index")


local this = {}
this.BAN_REASON = "re"
this.BAN_DURATION = "du"
this.BAN_DURATION_PERM = "Permanently"
this.BAN_ISSUER = "by"
this.BAN_CREATION = "cr"
this.BAN_NOTE = "no"

function this.getPath(path) return path..".ban" end

function this.getData(path)
    path = this.getPath(path)
    if not punishments.storage:has(path) then return nil end
    local data = {}
    data.duration = punishments.storage:get(path.."."..this.BAN_DURATION)
    data.creation = punishments.storage:get(path.."."..this.BAN_CREATION)
    data.durationTime = punishments.getRemaningTimeFromDuration(data)
    if data.durationTime == -1 then
        punishments.storage:set(path, nil)
        return nil
    end
    data.reason = punishments.storage:get(path.."."..this.BAN_REASON)
    data.issuer = punishments.storage:get(path.."."..this.BAN_ISSUER)
    data.note = punishments.storage:get(path.."."..this.BAN_NOTE)
    return data
end

---@param playerId string
---@return string?
function this.getKickMessage(playerId)
    local path = punishments.getPath(playerId)
    local data = this.getData(path)
    if data == nil then return end

    local msg = "§cDu bist "
    if data.duration == nil then
        msg = msg.."permanent"
    else
        msg = msg.."temporär"
    end
    if data.duration ~= nil then
        msg = msg.." für §f"..punishments.formatSeconds(data.durationTime).."§c"
    end
    msg = msg.." gebannt."

    msg = msg.."\n§7Grund: §f"..data.reason
    msg = msg.."\n\n§8Discord: §n"..NicoSMP.discordInvite

    return msg
end

addEvent(AsyncPlayerPreLoginEvent, function(event)
    local playerId = event.getUniqueId().toString()

    local disconnectMessage = this.getKickMessage(playerId)
    if disconnectMessage ~= nil then
        event.disallow(AsyncPlayerPreLoginEvent_Result.KICK_OTHER, disconnectMessage)
    end
end)

return this
