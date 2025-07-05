local function now()
    return math.floor(Time.now() / 1000)
end

local COLLECTION_TIME = 3
local ticks = 0
local lastCheck = now()
local lastTps = 20

every(1, function()
    ticks = ticks + 1
end)

return function()
    local passed = now() - lastCheck
    if passed > COLLECTION_TIME then
        lastTps = ticks / passed
        ticks = 0
        lastCheck = now()
    end

    return lastTps
end
