local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local PlayerModule = require(ServerScriptService:WaitForChild("Player"))

DataStore2.Combine("SMS", "upgrades")


-- list of the player's upgrades
local defaultUpgrades : {upgrade} = {
    -- walkSpeed
    {
        id = 1,
        level = 1,
        maxLevel = 10,
        baseValue = 16,
        upgradeValues = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9},
        costs = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
    },
    
    -- bot speed
    {
        id = 2,
        level = 1,
        maxLevel = 10,
        baseValue = 3000,
        upgradeValues = {2950, 2900, 2850, 2800, 2750, 2700, 2650, 2600, 2550, 2500},
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
    CanUpgrade : (self : UpgradeModule, p : PlayerModule.PlayerModule, upgrade : upgrade, id : number) -> boolean,
    ApplyUpgrade : (self : UpgradeModule, p : PlayerModule.PlayerModule, upgrade : upgrade) -> nil,
    ApplyUpgrades : (self : UpgradeModule, p : PlayerModule.PlayerModule) -> nil,
    Upgrade : (self : UpgradeModule, p : PlayerModule.PlayerModule, id : number) -> {upgrade} | upgrade,
    GetUpgradeWithId : (self : UpgradeModule, id : number) -> upgrade?
}

type upgrade = {
    id : number,
    level : number,
    maxLevel : number,
    baseValue : number,
    upgradeValues : number,
    costs : number
}


local UpgradeModule : UpgradeModule = {}
UpgradeModule.__index = UpgradeModule


function UpgradeModule.new(plr : Player) : UpgradeModule
    local upgradeModule : UpgradeModule = {}

    upgradeModule.upgrades = DataStore2("upgrades", plr):Get(defaultUpgrades)
    upgradeModule.firstFire = true

    return setmetatable(upgradeModule, UpgradeModule)
end


function UpgradeModule:CanUpgrade(upgrade : upgrade, id : number) : boolean
    if upgrade.id == id then
        if upgrade.level + 1 < upgrade.maxLevel then
            return true
        end
    end

    return false
end


function UpgradeModule:ApplyUpgrade(p : PlayerModule.PlayerModule, upgrade : upgrade)
    if upgrade.id == 1 then
        if p.player.Character then
            p.player.Character.WalkSpeed = upgrade.baseValue + upgrade.upgradeValues[upgrade.level]
        end

    elseif upgrade.id == 2 then
        p.postModule.autoPostInverval = upgrade.baseValue - upgrade.upgradeValues[upgrade.level]

    elseif upgrade.id == 3 then
        p.followersMultiplier = upgrade.baseValue + upgrade.upgradeValues[upgrade.level] + p.gamepassModule:GetFollowersMultiplier()

    elseif upgrade.id == 4 then
        p.coinsMultiplier = upgrade.baseValue + upgrade.upgradeValues[upgrade.level] + p.gamepassModule:GetCoinsMultiplier()
    end
end


function UpgradeModule:ApplyUpgrades(p : PlayerModule.PlayerModule)
    for _,upgrade : upgrade in pairs(self.upgrades) do
        self:ApplyUpgrade(p, upgrade)
    end
end


function UpgradeModule:Upgrade(p : PlayerModule.PlayerModule, id : number) : {upgrade} | upgrade
    if self.firstFire then
        self.firstFire = nil

        self:ApplyUpgrades(p)
        return self.upgrades
    end

    local upgrade : upgrade? = self:GetUpgradeWithId(id)

    if upgrade then
        if self:CanUpgrade(upgrade) then
            
            if p:HasEnoughCoins(upgrade.costs[upgrade.level + 1]) then
                p:UpdateCoinsAmount(-upgrade.costs[upgrade.level + 1])

                self.upgrades[id].level += 1
                DataStore2("upgrades", p.player):Set(self.upgrades)

                self:ApplyUpgrade(p, upgrade)

                return self.upgrades[id]
            end
        end
    end
end


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


return UpgradeModule