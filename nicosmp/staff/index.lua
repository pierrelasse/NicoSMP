local this = {}

this.ADMIN = "!.staff.admin"

this.COLOR_TARGET = "#B6DCF2"
this.COLOR_MSG_GENERIC = "#99C8F0"
this.COLOR_MSG_YELLOW = "#DADF91"
this.COLOR_MSG_RED = "#EF8D8D"

---@param perm string|nil
---@param ... bukkit.components.Deserializable
function this.notify(perm, ...)
    local comp = bukkit.components.deserialize({ "§3[§bS§3] ", ... })
    for p in bukkit.playersLoop() do
        if p.hasPermission(perm or "!.staff") then
            bukkit.sendComponent(p, comp)
        end
    end
end

return this
