local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local Types = require(ServerScriptService:WaitForChild("Types"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))

local DisplayPotionsRE : RemoteEvent = ReplicatedStorage:WaitForChild("DisplayPotions")

DataStore2.Combine("SMS", "potions")


export type PotionModule = {
    potionTypes : potionTypes,
    plr : Player,
    activePotions : {potion},
    potionsTimeLeft : Promise.Promise,
    followersMultiplier : number,
    coinsMultiplier : number,
    speedBoost : number,
    potionTypes : number,
    new : () -> PotionModule,
    UsePotion : (self : PotionModule, potion : potion, p : Types.PlayerModule) -> nil,
    UseAllActivePotions : (self : PotionModule, p : Types.PlayerModule) -> nil,
    CreatePotion : (self : PotionModule, type : number, value : number, duration : number) -> potion,
    CreateAndUsePotion : (self : PotionModule, type : number, value : number, duration : number, p : Types.PlayerModule) -> nil,
    ApplyPotionsBoosts : (self : PotionModule, type : number, p : Types.PlayerModule) -> nil,
    OnLeave : (self : PotionModule) -> nil
}

export type potion = {
    type : number,
    value : number,
    duration : number,
    timeLeft : number
}

export type potionTypes = {
    Followers : number,
    Coins : number,
    AutoPostSpeed : number,
    FollowersCoins : number
}


local PotionModule : PotionModule = {}
PotionModule.__index = PotionModule


function PotionModule.new(plr : Player)
    local potionModule : PotionModule = {}

    -- potion types enum
    potionModule.potionTypes = {
        Followers = 0,
        Coins = 1,
        AutoPostSpeed = 2,
        FollowersCoins = 3
    }
    potionModule.plr = plr

    -- DataStore2("potions", plr):Set(nil)
    potionModule.activePotions = DataStore2("potions", plr):Get({})
    potionModule.potionsTimeLeft = nil
    
    potionModule.followersMultiplier = 0
    potionModule.coinsMultiplier = 0
    potionModule.speedBoost = 0

    return setmetatable(potionModule, PotionModule)
end


--[[
    Applies the effects of the given potion

    @param potion : potion, the potion to use
]]--
function PotionModule:UsePotion(potion : potion, p : Types.PlayerModule)

    -- add the potion to the active potions table
    table.insert(self.activePotions, potion)

    -- save the active potions
    DataStore2("potions", self.plr):Set(self.activePotions)

    -- apply the effect of the potion
    self:ApplyPotionsBoosts(potion.type, p)

    -- fire the client to update the display of all the potions
    DisplayPotionsRE:FireClient(self.plr, self.activePotions)

    -- if there were no active potions, we start the promise to decrease the time left for all the potions
    if #self.activePotions == 1 and not self.potionsTimeLeft then
        self.potionsTimeLeft = Promise.new(function(resolve)

            -- stop the promise when the are no more active potions
            while #self.activePotions ~= 0 do
                task.wait(60)

                -- table of the type of potions that have expired since the last loop iteration
                local expiredPotions : {number} = {}

                -- decrease all potions time left by 1 minute
                for i : number,_ in pairs(self.activePotions) do
                    self.activePotions[i].timeLeft -= 1

                    -- if the potion is expired, add the type to the table of the expired potion types
                    if self.activePotions[i].timeLeft <= 0 then
                        table.insert(expiredPotions, 1, i)
                    end
                end

                -- remove the expired potions from the table and re-apply the boosts
                for _,potionPosition : number in pairs(expiredPotions) do
                    local type : number = self.activePotions[potionPosition].type

                    -- remove the potion from the table once it has expired
                    table.remove(self.activePotions, potionPosition)
                    
                    -- update the boosts
                    self:ApplyPotionsBoosts(type, p)
                end
                
                -- save the active potions
                DataStore2("potions", self.plr):Set(self.activePotions)
                
                -- fire the client to update the display of all the potions
                DisplayPotionsRE:FireClient(self.plr, self.activePotions)
            end
            
            resolve()
            self.potionsTimeLeft = nil

            -- fire the client with an empty table to remove all potions
            DisplayPotionsRE:FireClient(self.plr, {})
        end)
    end
end


--[[
    Applies the effects for all the active potions
]]--
function PotionModule:UseAllActivePotions(p : Types.PlayerModule)
    -- make a copy of the table to empty the self.activePotions table, because self:UsePotion adds the potion to the table.
    -- So if we don't remove the potions prior to calling UsePotion, we end up in a endless loop
    local activePotions : {potion} = {}
    for _,potion : potion in pairs(self.activePotions) do
        table.insert(activePotions, potion)
    end
    table.clear(self.activePotions)
    
    for _,potion : potion in pairs(activePotions) do
        self:UsePotion(potion, p)
    end
end


--[[
    Creates and returns a potion that can be later used

    @param type : number, the type of potion to create
    @param value : number, the value (multiplier...) to apply to the potion
    @param duration : number, the time the potion will last (in minutes)
    @return potion, the potion that was created and can then be used
]]--
function PotionModule:CreatePotion(type : number, value : number, duration : number) : potion
    return {
        type = type,
        value = value,
        duration = duration,
        timeLeft = duration
    }
end


--[[
    Creates and automatically uses a potion

    @param type : number, the type of potion to create
    @param value : number, the value (multiplier...) to apply to the potion
    @param duration : number, the time the potion will last (in minutes)
]]--
function PotionModule:CreateAndUsePotion(type : number, value : number, duration : number, p : Types.PlayerModule)
    -- create the potion
    local potion : potion = self:CreatePotion(type, value, duration)

    -- apply the effects of the potion
    self:UsePotion(potion, p)
end


--[[
    Apply the boosts corresponding to the given type

    @param type : number, the type of potion to apply the boost for
]]--
function PotionModule:ApplyPotionsBoosts(type : number, p : Types.PlayerModule)
    local boost : number = 0

    -- sum the boosts of all the potions matching the given type
    for _,potion : potion in pairs(self.activePotions) do
        if potion.type == type then
            boost += potion.value
        end
    end

    if type == self.potionTypes.Followers or type == self.potionTypes.FollowersCoins then
        -- remove one to the boost, otherwise it's one too high
        self.followersMultiplier = boost >= 1 and boost - 1 or 0

        p:UpdateFollowersMultiplier()

    elseif type == self.potionTypes.Coins or type == self.potionTypes.FollowersCoins then
        -- remove one to the boost, otherwise it's one too high
        self.coinsMultiplier = boost >= 1 and boost - 1 or 0

        p:UpdateCoinsMultiplier()

    elseif type == self.potionTypes.AutoPostSpeed then
        self.speedBoost = boost

        p:UpdateAutopostInterval()
    end
end


function PotionModule:OnLeave()
    self.potionsTimeLeft:cancel()

    setmetatable(self, nil)
	self = nil
end


return PotionModule