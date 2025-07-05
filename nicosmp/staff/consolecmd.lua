local ServerCommandEvent = import("org.bukkit.event.server.ServerCommandEvent")

local staff = require("nicosmp/staff/index")


addEvent(ServerCommandEvent, function(event)
    if event.getSender().getName() == "@" then return end

    event.setCancelled(true)

    if event.getSender().getName() ~= "CONSOLE" then
        print(event.getSender().getName())
        return
    end

    local command = event.getCommand()
    staff.notify(staff.ADMIN, "§cconsole: §4"..command)

    if command == "stop"
    or command == "scripting"
    then
        event.setCancelled(false)
    end

    -- local Level = import("java.util.logging.Level")
    -- local function send(level)
    --     local function log(s)
    --         bukkit.Bukkit.getLogger().log(level, tostring(s))
    --     end
    -- end
    -- send(Level.SEVERE)
end)
