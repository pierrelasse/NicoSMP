local ScriptStoppingEvent = classFor("net.bluept.scripting.ScriptStoppingEvent")
local Display_Billboard = classFor("org.bukkit.entity.Display$Billboard")
local Transformation = classFor("org.bukkit.util.Transformation")
local AxisAngle4f = classFor("org.joml.AxisAngle4f")
local Vector3f = classFor("org.joml.Vector3f")



local entities = {}

local function create(commandName, text, permission)
    ---@type table<string, true>
    local active = {}
    addCommand(commandName, function(sender, args)
        local playerId = sender.getUniqueId().toString()
        if active[playerId] ~= nil then
            active[playerId] = nil
            bukkit.send(sender, "§aAnzeige deaktiviert")
            return
        end
        active[playerId] = true

        local function spawnOne()
            local loc = sender.getLocation()

            local entity = bukkit.spawn(
                bukkit.location4(
                    loc.getWorld(),
                    loc.getX() + math.random(-1, 1),
                    loc.getY() - 0.5,
                    loc.getZ() + math.random(-1, 1)
                ),
                "TEXT_DISPLAY"
            )

            entity.addScoreboardTag("temp")
            entity.addScoreboardTag("staffdisplay")
            entity.setText(bukkit.hex(text))
            entity.setBillboard(Display_Billboard.VERTICAL)

            table.insert(entities, entity)

            wait(1, function()
                entity.setInterpolationDelay(-1)
                entity.setInterpolationDuration(40)
                entity.setTransformation(Transformation(
                    Vector3f(0, 3, 0), -- transformation
                    AxisAngle4f(),     -- left rotation
                    Vector3f(1),       -- scale
                    AxisAngle4f()      -- right rotation
                ))
            end)

            return entity
        end

        local function launch()
            local offset = 0
            local entity = spawnOne()

            local function run()
                offset = offset + 1

                if offset > 40 or active[playerId] == nil or not sender.isOnline() then
                    entity.remove()
                    table.remove(entities, table.key(entities, entity))
                    if active[playerId] ~= nil then
                        wait(1, launch)
                    end
                    return
                end
                wait(1, run)
            end

            wait(1, run)
        end

        for _ = 1, 6 do
            wait(math.random(1, 15), launch)
        end

        bukkit.send(sender, "§aAnzeige aktiviert")
    end)
        .permission(permission)
end

create("admindisplay", "§#FE122E§l§nADMINISTRATION", "!.staff.display.admin")
create("moddisplay", "§#12B024§l§nMODERATION", "!.staff.display.mod")

addEvent(ScriptStoppingEvent, function()
    for _, entity in ipairs(entities) do
        entity.remove()
    end
end)
