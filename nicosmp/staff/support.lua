local Storage = require("@bukkit/Storage")
local staff = require("nicosmp/staff/index")
local formatSecondsDE = require("nicosmp/utils/formatSecondsDE")


local PERM = "!.staff.tickets"

---@class nicosmp.tickets.Id : string

---@alias nicosmp.tickets.state "WAITING"|"TAKEN"|nil

local this = {}

this.storage = Storage.new("nicosmp", "tickets")
this.storage:loadSave()


---@param id nicosmp.tickets.Id
function this.isTicketIdInUse(id)
    return this.storage:has("tickets."..id)
end

---@return nicosmp.tickets.Id?
function this.getNewTicketId()
    for _ = 1, 5 do
        local chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        local id = ""
        for _ = 1, 8 do
            id = id..chars:at(math.random(1, #chars))
        end
        if not this.isTicketIdInUse(id) then
            return id
        end
    end
end

---@param creator java.Object
---@param message string
---@return nicosmp.tickets.Id?
function this.createTicket(creator, message)
    local id = this.getNewTicketId()
    if id == nil then
        staff.notify(staff.ADMIN, "§cCould not generate ticket id")
        return
    end
    local path = "tickets."..id
    this.storage:set(path..".c", bukkit.uuid(creator))
    this.storage:set(path..".t", time.unix())
    this.storage:set(path..".m", message)
    this.storage:set(path..".s", "WAITING")
    return id
end

---@param id nicosmp.tickets.Id
function this.getTicketData(id)
    if id == nil or not this.isTicketIdInUse(id) then return end
    local path = "tickets."..id
    return {
        ---@type string
        creator = this.storage:get(path..".c"),
        ---@type number
        time = this.storage:get(path..".t"),
        ---@type string
        message = this.storage:get(path..".m"),
        ---@type nicosmp.tickets.state
        state = this.storage:get(path..".s")
    }
end

function this.getWaitingTickets()
    local list = makeList()
    for id in this.storage:loopKeys("tickets") do
        if this.storage:get("tickets."..id..".s") == "WAITING" then
            list.add(id)
        end
    end
    return list
end

function this.getCreator(ticket)
    return bukkit.offlinePlayerByUUID(bukkit.uuidFromString(ticket.creator))
end

function this.getCreatorOnline(ticket)
    local creator = this.getCreator(ticket)
    if creator ~= nil and creator.isOnline() then
        return creator
    end
end

function this.getCreatorName(ticket)
    local creator = this.getCreator(ticket)
    if creator == nil then return "???" end
    return creator.getName()
end

---@param id nicosmp.tickets.Id
function this.notifyNewTicket(id)
    local ticket = this.getTicketData(id)
    if ticket == nil then return end
    local comp = bukkit.components.deserialize({
        bukkit.hex("§3[§bS§3] §#4BE1F7Neues Ticket von §#70E9FB"..
            this.getCreatorName(ticket).."§#4BE1F7: §#87E5F3"..ticket.message),
        "\n",
        {
            text = " [Bearbeiten]",
            color = "#4F87EF",
            clickEvent = { action = "run_command", value = "/tickets take "..id },
            hoverEvent = { action = "show_text", value = { { text = "§eKlicke um dieses Ticket zu bearbeiten!" } } }
        },
        {
            text = " [Bearbeiten (S)]",
            color = "#5F84C9",
            clickEvent = { action = "run_command", value = "/tickets take-silent "..id },
            hoverEvent = { action = "show_text", value = { { text = "§eKlicke um dieses Ticket zu bearbeiten\n§eohne den Spieler zu benachrichtigen!" } } }
        },
        {
            text = " [Fertig]",
            color = "#5BEC92",
            clickEvent = { action = "run_command", value = "/tickets complete "..id },
            hoverEvent = { action = "show_text", value = { { text = "§eKlicke um dieses Ticket als\n§efertig markieren!" } } }
        }
    })
    for p in bukkit.playersLoop() do
        if p.hasPermission(PERM) then
            bukkit.sendComponent(p, comp)
        end
    end
end

function this.sendTicketOptions(player, id)
    local playerId = bukkit.uuid(player)

    local takenId = this.getTicketIdOfTaker(playerId)
    if id == nil then id = takenId end
    local isTaken = takenId == id

    local ticket = this.getTicketData(id)
    if ticket == nil then
        if id == nil then
            bukkit.send(player, "§cDu bearbeitest zurzeit kein Ticket!")
        else
            bukkit.send(player, "§cTicket nicht gefunden!")
        end
        return
    end
    local creator = this.getCreatorOnline(ticket)

    ---@type (string|table)[]
    local components = {
        "§aTicket §2#"..id.."§a von §2"..this.getCreatorName(ticket).."§a"..":\n",
        "§f  "..ticket.message.."\n"
    }

    if isTaken then
        components[#components + 1] = {
            text = " [Chat]",
            color = "#56ED84",
            clickEvent = { action = "suggest_command", value = "/tickets chat " },
            hoverEvent = { action = "show_text", value = { { text = "§eKlicke um zu Chatten!" } } }
        }
    else
        components[#components + 1] = {
            text = " [Bearbeiten]",
            color = "#4F87EF",
            clickEvent = { action = "run_command", value = "/tickets take "..id },
            hoverEvent = { action = "show_text", value = { { text = "§eKlicke um dieses Ticket zu bearbeiten!" } } }
        }
        components[#components + 1] = {
            text = " [Bearbeiten (S)]",
            color = "#5F84C9",
            clickEvent = { action = "run_command", value = "/tickets take-silent "..id },
            hoverEvent = { action = "show_text", value = { { text = "§eKlicke um dieses Ticket zu bearbeiten\n§eohne den Spieler zu benachrichtigen!" } } }
        }
    end

    components[#components + 1] = {
        text = " [Spec]",
        color = creator == nil and "#999B59" or "#EEF44B",
        clickEvent = creator ~= nil and { action = "run_command", value = "/spec "..creator.getName() } or nil,
        hoverEvent = {
            action = "show_text",
            value = {
                creator == nil
                and "§cDer ersteller des Tickets ist zurzeit nicht online!"
                or "§eKlicke um dieses Ticket als\n§efertig markieren!"
            }
        }
    }
    components[#components + 1] = {
        text = " [Fertig]",
        color = "#5BEC92",
        clickEvent = { action = "run_command", value = "/tickets complete "..id },
        hoverEvent = { action = "show_text", value = { { text = "§eKlicke um dieses Ticket als\n§ebearbeitet zu markieren!" } } }
    }
    components[#components + 1] = {
        text = " [Löschen]",
        color = "#C95F89",
        clickEvent = { action = "run_command", value = "/tickets delete "..id },
        hoverEvent = { action = "show_text", value = { { text = "§eKlicke um dieses Ticket zu löschen!" } } }
    }
    bukkit.sendComponent(player, bukkit.components.deserialize(components))
end

function this.sendCompleteOptions(player, id)
    local ticket = this.getTicketData(id)
    if ticket == nil then return end

    local components = {
        "§aTicket §2#"..id.."§a von §2"..this.getCreatorName(ticket).."§a"..":\n"
    }

    components[#components + 1] = {
        text = " [Löschen]",
        color = "#C95F89",
        clickEvent = { action = "run_command", value = "/tickets delete "..id },
        hoverEvent = { action = "show_text", value = { { text = "§eKlicke um dieses Ticket zu löschen!" } } }
    }
    bukkit.sendComponent(player, bukkit.components.deserialize(components))
end

---@param playerId string
---@return nicosmp.tickets.Id?
function this.getTicketIdOfTaker(playerId)
    for id in this.storage:loopKeys("tickets") do
        if  this.storage:get("tickets."..id..".s") == "TAKEN"
        and this.storage:get("tickets."..id..".ta") == playerId
        then
            return id
        end
    end
end

---@param id nicosmp.tickets.Id
function this.take(id, takerId)
    if this.isTicketIdInUse(id) and this.storage:get("tickets."..id..".s") == "WAITING" then
        this.storage:set("tickets."..id..".s", "TAKEN")
        this.storage:set("tickets."..id..".ta", takerId)
        return true
    end
end

---@param id nicosmp.tickets.Id
function this.delete(id)
    if this.isTicketIdInUse(id) then
        this.storage:set("tickets."..id, nil)
        return true
    end
end

function this.complete(id)
    if this.isTicketIdInUse(id) and this.storage:get("tickets."..id..".s") ~= nil then
        this.storage:set("tickets."..id..".s", nil)
        this.storage:set("tickets."..id..".ta", nil)
        return true
    end
end

addCommand("support", function(sender, args)
    local message = table.concat(args, " ")
    if #message == 0 then
        bukkit.send(sender, "§cUsage: /support <nachricht...>")
        return
    end

    local ticketId = this.createTicket(sender, message)
    if ticketId == nil then
        bukkit.send(sender, "§cEin unbekannter Feheler beim erstellen des Tickets ist aufgetreten!")
        return
    end

    this.notifyNewTicket(ticketId)

    bukkit.send(
        sender,
        "§aTicket erfolgreich erstellt! §7(ID: #"..ticketId..")\n"..
        "§#A4F691Bitte habe einen Moment gedult bis ein Team-Mitglied sich um dich kümmert.\n"..
        "§#9CCF90Du kannst auch optional ein Ticket auf dem /discord erstellen."
    )
end)
    .complete(function(completions, sender, args)
        if #args == 0 then
            completions.add("<deine nachricht ans team>")
        end
    end)

addCommand("tickets", function(sender, args)
    if args[1] == nil then
        local waitingTickets = this.getWaitingTickets()
        if waitingTickets.size() == 0 then
            bukkit.send(sender, "§aEs gibt keine offene Tickets!")
            return
        end
        bukkit.send(sender, "§7Offene Tickets:")
        for id in forEach(waitingTickets) do
            local ticket = this.getTicketData(id)
            if ticket == nil then goto continue end

            local now = time.unix()
            local ago = now - ticket.time

            bukkit.sendComponent(sender, bukkit.components.deserialize({
                {
                    text = "§8 #"..id.." "..formatSecondsDE(ago, "§b", "§3").." §7"
                        ..this.getCreatorName(ticket)
                        .."§r: "..ticket.message,
                    clickEvent = { action = "run_command", value = "/tickets info "..id },
                    hoverEvent = { action = "show_text", value = { { text = "§eKlicke für die Ticket Optionen!" } } }
                }
            }))

            ::continue::
        end
        return
    end

    if args[1] == "list" then
        bukkit.send(sender, "§7Tickets:")
        return
    end

    if args[1] == "chat" then
        local playerId = bukkit.uuid(sender)
        local takenId = this.getTicketIdOfTaker(playerId)

        if takenId == nil then
            bukkit.send(sender, "§cDu bearbeitest zurzeit kein Ticket!")
            return
        end

        local ticket = this.getTicketData(takenId)
        local creator = this.getCreatorOnline(ticket)

        if creator == nil then
            bukkit.send(sender, "§cDer Ersteller des Tickets ist zurzeit nicht online!")
            return
        end

        local message = table.concat(args, " ", 2)
        if #message == 0 then
            bukkit.send(sender, "§cBitte gib eine Nachricht an!")
            return
        end

        bukkit.send(creator, "\n§#5331FF§l[Support] §#8AC3EF"..message.."\n")
        bukkit.sendComponent(sender, bukkit.components.deserialize({
            {
                text = "[Support]",
                color = "#5331FF",
                bold = true,
                clickEvent = { action = "run_command", value = "/tickets info "..takenId },
                hoverEvent = { action = "show_text", value = { { text = "§eKlicke für Ticket Optionen!" } } }
            },
            " ",
            {
                text = message,
                color = "#8AC3EF"
            }
        }))
        return
    end

    if args[1] == "untake" then
        local playerId = bukkit.uuid(sender)
        local id = this.getTicketIdOfTaker(playerId)
        if id == nil then
            bukkit.send(sender, "§cDu bearbeitest zurzeit kein Ticket!")
            return
        end

        local ticket = this.getTicketData(id)
        if ticket == nil then return end

        staff.notify(
            PERM,
            {
                color = "#5FC9AF",
                text = sender.getName()
            },
            {
                color = "#DECD9A",
                text = " bearbetet nun nicht mehr das Ticket von "..this.getCreatorName(ticket)
            }
        )

        this.sendTicketOptions(sender, id)

        local creator = this.getCreatorOnline(ticket)
        if creator ~= nil then
            bukkit.send(creator, "\n§#D4E564Dein Ticket wird nicht mehr bearbeitet!\n")
        end
        return
    end

    local id = args[2]

    if args[1] == "info" then
        this.sendTicketOptions(sender, id)
        return
    end

    local ticket = this.getTicketData(id)
    if ticket == nil then
        bukkit.send(sender, "§cInvalides Ticket")
        return
    end

    if args[1] == "take" then
        local playerId = bukkit.uuid(sender)
        do
            local tid = this.getTicketIdOfTaker(playerId)
            if tid ~= nil then
                this.sendTicketOptions(sender, tid)
                return
            end
        end

        if not this.take(id, playerId) then return end

        staff.notify(
            PERM,
            {
                color = "#5FC9AF",
                text = sender.getName()
            },
            {
                color = "#5DF4EB",
                text = " bearbetet nun das Ticket von "..this.getCreatorName(ticket)
            }
        )

        this.sendTicketOptions(sender, id)

        local creator = this.getCreatorOnline(ticket)
        if creator ~= nil then
            bukkit.send(creator, "\n§#42E942Dein Ticket wird nun bearbeitet! Nachricht:\n§r"..ticket.message.."\n")
        end
        return
    end
    if args[1] == "take-silent" then
        local playerId = bukkit.uuid(sender)
        do
            local tid = this.getTicketIdOfTaker(playerId)
            if tid ~= nil then
                this.sendTicketOptions(sender, tid)
                return
            end
        end
        if not this.take(id, playerId) then return end

        staff.notify(
            PERM,
            {
                color = "#5FC9AF",
                text = sender.getName()
            },
            {
                color = "#5DF4EB",
                text = " bearbetet nun das Ticket von "..this.getCreatorName(ticket)
            }
        )
        return
    end

    if args[1] == "complete" then
        if not this.complete(id) then return end

        local creatorName = this.getCreatorName(ticket)
        staff.notify(
            PERM,
            {
                color = "#5FC9AF",
                text = sender.getName()
            },
            {
                color = "#AA7DC1",
                text = " hat das Ticket von "..creatorName.." als bearbeitet markiert"
            }
        )

        this.sendCompleteOptions(sender, id)
        return
    end

    if args[1] == "delete" then
        if not this.delete(id) then return end

        local creatorName = this.getCreatorName(ticket)
        staff.notify(
            PERM,
            {
                color = "#5FC9AF",
                text = sender.getName()
            },
            {
                color = "#F45D92",
                text = " hat das Ticket von "..creatorName.." gelöscht"
            }
        )
        return
    end

    bukkit.send(sender, "§cSub-Command nicht gefunden")
end)
    .permission("!.staff.tickets")
    .complete(function(completions, sender, args)
        if #args == 1 then
            completions.add("take")
            completions.add("take-silent")
            completions.add("complete")
            completions.add("delete")
            completions.add("info")
            completions.add("chat")
        elseif #args == 2 then
            if args[1] == "take"
            or args[1] == "take-silent"
            or args[1] == "complete"
            or args[1] == "delete"
            or args[1] == "info"
            then
                for id in this.storage:loopKeys("tickets") do
                    completions.add(id)
                end
            end
        end
    end)

return this
