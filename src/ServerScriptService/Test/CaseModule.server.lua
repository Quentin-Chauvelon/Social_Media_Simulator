local ServerScriptService = game:GetService("ServerScriptService")
local CaseModule = require(ServerScriptService:WaitForChild("CaseModule"))
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


-- checks if the content of two tables is the same (even if it's not the same order)
local function TableContentEqual(t1, t2)
    if #t1 ~= #t2 then
        return false
    end

    for _,v in pairs(t1) do
        if not table.find(t2, v) then
            return false
        end
    end

    return true
end


local function GetOwnedColors(ownedCases : {[string] : boolean}) : boolean
    local ownedColors : {string} = {}

    for color : string,owned : boolean in pairs(ownedCases) do
        if owned then
            table.insert(ownedColors, color)
        end
    end

    return ownedColors
end


local function GetNumberOfElementsInDictionary(dictionary) : number
    local numberOfElements : number = 0

    for _,_ in pairs(dictionary) do
        numberOfElements += 1
    end

    return numberOfElements
end


local function testCaseModuleNew()
    DataStore2("cases", plr):Set(nil)
    DataStore2("followers", plr):Set(nil)
    local caseModule : CaseModule.CaseModule = CaseModule.new(plr)
    
    assert(caseModule.equippedCase == "Grey", caseModule.equippedCase)
    assert(GetNumberOfElementsInDictionary(caseModule.ownedCases) == 22, GetNumberOfElementsInDictionary(caseModule.ownedCases) == 22)
    assert(TableContentEqual(GetOwnedColors(caseModule:GetOwnedCases().ownedCases), {"Grey"}))
end


local function testBuyCaseInvalidParameter()
    DataStore2("cases", plr):Set(nil)
    DataStore2("followers", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule:UpdateFollowersAmount(100000)
    playerModule.plotModule.phone = workspace:WaitForChild("Plots"):WaitForChild("Phone")

    assert(not playerModule.caseModule:BuyCase())
    assert(not playerModule.caseModule:BuyCase(123, playerModule))
    assert(not playerModule.caseModule:BuyCase("jfdqksfjslqkjdkfmlj", playerModule))
end


local function testBuyCase()
    DataStore2("cases", plr):Set(nil)
    DataStore2("followers", plr):Set(nil)
    DataStore2("upgrades", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.followers = 100_000
    print("followers:", playerModule.followers)
    playerModule.plotModule.phone = workspace:WaitForChild("Plots"):WaitForChild("Phone")

    assert(playerModule.caseModule.equippedCase == "Grey")

    assert(playerModule.caseModule:BuyCase("Green", playerModule))
    assert(playerModule.followers == 90_000, playerModule.followers)
    assert(playerModule.caseModule.equippedCase == "Green", playerModule.caseModule.equippedCase)
    assert(TableContentEqual(GetOwnedColors(playerModule.caseModule:GetOwnedCases().ownedCases), {"Grey", "Green"}) == true, GetOwnedColors(playerModule.caseModule:GetOwnedCases().ownedCases))
    assert(playerModule.caseModule.speedBoost == 350)
    assert(playerModule.postModule.autoPostInterval == 2650)
    for _,backPart : BasePart in ipairs(playerModule.plotModule.phone.PhoneModel.Back:GetChildren()) do
        assert(backPart.color == Color3.fromRGB(36, 143, 59))
    end

    print(DataStore2("cases", plr):Get({}))
    assert(DataStore2("cases", plr):Get({}).equippedCase == "Green", DataStore2("cases", plr):Get({}).equippedCase)
    assert(TableContentEqual(GetOwnedColors(DataStore2("cases", plr):Get({}).ownedCases), {"Grey", "Green"}) == true, GetOwnedColors(DataStore2("cases", plr):Get({}).ownedCases))
end


local function testBuyMultipleCases()
    DataStore2("cases", plr):Set(nil)
    DataStore2("followers", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.followers = 1_000_000
    playerModule.plotModule.phone = workspace:WaitForChild("Plots"):WaitForChild("Phone")

    assert(playerModule.caseModule.equippedCase == "Grey")

    assert(playerModule.caseModule:BuyCase("Green", playerModule))
    assert(playerModule.caseModule:BuyCase("Orange", playerModule))
    assert(playerModule.caseModule:BuyCase("GreenBlue", playerModule))
    assert(playerModule.caseModule:BuyCase("Rainbow", playerModule))
    assert(playerModule.followers == 387_500)
    assert(playerModule.caseModule.equippedCase == "Rainbow")
    assert(TableContentEqual(GetOwnedColors(playerModule.caseModule:GetOwnedCases().ownedCases), {"Grey", "Green", "Orange", "GreenBlue", "Rainbow"}) == true, GetOwnedColors(playerModule.caseModule:GetOwnedCases().ownedCases))
    assert(playerModule.caseModule.speedBoost == 600)
    assert(playerModule.postModule.autoPostInterval == 2400)
    for _,backPart : BasePart in ipairs(playerModule.plotModule.phone.PhoneModel.Back:GetChildren()) do
        assert(backPart.color == Color3.new(1,1,1))
    end

    assert(DataStore2("cases", plr):Get({}).equippedCase == "Rainbow")
    assert(TableContentEqual(GetOwnedColors(DataStore2("cases", plr):Get({}).ownedCases), {"Grey", "Green", "Orange", "GreenBlue", "Rainbow"}) == true)
end


local function testEquipOwnedCase()
    DataStore2("cases", plr):Set(nil)
    DataStore2("followers", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.followers = 1_000_000
    playerModule.plotModule.phone = workspace:WaitForChild("Plots"):WaitForChild("Phone")

    assert(playerModule.caseModule.equippedCase == "Grey")

    playerModule.caseModule:BuyCase("Green", playerModule)
    playerModule.caseModule:BuyCase("Orange", playerModule)
    playerModule.caseModule:BuyCase("GreenBlue", playerModule)
    playerModule.caseModule:BuyCase("Rainbow", playerModule)
    playerModule.caseModule:BuyCase("GreenBlue", playerModule)

    assert(playerModule.followers == 387_500)
    assert(playerModule.caseModule.equippedCase == "GreenBlue")
    assert(TableContentEqual(GetOwnedColors(playerModule.caseModule:GetOwnedCases().ownedCases), {"Grey", "Green", "Orange", "GreenBlue", "Rainbow"}) == true, GetOwnedColors(playerModule.caseModule:GetOwnedCases().ownedCases))
    assert(playerModule.caseModule.speedBoost == 500)
    assert(playerModule.postModule.autoPostInterval == 2500)
    for _,backPart : BasePart in ipairs(playerModule.plotModule.phone.PhoneModel.Back:GetChildren()) do
        assert(backPart.color == Color3.new(1,1,1))
    end

    assert(DataStore2("cases", plr):Get({}).equippedCase == "GreenBlue")
    assert(TableContentEqual(GetOwnedColors(DataStore2("cases", plr):Get({}).ownedCases), {"Grey", "Green", "Orange", "GreenBlue", "Rainbow"}) == true)
end


local function testEquipNotOwnedCase()
    DataStore2("cases", plr):Set(nil)
    DataStore2("followers", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.followers = 1_000_000
    playerModule.plotModule.phone = workspace:WaitForChild("Plots"):WaitForChild("Phone")

    playerModule.caseModule:BuyCase("Green", playerModule)
    playerModule.caseModule:BuyCase("Orange", playerModule)
    playerModule.caseModule:BuyCase("GreenBlue", playerModule)
    playerModule.caseModule:BuyCase("Rainbow", playerModule)
    playerModule.caseModule:BuyCase("GreenBlue", playerModule)
    playerModule.caseModule:EquipCase(playerModule, "Red")

    assert(playerModule.followers == 387_500)
    assert(playerModule.caseModule.equippedCase == "GreenBlue", playerModule.caseModule.equippedCase)
    assert(TableContentEqual(GetOwnedColors(playerModule.caseModule:GetOwnedCases().ownedCases), {"Grey", "Green", "Orange", "GreenBlue", "Rainbow"}) == true, GetOwnedColors(playerModule.caseModule:GetOwnedCases().ownedCases))
    assert(playerModule.caseModule.speedBoost == 500)
    assert(playerModule.postModule.autoPostInterval == 2500)
    for _,backPart : BasePart in ipairs(playerModule.plotModule.phone.PhoneModel.Back:GetChildren()) do
        assert(backPart.color == Color3.new(1,1,1))
    end

    assert(DataStore2("cases", plr):Get({}).equippedCase == "GreenBlue")
    assert(TableContentEqual(GetOwnedColors(DataStore2("cases", plr):Get({}).ownedCases), {"Grey", "Green", "Orange", "GreenBlue", "Rainbow"}) == true, GetOwnedColors(DataStore2("cases", plr):Get({}).ownedCases))
end


local function test()
    testCaseModuleNew()
    testBuyCaseInvalidParameter()
    testBuyCase()
    testBuyMultipleCases()
    testEquipOwnedCase()
    testEquipNotOwnedCase()

    print("All tests passed !")
end

test()