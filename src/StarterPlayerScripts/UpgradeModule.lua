local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpgradeRF : RemoteFunction = ReplicatedStorage:WaitForChild("Upgrade")

local upgradesList : Frame



export type UpgradeModule = {
    upgrades : {upgrade},
    new : () -> UpgradeModule
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


function UpgradeModule.new() : UpgradeModule
    local upgradeModule : UpgradeModule = {}

    -- fire the server once to get the data and tell it we are ready
    upgradeModule.upgrades = UpgradeRF:InvokeServer()

    for _,upgradeContainer : Frame | UIListLayout in ipairs(upgradesList:GetChildren()) do
        if upgradeContainer:IsA("Frame") then
            upgradeContainer.UpgradeButton.MouseButton1Down:Connect(function()
                
                local upgrade : upgrade = UpgradeRF:InvokeServer(upgradeContainer.Id.Value)


            end)
        end
    end

    return setmetatable(upgradeModule, UpgradeModule)
end


return UpgradeModule