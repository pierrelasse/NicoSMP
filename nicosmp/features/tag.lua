local Storage = require("@bukkit/Storage")


local this = {}
this.PREFIX = "§7["
this.SUFFIX = "§7]"
this.OPTIONS = {
    NICO = "§#6A31BFNICO",
    REDSTONE = "§#F441EEREDSTONE",
    Edgar = "§#FF7C35Edgar",
    Z = "§#6017C3Z",
    AFK = "§#60CDE8AFK",
    GRINDER = "§#44F855GRINDER",
    ZRX = "§#5DFC4CZRX",
    ShadwoCraft = "§#212121ShadwoCraft",
    GHG = "§#B137F7GHG",
    ZZZ = "§#A13AF8ZZZ",
    UDGR = "§#940B01UDGR",
    RJP = "§#4DA920RJP",
    ZAHIDE = "§cZAH1DE",
    TIGER = "§#FF7E00TIGER",
    GG = "§#FF2312GG",
    ii = "§dii",
    AfM = "§#30B322AfM",
    Lucifer = "§#FF3C16Lucifer",
    JKT = "§#131313JKT",
    JKC = "§#131313JKC",
    Dragons = "§#41F24DDragons",
    Haxe = "Haxe"
}

this.storage = Storage.new("nicosmp", "status")
this.storage:loadSave()

---@param playerId string
---@return string? id
function this.getStatus(playerId)
    local id = this.storage:get("status."..playerId)
    if this.OPTIONS[id] == nil then
        this.setStatus(playerId, nil)
        return
    end
    return id
end

---@param playerId string
---@return string? status
function this.getFormattedStatus(playerId)
    local id = this.getStatus(playerId)
    if id ~= nil then
        return this.PREFIX..this.OPTIONS[id]..this.SUFFIX
    end
end

---@param playerId string
---@param id string?
function this.setStatus(playerId, id)
    if id ~= nil and this.OPTIONS[id] == nil then return end
    this.storage:set("status."..playerId, id)
end

addCommand({ "status", "tag", "clantag" }, function(sender, args)
    if args[1] == nil then
        this.setStatus(bukkit.uuid(sender), nil)
        bukkit.send(sender, "§aStatus gelöscht!")
        return
    end

    if args[1] == "-top" then
        async(function()
            bukkit.send(sender, "§7Top tags:")

            local counter = {}

            for playerId in this.storage:loopKeys("status") do
                local status = this.storage:get("status."..playerId)
                counter[status] = (counter[status] or 0) + 1
            end

            local items = {}
            for k, v in pairs(counter) do
                table.insert(items, { k = k, v = v })
            end

            table.sort(items, function(a, b) return a.v > b.v end)

            local i = 0
            for _, item in ipairs(items) do
                i = i + 1
                local color
                if i > 3 then
                    color = "§7"
                elseif i == 3 then
                    color = "§#CD7F32"
                elseif i == 2 then
                    color = "§#C0C0C0"
                elseif i == 1 then
                    color = "§#FFD700"
                end
                bukkit.send(sender, color.." #"..i.." "..this.OPTIONS[item.k].."§8: §f"..item.v)
                if i == 10 then break end
            end
        end)
        return
    end

    local id = args[1]
    if this.OPTIONS[id] == nil then
        bukkit.send(sender,
                    "§cDieser Status existiert nicht!\n"..
                    "§6Du kannst einen Status mit §e/support Ich möchte gerne einen neuen status. \"<Name>\" in <farbe>§6 z.B.")
        return
    end
    this.setStatus(bukkit.uuid(sender), id)
    bukkit.send(sender, "§aStatus auf §2"..id.."§a geändert!")
end)
    .complete(function(completions, sender, args)
        if #args == 1 then
            completions.add("-top")
            for id in pairs(this.OPTIONS) do
                if args[1] == nil or id:lower():startsWith(args[1]:lower()) then
                    completions.add(id)
                end
            end
        end
    end)

return this
