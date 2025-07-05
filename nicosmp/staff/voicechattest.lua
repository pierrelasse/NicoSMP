addCommand("voicechatgrouppw", function(sender, args)
    if args[1] == nil then
        bukkit.send(sender, "§cUsage: /voicechatgrouppw <group>")
        return
    end
    local groupName = table.concat(args, " ")

    local Voicechat = import("de.maxhenkel.voicechat.Voicechat")
    local server = Voicechat.SERVER.server
    local groupManager = server.groupManager
    local groups = groupManager.groups

    local group
    for g in forEach(groups.values()) do
        local gName = g.name
        if gName == groupName then
            group = g
            break
        end
    end
    if group == nil then
        bukkit.send(sender, "§cGroup not found")
        return
    end

    bukkit.send(sender, "Password: §a"..group.password)
end)
    .permission("op")
