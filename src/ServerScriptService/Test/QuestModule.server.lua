local ServerScriptService = game:GetService("ServerScriptService")
local QuestModule = require(ServerScriptService:WaitForChild("QuestModule"))
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


local function testQuestsModuleNew()
    DataStore2("quests", plr):Set(nil)
    DataStore2("questsStreak", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.questModule = QuestModule.new(playerModule)

    assert(#playerModule.questModule.quests == 3)
    assert(playerModule.questModule.questStreak.lastDayCompleted == 0)
    assert(playerModule.questModule.questStreak.streak == 0)

    local takenIds : {number} = {}
    for _,quest in pairs(playerModule.questModule.quests) do
        if table.find(takenIds, quest.id) then
            assert(false, "id already taken")
        end
        table.insert(takenIds, quest.id)
    end

    local takenQuestTypes : {number} = {}
    for _,quest in pairs(playerModule.questModule.quests) do
        if table.find(takenQuestTypes, quest.questType) then
            assert(false, "quest type already taken")
        end
        table.insert(takenQuestTypes, quest.questType)
    end
end


local function testQuestsModuleSaveQuests()
    DataStore2("quests", plr):Set(nil)
    DataStore2("questsStreak", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.questModule = QuestModule.new(playerModule)

    playerModule.questModule:SaveQuests(playerModule.player)

    assert(#DataStore2("quests", plr):Get({}) == 3)
end


local function testQuestsModuleDeleteQuest()
    DataStore2("quests", plr):Set(nil)
    DataStore2("questsStreak", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.questModule = QuestModule.new(playerModule)

    playerModule.questModule:DeleteQuest(playerModule, playerModule.questModule.quests[1].id)

    assert(#playerModule.questModule.quests == 2)
end


local function testQuestsModuleDeleteAllQuests()
    DataStore2("quests", plr):Set(nil)
    DataStore2("questsStreak", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.questModule = QuestModule.new(playerModule)

    playerModule.questModule:DeleteAllQuests(playerModule)

    assert(#playerModule.questModule.quests == 0)
end


local function testQuestsModuleCompleteQuest()
    DataStore2("quests", plr):Set(nil)
    DataStore2("questsStreak", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.questModule = QuestModule.new(playerModule)

    playerModule.questModule:CompleteQuest(playerModule, playerModule.questModule.quests[2].id)

    assert(playerModule.questModule.quests[2].status == 1)
    assert(playerModule.questModule.quests[2].progress == playerModule.questModule.quests[2].target)
end


local function testQuestsModuleIsCompleted()
    DataStore2("quests", plr):Set(nil)
    DataStore2("questsStreak", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.questModule = QuestModule.new(playerModule)

    assert(not playerModule.questModule:IsCompleted(playerModule.questModule.quests[2].id))
    playerModule.questModule:CompleteQuest(playerModule, playerModule.questModule.quests[2].id)
    assert(playerModule.questModule:IsCompleted(playerModule.questModule.quests[2].id))
end


local function testQuestsModuleAreAllQuestsCompleted()
    DataStore2("quests", plr):Set(nil)
    DataStore2("questsStreak", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.questModule = QuestModule.new(playerModule)

    assert(not playerModule.questModule:AreAllQuestsCompleted())
    playerModule.questModule:CompleteQuest(playerModule, playerModule.questModule.quests[1].id)
    assert(not playerModule.questModule:AreAllQuestsCompleted())
    playerModule.questModule:CompleteQuest(playerModule, playerModule.questModule.quests[2].id)
    assert(not playerModule.questModule:AreAllQuestsCompleted())
    playerModule.questModule:CompleteQuest(playerModule, playerModule.questModule.quests[3].id)
    assert(playerModule.questModule:AreAllQuestsCompleted())

    assert(playerModule.questModule.questStreak.lastDayCompleted == tonumber(os.date("%j")))
    assert(playerModule.questModule.questStreak.streak == 1)
end


local function testQuestsModuleClaimReward()
    DataStore2("quests", plr):Set(nil)
    DataStore2("questsStreak", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.questModule = QuestModule.new(playerModule)

    assert(not playerModule.questModule:ClaimReward(playerModule, playerModule.questModule.quests[1].id))
    playerModule.questModule:CompleteQuest(playerModule, playerModule.questModule.quests[2].id)

    assert(playerModule.questModule:ClaimReward(playerModule, playerModule.questModule.quests[2].id))
    assert(playerModule.questModule.quests[2].status == 2)

    assert(not playerModule.questModule:ClaimReward(playerModule, playerModule.questModule.quests[1].id))
end


local function testQuestsModule7Streak()
    DataStore2("quests", plr):Set(nil)
    DataStore2("questsStreak", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.questModule = QuestModule.new(playerModule)

    local numberOfSunglassesPetsBefore : number = 0
    for _,pet in pairs(playerModule.petModule.ownedPets) do
        if pet.identifier == "Sunglasses" then
            numberOfSunglassesPetsBefore += 1
        end
    end

    playerModule.questModule.questStreak.streak = 6
    playerModule.questModule:CompleteQuest(playerModule, playerModule.questModule.quests[1].id)
    playerModule.questModule:CompleteQuest(playerModule, playerModule.questModule.quests[2].id)
    playerModule.questModule:CompleteQuest(playerModule, playerModule.questModule.quests[3].id)

    local numberOfSunglassesPetsAfter : number = 0
    for _,pet in pairs(playerModule.petModule.ownedPets) do
        if pet.identifier == "Sunglasses" then
            numberOfSunglassesPetsAfter += 1
        end
    end

    assert(playerModule.questModule.questStreak.streak == 7)
    assert(numberOfSunglassesPetsAfter == numberOfSunglassesPetsBefore + 1)

    playerModule.questModule = QuestModule.new(playerModule)
    assert(playerModule.questModule.questStreak.streak == 0)
end


local function testQuestsModuleResetStreak()
    DataStore2("quests", plr):Set(nil)
    DataStore2("questsStreak", plr):Set(nil)
    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.questModule = QuestModule.new(playerModule)

    playerModule.questModule:CompleteQuest(playerModule, playerModule.questModule.quests[1].id)
    playerModule.questModule:CompleteQuest(playerModule, playerModule.questModule.quests[2].id)
    playerModule.questModule:CompleteQuest(playerModule, playerModule.questModule.quests[3].id)

    playerModule.questModule = QuestModule.new(playerModule)

    assert(playerModule.questModule.questStreak.lastDayCompleted == tonumber(os.date("%j")))
    assert(playerModule.questModule.questStreak.streak == 1)

    playerModule.questModule.questStreak.lastDayCompleted = tonumber(os.date("%j")) - 2
    DataStore2("questsStreak", plr):Set(playerModule.questModule.questStreak)

    playerModule.questModule = QuestModule.new(playerModule)

    assert(playerModule.questModule.questStreak.streak == 0)
end


local function test()
    testQuestsModuleNew()
    testQuestsModuleSaveQuests()
    testQuestsModuleDeleteQuest()
    testQuestsModuleDeleteAllQuests()
    testQuestsModuleCompleteQuest()
    testQuestsModuleIsCompleted()
    testQuestsModuleAreAllQuestsCompleted()
    testQuestsModuleClaimReward()
    testQuestsModule7Streak()
    testQuestsModuleResetStreak()

    print("All tests passed !")
end

test()