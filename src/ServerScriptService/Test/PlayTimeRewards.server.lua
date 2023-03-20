local ServerScriptService = game:GetService("ServerScriptService")
local PlayTimeRewards = require(ServerScriptService:WaitForChild("PlayTimeRewards"))
local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))

local plr = game:GetService("Players").PlayerAdded:Wait()

local function TableEqual(t1, t2)
    if #t1 ~= #t2 then
        return false
    end

    if #t1 == 0 then
        return true
    end

    for i = 1, #t1 do
        if t1[i] ~= t2[i] then
            return false
        end
    end

    return true
end


local function test1()
    DataStore2("playTimeRewards", plr):Set(nil)
    local playTimeRewards = PlayTimeRewards.new(plr)
    playTimeRewards:StartTimer()

	assert(playTimeRewards.lastDayPlayed == os.time(), "lastDayPlayed should be equal to " .. os.time() .. " but was equal to " .. playTimeRewards.lastDayPlayed)
	assert(playTimeRewards.timePlayedToday == 0, "timePlayedToday should be equal to 0 but was equal to " .. playTimeRewards.timePlayedToday)
    assert(TableEqual(playTimeRewards.nextRewards, {120, 300, 600, 900, 1_500, 2_400, 3_600, 5_400, 7_200, 10_800, 14_400, 18_000}), "nextRewards should be equal to ... but was equal to " .. tostring(playTimeRewards.nextRewards))
end


local function test2()
    DataStore2("playTimeRewards", plr):Set(nil)
	local playTimeRewards = PlayTimeRewards.new(plr)
    playTimeRewards.timePlayedToday = 100
    playTimeRewards:StartTimer()

	assert(playTimeRewards.lastDayPlayed == os.time(), "lastDayPlayed should be equal to " .. os.time() .. " but was equal to " .. playTimeRewards.lastDayPlayed)
	assert(playTimeRewards.timePlayedToday == 0, "timePlayedToday should be equal to 0 but was equal to " .. playTimeRewards.timePlayedToday)
	assert(TableEqual(playTimeRewards.nextRewards, {120, 300, 600, 900, 1_500, 2_400, 3_600, 5_400, 7_200, 10_800, 14_400, 18_000}), "nextRewards should be equal to ... but was equal to " .. tostring(playTimeRewards.nextRewards))
end


local function test3()
    DataStore2("playTimeRewards", plr):Set(nil)
	local playTimeRewards = PlayTimeRewards.new(plr)
    playTimeRewards.lastDayPlayed = os.time()
    playTimeRewards.timePlayedToday = 1000
    playTimeRewards:StartTimer()

	assert(playTimeRewards.lastDayPlayed == os.time(), "lastDayPlayed should be equal to " .. os.time() .. " but was equal to " .. playTimeRewards.lastDayPlayed)
	assert(playTimeRewards.timePlayedToday == 1000, "timePlayedToday should be equal to 1000 but was equal to " .. playTimeRewards.timePlayedToday)
	assert(TableEqual(playTimeRewards.nextRewards, {1_500, 2_400, 3_600, 5_400, 7_200, 10_800, 14_400, 18_000}), "nextRewards should be equal to ... but was equal to " .. tostring(playTimeRewards.nextRewards))
end


local function test4()
    DataStore2("playTimeRewards", plr):Set(nil)
	local playTimeRewards = PlayTimeRewards.new(plr)
    playTimeRewards.lastDayPlayed = os.time()
    playTimeRewards.timePlayedToday = 100_000
    playTimeRewards:StartTimer()

	assert(playTimeRewards.lastDayPlayed == os.time(), "lastDayPlayed should be equal to " .. os.time() .. " but was equal to " .. playTimeRewards.lastDayPlayed)
	assert(playTimeRewards.timePlayedToday == 100_000, "timePlayedToday should be equal to 1000 but was equal to " .. playTimeRewards.timePlayedToday)
	assert(TableEqual(playTimeRewards.nextRewards, {}), "nextRewards should be equal to ... but was equal to " .. tostring(playTimeRewards.nextRewards))
end


local function test5()
    DataStore2("playTimeRewards", plr):Set(nil)
	local playTimeRewards = PlayTimeRewards.new(plr)
    playTimeRewards.lastDayPlayed = 1
    playTimeRewards.timePlayedToday = 500
    print(playTimeRewards)
    playTimeRewards:StartTimer()

	assert(playTimeRewards.lastDayPlayed == os.time(), "lastDayPlayed should be equal to " .. os.time() .. " but was equal to " .. playTimeRewards.lastDayPlayed)
	assert(playTimeRewards.timePlayedToday == 0, "timePlayedToday should be equal to 0 but was equal to " .. playTimeRewards.timePlayedToday)
    print(playTimeRewards.nextRewards)
	assert(TableEqual(playTimeRewards.nextRewards, {120, 300, 600, 900, 1_500, 2_400, 3_600, 5_400, 7_200, 10_800, 14_400, 18_000}), "nextRewards should be equal to ... but was equal to " .. tostring(playTimeRewards.nextRewards))
end


local function test()
    test1()
    test2()
    test3()
	test4()
    test5()
	
	print("All tests passed !")
end

-- test()