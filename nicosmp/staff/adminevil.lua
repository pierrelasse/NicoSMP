local this = {}

---@type string?
this.name = nil

this.PREFIX = "§4§lOWNER | "
this.NAME = "AdminEvil"

addCommand("adminevil", function(sender, args)
    if args[1] == nil then
        this.name = nil
        bukkit.send(sender, "§aCleared!")
        return
    end
    local target = bukkit.getPlayer(args[1])
    if target == nil then
        bukkit.send(sender, "§cPlayer not found!")
        return
    end

    this.name = target.getName()
    bukkit.send(sender, "§aSet!")
end)
    .permission("!.staff.adminevil")

return this
