local ScriptStoppingEvent = import("net.bluept.scripting.ScriptStoppingEvent")
local Color = import("org.bukkit.Color")
local Statistic = import("org.bukkit.Statistic")
local Display_Billboard = import("org.bukkit.entity.Display$Billboard")


---@param ticks number
---@return string
local function formatPlaytime(ticks)
    local totalSeconds = ticks / 20
    local minutes = math.floor(totalSeconds / 60)
    local hours = math.floor(minutes / 60)
    local days = math.floor(hours / 24)
    minutes = minutes % 60
    hours = hours % 24
    local result = ""
    if days > 0 then result = result..days.."§#A52AB7t.§#E010FF " end
    if hours > 0 then result = result..hours.."§#A52AB7std.§#E010FF " end
    if minutes > 0 then result = result..minutes.."§#A52AB7min.§#E010FF " end
    if result == "" then result = result.."§80min." end
    return result
end

local this = {
    ---@type table<integer, { entity: JavaObject, update: fun()|nil }>
    boards = {}
}

function this.new(location)
    local id = #this.boards + 1

    local board = {
        ---@type JavaObject
        entity = nil,
        ---@type fun()|nil
        update = nil
    }

    board.entity = bukkit.spawn(location, "TEXT_DISPLAY")
    board.entity.addScoreboardTag("temp")
    board.entity.setBackgroundColor(Color.fromARGB(0, 0, 0, 0))

    this.boards[id] = board
    return board
end

function this.setupBoards()
    addEvent(ScriptStoppingEvent, function()
        if this.boards == nil then
            print("§eZEROOOOOOO SINN")
        else
            for _, board in ipairs(this.boards) do
                if board.entity ~= nil then
                    board.entity.remove()
                end
            end
            this.boards = nil
        end

        if this.updating then
            print("§eleaderboards updating!")
        end
    end)

    ---@param x number
    ---@param y number
    ---@param z number
    ---@param title string
    ---@param formatValueCb fun(f: number): string
    local function createSimpleBoard(x, y, z, title, formatValueCb)
        local board = this.new(bukkit.location4(bukkit.defaultWorld(), x, y, z))
        board.entity.setBillboard(Display_Billboard.VERTICAL)

        ---@param data { [1]: integer, [2]: string }[]
        return function(data)
            local text = "§#BB36F9§l§n"..title

            local slotsLeft = 10
            for _, entry in ipairs(data) do
                text = text.."\n§#EFDEF4"..entry[2].."§#DEB4C6: §#E010FF"..formatValueCb(entry[1])

                slotsLeft = slotsLeft - 1
                if slotsLeft == 0 then break end
            end

            board.entity.setText(bukkit.hex(text))
        end
    end


    local u_playtime = createSimpleBoard(1.5, 197.5, -197.5, "Top Spielzeit", formatPlaytime)
    local u_kills = createSimpleBoard(-11.5, 197, -199.5, "Top Kills", tostring)
    local u_deaths = createSimpleBoard(-12.5, 197, -209.5, "Top Tode", tostring)

    function this.update()
        if this.updating then
            print("  §calready updating leaderboards!")
            return
        end
        this.updating = true

        async(function()
            ---@type { [1]: integer, [2]: string }[]
            local d_playtime = {}
            ---@type { [1]: integer, [2]: string }[]
            local d_kills = {}
            ---@type { [1]: integer, [2]: string }[]
            local d_deaths = {}

            for player in bukkit.offlinePlayersLoop() do
                if this.boards == nil then return end

                local name = player.getName()

                do -- playtime
                    local value = player.getStatistic(Statistic.PLAY_ONE_MINUTE)
                    d_playtime[#d_playtime + 1] = { value, name }
                end

                if name == "pierrelasse"
                or name == "No1KnowsMyName_"
                or name == "BluePT"
                then
                    goto continue
                end

                do -- kills
                    local value = player.getStatistic(Statistic.PLAYER_KILLS)
                    d_kills[#d_kills + 1] = { value, name }
                end
                do -- deaths
                    local value = player.getStatistic(Statistic.DEATHS)
                    d_deaths[#d_deaths + 1] = { value, name }
                end

                ::continue::
            end

            if this.boards == nil then return end

            table.sort(d_playtime, function(a, b) return a[1] > b[1] end)
            table.sort(d_kills, function(a, b) return a[1] > b[1] end)
            table.sort(d_deaths, function(a, b) return a[1] > b[1] end)

            wait(0, function()
                if this.boards == nil then return end

                u_playtime(d_playtime)
                u_kills(d_kills)
                u_deaths(d_deaths)
            end)

            this.updating = nil
        end)
    end
end

wait(10, function()
    this.setupBoards()
    every(20 * 60, this.update)
end)

return this
