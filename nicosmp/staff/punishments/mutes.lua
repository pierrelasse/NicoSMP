local AsyncPlayerChatEvent = import("org.bukkit.event.player.AsyncPlayerChatEvent")

local punishments = require("nicosmp/staff/punishments/index")


local this = {}
this.BAN_REASON = "re"
this.BAN_DURATION = "du"
this.BAN_DURATION_PERM = "Permanently"
this.BAN_ISSUER = "by"
this.BAN_CREATION = "cr"
this.BAN_NOTE = "no"

function this.getPath(path) return path .. ".mute" end

function this.getData(path)
    path = this.getPath(path)
    if not punishments.storage:has(path) then return nil end
    local data = {}
    data.duration = punishments.storage:get(path .. "." .. this.BAN_DURATION)
    data.creation = punishments.storage:get(path .. "." .. this.BAN_CREATION)
    data.durationTime = punishments.getRemaningTimeFromDuration(data)
    if data.durationTime == -1 then
        punishments.storage:set(path, nil)
        return nil
    end
    data.reason = punishments.storage:get(path .. "." .. this.BAN_REASON)
    data.issuer = punishments.storage:get(path .. "." .. this.BAN_ISSUER)
    data.note = punishments.storage:get(path .. "." .. this.BAN_NOTE)
    return data
end

---@param playerId string
---@param happenedNow? true
---@return string?
function this.getMessage(playerId, happenedNow)
    local data = this.getData(punishments.getPath(playerId))
    if data == nil then return end

    local LINE =
    "§c§m                                                                           "

    local s = LINE
    if data.reason == "Unter Überprüfung" then
        s = s .. "\n§cEine Meldung gegen dich wird zurzeit überprüft."
    else
        if happenedNow == true then
            s = s .. "\n§cDu wurdest für " .. data.reason .. " gemuted."
        else
            s = s .. "\n§cDu bist zurzeit gemuted: " .. data.reason .. "."
        end
    end
    if data.durationTime == nil then
        s = s .. "\n§7Der Mute wird nicht ablaufen"
    else
        s = s .. "\n§7Der Mute läuft in §c" .. punishments.formatSeconds(data.durationTime) .. "§7 ab"
    end
    s = s .. "\n"
    s = s .. "\n§7Discord: §b§n" .. NicoSMP.discordInvite
    s = s .. "\n" .. LINE

    return s
end

addEvent(AsyncPlayerChatEvent, function(event)
    local player = event.getPlayer()

    local message = this.getMessage(bukkit.uuid(player))
    if message ~= nil then
        event.setCancelled(true)
        bukkit.send(player, message)
    end
end)
    .priority("LOW")

return this
