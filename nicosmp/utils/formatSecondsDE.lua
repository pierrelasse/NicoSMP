return function(secs, primaryColor, secondaryColor)
    if primaryColor == nil then primaryColor = "" end
    if secondaryColor == nil then secondaryColor = "" end
    if secs == nil then return primaryColor.."0"..secondaryColor.."sek." end

    local years = math.floor(secs / 31536000)
    local days = math.floor((secs % 31536000) / 86400)
    local hours = math.floor((secs % 86400) / 3600)
    local minutes = math.floor((secs % 3600) / 60)
    local seconds = secs % 60

    local parts = {}
    if years > 0 then table.insert(parts, string.format(primaryColor.."%d"..secondaryColor.."jahr", years)) end
    if days > 0 then table.insert(parts, string.format(primaryColor.."%d"..secondaryColor.."t.", days)) end
    if hours > 0 then table.insert(parts, string.format(primaryColor.."%d"..secondaryColor.."std.", hours)) end
    if minutes > 0 then table.insert(parts, string.format(primaryColor.."%d"..secondaryColor.."min.", minutes)) end
    if seconds > 0 or #parts == 0 then
        table.insert(parts,
                     string.format(primaryColor.."%d"..secondaryColor.."sek.", seconds))
    end

    return table.concat(parts, " ")
end
