local Statistic = import("org.bukkit.Statistic")

local punishments = require("nicosmp/staff/punishments/index")
local bans = require("nicosmp/staff/punishments/bans")
local ips = require("nicosmp/staff/punishments/ips")


local function addInfo_punishments(playerId)
    local s = ""

    local path = punishments.getPath(playerId)
    if not punishments.storage:has(path) then return s end

    local banData = bans.getData(path)
    if banData ~= nil then
        s = s.."\n§7 Banned§8:"
        s = s.."\n§7  Reason§8: §f"..banData.reason
        s = s.."\n§7  Duration§8: "..
            (banData.duration == nil
                and "§c"..bans.BAN_DURATION_PERM
                or ("§b"..punishments.formatSeconds(banData.durationTime).."§8/§3"..punishments.formatSeconds(banData.duration)))

        if banData.issuer ~= nil then
            local uuid
            pcall(function() uuid = bukkit.uuidFromString(banData.issuer) end)
            local name
            if uuid ~= nil then
                local player = bukkit.getOfflinePlayerByUUID(uuid)
                if player ~= nil then
                    name = player.getName()
                end
            end
            if name == nil then name = tostring(banData.issuer) end

            s = s.."\n§7  Issuer§8: §f"..name
        end
        if banData.note ~= nil then
            s = s.."\n§7  Note§8: §f"..banData.note
        end
    end

    return s
end

local function addInfo_ip(playerId, target)
    local s = ""

    if target.isOnline() then
        local addr = target.getAddress().getAddress()
        local ip = addr.getHostAddress()
        local chn = addr.getCanonicalHostName()
        s = s.."\n§7 IP: §f"..ip
        if chn ~= ip then
            s = s.."\n§7  HN: §f"..chn
        end
    end

    local ipMap = ips.getIps(playerId)
    if not ipMap.isEmpty() then
        s = s.."\n§7 All IPs §8("..ipMap.size().."):"
        for ip in forEach(ipMap.keySet()) do
            s = s.."\n§8  - §f"..ip.."§8: §7"..ipMap.get(ip)
        end
    end

    local alts = ips.findAlts(playerId)
    if not alts.isEmpty() then
        s = s.."\n§7 Alts:"
        for alt in forEach(alts) do
            local altUUID   = bukkit.uuidFromString(alt)
            local altPlayer = bukkit.getOfflinePlayerByUUID(altUUID)
            local altName
            if altPlayer == nil then
                altName = alt
            else
                altName = altPlayer.getName()
            end
            s = s.."\n§8  - §f"..altName
        end
    end

    return s
end

addCommand("profile", function(sender, args)
    if #args == 0 then
        bukkit.send(sender, "§cUsage: /profile <offlineplayer>")
        return
    end
    bukkit.send(sender, "§8Loading profile...")
    async(function()
        local target = punishments.getTarget(args[1])
        if target == nil then
            bukkit.send(sender, "§cTarget not found!")
            return
        end
        local targetId = bukkit.uuid(target)

        local s = "§7Profile of §e"..(target.getName() or "???")
        if target.isOnline() then
            s = s.."§a ●"
        end
        s = s.."§8:"
        s = s.."\n§7 UUID§8: §f"..targetId

        if target.isOnline() then
        elseif target.hasPlayedBefore() then
            local now = Time.now()
            s = s..
                "\n§7 Last online: §f"..punishments.formatSeconds((now - math.min(now, target.getLastPlayed())) / 1000)
        else
            goto finish
        end

        do
            local stat = target.getStatistic(Statistic.PLAY_ONE_MINUTE)
            s = s.."\n§7 Playtime: §f"..punishments.formatSeconds(stat / 20)
        end

        s = s..addInfo_punishments(targetId)
        s = s..addInfo_ip(targetId, target)

        ::finish::
        bukkit.send(sender, s)
    end)
end)
    .permission("!.staff.profile")
    .complete(function(completions, sender, args)
        if #args == 1 then
            local prefix = string.lower(args[1])
            for player in bukkit.offlinePlayersLoop() do
                local name = player.getName()
                if string.startswith(string.lower(name), prefix) then
                    completions.add(name)
                end
            end
        end
    end)
