local AsyncPlayerPreLoginEvent = import("org.bukkit.event.player.AsyncPlayerPreLoginEvent")

local staff = require("nicosmp/staff/index")
local punishments = require("nicosmp/staff/punishments/index")
local bans = require("nicosmp/staff/punishments/bans")


addEvent(AsyncPlayerPreLoginEvent, function(event)
    local comp = {}

    comp[#comp + 1] = {
        text = event.getName(),
        color = staff.COLOR_TARGET
    }
    comp[#comp + 1] = {
        text = " logging in",
        color = staff.COLOR_MSG_GENERIC
    }

    if event.isTransferred() then
        comp[#comp + 1] = " [TRANSFERRED]"
    end

    local result = event.getLoginResult()
    local resultName = result.name()
    if resultName ~= "ALLOWED" then
        comp[#comp + 1] = ": "
        if resultName == "KICK_OTHER" then
            local banData = bans.getData(punishments.getPath(event.getUniqueId().toString()))
            if banData ~= nil then
                comp[#comp + 1] = "§7banned"
            else
                comp[#comp + 1] = "§f"..event.getKickMessage()
            end
        elseif resultName == "KICK_WHITELIST" then
            comp[#comp + 1] = "§8whitelist"
        elseif resultName == "KICK_FULL" then
            comp[#comp + 1] = "§7full"
        elseif resultName == "KICK_BANNED" then
            comp[#comp + 1] = "§7banned (mc)"
        end
    end
    staff.notify(nil, table.unpack(comp))
end)
