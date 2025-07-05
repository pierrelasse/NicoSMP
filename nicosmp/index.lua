local paman = require("@base/paman")

paman.need("bukkit/basic")
paman.need("bukkit/Storage")
paman.need("bukkit/worldmanager")

NicoSMP = {}

NicoSMP.maxPlayers = bukkit.Bukkit.getMaxPlayers()
NicoSMP.joinAddress = "45.85.219.230:25566"
NicoSMP.discordInvite = "https://discord.gg/8ctX7F7s"

function NicoSMP.isCreativeOrSpec(player)
    local gameMode = player.getGameMode().name()
    return gameMode == "CREATIVE" or gameMode == "SPECTATOR"
end

require("nicosmp/staff/punishments/index")
require("nicosmp/staff/punishments/banCommands")
require("nicosmp/staff/punishments/muteCommands")
require("nicosmp/staff/punishments/profile")
require("nicosmp/staff/punishments/voicechatmute")
require("nicosmp/staff/punishments/nameHistory")

require("nicosmp/staff/vanish")

require("nicosmp/display/joinleave")
require("nicosmp/display/chat")
require("nicosmp/display/playerlist")
require("nicosmp/display/commandList")
require("nicosmp/display/status")

require("nicosmp/combat/index")
require("nicosmp/combat/display")
require("nicosmp/combat/events")
require("nicosmp/combat/toggle")

require("nicosmp/commands/messaging")
require("nicosmp/commands/fullbright")

require("nicosmp/staff/spec")
require("nicosmp/staff/spy")
require("nicosmp/staff/login")

require("nicosmp/features/spawn")
require("nicosmp/features/spawnbeacon")
require("nicosmp/features/tag")
require("nicosmp/features/tpa")
require("nicosmp/features/skullDrops")

require("nicosmp/staff/consolecmd")
require("nicosmp/staff/voidWorld")
require("nicosmp/staff/support")
require("nicosmp/staff/xray")
require("nicosmp/staff/deathLog")

wait(0, function()
    require("nicosmp/staff/chat")
    require("nicosmp/staff/displayer")

    require("nicosmp/display/leaderboards")

    wait(1, function()
        require("nicosmp/staff/blitzdingsbums")
        require("nicosmp/staff/voicechattest")
    end)

    require("nicosmp/commands/discord")

    for player in bukkit.playersLoop() do
        player.updateCommands()
    end
end)
