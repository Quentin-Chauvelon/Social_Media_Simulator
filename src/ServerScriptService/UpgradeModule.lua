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
        baseValue = 16,
        upgradeValues = {0, 2, 4, 6, 8, 10, 12, 14, 16, 18},
        costs = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
    },
    
    -- bot speed
    {
        id = 2,
        level = 1,
        maxLevel = 10,
        baseValue = 3000,
        upgradeValues = {0, 50, 100, 150, 200, 250, 300, 350, 400, 450},
        costs = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
    },
    
    -- followers multiplier
    {
        id = 3,
        level = 1,
        maxLevel = 10,
        baseValue = 1,
        upgradeValues = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
        costs = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
    },
    
    -- coins multiplier
    {
        id = 4,
        level = 1,
        maxLevel = 10,
        baseValue = 1,
        upgradeValues = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
        costs = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
    },
}


export type UpgradeModule = {
    upgrades : {upgrade},
    firstFire : boolean?,
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

    upgradeModule.upgrades = DataStore2("upgrades", plr):Get(defaultUpgrades)
    upgradeModule.firstFire = true

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
            p.player.Character.Humanoid.WalkSpeed = upgrade.baseValue + upgrade.upgradeValues[upgrade.level]
        end

    elseif upgrade.id == 2 then
        p.postModule.autoPostInverval = upgrade.baseValue - upgrade.upgradeValues[upgrade.level]

    elseif upgrade.id == 3 then
        p.followersMultiplier = upgrade.baseValue + upgrade.upgradeValues[upgrade.level] + p.gamepassModule:GetFollowersMultiplier()

    elseif upgrade.id == 4 then
        p.coinsMultiplier = upgrade.baseValue + upgrade.upgradeValues[upgrade.level] + p.gamepassModule:GetCoinsMultiplier()
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
            
            if p:HasEnoughCoins(upgrade.costs[upgrade.level + 1]) then
                p:UpdateCoinsAmount(-upgrade.costs[upgrade.level + 1])

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