local ServerScriptService = game:GetService("ServerScriptService")
local RebirthModule = require(ServerScriptService:WaitForChild("RebirthModule"))
local PlayerModule = require(ServerScriptService:WaitForChild("Player"))
local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))

local plr = game:GetService("Players").PlayerAdded:Wait()


local function testNewRebirthModule()
    DataStore2("rebirth", plr):Set(nil)
    local rebirthModule : RebirthModule.RebirthModule = RebirthModule.new(plr)
    rebirthModule:UpdateFollowersNeededToRebirth()

    assert(rebirthModule.rebirthLevel == 0, "rebirth level should be 0 but was " .. rebirthModule.rebirthLevel)
    assert(rebirthModule.followersMultiplier == 0, "rebirth follower multiplier should be 0 but was " .. rebirthModule.followersMultiplier)
    assert(rebirthModule.followersNeededToRebirth == 100, "rebirth followers needed to rebirth should be 100 but was " .. rebirthModule.followersNeededToRebirth)
end


local function testUpdateFollowersNeededToRebirthUnder100()
    DataStore2("rebirth", plr):Set(nil)
    local rebirthModule : RebirthModule.RebirthModule = RebirthModule.new(plr)
    rebirthModule:UpdateFollowersNeededToRebirth()

    rebirthModule.rebirthLevel = 50
    assert(rebirthModule.rebirthLevel == 50, "rebirth level should be 50 but was " .. rebirthModule.rebirthLevel)
    assert(rebirthModule.followersMultiplier == 0, "rebirth follower multiplier should be 0 but was " .. rebirthModule.followersMultiplier)

    rebirthModule:UpdateFollowersNeededToRebirth()

    assert(rebirthModule.followersNeededToRebirth == 1802000, "rebirth followers needed to rebirth should be 1802000 but was " .. rebirthModule.followersNeededToRebirth)
end


local function testUpdateFollowersNeededToRebirthOver100()
    DataStore2("rebirth", plr):Set(nil)
    local rebirthModule : RebirthModule.RebirthModule = RebirthModule.new(plr)
    rebirthModule:UpdateFollowersNeededToRebirth()

    rebirthModule.rebirthLevel = 150
    assert(rebirthModule.rebirthLevel == 150, "rebirth level should be 150 but was " .. rebirthModule.rebirthLevel)
    assert(rebirthModule.followersMultiplier == 0, "rebirth follower multiplier should be 0 but was " .. rebirthModule.followersMultiplier)

    rebirthModule:UpdateFollowersNeededToRebirth()
    assert(rebirthModule.followersNeededToRebirth == 113090000, "rebirth followers needed to rebirth should be 113090000 but was " .. rebirthModule.followersNeededToRebirth)
end


local function testRebirth()
    DataStore2("rebirth", plr):Set(nil)
    local rebirthModule : RebirthModule.RebirthModule = RebirthModule.new(plr)
    rebirthModule:UpdateFollowersNeededToRebirth()

    assert(rebirthModule.followersNeededToRebirth == 100, "rebirth followers needed to rebirth should be 100 but was " .. rebirthModule.followersNeededToRebirth)

    local rebirth : boolean = rebirthModule:Rebirth(50)
    assert(not rebirth, "rebirth should have been false but was true")
    assert(rebirthModule.rebirthLevel == 0, "rebirth level should be 0 but was " .. rebirthModule.rebirthLevel)
    assert(rebirthModule.followersMultiplier == 0, "rebirth follower multiplier should be 0 but was " .. rebirthModule.followersMultiplier)
    assert(rebirthModule.followersNeededToRebirth == 100, "rebirth followers needed to rebirth should be 100 but was " .. rebirthModule.followersNeededToRebirth)

    local rebirth : boolean = rebirthModule:Rebirth(150)
    assert(rebirth, "rebirth should have been true but was false")
    assert(rebirthModule.rebirthLevel == 1, "rebirth level should be 1 but was " .. rebirthModule.rebirthLevel)
    assert(rebirthModule.followersMultiplier == 0.1, "rebirth follower multiplier should be 0.1 but was " .. rebirthModule.followersMultiplier)
    assert(rebirthModule.followersNeededToRebirth == 225, "rebirth followers needed to rebirth should be 225 but was " .. rebirthModule.followersNeededToRebirth)
end


local function test()
    testNewRebirthModule()
    testUpdateFollowersNeededToRebirthUnder100()
    testUpdateFollowersNeededToRebirthOver100()
    testRebirth()

    print("All tests passed!")
end

test()