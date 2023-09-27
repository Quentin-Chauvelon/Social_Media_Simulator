local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local Types = require(ServerScriptService:WaitForChild("Types"))

local GroupChestRewardRE : RemoteEvent = ReplicatedStorage:WaitForChild("GroupChestReward")
local PetsRE : RemoteEvent = ReplicatedStorage:WaitForChild("Pets")

DataStore2.Combine("SMS", "groupRewardChest")

local groupChestTouchDetector : Part = workspace:WaitForChild("GroupChest"):WaitForChild("TouchDetector")

local FLOAT_GAMES_GROUP_ID : number = 33137062

export type GroupModule = {
    hasCollectedRewardChest : boolean,
    isInGroupLoaded : boolean,
    isInGroup : boolean,
    plr : Player,
    new : (p : Types.PlayerModule) -> GroupModule,
    CanCollectRewardChest : (self : GroupModule) -> boolean,
    CollectRewardChest : (self : GroupModule, p : Types.PlayerModule) -> nil,
    IsInGroup : (self : GroupModule) -> boolean,
    OnLeave : (self : GroupModule) -> nil
}


local GroupModule : GroupModule = {}
GroupModule.__index = GroupModule


function GroupModule.new(p : Types.PlayerModule)
    local groupModule : GroupModule = {}
    setmetatable(groupModule, GroupModule)

    groupModule.hasCollectedRewardChest = DataStore2("groupRewardChest", p.player):Get(false)

    groupModule.isInGroupLoaded = false
    groupModule.isInGroup = false

    groupModule.plr = p.player

    groupChestTouchDetector.Touched:Connect(function(hit : BasePart)
        if hit.Parent and hit.Name == "HumanoidRootPart" then
            if Players:GetPlayerFromCharacter(hit.Parent) == p.player then
                groupModule:CollectRewardChest(p)
            end
        end
    end)

    -- load the value to know if the player is in a group
    groupModule:IsInGroup()

    return groupModule
end


--[[
    Checks if the player is in the group


    @return boolean, true if the player is in the group, false otherwise
]]--
function GroupModule:IsInGroup() : boolean
    if self.isInGroupLoaded then
        return self.isInGroup

    else
        local success, isInGroup = pcall(function()
            return self.plr:IsInGroup(FLOAT_GAMES_GROUP_ID)
        end)

        if success then
            self.isInGroupLoaded = true
            self.isInGroup = isInGroup

            return self.isInGroup
        end
    end

    return false
end


--[[
    Returns a boolean indicating if the player can collect the reward chest or if he already did

    @return, true if the player can collect the reward, false otherwise
]]--
function GroupModule:CanCollectRewardChest() : boolean
    return not self.hasCollectedRewardChest and self:IsInGroup()
end


--[[
    Collects the reward

    @param p : PlayerModule, the player object representing the player
]]--
function GroupModule:CollectRewardChest(p : Types.PlayerModule)
    -- if the player is not in the group or has already collected the reward, return
    if not self:CanCollectRewardChest() then return end

    self.hasCollectedRewardChest = true
    DataStore2("groupRewardChest", self.plr):Set(self.hasCollectedRewardChest)

    GroupChestRewardRE:FireClient(self.plr)

    --  give followers and coins to the player
    p:UpdateFollowersAmount(100_000)
    p:UpdateCoinsAmount(15_000)

    -- give the folded hands pet to the player
    local pet : {} = p.petModule:GetPetFromPetId(20)
    if not pet then
        return nil
    end

    -- set the unique id for the pet
    pet.id = p.petModule.nextId
    p.petModule.nextId += 1

    p.petModule:AddPetToInventory(pet)

    -- add the pet to the inventory
    PetsRE:FireClient(p.player, {pet}, false)
end


function GroupModule:OnLeave()
    setmetatable(self, nil)
	self = nil
end


return GroupModule