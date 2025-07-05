local PlayerJoinEvent = classFor("org.bukkit.event.player.PlayerJoinEvent")

local lp = require("nicosmp/utils/luckperms")
local vanish = require("nicosmp/staff/vanish")
local adminevil = require("nicosmp/staff/adminevil")
local combat = require("nicosmp/combat/index")
local tag = require("nicosmp/features/tag")
local tpsTracker = require("nicosmp/utils/tpsTracker")


local bsInfoCol = "§#A8A2B9"
local bsInfo = {
    "Sende Privat-Nachrichten mit §#D55AA8/w <spieler> <nachricht...>",
    "Nutze §#E5E486/spawn"..bsInfoCol.." um zum Spawn zu gelangen",
    "Weißt du wer ich bin?    Ich auch nicht..",
    "Ist es zu dunkel? Nutze §#5567ED/fullbright"..bsInfoCol,
    "Hier könnte ihre Werbung stehen!",
    "Live bei Nico zuschauen: §#931FFFhttps://twitch.tv/z_nicotv",
    "Setze deinen Status mit §#DED6F3/tag <status>",
    "Aktiviere oder deaktiviert PvP mit §#FB4949/pvp",
    "Du brauchst Hilfe? Nutze §#8693F4/support <nachricht...>"
}
local bsInfoIndex = math.random(1, #bsInfo)

---@param player java.Object
local function update(player)
    local playerId = bukkit.uuid(player)

    local otherPlayers = 1
    for otherPlayer in bukkit.playersLoop() do
        if player ~= otherPlayer and player.canSee(otherPlayer) then
            otherPlayers = otherPlayers + 1
        end
    end

    do
        local header = "                                                                  §7"..
            otherPlayers.."/"..NicoSMP.maxPlayers
        if player.getName() == "pierrelasse" then
            header = header.."\n§#AB4ADD§lNico Drama SMP"
        else
            header = header.."\n§#AB4ADD§lNico SMP 2.0"
        end
        header = header.."\n§#936FA5"..NicoSMP.joinAddress
        -- if bukkit.Bukkit.hasWhitelist() then
        --     header = header.."\n§#FF6000§lMAINTENANCE!"
        -- end
        header = header.."\n"
        player.setPlayerListHeader(bukkit.hex(header))
    end

    do
        local footer = ""

        local info = bsInfo[bsInfoIndex] or ""
        footer = footer.."\n"..bukkit.hex(bsInfoCol..info)
        footer = footer.."\n§#5A4689§m"
        for i = 1, #bsInfo do
            footer = footer.." "
            if i == bsInfoIndex then
                footer = footer.."§#181520§m"
            end
        end
        footer = footer.."\n"

        local tps = tpsTracker()
        if tps < 19 then
            footer = footer.."§#9D91A7TPS: "..tps
        end

        footer = footer.."\n"

        player.setPlayerListFooter(bukkit.hex(footer))
    end

    do
        if lp.prov == nil then return end

        local s = ""

        if vanish.isActive(playerId) then
            s = "§#4CF99D§l[V"
            local level = vanish.states[playerId]
            if level ~= 1 then
                s = s..level
            end
            s = s.."]§r "
        end

        do
            local prefix = string.replace(lp.getPrefix(player) or "", "&", "§")
            local name = player.getName()

            local isAdminEvil = name == adminevil.name
            if isAdminEvil then
                prefix = adminevil.PREFIX
                name = adminevil.NAME
            end

            s = s..prefix..name
        end

        do
            local sts = tag.getFormattedStatus(playerId)
            if sts ~= nil then
                s = s.." "..sts
            end
        end

        if combat.isInCombat(player) then
            s = s.." §#FD1631⚔"
        end

        player.setPlayerListName(bukkit.hex(s))
    end
end

wait(1, function()
    for player in bukkit.playersLoop() do
        update(player)
    end
end)

addEvent(PlayerJoinEvent, function(event)
    update(event.getPlayer())
end)

every(20, function()
    async(function()
        for player in bukkit.playersLoop() do
            update(player)
        end
    end)
end)

every(20 * 5, function()
    bsInfoIndex = bsInfoIndex + 1
    if bsInfoIndex > #bsInfo then
        bsInfoIndex = 1
    end
end)
