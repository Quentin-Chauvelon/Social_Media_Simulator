local ServerScriptService = game:GetService("ServerScriptService")
local PotionModule = require(ServerScriptService:WaitForChild("PotionModule"))
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
                return false
            end
        end
    end

    return true
end


-- checks if two potion tables are equal
local function PotionTableContentEqual(t1 : {PotionModule.potion}, t2 : {PotionModule.potion})
    if #t1 == 0 and #t2 == 0 then
        return true
    end

    if #t1 ~= #t2 then
        return false
    end

    for _,potion : PotionModule.potion in pairs(t1) do
        local matchingPotion : boolean = false

        for _,potion2 : PotionModule.potion in pairs(t2) do
            if (potion.type == potion2.type) and (potion.value == potion2.value) and (potion.duration == potion2.duration) and (potion.timeLeft == potion2.timeLeft) then
                matchingPotion = true
            end
        end

        if not matchingPotion then
            return false
        end
    end

    return true
end


local function testPotionModuleNew()
    DataStore2("potions", plr):Set(nil)
    local potionModule : PotionModule.PotionModule = PotionModule.new(plr)

    assert(PotionTableContentEqual(potionModule.activePotions, {}) == true)
    assert(potionModule.potionsTimeLeft == nil, potionModule.potionsTimeLeft)
    assert(potionModule.followersMultiplier == 0, potionModule.followersMultiplier)
    assert(potionModule.coinsMultiplier == 0, potionModule.coinsMultiplier)
    assert(potionModule.speedBoost == 0, potionModule.speedBoost)
end


local function testCreatePotion()
    DataStore2("potions", plr):Set(nil)
    local potionModule : PotionModule.PotionModule = PotionModule.new(plr)
    
    local potion : PotionModule.potion = potionModule:CreatePotion(potionModule.potionTypes.Coins, 3, 10)
    assert(potion.type == potionModule.potionTypes.Coins, potion.type)
    assert(potion.value == 3, potion.value)
    assert(potion.duration == 10, potion.duration)
    assert(potion.timeLeft == 10, potion.timeLeft)
end


local function testUseFollowersPotion()
    DataStore2("potions", plr):Set(nil)
    DataStore2("upgrades", plr):Set(nil)
    DataStore2("rebirth", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)

    local potion : PotionModule.potion = playerModule.potionModule:CreatePotion(playerModule.potionModule.potionTypes.Followers, 3, 10)
    assert(potion.type == playerModule.potionModule.potionTypes.Followers, potion.type)
    assert(potion.value == 3, potion.value)
    assert(potion.duration == 10, potion.duration)
    assert(potion.timeLeft == 10, potion.timeLeft)

    playerModule.potionModule:UsePotion(potion, playerModule)
    assert(PotionTableContentEqual(playerModule.potionModule.activePotions, {{type = playerModule.potionModule.potionTypes.Followers, value = 3, duration = 10, timeLeft = 10}}))
    assert(playerModule.followersMultiplier == 3, playerModule.followersMultiplier)

    assert(PotionTableContentEqual(DataStore2("potions", plr):Get({}), {{type = playerModule.potionModule.potionTypes.Followers, value = 3, duration = 10, timeLeft = 10}}))
end


local function testUseCoinsPotion()
    DataStore2("potions", plr):Set(nil)
    DataStore2("upgrades", plr):Set(nil)
    DataStore2("rebirth", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)

    local potion : PotionModule.potion = playerModule.potionModule:CreatePotion(playerModule.potionModule.potionTypes.Coins, 3, 10)
    assert(potion.type == playerModule.potionModule.potionTypes.Coins, potion.type)
    assert(potion.value == 3, potion.value)
    assert(potion.duration == 10, potion.duration)
    assert(potion.timeLeft == 10, potion.timeLeft)

    playerModule.potionModule:UsePotion(potion, playerModule)
    assert(PotionTableContentEqual(playerModule.potionModule.activePotions, {{type = playerModule.potionModule.potionTypes.Coins, value = 3, duration = 10, timeLeft = 10}}))
    assert(playerModule.coinsMultiplier == 3, playerModule.coinsMultiplier)

    assert(PotionTableContentEqual(DataStore2("potions", plr):Get({}), {{type = playerModule.potionModule.potionTypes.Coins, value = 3, duration = 10, timeLeft = 10}}))
end


local function testUseAutoPostPotion()
    DataStore2("potions", plr):Set(nil)
    DataStore2("upgrades", plr):Set(nil)
    DataStore2("cases", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)

    local potion : PotionModule.potion = playerModule.potionModule:CreatePotion(playerModule.potionModule.potionTypes.AutoPostSpeed, 500, 10)
    assert(potion.type == playerModule.potionModule.potionTypes.AutoPostSpeed, potion.type)
    assert(potion.value == 500, potion.value)
    assert(potion.duration == 10, potion.duration)
    assert(potion.timeLeft == 10, potion.timeLeft)

    playerModule.potionModule:UsePotion(potion, playerModule)
    assert(PotionTableContentEqual(playerModule.potionModule.activePotions, {{type = playerModule.potionModule.potionTypes.AutoPostSpeed, value = 500, duration = 10, timeLeft = 10}}))
    assert(playerModule.postModule.autoPostInterval == 2500, playerModule.postModule.autoPostInterval)

    assert(PotionTableContentEqual(DataStore2("potions", plr):Get({}), {{type = playerModule.potionModule.potionTypes.AutoPostSpeed, value = 500, duration = 10, timeLeft = 10}}))
end


local function testCreateAndUseMultiplePotions()
    DataStore2("potions", plr):Set(nil)
    DataStore2("upgrades", plr):Set(nil)
    DataStore2("rebirth", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)

    playerModule.potionModule:CreateAndUsePotion(playerModule.potionModule.potionTypes.Followers, 3, 10, playerModule)
    playerModule.potionModule:CreateAndUsePotion(playerModule.potionModule.potionTypes.Coins, 5, 30, playerModule)
    playerModule.potionModule:CreateAndUsePotion(playerModule.potionModule.potionTypes.Coins, 2, 1, playerModule)
    playerModule.potionModule:CreateAndUsePotion(playerModule.potionModule.potionTypes.Followers, 3, 20, playerModule)
    playerModule.potionModule:CreateAndUsePotion(playerModule.potionModule.potionTypes.AutoPostSpeed, 500, 30, playerModule)

    assert(PotionTableContentEqual(playerModule.potionModule.activePotions, {
        {type = playerModule.potionModule.potionTypes.Followers, value = 3, duration = 10, timeLeft = 10},
        {type = playerModule.potionModule.potionTypes.Coins, value = 5, duration = 30, timeLeft = 30},
        {type = playerModule.potionModule.potionTypes.Coins, value = 2, duration = 1, timeLeft = 1},
        {type = playerModule.potionModule.potionTypes.Followers, value = 3, duration = 20, timeLeft = 20},
        {type = playerModule.potionModule.potionTypes.AutoPostSpeed, value = 500, duration = 30, timeLeft = 30}
    }))
    assert(playerModule.followersMultiplier == 6, playerModule.followersMultiplier)
    assert(playerModule.coinsMultiplier == 7, playerModule.coinsMultiplier)
    assert(playerModule.postModule.autoPostInterval == 2500, playerModule.postModule.autoPostInterval)

    assert(PotionTableContentEqual(DataStore2("potions", plr):Get({}), {
        {type = playerModule.potionModule.potionTypes.Followers, value = 3, duration = 10, timeLeft = 10},
        {type = playerModule.potionModule.potionTypes.Coins, value = 5, duration = 30, timeLeft = 30},
        {type = playerModule.potionModule.potionTypes.Coins, value = 2, duration = 1, timeLeft = 1},
        {type = playerModule.potionModule.potionTypes.Followers, value = 3, duration = 20, timeLeft = 20},
        {type = playerModule.potionModule.potionTypes.AutoPostSpeed, value = 500, duration = 30, timeLeft = 30}
    }))
end


local function test()
    testPotionModuleNew()
    testCreatePotion()
    testUseFollowersPotion()
    testUseCoinsPotion()
    testUseAutoPostPotion()
    testCreateAndUseMultiplePotions()

    print("All tests passed !")
end

test()