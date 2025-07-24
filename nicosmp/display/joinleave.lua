local PlayerJoinEvent = import("org.bukkit.event.player.PlayerJoinEvent")
local PlayerQuitEvent = import("org.bukkit.event.player.PlayerQuitEvent")


function SendFirstJoinMSG(player)
    wait(15, function()
        if not player.isOnline() then return end

        bukkit.send(player, "§8§m                         ")
        bukkit.send(player, "§#4EFB4E§lWillkommen auf dem Nico SMP!")
        bukkit.send(player, "§#C8B380IP: §#D3C6A8"..NicoSMP.joinAddress)
        bukkit.send(player, "§#C8B380Discord: §#D3C6A8https://discord.gg/crzgZCckmD §#676767(or /discord)")
        bukkit.send(player, "§8§m                         ")
    end)
end

addEvent(PlayerJoinEvent, function(event)
    local player = event.getPlayer()
    local name = player.getName()

    event.setJoinMessage(nil)

    local playedBefore = player.hasPlayedBefore()

    wait(2, function()
        local msg = "§#5B6374"..name.." hat den Server"

        if not playedBefore then
            msg = msg.." zum ersten mal"
            SendFirstJoinMSG(player)
        end

        msg = msg.." betreten"

        for otherPlayer in bukkit.playersLoop() do
            if otherPlayer == player or otherPlayer.canSee(player) then
                bukkit.send(otherPlayer, msg)
            end
        end
    end)
end)

addEvent(PlayerQuitEvent, function(event)
    local player = event.getPlayer()
    local name = player.getName()

    event.setQuitMessage(nil)

    local msg = "§#5B6374"..name.." hat den Server verlassen"
    for otherPlayer in bukkit.playersLoop() do
        if otherPlayer ~= player and otherPlayer.canSee(player) then
            bukkit.send(otherPlayer, msg)
        end
    end
end)
