addCommand({ "msg", "w", "tell" }, function(sender, args)
    if args[1] == nil then
        bukkit.send(sender, "§cUsage: /w <player> <message...>")
        return
    end

    local target = bukkit.getPlayer(args[1])
    if target == nil or not sender.canSee(target) or sender == target then
        bukkit.send(sender, "§cSpieler nicht gefunden")
        return
    end

    local message = table.concat(args, " ", 2)

    bukkit.sendComponent(sender, bukkit.components.deserialize({
        {
            text = "Zu "..target.getName()..":",
            color = "#D55AA8"
        },
        " ",
        message
    }))
    bukkit.sendComponent(target, bukkit.components.deserialize({
        {
            text = "Von "..sender.getName()..":",
            color = "#D55AA8",
            clickEvent = { action = "suggest_command", value = "/w "..sender.getName().." " },
            hoverEvent = { action = "show_text", value = { { text = "§eKlicke um diesem Spieler zu antworten!" } } }
        },
        " ",
        message
    }))
end)
    .complete(function(completions, sender, args)
        if #args == 1 then
            ---@type string?
            local input
            if args[1] ~= nil then input = string.lower(args[1]) end
            for p in bukkit.playersLoop() do
                ---@type string
                local name = p.getName()
                if input == nil or name:lower():startsWith(input) and sender.canSee(p) then
                    completions.add(name)
                end
            end
        end
    end)
