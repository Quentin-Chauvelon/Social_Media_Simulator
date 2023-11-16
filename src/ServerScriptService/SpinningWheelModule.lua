local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local Types = require(ServerScriptService:WaitForChild("Types"))

local SpinWheelRE : RemoteEvent = ReplicatedStorage:WaitForChild("SpinWheel")
local UpdateFreeSpinsRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpdateFreeSpins")
local PetsRE : RemoteEvent = ReplicatedStorage:WaitForChild("Pets")

DataStore2.Combine("SMS", "freeSpins")


type WheelReward = {
    id : number,
    petId : number,
    probability : number
}

type Wheel = {
    id : number,
    rewards : {WheelReward},
}

type FreeSpinsSaved = {
    freeSpinsLeft : number,
    crazySpinsLeft : number,
    crazySpinsUsed : number
}

export type SpinningWheelModule = {
    spinning : boolean,
    currentWheel : Wheel,
    nextReward : WheelReward?,
    normalFreeSpinsLeft : number,
    crazyFreeSpinsLeft : number,
    crazyFreeSpinsUsed : number,
    plr : Player,
    new : (plr : Player) -> SpinningWheelModule,
    GetRandomReward : (self: SpinningWheelModule) -> WheelReward,
    SpinWheel : (self: SpinningWheelModule) -> boolean,
    WheelSpinEnded : (self: SpinningWheelModule, p : Types.PlayerModule) -> nil,
    SwitchWheel : (self: SpinningWheelModule, wheel : string) -> nil,
    FreeSpinWheel : (self: SpinningWheelModule) -> nil,
    HasFreeSpin : (self: SpinningWheelModule) -> boolean,
    GiveFreeSpin : (self: SpinningWheelModule, wheel : string) -> nil,
    UseFreeSpin : (self: SpinningWheelModule) -> nil,
}


local normalWheel : Wheel = {
    id = 1,
    rewards = {
        {
            id = 1,
            petId = 5,
            probability = 0.35
        },
        {
            id = 2,
            petId = 8,
            probability = 0.3
        },
        {
            id = 3,
            petId = 11,
            probability = 0.2
        },
        {
            id = 4,
            petId = 19,
            probability = 0.1
        },
        {
            id = 5,
            petId = 27,
            probability = 0.05
        },
    }
}

local crazyWheel : Wheel = {
    id = 2,
    rewards = {
        {
            id = 1,
            petId = 23,
            probability = 0.35
        },
        {
            id = 2,
            petId = 25,
            probability = 0.3
        },
        {
            id = 3,
            petId = 27,
            probability = 0.2
        },
        {
            id = 4,
            petId = 28,
            probability = 0.1
        },
        {
            id = 5,
            petId = 105,
            probability = 0.05
        },
    }
}

local defaultFreeSpinsSaved : FreeSpinsSaved = {
    freeSpinsLeft = 0,
    crazySpinsLeft = 0,
    crazySpinsUsed = 0
}


local SpinningWheelModule : SpinningWheelModule = {}
SpinningWheelModule.__index = SpinningWheelModule


function SpinningWheelModule.new(plr : Player)
    local spinningWheelModule = setmetatable({}, SpinningWheelModule)

    spinningWheelModule.spinning = false
    spinningWheelModule.currentWheel = normalWheel
    spinningWheelModule.nextReward = nil

    spinningWheelModule.plr = plr

    local freeSpinsSaved : FreeSpinsSaved = DataStore2("freeSpins", plr):Get(defaultFreeSpinsSaved)
    spinningWheelModule.normalFreeSpinsLeft = freeSpinsSaved.freeSpinsLeft
    spinningWheelModule.crazyFreeSpinsLeft = freeSpinsSaved.crazySpinsLeft
    spinningWheelModule.crazyFreeSpinsUsed = freeSpinsSaved.crazySpinsUsed


    return spinningWheelModule
end


--[[
    Returns a random reward from the current wheel based on the reward probability.

    @return WheelReward, the reward that was selected.
]]--
function SpinningWheelModule:GetRandomReward() : WheelReward
    local randomValue : number = math.random()

    for _,reward : WheelReward in pairs(self.currentWheel.rewards) do
        if randomValue <= reward.probability then
            return reward
        end
        randomValue -= reward.probability
    end
end


--[[
    Selects a random reward and sets the spinning value to true.
    Fires the client to spin the wheel UI.

    @return boolean, true if the wheel was spun successfully, false otherwise.
]]--
function SpinningWheelModule:SpinWheel() : boolean
    if not self.spinning then
        self.spinning = true
        self.nextReward = self:GetRandomReward()

        SpinWheelRE:FireClient(self.plr, self.nextReward.id)
        return true
    end

    return false
end


--[[
    This function is called when the spinning wheel animation ends. It gives the pet reward to the player.

    @param p : PlayerModule, the object representing the player.
]]--
function SpinningWheelModule:WheelSpinEnded(p : Types.PlayerModule)
    if self.spinning then
        self.spinning = false

        if self.nextReward then
            local pet : {} = p.petModule:GetPetFromPetId(self.nextReward.petId)
            if not pet then return nil end

            -- set the unique id for the pet
            pet.id = p.petModule.nextId
            p.petModule.nextId += 1

            p.petModule:AddPetToInventory(pet)

            -- add the pet to the inventory
            PetsRE:FireClient(p.player, {pet}, false)

            self.nextReward = nil
        end
    end
end


--[[
    Switches the current wheel to the specified one.

    @param wheel : Wheel, The name of the wheel to switch to. Can be "normal" or "crazy".
]]--
function SpinningWheelModule:SwitchWheel(wheel : string)
    if wheel == "normal" then
        self.currentWheel = normalWheel
        return self.normalFreeSpinsLeft
    elseif wheel == "crazy" then
        self.currentWheel = crazyWheel
        return self.crazyFreeSpinsLeft
    end

    return 0
end


--[[
    This function checks if the player has a free spin available, spins the wheel, and uses the free spin if successful.
]]--
function SpinningWheelModule:FreeSpinWheel()
    if self:HasFreeSpin() then
        if self:SpinWheel() then
            self:UseFreeSpin()
        end
    end
end


--[[
    Determines if the spinning wheel has a free spin available based on the current wheel type.

    @return boolean: true if there is a free spin available, false otherwise.
]]--
function SpinningWheelModule:HasFreeSpin() : boolean
    if self.currentWheel.id == 1 then
        return self.normalFreeSpinsLeft > 0
    elseif self.currentWheel.id == 2 then
        return self.crazyFreeSpinsLeft > 0
    end
end


--[[
    Increases the number of free spins left for the current spinning wheel based on its ID.

    @param wheel : string, The name of the wheel to give a free spin to. Can be "normal" or "crazy".
]]--
function SpinningWheelModule:GiveFreeSpin(wheel : string)
    if wheel == "normal" then
        self.normalFreeSpinsLeft += 1
    elseif wheel == "crazy" then
        self.crazyFreeSpinsLeft += 1
    end

    DataStore2("freeSpins", self.plr):Set({
        freeSpinsLeft = self.normalFreeSpinsLeft,
        crazySpinsLeft = self.crazyFreeSpinsLeft,
        crazySpinsUsed = self.crazyFreeSpinsUsed
    })

    UpdateFreeSpinsRE:FireClient(self.plr, self.normalFreeSpinsLeft, self.crazyFreeSpinsLeft)
end


--[[
    Decreases the number of free spins left for the current wheel and updates the freeSpins DataStore2 entry.
]]--
function SpinningWheelModule:UseFreeSpin()
    if self.currentWheel.id == 1 then
        self.normalFreeSpinsLeft -= 1
    elseif self.currentWheel.id == 2 then
        self.crazyFreeSpinsLeft -= 1
        self.crazyFreeSpinsUsed += 1
    end

    DataStore2("freeSpins", self.plr):Set({
        freeSpinsLeft = self.normalFreeSpinsLeft,
        crazySpinsLeft = self.crazyFreeSpinsLeft,
        crazySpinsUsed = self.crazyFreeSpinsUsed
    })

    UpdateFreeSpinsRE:FireClient(self.plr, self.normalFreeSpinsLeft, self.crazyFreeSpinsLeft)
end


return SpinningWheelModule