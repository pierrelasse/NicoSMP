local punishments = require("nicosmp/staff/punishments/index")
local bans = require("nicosmp/staff/punishments/bans")
local banIds = require("nicosmp/staff/punishments/banIds")


local function listBanIds(sender)
    local sortedIds = table.keys(banIds)
    table.sort(sortedIds, function(a, b) return a < b end)
    for _, id in ipairs(sortedIds) do
        local data = banIds[id]
        bukkit.send(sender, "§4ID: "..id.." §c- §4BAN §c- §4"..data.reason.." - "..(data.duration or "PERM"))
    end
end

addCommand("ban", function(sender, args)
    local target, targetId = punishments.getTarget(args[1])
    if target == nil then
        listBanIds(sender)
        return
    end

    local path = bans.getPath(punishments.getPath(targetId))

    local data = punishments.parseOptions(args, 2)
    local reason = data[""] or punishments.MSG_NO_REASON
    local duration = data["duration"]

    do
        local reasonId = tonumber(reason)
        if reasonId ~= nil then
            local banIDData = banIds[reasonId]
            if banIDData ~= nil then
                reason = banIDData.reason
                duration = banIDData.duration
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
        bukkit.send(sender, "§cPlease use /unban")
        return
    end

    local note = data["note"]

    punishments.storage:set(path, nil) -- clear previous data
    punishments.storage:set(path.."."..bans.BAN_REASON, reason)
    punishments.storage:set(path.."."..bans.BAN_DURATION, duration)
    if bukkit.isPlayer(sender) then
        punishments.storage:set(path.."."..bans.BAN_ISSUER, sender.getUniqueId().toString())
    end
    punishments.storage:set(path.."."..bans.BAN_CREATION, punishments.now() / 1000)
    if note ~= nil then
        punishments.storage:set(path.."."..bans.BAN_NOTE, note)
    end
    punishments.storage:save()

    local senderName = punishments.getSenderName(sender)
    local formattedDuration = (duration == nil and bans.BAN_DURATION_PERM or punishments.formatSeconds(duration))
    punishments.broadcastStaff("§4"..
        (target.getName() or targetId).."§7 was banned by §8"..senderName..
        "§7 for §b"..formattedDuration.."§8: §f"..reason)

    if target.isOnline() then
        wait(0, function()
            if target.isOnline() then
                target.kickPlayer(bans.getKickMessage(targetId) or "")
            end
        end)
    end
end)
    .permission("!.staff.ban")
    .complete(function(completions, sender, args)
        if #args == 1 then
            local prefix = string.lower(args[1])
            for player in bukkit.offlinePlayersLoop() do
                local name = player.getName()
                if string.startswith(string.lower(name), prefix) then
                    completions.add(name)
                end
            end
        elseif #args > 1 then
            if #args == 2 then
                completions.add("<reason|id>")
            end
            completions.add("duration:")
            completions.add("note:")
        end
    end)


addCommand("unban", function(sender, args)
    local target, targetId = punishments.getTarget(args[1])
    if target == nil then
        punishments.send(sender, punishments.MSG_INVALID_TARGET)
        return
    end
    local path = bans.getPath(punishments.getPath(targetId))

    local data = punishments.parseOptions(args, 2)
    local reason = data[""] or punishments.MSG_NO_REASON

    local senderName = punishments.getSenderName(sender)

    if not punishments.storage:has(path) then
        punishments.send(sender, "§cTarget is not banned")
        return
    end

    punishments.broadcastStaff("§f"..
        (target.getName() or targetId).."§7 was unbanned by §f"..senderName.."§8: §f"..reason)

    punishments.storage:set(path, nil)
    punishments.storage:save()
end)
    .permission("!.staff.ban")
    .complete(function(completions, sender, args)
        if #args == 1 then
            ---@type string?
            local input
            if args[1] ~= nil then input = string.lower(args[1]) end
            for p in bukkit.offlinePlayersLoop() do
                ---@type string
                local name = p.getName()
                if input == nil or name:lower():startsWith(input) then
                    local banData = bans.getData(punishments.getPath(bukkit.uuid(p)))
                    if banData ~= nil then
                        completions.add(name)
                    end
                end
            end
        elseif #args == 2 then
            completions.add("<reason>")
        end
    end)
