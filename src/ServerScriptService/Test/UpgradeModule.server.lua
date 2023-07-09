local ServerScriptService = game:GetService("ServerScriptService")
local UpgradeModule = require(ServerScriptService:WaitForChild("UpgradeModule"))
local PlayerModule = require(ServerScriptService:WaitForChild("Player"))
local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))

local plr = game:GetService("Players").PlayerAdded:Wait()


local function TableEqual(t1, t2)
    if not t1 or not t2 or typeof(t1) ~= "table" or typeof(t2) ~= "table" then
        return false
    end

    if #t1 ~= #t2 then
        return false
    end

    for i,_ in pairs(t1) do
        if typeof(t1[i]) == "table" then
            if not TableEqual(t1[i], t2[i]) then
                return false
            end
        else
            if t1[i] ~= t2[i] then
                warn(tostring(t1[i]) .. " is not equal to " .. tostring(t2[i]))
                warn(t1)
                warn(t2)
                return false
            end
        end
    end

    return true
end


local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end


local numberOfUpgrades : number = 4


local function testDefaultUpgrades()
    DataStore2("upgrades", plr):Set(nil)
    local upgradeModule : UpgradeModule.UpgradeModule = UpgradeModule.new(plr)

    assert(#upgradeModule.upgrades == numberOfUpgrades, "upgrades table should have " .. numberOfUpgrades .. " elements but has " .. #upgradeModule.upgrades)

    for i : number, upgrade : UpgradeModule.upgrade in pairs(upgradeModule.upgrades) do
        assert(upgrade.id == i, "upgrade id should be equal to " .. i .. " but was equal to " .. upgrade.id)
        assert(upgrade.level == 1, "upgrade id should be equal to 1 but was equal to " .. upgrade.level)
    end
end


local function testCanUpgradeDefault()
    DataStore2("upgrades", plr):Set(nil)
    local upgradeModule : UpgradeModule.UpgradeModule = UpgradeModule.new(plr)

    assert(upgradeModule:CanUpgrade(upgradeModule.upgrades[2], 2) == true, "testCanUpgrade should be true but was false")
end


local function testCanUpgradeLevel5()
    DataStore2("upgrades", plr):Set(nil)
    local upgradeModule : UpgradeModule.UpgradeModule = UpgradeModule.new(plr)

    upgradeModule.upgrades[2].level = 5

    assert(upgradeModule:CanUpgrade(upgradeModule.upgrades[2], 2) == true, "testCanUpgrade should be true but was false")
end


local function testCanUpgradeLevelMaxMinusOne()
    DataStore2("upgrades", plr):Set(nil)
    local upgradeModule : UpgradeModule.UpgradeModule = UpgradeModule.new(plr)

    upgradeModule.upgrades[2].level = 9

    assert(upgradeModule:CanUpgrade(upgradeModule.upgrades[2], 2) == true, "testCanUpgrade should be true but was false")
end


local function testCanUpgradeMaxLevel()
    DataStore2("upgrades", plr):Set(nil)
    local upgradeModule : UpgradeModule.UpgradeModule = UpgradeModule.new(plr)

    upgradeModule.upgrades[2].level = upgradeModule.upgrades[2].maxLevel

    assert(upgradeModule:CanUpgrade(upgradeModule.upgrades[2], 2) == false, "testCanUpgrade should be false but was true")
end


local function testUpgradeFirstFire()
    DataStore2("upgrades", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)

    local equalTo : {UpgradeModule.upgrade} = deepCopy(playerModule.upgradeModule.upgrades)

    local result : {UpgradeModule.upgrade} | UpgradeModule.upgrade | nil = playerModule.upgradeModule:Upgrade(playerModule, 1)

    assert(TableEqual(playerModule.upgradeModule.upgrades, equalTo) == true, "testUpgradeFirstFire modified the default table")
    assert(TableEqual(result, equalTo) == true, "testUpgradeFirstFire didn't return the right table")
end


local function testUpgradeMaxLevel()
    DataStore2("upgrades", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)

    playerModule.upgradeModule.firstFire = nil
    playerModule.upgradeModule.upgrades[1].level = playerModule.upgradeModule.upgrades[1].maxLevel
    local equalTo : {UpgradeModule.upgrade} = deepCopy(playerModule.upgradeModule.upgrades)

    local result : {UpgradeModule.upgrade} | UpgradeModule.upgrade | nil = playerModule.upgradeModule:Upgrade(playerModule, 1)

    assert(TableEqual(playerModule.upgradeModule.upgrades, equalTo) == true, "testupgrademaxlevel modified the default table")
    assert(result == nil, "testUpgradeMaxLevel should be nil but was equal to " .. tostring(result))
end


local function testUpgradeNotEnoughCoins()
    DataStore2("upgrades", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)

    playerModule.upgradeModule.firstFire = nil
    playerModule.coins = 0
    local equalTo : {UpgradeModule.upgrade} = deepCopy(playerModule.upgradeModule.upgrades)

    local result : {UpgradeModule.upgrade} | UpgradeModule.upgrade | nil = playerModule.upgradeModule:Upgrade(playerModule, 1)

    assert(TableEqual(playerModule.upgradeModule.upgrades, equalTo) == true, "testUpgradeNotEnoughCoins modified the default table ")
    assert(result == nil, "testUpgradeNotEnoughCoins should be nil but was equal to " .. tostring(result))
end


local function testUpgrade2()
    DataStore2("upgrades", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)

    playerModule.upgradeModule.firstFire = nil
    playerModule.coins = 1_000_000

    local equalTo : {UpgradeModule.upgrade} = deepCopy(playerModule.upgradeModule.upgrades)
    equalTo[2].level += 1
    
    local result : {UpgradeModule.upgrade} | UpgradeModule.upgrade | nil = playerModule.upgradeModule:Upgrade(playerModule, 2)

    assert(TableEqual(playerModule.upgradeModule.upgrades, equalTo) == true, "testUpgrade2 didn't modify the table as expected")
    assert(TableEqual(result, equalTo[2]) == true, "test upgrade 2 didn't return the right table")
    assert(playerModule.coins == 1_000_000 - playerModule.upgradeModule.upgrades[2].costs[2])
    assert(TableEqual(DataStore2("upgrades", plr):Get(nil), equalTo) == true, "saved data does not match the table (data didn't save properly)")
end


local function testGetUpgradeWithId()
    DataStore2("upgrades", plr):Set(nil)
    local upgradeModule : UpgradeModule.UpgradeModule = UpgradeModule.new(plr)

    assert(TableEqual(upgradeModule:GetUpgradeWithId(2), upgradeModule.upgrades[2]) == true, "testGetUpgradeWithId(2) didn't return the right table")
end


local function testApplyUpgrade1()
    DataStore2("upgrades", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)

    if not plr.Character then
		plr.CharacterAdded:Wait()
	end
    
    playerModule.upgradeModule.upgrades[1].level = 5

    playerModule.upgradeModule:ApplyUpgrade(playerModule, playerModule.upgradeModule.upgrades[1])

    assert(plr.Character.Humanoid.WalkSpeed == 24, "player's walkspeed should be 24 but was " .. plr.Character.Humanoid.WalkSpeed)
end


local function testApplyUpgrade2()
    DataStore2("upgrades", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    
    playerModule.upgradeModule.upgrades[2].level = 5

    playerModule.upgradeModule:ApplyUpgrade(playerModule, playerModule.upgradeModule.upgrades[2])

    assert(playerModule.postModule.autoPostInterval == 2800, "player's autoPostInterval should be equal to 2800 but was equal to " .. playerModule.postModule.autoPostInterval)
end


local function testApplyUpgrade3()
    DataStore2("upgrades", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    
    playerModule.upgradeModule.upgrades[3].level = 9

    playerModule.gamepassModule.boughtFollowersMultiplier = false
    playerModule.upgradeModule:ApplyUpgrade(playerModule, playerModule.upgradeModule.upgrades[3])

    assert(playerModule.upgradeModule.followersMultiplier == 0.8, "player's followersMultiplier should be equal to 0.8 but was equal to " .. playerModule.upgradeModule.followersMultiplier)
end


local function testApplyUpgrade4()
    DataStore2("upgrades", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    
    playerModule.gamepassModule.boughtCoinsMultiplier = false
    playerModule.upgradeModule:ApplyUpgrade(playerModule, playerModule.upgradeModule.upgrades[4])

    assert(playerModule.upgradeModule.coinsMultiplier == 0, "player's coinsMultiplier should be equal to 0 but was equal to " .. playerModule.upgradeModule.coinsMultiplier)
end


local function testApplyUpgrades()
    DataStore2("upgrades", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)

    if not plr.Character then
		plr.CharacterAdded:Wait()
	end
    
    playerModule.upgradeModule.upgrades[1].level = 5
    playerModule.upgradeModule.upgrades[2].level = 5
    playerModule.upgradeModule.upgrades[3].level = 9

    playerModule.gamepassModule.boughtCoinsMultiplier = false
    playerModule.gamepassModule.boughtFollowersMultiplier = false
    playerModule.upgradeModule:ApplyUpgrades(playerModule)

    assert(plr.Character.Humanoid.WalkSpeed == 24, "player's walkspeed should be 24 but was " .. plr.Character.Humanoid.WalkSpeed)
    assert(playerModule.postModule.autoPostInterval == 2800, "player's autoPostInterval should be equal to 2800 but was equal to " .. playerModule.postModule.autoPostInterval)
    assert(playerModule.upgradeModule.followersMultiplier == 0.8, "player's followersMultiplier should be equal to 0.8 but was equal to " .. playerModule.upgradeModule.followersMultiplier)
    assert(playerModule.upgradeModule.coinsMultiplier == 0, "player's coinsMultiplier should be equal to 0 but was equal to " .. playerModule.upgradeModule.coinsMultiplier)
end


local function test()
    testDefaultUpgrades()
    testCanUpgradeDefault()
    testCanUpgradeLevel5()
    testCanUpgradeLevelMaxMinusOne()
    testCanUpgradeMaxLevel()
    testUpgradeFirstFire()
    testUpgradeMaxLevel()
    testUpgradeNotEnoughCoins()
    testUpgrade2()
    testGetUpgradeWithId()
    testApplyUpgrade1()
    testApplyUpgrade2()
    testApplyUpgrade3()
    testApplyUpgrade4()
    testApplyUpgrades()

    print("All tests passed !")
end

test()