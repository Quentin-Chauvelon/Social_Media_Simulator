local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local Types = require(ServerScriptService:WaitForChild("Types"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))

local PetsRE : RemoteEvent = ReplicatedStorage:WaitForChild("Pets")
local CreateQuestRE : RemoteEvent = ReplicatedStorage:WaitForChild("CreateQuest")
local UpdateStreakRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpdateStreak")
local UpdateQuestProgressRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpdateQuestProgress")
local ParticleRE : RemoteEvent = ReplicatedStorage:WaitForChild("Particle")

local NUMBER_ABBREVIATIONS : {[string] : number} = {["k"] = 4,["M"] = 7,["B"] = 10,["T"] = 13,["Qa"] = 16,["Qi"] = 19}


DataStore2.Combine("SMS", "quests", "questsStreak")


type QuestStatus = {
    Pending : number,
    Completed : number,
    Claimed : number
}

local QuestStatus : QuestStatus = {
    Pending = 0,
    Completed = 1,
    Claimed = 2
}


type QuestRewardType = {
    Followers : number,
    Coins : number
}

local QuestRewardTypes : QuestRewardType = {
    Followers = 0,
    Coins = 1
}


type QuestType = {
    GetXFollowers : number,
    GetXCoins : number,
    UpgradeOnce : number,
    PlayXMinutesToday : number,
    OpenOneEgg : number,
    GetARarePet : number,
    PostXTimes : number,
    CraftOnePetIntoBig : number,
    CraftOnePetIntoHuge : number,
    UpgradeOnePetToShiny : number,
    UpgradeOnePetToRainbow : number
}

local QuestTypes : QuestType = {
    GetXFollowers = 0,
    GetXCoins = 1,
    UpgradeOnce = 2,
    PlayXMinutesToday = 3,
    OpenOneEgg = 4,
    GetARarePet = 5,
    PostXTimes = 6,
    CraftOnePetIntoBig = 7,
    CraftOnePetIntoHuge = 8,
    UpgradeOnePetToShiny = 9,
    UpgradeOnePetToRainbow = 10
}


type Quest = {
    id : number,
    name : string,
    questType : QuestType,
    progress : number,
    target : number,
    status : QuestStatus,
    rewardValue : number,
    rewardType : QuestRewardType
}

export type QuestModule = {
    quests : {Quest},
    questStreak : QuestStreak,
    averageFollowersPerSecond : number,
    averageCoinsPerSecond : number,
    playedTodayPromise : Promise.Promise,
    updateUIProgress : boolean,
    plr : Player,
    new : (p : Types.PlayerModule) -> QuestModule,
    LoadQuests : (self : QuestModule, p : Types.PlayerModule) -> nil,
    SaveQuests : (self : QuestModule, plr : Player) -> nil,
    CreateQuest : (self : QuestModule, p : Types.PlayerModule) -> Quest,
    AddQuestsListeners : (self : QuestModule, p : Types.PlayerModule, quest : Quest) -> Quest,
    DeleteQuest : (self : QuestModule, p : Types.PlayerModule, id : number) -> nil,
    DeleteAllQuests : (self : QuestModule, p : Types.PlayerModule) -> nil,
    IsCompleted : (self : QuestModule, id : number) -> boolean,
    AreAllQuestsCompleted : (self : QuestModule) -> boolean,
    CompleteQuest : (self : QuestModule, p : Types.PlayerModule, id : number) -> nil,
    HasClaimedReward : (self : QuestModule, id : number) -> boolean,
    ClaimReward : (self : QuestModule, p : Types.PlayerModule, id : number) -> boolean,
    AreAllQuestsClaimed : (self : QuestModule) -> boolean,
    GetPositionOfQuestWithId : (self : QuestModule, id : number) -> number,
    FollowersToCoins : (self : QuestModule, followers : number) -> number,
    CoinsToFollowers : (self : QuestModule, coins : number) -> number,
    AbbreviateNumber : (self : QuestModule, number : number) -> number,
    OnLeave : (self : QuestModule) -> nil
}

type QuestStreak = {
    lastDayCompleted : number,
    streak : number
}

local defautQuestStreak : QuestStreak = {
    lastDayCompleted = 0,
    streak = 0
}


local QuestModule : QuestModule = {}
QuestModule.__index = QuestModule


function QuestModule.new(p : Types.PlayerModule)
    local questModule : QuestModule = {}
    setmetatable(questModule, QuestModule)

    -- DataStore2("quests", p.player):Set(nil)
    questModule.quests = DataStore2("quests", p.player):Get({})
    questModule.questStreak = DataStore2("questsStreak", p.player):Get(defautQuestStreak)

    questModule.averageFollowersPerSecond = 2.248 / (p.postModule.autoPostInterval / 1000) * p.followersMultiplier
    questModule.averageCoinsPerSecond = (0.05 + (p.rebirthModule.rebirthLevel / 100)) / (p.postModule.autoPostInterval / 1000) * p.coinsMultiplier

    questModule.updateUIProgress = false


    -- if the player didn't complete all quests the day prior, reset the streak
    if (tonumber(os.date("%j")) - questModule.questStreak.lastDayCompleted > 1) or questModule.questStreak.streak == 7 then
        questModule.questStreak.streak = 0
        DataStore2("questsStreak", p.player):Set(questModule.questStreak)
    end

    -- if the player has already played, load the quests, otherwise create 3 new quests
    if not p.alreadyPlayedToday or #questModule.quests ~= 3 then
        questModule:DeleteAllQuests(p)

        for _=1,3 do
            questModule:CreateQuest(p)
        end
    end

    questModule:LoadQuests(p)

    -- create the quests gui
    for _,quest : Quest in pairs(questModule.quests) do
        CreateQuestRE:FireClient(p.player, quest)
    end

    -- update the streak gui
    UpdateStreakRE:FireClient(p.player, questModule.questStreak.streak)

    questModule.plr = p.player

    return questModule
end


--[[
    Loads the already existing quests

    @param p : PlayerModule, the object reprensenting the player
]]--
function QuestModule:LoadQuests(p)
    for _,quest : Quest in pairs(self.quests) do
        self:AddQuestsListeners(p, quest)
    end
end


--[[
    Saves the quests

    @param plr : Player, the player for whom to save the quests
]]--
function QuestModule:SaveQuests(plr : Player)
    DataStore2("quests", plr):Set(self.quests)
end


--[[
    Creates a quest

    @param p : PlayerModule, the object reprensenting the player
    @return the created quest
]]--
function QuestModule:CreateQuest(p : Types.PlayerModule) : Quest
    -- find the next available id based on the ones already taken by other quests
    local takenIds : {number} = {}
    for _,quest : Quest in pairs(self.quests) do
        table.insert(takenIds, quest.id)
    end
    table.sort(takenIds)

    -- find a quest type that is not already used
    local takenQuestsTypes : {number} = {}
    for _,quest : Quest in pairs(self.quests) do
        table.insert(takenQuestsTypes, quest.questType)
    end
    local questType : QuestType
    repeat
        questType = math.random(0, 10)
    until not table.find(takenQuestsTypes, questType)

    local name : string
    local target : number
    local rewardValue : number
    local rewardType : QuestRewardType

    if questType == QuestTypes.GetXFollowers then
        target = self.averageFollowersPerSecond * (math.random(5,15) * 60)
        rewardValue = self.averageCoinsPerSecond * (math.random(5,15) * 60) * math.random(2,5)
        rewardType = QuestRewardTypes.Coins
        name = string.format("Get %s followers", self:AbbreviateNumber(target))

    elseif questType == QuestTypes.GetXCoins then
        target = self.averageCoinsPerSecond * (math.random(5,15) * 60)
        rewardValue = self.averageFollowersPerSecond * (math.random(5,15) * 60) * math.random(2,5)
        rewardType = QuestRewardTypes.Followers
        name = string.format("Get %s coins", self:AbbreviateNumber(target))

    elseif questType == QuestTypes.UpgradeOnce then
        target = 1

        -- find the cheapest upgrade left
        local cheapestUpgradePrice : number = math.huge
        for _,upgrade in pairs(p.upgradeModule.upgrades) do
            if upgrade.level < upgrade.maxLevel then
                if upgrade.costs[upgrade.level + 1] < cheapestUpgradePrice then
                    cheapestUpgradePrice = upgrade.costs[upgrade.level + 1]
                end
            end
        end

        rewardValue = self:FollowersToCoins(cheapestUpgradePrice * math.random(2,5))
        rewardType = QuestRewardTypes.Coins
        name = "Buy one upgrade"

    elseif questType == QuestTypes.PlayXMinutesToday then
        target = math.random(5,15)
        rewardValue = self.averageFollowersPerSecond * math.random(20 - (15 - target), 35 - (15 - target)) * 60
        rewardType = QuestRewardTypes.Followers
        name = string.format("Play for %d minutes", target)

    elseif questType == QuestTypes.OpenOneEgg then
        target = 1
        rewardValue = self:CoinsToFollowers(math.random(2,5))
        rewardType = QuestRewardTypes.Followers
        name = "Open one egg"

    elseif questType == QuestTypes.GetARarePet then
        target = 1
        rewardValue = self:CoinsToFollowers((1 / 0.126) * math.random(2,5))
        rewardType = QuestRewardTypes.Followers
        name = "Get a rare pet"

    elseif questType == QuestTypes.PostXTimes then
        target = 1 / (p.postModule.autoPostInterval / 1000) * math.random(10, 15) * 60
        rewardValue = self.averageCoinsPerSecond * math.random(15, 25) * 60
        rewardType = QuestRewardTypes.Coins
        name = string.format("Post %d times", target)

    elseif questType == QuestTypes.CraftOnePetIntoBig then
        target = 1
        rewardValue = 6.5 * math.random(2,5) * math.max(self.averageCoinsPerSecond, 1)
        rewardType = QuestRewardTypes.Coins
        name = "Craft one pet into big"

    elseif questType == QuestTypes.CraftOnePetIntoHuge then
        target = 1
        rewardValue = 50 * math.random(2,5) * math.max(self.averageCoinsPerSecond, 1)
        rewardType = QuestRewardTypes.Coins
        name = "Craft one pet into huge"

    elseif questType == QuestTypes.UpgradeOnePetToShiny then
        target = 1
        rewardValue = 10 * math.random(2,5) * math.max(self.averageCoinsPerSecond, 1)
        rewardType = QuestRewardTypes.Coins
        name = "Upgrade one pet to shiny"

    elseif questType == QuestTypes.UpgradeOnePetToRainbow then
        target = 1
        rewardValue = 100 * math.random(2,5) * math.max(self.averageCoinsPerSecond, 1)
        rewardType = QuestRewardTypes.Coins
        name = "Upgrade one pet to rainbow"
    end

    local quest : Quest = {
        id = #takenIds ~= 0 and takenIds[#takenIds] + 1 or 1, -- highest taken id + 1 or 1 if the table is empty
        name = name,
        questType = questType,
        progress = 0,
        target = target,
        status = QuestStatus.Pending,
        rewardValue = rewardValue,
        rewardType = rewardType
    }

    -- if the quest is to upgrade once but the player already maxed out all the upgrades, then complete the quest
    if questType == QuestTypes.UpgradeOnce then
        local maxed : boolean = true

        for _,upgrade in pairs(p.upgradeModule.upgrades) do
            if upgrade.level < upgrade.maxLevel then
                maxed = false
            end
        end

        if maxed and quest.status == QuestStatus.Pending then
            self:CompleteQuest(p, quest.id)
        end
    end

    table.insert(self.quests, quest)

    return quest
end


--[[
    Adds the listeners to the scripts to control the progress and completion of quests

    @param p : PlayerModule, the object reprensenting the player
    @param quest : Quest, the quest to add the listener for
]]--
function QuestModule:AddQuestsListeners(p : Types.PlayerModule, quest : Quest)

    if quest.questType == QuestTypes.GetXFollowers then
        p.getXFollowersQuest = function(followers : number)
            quest.progress += followers
            if self.updateUIProgress then
                UpdateQuestProgressRE:FireClient(self.plr, quest.id, quest.progress)
            end

            if quest.progress >= quest.target then
                self:CompleteQuest(p, quest.id)

                p.getXFollowersQuest = nil
            end
        end

    elseif quest.questType == QuestTypes.GetXCoins then
        p.getXCoinsQuest = function(coins : number)
            quest.progress += coins
            if self.updateUIProgress then
                UpdateQuestProgressRE:FireClient(self.plr, quest.id, quest.progress)
            end

            if quest.progress >= quest.target then
                self:CompleteQuest(p, quest.id)

                p.getXCoinsQuest = nil
            end
        end

    elseif quest.questType == QuestTypes.UpgradeOnce then
        p.upgradeModule.upgradeOnceQuest = function()
            if self.updateUIProgress then
                UpdateQuestProgressRE:FireClient(self.plr, quest.id, 1)
            end
            self:CompleteQuest(p, quest.id)

            p.upgradeModule.upgradeOnceQuest = nil
        end

    elseif quest.questType == QuestTypes.PlayXMinutesToday then
        self.playedTodayPromise = Promise.new(function(resolve)
            while quest.progress < quest.target  do
                task.wait(60)
                quest.progress += 1
                UpdateQuestProgressRE:FireClient(self.plr, quest.id, quest.progress)
            end

            self:CompleteQuest(p, quest.id)

            resolve()
        end)

    elseif quest.questType == QuestTypes.OpenOneEgg then
        p.petModule.openOneEggQuest = function()
            if self.updateUIProgress then
                UpdateQuestProgressRE:FireClient(self.plr, quest.id, 1)
            end
            self:CompleteQuest(p, quest.id)

            p.petModule.openOneEggQuest = nil
        end

    elseif quest.questType == QuestTypes.GetARarePet then
        p.petModule.getARarePetQuest = function()
            if self.updateUIProgress then
                UpdateQuestProgressRE:FireClient(self.plr, quest.id, 1)
            end
            self:CompleteQuest(p, quest.id)

            p.petModule.getARarePetQuest = nil
        end

    elseif quest.questType == QuestTypes.PostXTimes then
        p.postModule.postXTimesQuest = function()
            quest.progress += 1
            if self.updateUIProgress then
                UpdateQuestProgressRE:FireClient(self.plr, quest.id, quest.progress)
            end

            if quest.progress >= quest.target then
                self:CompleteQuest(p, quest.id)

                p.postModule.postXTimesQuest = nil
            end
        end

    elseif quest.questType == QuestTypes.CraftOnePetIntoBig then
        p.petModule.craftOnePetIntoBigQuest = function()
            if self.updateUIProgress then
                UpdateQuestProgressRE:FireClient(self.plr, quest.id, 1)
            end
            self:CompleteQuest(p, quest.id)

            p.petModule.craftOnePetIntoBigQuest = nil
        end

    elseif quest.questType == QuestTypes.CraftOnePetIntoHuge then
        p.petModule.craftOnePetIntoHugeQuest = function()
            if self.updateUIProgress then
                UpdateQuestProgressRE:FireClient(self.plr, quest.id, 1)
            end
            self:CompleteQuest(p, quest.id)

            p.petModule.craftOnePetIntoHugeQuest = nil
        end

    elseif quest.questType == QuestTypes.UpgradeOnePetToShiny then
        p.petModule.upgradeOnePetToShinyQuest = function()
            if self.updateUIProgress then
                UpdateQuestProgressRE:FireClient(self.plr, quest.id, 1)
            end
            self:CompleteQuest(p, quest.id)

            p.petModule.upgradeOnePetToShinyQuest = nil
        end

    elseif quest.questType == QuestTypes.UpgradeOnePetToRainbow then
        p.petModule.upgradeOnePetToRainbowQuest = function()
            if self.updateUIProgress then
                UpdateQuestProgressRE:FireClient(self.plr, quest.id, 1)
            end
            self:CompleteQuest(p, quest.id)

            p.petModule.upgradeOnePetToRainbowQuest = nil
        end
    end
end


--[[
    Deletes a quest

    @param p : PlayerModule, the object reprensenting the player
    @param id : number, the id of the quest to delete
]]--
function QuestModule:DeleteQuest(p : Types.PlayerModule, id : number)
    local position : number = self:GetPositionOfQuestWithId(id)
    if position == -1 then return end

    local questType : QuestType = self.quests[position].questType

    -- remove the quest listener
    if questType == QuestTypes.GetXFollowers then
        p.getXFollowersQuest = nil

    elseif questType == QuestTypes.GetXCoins then
        p.getXCoinsQuest = nil

    elseif questType == QuestTypes.UpgradeOnce then
        p.upgradeModule.upgradeOnceQuest = nil

    elseif questType == QuestTypes.PlayXMinutesToday then
        if self.playedTodayPromise then
            self.playedTodayPromise:cancel()
            self.playedTodayPromise = nil
        end

    elseif questType == QuestTypes.OpenOneEgg then
        p.petModule.openOneEggQuest = nil

    elseif questType == QuestTypes.GetARarePet then
        p.petModule.getARarePetQuest = nil

    elseif questType == QuestTypes.PostXTimes then
        p.postModule.postXTimesQuest = nil

    elseif questType == QuestTypes.CraftOnePetIntoBig then
        p.petModule.craftOnePetIntoBigQuest = nil

    elseif questType == QuestTypes.CraftOnePetIntoHuge then
        p.petModule.craftOnePetIntoHugeQuest = nil

    elseif questType == QuestTypes.UpgradeOnePetToShiny then
        p.petModule.upgradeOnePetToShinyQuest = nil

    elseif questType == QuestTypes.UpgradeOnePetToRainbow then
        p.petModule.upgradeOnePetToRainbowQuest = nil
    end

    table.remove(self.quests, position)
end


--[[
    Deletes all the current quests of the player

    @param p : PlayerModule, the object reprensenting the player
]]--
function QuestModule:DeleteAllQuests(p : Types.PlayerModule)
    -- store ids in a table because if we loop through the quests and delete them right away, the loop might skip some quests
    local ids : {number} = {}
    for _,quest in pairs(self.quests) do
        table.insert(ids, quest.id)
    end

    for _,id : number in pairs(ids) do
        self:DeleteQuest(p, id)
    end
end


--[[
    Checks the quest matching the given id for completion

    @param id : number, the id of the quest to check for completion
    @return boolean, true if the quest is completed, false otherwise
]]--
function QuestModule:IsCompleted(id : number) : boolean
    local position : number = self:GetPositionOfQuestWithId(id)
    if position == -1 then return false end

    -- return true if the quest is Completed or Claimed and false if it's Pending
    return self.quests[position].status ~= QuestStatus.Pending
end


--[[
    Checks all quests for completion

    @return boolean, true if all the quests have been completed
]]--
function QuestModule:AreAllQuestsCompleted() : boolean
    for _,quest in pairs(self.quests) do
        if not self:IsCompleted(quest.id) then
            return false
        end
    end

    return true
end


--[[
    Completes the quest matching the given id

    @param p : PlayerModule, the object reprensenting the player
    @param id : number, the id of the quest to complete
]]--
function QuestModule:CompleteQuest(p : Types.PlayerModule, id : number)
    local position : number = self:GetPositionOfQuestWithId(id)
    if position == -1 then return end

    if self.quests[position].status == QuestStatus.Pending then
        self.quests[position].status = QuestStatus.Completed
        self.quests[position].progress = self.quests[position].target -- set the progress value to target in case it passed it when completing

        self:SaveQuests(p.player)

        UpdateQuestProgressRE:FireClient(self.plr, self.quests[position].id, self.quests[position].progress)
    end
end


--[[
    Checks if the reward of the quest matching the given id has already been claimed

    @param id : number, the id of the quest to check for reward claimed
    @return boolean, true if the reward has already been claimed, false otherwise
]]--
function QuestModule:HasClaimedReward(id : number) : boolean
    local position : number = self:GetPositionOfQuestWithId(id)
    if position == -1 then return false end

    return self.quests[position].status == QuestStatus.Claimed
end


--[[
    Claims the reward for the quest matching the given id

    @param p : PlayerModule, the object reprensenting the player
    @param id : number, the id of the quest to claim the reward for
    @return boolean, true if the reward could be claimed, false otherwise
]]--
function QuestModule:ClaimReward(p : Types.PlayerModule, id : number) : boolean
    if self:IsCompleted(id) and not self:HasClaimedReward(id) then
        local position : number = self:GetPositionOfQuestWithId(id)
        if position == -1 then return end

        local quest : Quest = self.quests[position]
        quest.status = QuestStatus.Claimed

        if quest.rewardType == QuestRewardTypes.Followers then
            p.followers += quest.rewardValue
	        DataStore2("followers", p.player):Increment(quest.rewardValue, quest.rewardValue)
            p.player.leaderstats.Followers.Value = p.followers

        elseif quest.rewardType == QuestRewardTypes.Coins then
            p.coins += quest.rewardValue
            DataStore2("coins", p.player):Increment(quest.rewardValue, quest.rewardValue)
            p.player.leaderstats.Followers.Value = p.coins
        end

        self:SaveQuests(p.player)

        ParticleRE:FireClient(p.player)

        if self:AreAllQuestsClaimed() then
            self.questStreak.lastDayCompleted = tonumber(os.date("%j"))
            self.questStreak.streak += 1

            if self.questStreak.streak == 7 then
                local pet : {} = p.petModule:GetPetFromPetId(26)
                if not pet then return nil end

                -- set the unique id for the pet
                pet.id = p.petModule.nextId
                p.petModule.nextId += 1

                p.petModule:AddPetToInventory(pet)

                -- add the pet to the inventory
                PetsRE:FireClient(p.player, {pet}, false)
            end

            UpdateStreakRE:FireClient(self.plr, self.questStreak.streak)

            DataStore2("questsStreak", self.plr):Set(self.questStreak)
        end

        return true
    end

    return false
end


--[[
    Checks if all quests have been claimed

    @return boolean, true if all the quests have been claimed
]]--
function QuestModule:AreAllQuestsClaimed() : boolean
    for _,quest in pairs(self.quests) do
        if not self:HasClaimedReward(quest.id) then
            return false
        end
    end

    return true
end


--[[
    Returns the position in the quests table of the quest matching the given id

    @param id : number, the id of the quest to find
    @return the potision of the quest in the quests table
]]--
function QuestModule:GetPositionOfQuestWithId(id : number) : number
    for i : number, quest : Quest in pairs(self.quests) do
        if quest.id == id then
            return i
        end
    end

    return -1
end


--[[
    Convert a number of followers to a number of coins based on the average followers and coins per second values

    @param followers : number, the number of followers to convert to coins
    @return number, the number of coins corresponding to the given number of followers
]]--
function QuestModule:FollowersToCoins(followers : number)
    return math.round(followers * self.averageCoinsPerSecond / self.averageFollowersPerSecond)
end


--[[
    Convert a number of coins to a number of followers based on the average followers and coins per second values

    @param coins : number, the number of coins to convert to followers
    @return number, the number of followers corresponding to the given number of coins
]]--
function QuestModule:CoinsToFollowers(coins : number)
    return math.round(coins * self.averageFollowersPerSecond / self.averageCoinsPerSecond)
end


--[[
    Abbreviates the given number

    @param number : number, the number to abbreviate
    @return string, the abbreviated number
]]--
function QuestModule:AbbreviateNumber(number : number) : string
    local text : string = tostring(string.format("%.f",math.floor(number)))

    local chosenAbbreviation : string
        for abbreviation : string, digit : number in pairs(NUMBER_ABBREVIATIONS) do
            if (#text >= digit and #text < (digit + 3)) then
                chosenAbbreviation = abbreviation
                break
        end
    end

    if (chosenAbbreviation and chosenAbbreviation ~= 0) then
        local digits : number = NUMBER_ABBREVIATIONS[chosenAbbreviation]

        local rounded : number = math.floor(number / 10 ^  (digits - 2)) * 10 ^  (digits - 2)
        return string.format("%.1f", rounded / 10 ^ (digits - 1)) .. chosenAbbreviation
    else
        return tostring(number)
    end
end


function QuestModule:OnLeave()
    if self.playedTodayPromise then
        self.playedTodayPromise:cancel()
    end

    setmetatable(self, nil)
	self = nil
end


return QuestModule