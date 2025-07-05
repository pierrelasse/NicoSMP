local Node = import("net.luckperms.api.node.Node")

local punishments = require("nicosmp/staff/punishments/index")
local lp = require("nicosmp/utils/luckperms")


local PERM_NODE = Node.builder("voicechat.speak").value(false).build()

-- TODO: time, unmute

addCommand("mutevoicechat", function(sender, args)
    local target, targetId = punishments.getTarget(args[1])
    if target == nil then
        bukkit.send(sender, "§cTarget not found")
        return
    end

    local lpUser = lp.getUser(target)
    if lpUser == nil then
        bukkit.send(sender, "§cError §7(LPUSER_NOT_FOUND)")
        return
    end
    lpUser.data().add(PERM_NODE)
    lp.saveUser(lpUser)

    local senderName = punishments.getSenderName(sender)
    punishments.broadcastStaff("§4"..(target.getName() or targetId).."§7 was voicechat-muted by §8"..senderName)
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
        end
    end)
