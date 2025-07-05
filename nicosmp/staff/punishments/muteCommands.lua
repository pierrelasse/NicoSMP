local punishments = require("nicosmp/staff/punishments/index")
local mutes = require("nicosmp/staff/punishments/mutes")
local muteIds = require("nicosmp/staff/punishments/muteIds")


local function listMuteIds(sender)
    local sortedIds = table.keys(muteIds)
    table.sort(sortedIds, function(a, b) return a < b end)
    for _, id in ipairs(sortedIds) do
        local data = muteIds[id]
        bukkit.send(
            sender,
            "§4ID: "..id.." §c- §4MUTE §c- §4"
            ..(data.reason or "UNDER_REVIEW")
            .." - "..(data.duration or "PERM")
        )
    end
end

addCommand("mute", function(sender, args)
    local target, targetId = punishments.getTarget(args[1])
    if target == nil then
        listMuteIds(sender)
        return
    end

    local path = mutes.getPath(punishments.getPath(targetId))

    local data = punishments.parseOptions(args, 2)
    local reason = data[""] or punishments.MSG_NO_REASON
    local duration = data["duration"]

    do
        local reasonId = tonumber(reason)
        if reasonId ~= nil then
            local muteIDData = muteIds[reasonId]
            if muteIDData ~= nil then
                reason = muteIDData.reason
                duration = muteIDData.duration
            end
        end
    end

    if duration ~= nil then
        duration = punishments.parseSeconds(duration)
        if duration == nil then
            punishments.send(sender, "§cInvalid duration")
            return
        end
        duration = math.ceil(duration)
    end
    if duration ~= nil and duration <= 0 then
        bukkit.send(sender, "§cPlease use /unmute")
        return
    end

    local note = data["note"]

    punishments.storage:set(path, nil) -- clear previous data
    punishments.storage:set(path.."."..mutes.BAN_REASON, reason)
    punishments.storage:set(path.."."..mutes.BAN_DURATION, duration)
    if bukkit.isPlayer(sender) then
        punishments.storage:set(path.."."..mutes.BAN_ISSUER, sender.getUniqueId().toString())
    end
    punishments.storage:set(path.."."..mutes.BAN_CREATION, punishments.now() / 1000)
    if note ~= nil then
        punishments.storage:set(path.."."..mutes.BAN_NOTE, note)
    end
    punishments.storage:save()

    local senderName = punishments.getSenderName(sender)
    local formattedDuration = (duration == nil and mutes.BAN_DURATION_PERM or punishments.formatSeconds(duration))
    punishments.broadcastStaff("§4"..
        (target.getName() or targetId).."§7 was muted by §8"..senderName..
        "§7 for §b"..formattedDuration.."§8: §f"..reason)

    if target.isOnline() then
        wait(0, function()
            bukkit.send(target, mutes.getMessage(targetId, true) or "")
        end)
    end
end)
    .permission("!.staff.mute")
    .complete(function(completions, sender, args)
        if #args == 1 then
            local prefix = string.lower(args[1])
            for player in bukkit.offlinePlayersLoop() do
                local name = player.getName()
                if string.startswith(string.lower(name), prefix) then
                    completions.add(name)
                end
            end
        elseif #args == 2 then
            completions.add("<reason>")
        end
    end)

addCommand("unmute", function(sender, args)
    local target, targetId = punishments.getTarget(args[1])
    if target == nil then
        punishments.send(sender, punishments.MSG_INVALID_TARGET)
        return
    end

    local path = mutes.getPath(punishments.getPath(targetId))

    local data = punishments.parseOptions(args, 2)
    local reason = data[""] or punishments.MSG_NO_REASON

    local senderName = punishments.getSenderName(sender)

    if not punishments.storage:has(path) then
        punishments.send(sender, "§cTarget is not muted")
        return
    end

    punishments.broadcastStaff("§f"..
        (target.getName() or targetId).."§7 was unmuted by §f"..senderName.."§8: §f"..reason)

    punishments.storage:set(path, nil)
    punishments.storage:save()
end)
    .permission("!.staff.mute")
    .complete(function(completions, sender, args)
        if #args == 1 then
            local prefix = string.lower(args[1])
            for player in bukkit.offlinePlayersLoop() do
                local name = player.getName()
                if string.startswith(string.lower(name), prefix) then
                    completions.add(name)
                end
            end
        elseif #args == 2 then
            completions.add("<reason>")
        end
    end)
