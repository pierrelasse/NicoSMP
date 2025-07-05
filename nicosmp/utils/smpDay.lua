local START = 1741453200

return function()
    local nowSeconds = math.floor(Time.now() / 1000)
    local passedSeconds = nowSeconds - START
    return math.ceil(passedSeconds / 86400) + 1
end
