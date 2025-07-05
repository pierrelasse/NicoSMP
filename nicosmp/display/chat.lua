local String = import("java.lang.String")
local Character = import("java.lang.Character")
local AsyncPlayerChatEvent = classFor("org.bukkit.event.player.AsyncPlayerChatEvent")

local lp = require("nicosmp/utils/luckperms")
local adminevil = require("nicosmp/staff/adminevil")
local tag = require("nicosmp/features/tag")


local zzzText = "§#5AA9E6"..
    tostring(String(Character.toChars(0x1F4A4))).." §#EDFF1F"..tostring(String(Character.toChars(0x1F634)))

local function isInRange(loc, otherLoc, range)
    if loc.getWorld() ~= otherLoc.getWorld() then return false end
    return loc.distance(otherLoc) <= range
end

addEvent(AsyncPlayerChatEvent, function(event)
    if lp.prov == nil then return end

    event.setCancelled(true)

    local player = event.getPlayer()
    ---@type string
    local message = event.getMessage()

    local isLocal = message:at(1) == "-"
    if isLocal then
        message = message:sub(2)
    end

    if string.lower(message) == "zz"
    or string.lower(message) == "zzz"
    or string.lower(message) == "zzzz"
    or string.lower(message) == "liege wie"
    then
        local dworld = bukkit.defaultWorld()
        local time = dworld.getTime()
        if time > 12300 and time < 23800 then
            message = zzzText
        end
    end

    if player.hasPermission("!.chat.colored") then
        message = string.gsub(message, "&([0-9a-fklmnor#])", "§%1")
    end

    local prefix = string.replace(lp.getPrefix(player) or "", "&", "§")
    local name = player.getName()

    local isAdminEvil = name == adminevil.name
    if isAdminEvil then
        prefix = adminevil.PREFIX
        name = adminevil.NAME
    else
        local sts = tag.getFormattedStatus(bukkit.uuid(player))
        if sts ~= nil then
            prefix = sts.." "..prefix
        end
    end

    local msg = ""

    if isLocal then
        msg = "§7(Lokal) §r"
    end

    msg = msg..prefix..name

    if isAdminEvil then
        msg = "§8»\n"..msg
        msg = msg.."§8 : §a§l"..message.."\n§8»"
    else
        msg = msg.."§r: "..message
    end

    local center = player.getLocation()

    for p in bukkit.playersLoop() do
        if not isLocal or isInRange(center, p.getLocation(), 20) then
            bukkit.send(p, msg)
        end
    end
    bukkit.Bukkit.getConsoleSender().sendMessage(name..": "..message)
end)
    .priority("HIGH")
