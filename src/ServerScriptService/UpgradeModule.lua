local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local Types = require(ServerScriptService:WaitForChild("Types"))

DataStore2.Combine("SMS", "upgrades")


-- list of the player's upgrades
local defaultUpgrades : {upgrade} = {
    -- walkSpeed
    {
        id = 1,
        level = 1,
        maxLevel = 10,
        baseValue = 20,
        upgradeValues = {0, 2, 4, 6, 8, 10, 12, 14, 16, 18},
        costs = {10, 25, 50, 200, 1_000, 3_000, 10_000, 25_000, 50_000, 100_000}
    },
    
    -- bot speed
    {
        id = 2,
        level = 1,
        maxLevel = 10,
        baseValue = 0,
        upgradeValues = {0, 50, 100, 150, 200, 250, 300, 350, 400, 450},
        costs = {100, 500, 2_000, 5_000, 15_000, 50_000, 150_000, 450_000, 1_000_000, 2_500_000}
    },
    
    -- followers multiplier
    {
        id = 3,
        level = 1,
        maxLevel = 10,
        baseValue = 0,
        upgradeValues = {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9},
        costs = {250, 1_000, 2_500, 7_500, 12_500, 50_000, 200_000, 550_000, 1_500_000, 4_000_000}
    },
    
    -- coins multiplier
    {
        id = 4,
        level = 1,
        maxLevel = 10,
        baseValue = 0,
        upgradeValues = {0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9},
        costs = {500, 2_000, 8_000, 20_000, 75_000, 250_000, 900_000, 2_000_000, 7_500_000, 20_000_000}
    },
}


export type UpgradeModule = {
    upgrades : {upgrade},
    firstFire : boolean?,
    followersMultiplier : number,
    coinsMultiplier : number,
    new : (plr : Player) -> UpgradeModule,  
    CanUpgrade : (self : UpgradeModule, p : Types.PlayerModule, upgrade : upgrade, id : number) -> boolean,
    ApplyUpgrade : (self : UpgradeModule, p : Types.PlayerModule, upgrade : upgrade) -> nil,
    ApplyUpgrades : (self : UpgradeModule, p : Types.PlayerModule) -> nil,
    Upgrade : (self : UpgradeModule, p : Types.PlayerModule, id : number) -> {upgrade} | upgrade | nil,
    GetUpgradeWithId : (self : UpgradeModule, id : number) -> upgrade?,
    OnLeave : (self : UpgradeModule) -> nil
}

export type upgrade = {
    id : number,
    level : number,
    maxLevel : number,
    baseValue : number,
    upgradeValues : {number},
    costs : {number}
}


local UpgradeModule : UpgradeModule = {}
UpgradeModule.__index = UpgradeModule


function UpgradeModule.new(plr : Player) : UpgradeModule
    local upgradeModule : UpgradeModule = {}

    -- DataStore2("upgrades", plr):Set(nil)
    upgradeModule.upgrades = DataStore2("upgrades", plr):Get(defaultUpgrades)
    upgradeModule.firstFire = true
    upgradeModule.followersMultiplier = 0
    upgradeModule.coinsMultiplier = 0

    return setmetatable(upgradeModule, UpgradeModule)
end


--[[
    Returns a boolean indicating if the player can upgrade the upgrade

    @param upgrade : upgrade, the upgrade to upgrade
    @param id : number, the id of the upgrade
    @return boolean, true if the player can upgrade, false otherwise
]]--
function UpgradeModule:CanUpgrade(upgrade : upgrade, id : number) : boolean
    if upgrade.id == id then
        if upgrade.level + 1 <= upgrade.maxLevel then
            return true
        end
    end

    return false
end


--[[
    Applies the upgrade (to the player or its character)

    @param p : PlayerModule, the PlayerModule representing the player to whom we want to apply the upgrade
    @param upgrade : upgrade, the upgrade to apply
]]--
function UpgradeModule:ApplyUpgrade(p : Types.PlayerModule, upgrade : upgrade)
    if upgrade.id == 1 then
        if p.player.Character then
            p.player.Character.Humanoid.WalkSpeed = upgrade.baseValue + upgrade.upgradeValues[upgrade.level] + (p.isPremium and 4 or 0)
        end

    elseif upgrade.id == 2 then
        p:UpdateAutopostInterval()

    elseif upgrade.id == 3 then
        self.followersMultiplier = upgrade.baseValue + upgrade.upgradeValues[upgrade.level]
        p:UpdateFollowersMultiplier()

    elseif upgrade.id == 4 then
        self.coinsMultiplier = upgrade.baseValue + upgrade.upgradeValues[upgrade.level]
        p:UpdateCoinsMultiplier()
    end
end


--[[
    Applies all the upgrades (to the player or its character).
    Used when the player joins the game or when we want to "refresh" the upgrades

    @param p : PlayerModule,  the PlayerModule reprensenting the player to whom we want to apply the upgrades
]]--
function UpgradeModule:ApplyUpgrades(p : Types.PlayerModule)
    for _,upgrade : upgrade in pairs(self.upgrades) do
        self:ApplyUpgrade(p, upgrade)
    end
end


--[[
    Upgrades one of the upgrade of the player

    @param p : PlayerModule,  the PlayerModule reprensenting the player to whom we want to apply the upgrades
    @param id : number, the id of the upgrade
    @return {upgrade} | upgrade, returns all the upgrades if self.firstFire is true, returns the upgraded upgrade
    if the upgrade could be upgraded, nil otherwise
]]--
function UpgradeModule:Upgrade(p : Types.PlayerModule, id : number) : {upgrade} | upgrade | nil
    if self.firstFire then
        self.firstFire = nil

        self:ApplyUpgrades(p)
        return self.upgrades
    end

    local upgrade : upgrade? = self:GetUpgradeWithId(id)

    if upgrade then
        if self:CanUpgrade(upgrade, id) then
            
            if p:HasEnoughFollowers(upgrade.costs[upgrade.level + 1]) then
                p:UpdateFollowersAmount(-upgrade.costs[upgrade.level + 1])

                self.upgrades[id].level += 1
                DataStore2("upgrades", p.player):Set(self.upgrades)

                self:ApplyUpgrade(p, upgrade)

                return self.upgrades[id]
            end
        end
    end

    return nil
end


--[[
    Gets the upgrade matching the given id if found

    @param id : number, the id of the upgrade
    @return upgrade?, the upgrade matching the id if it was found, nil otherwise
]]--
function UpgradeModule:GetUpgradeWithId(id : number) : upgrade?
    -- for i,upgrade : upgrade in self.upgrades do
    --     if upgrade.id == id then
    --         return upgrade, i
    --     end
    -- end

    if self.upgrades[id] then
        return self.upgrades[id]
    end

    return nil
end


function UpgradeModule:OnLeave()
	setmetatable(self, nil)
	self = nil
end


return UpgradeModule