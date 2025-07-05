local ArrayList = classFor("java.util.ArrayList")
local PlayerCommandSendEvent = classFor("org.bukkit.event.player.PlayerCommandSendEvent")


addEvent(PlayerCommandSendEvent, function(event)
    local player = event.getPlayer()
    local bypass = player.hasPermission("!.staff.commandlist")

    local cmds = event.getCommands()

    for command in forEach(ArrayList(event.getCommands())) do
        if bypass then goto continue end

        if string.contains(command, ":") then goto remove end
        if string.startswith(command, "/") then goto remove end

        goto continue
        ::remove::
        cmds.remove(command)
        ::continue::
    end

    cmds.remove("callback")
    cmds.remove("fastasyncworldedit")
    if not bypass then
        cmds.remove("fawe")
        cmds.remove("floodgate")
        cmds.remove("god")
        cmds.remove("rg")
        cmds.remove("ungod")
    end
    if string.at(player.getName(), 1) ~= "." then cmds.remove("geyser") end
    cmds.remove("region")
    cmds.remove("regions")
    cmds.remove("slay")
    cmds.remove("veinminer")
    cmds.remove("we")
    cmds.remove("worldedit")
    cmds.remove("core")
    cmds.remove("coreprotect")
    cmds.remove("terraform")
    cmds.remove("owe")
    cmds.remove("onewayelytra")
end)
