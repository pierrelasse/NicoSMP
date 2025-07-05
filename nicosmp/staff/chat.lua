local PERMISSION = "!.staff.chat"


addCommand({ "staffchat", "sc" }, function(sender, args)
    local name = sender.getName()
    local message = table.concat(args, " ")
    if #message == 0 then
        bukkit.send(sender, "§cUsage: /staffchat <message...>")
        return
    end

    local msg = "§3[§bS§3] "..name.."§r: "..message
    for otherPlayer in bukkit.playersLoop() do
        if otherPlayer.hasPermission(PERMISSION) then
            bukkit.send(otherPlayer, msg)
        end
    end
end)
    .permission(PERMISSION)
