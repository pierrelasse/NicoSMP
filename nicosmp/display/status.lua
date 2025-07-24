local PaperServerListPingEvent = import("com.destroystokyo.paper.event.server.PaperServerListPingEvent")

local vanish = require("nicosmp/staff/vanish")
local smpDay = require("nicosmp/utils/smpDay")

local NICO = "§#BD08FB§lN§#D01CF8§li§#E32FF4§lc§#F643F1§lo"
local SMP = "§#08B6FB§lS§#26D6E3§lM§#43F6CA§lP"
local ZWEIPUNKTNULL = "§#EEFB08§l2§#EAF926§l.§#E5F643§l0"
local TAG = "§#5AFB08§lT§#54FA35§la§#4FF962§lg §#43F6BC§l"..smpDay()
local VERSION = "§#FB0839§l1§#FA1447§l.§#F92054§l2§#F82B62§l1§#F7376F§l.§#F6437D§l4"
local MOTD = " §#F9951FEinfach Orangensaft, turn up!"

local motd = bukkit.hex(
    "            "..NICO.." "..SMP.." "..ZWEIPUNKTNULL.." "..TAG.." §#8D8C8D- "..VERSION.." \n"..
    MOTD
)

local function cb(event)
    event.setMotd(motd)
    event.setVersion("1.21.4")

    local playerCount = 0
    for player in bukkit.playersLoop() do
        if not vanish.isActive(bukkit.uuid(player)) then
            playerCount = playerCount + 1
        end
    end
    event.setNumPlayers(playerCount)
    event.getPlayerSample().clear()
end

local ev = addEvent(PaperServerListPingEvent, cb)
wait(10, function()
    ev.unregister()
    addEvent(PaperServerListPingEvent, cb)
end)
