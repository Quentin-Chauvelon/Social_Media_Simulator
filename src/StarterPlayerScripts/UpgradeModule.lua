local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(script.Parent:WaitForChild("Utility"))

local UpgradeRF : RemoteFunction = ReplicatedStorage:WaitForChild("Upgrade")

local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local upgradesScreenGui : ScreenGui = playerGui:WaitForChild("Upgrades")
local upgradesBackground : Frame = upgradesScreenGui:WaitForChild("Background")
local upgradesCloseButton : TextButton = upgradesBackground:WaitForChild("Close")
local upgradesContainer : Frame = upgradesBackground:WaitForChild("UpgradesContainer")

local UPGRADES_TWEEN_DURATION : number = 0.2


export type UpgradeModule = {
    upgrades : {upgrade},
    upgradesMachineTouchDetector : Part,
    upgradeButtonConnections : {RBXScriptConnection},
    utility : Utility.Utility,
    new : (utility : Utility.Utility) -> UpgradeModule,
    LoadUpgrades : (self : UpgradeModule) -> nil,
    GetUpgradeWithId : (self : UpgradeModule, id : number) -> upgrade?,
    UpdateUpgradeUI : (self : UpgradeModule, upgradeFrame : Frame, upgrade : upgrade) -> nil,
    OpenUpgradesGui : (self : UpgradeModule) -> nil,
    CloseUpgradesGui : (self : UpgradeModule) -> nil
}

type upgrade = {
    id : number,
    level : number,
    maxLevel : number,
    baseValue : number,
    upgradeValues : {number},
    costs : {number}
}


local UpgradeModule : UpgradeModule = {}
UpgradeModule.__index = UpgradeModule


function UpgradeModule.new(utility : Utility.Utility) : UpgradeModule
    local upgradeModule : UpgradeModule = {}

    upgradeModule.upgrades = {}
    upgradeModule.utility = utility
    upgradeModule.upgradeButtonConnections = {}
    upgradeModule.upgradesMachineTouchDetector = workspace:WaitForChild("UpgradesMachine"):WaitForChild("TouchDetector")

    utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
        upgradesBackground.Size = UDim2.new(utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 0.8, 0.5), 0, 0.7, 0)

        local upgradeCloseButtonUDim = UDim.new(utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 0.12, 0.15), 0)
        upgradesCloseButton.Size = UDim2.new(upgradeCloseButtonUDim, upgradeCloseButtonUDim)

        for _,upgradeBackground : Frame | UIListLayout in ipairs(upgradesContainer:GetChildren()) do
            if upgradeBackground:IsA("Frame") then
                local padding : number = utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 5, 12)
                upgradeBackground.ProgressContainer.Position = UDim2.new(0, padding, 0.5, 0)

                upgradeBackground.Descriptions.Position = UDim2.new(0, padding * 2.5 + upgradeBackground.ProgressContainer.AbsoluteSize.X, 0, 0)
                upgradeBackground.UpgradePurchaseContainer.Position = UDim2.new(1, -padding, 0.95, 0)
            end
        end
    end)

    upgradeModule.upgradesMachineTouchDetector.Touched:Connect(function(hit : BasePart)
        if hit and hit.Parent and hit.Name == "HumanoidRootPart" then
            if Players:GetPlayerFromCharacter(hit.Parent) == lplr then
                upgradeModule:OpenUpgradesGui()
            end
        end
    end)
    
    upgradeModule.upgradesMachineTouchDetector.TouchEnded:Connect(function(hit : BasePart)
        if hit and hit.Parent and hit.Name == "HumanoidRootPart" then
            if Players:GetPlayerFromCharacter(hit.Parent) == lplr then
                upgradeModule:CloseUpgradesGui()
            end
        end
    end)

    return setmetatable(upgradeModule, UpgradeModule)
end


--[[
    Fires the server to load the upgrades and loads the ui for each upgrade
]]--
function UpgradeModule:LoadUpgrades()
    -- fire the server once to get the data and tell it we are ready
    self.upgrades = UpgradeRF:InvokeServer(0)

    for _,upgradeBackground : Frame | UIListLayout in ipairs(upgradesContainer:GetChildren()) do
        if upgradeBackground:IsA("Frame") then
            
            local upgrade : upgrade? = self:GetUpgradeWithId(upgradeBackground.LayoutOrder)
            if upgrade then
                self:UpdateUpgradeUI(upgradeBackground, upgrade)
            end
        end
    end
end


--[[
    Gets the upgrade matching the given id if found

    @param id : number, the id of the upgrade
    @return upgrade?, the upgrade matching the id if it was found, nil otherwise
]]--
function UpgradeModule:GetUpgradeWithId(id : number) : upgrade?
    for _,upgrade : upgrade in pairs(self.upgrades) do
        if upgrade.id == id then
            return upgrade
        end
    end
end


--[[
    Updates the ui corresponding to the given upgrade to match the values

    @param upgradeFrame : Frame, the frame to update
    @param upgrade : upgrade, the upgrade used to update the frame
]]--
function UpgradeModule:UpdateUpgradeUI(upgradeFrame : Frame, upgrade : upgrade)
    local progressContainer : Frame = upgradeFrame.ProgressContainer
    progressContainer.Level.Text = upgrade.level

    local progress : number = (360 / upgrade.maxLevel) * upgrade.level
    if progress > 0 then
        -- set the right frame progress to the progress value or 180 (if progress is greater than 180)
        progressContainer.RightProgressBackground.RightProgressBar.UIGradient.Enabled = true
        progressContainer.RightProgressBackground.RightProgressBar.UIGradient.Rotation = math.min(progress, 180)
        
        if progress > 180 then
            -- set the left frame progress to the progress value or 180 (if progress is greater than 180)
            progressContainer.LeftProgressBackground.LeftProgressBar.UIGradient.Enabled = true
            progressContainer.LeftProgressBackground.LeftProgressBar.UIGradient.Rotation = progress
        end
    end

    if upgrade.id == 1 then
        upgradeFrame.Descriptions.Description.Text =
            '<stroke color="#1D4371" joins="miter" thickness="3"> +'
            .. ((upgrade.upgradeValues[upgrade.level] / upgrade.baseValue) * 100) ..
            '%   >>   </stroke><font color="#5EFF84"><stroke color="#004F09" joins="miter" thickness="3">+'
            .. ((upgrade.upgradeValues[math.min(upgrade.level + 1, 10)] / upgrade.baseValue) * 100) ..
            '%</stroke></font>'
        
    elseif upgrade.id == 2 then
        upgradeFrame.Descriptions.Description.Text =
            '<stroke color="#1D4371" joins="miter" thickness="3"> -'
            .. (upgrade.upgradeValues[upgrade.level] / 1000) ..
            's   >>   </stroke><font color="#5EFF84"><stroke color="#004F09" joins="miter" thickness="3">-'
            .. (upgrade.upgradeValues[math.min(upgrade.level + 1, 10)] / 1000) ..
            's</stroke></font>'

    else
        upgradeFrame.Descriptions.Description.Text =
            '<stroke color="#1D4371" joins="miter" thickness="3"> x'
            .. upgrade.upgradeValues[upgrade.level] ..
            '   >>   </stroke><font color="#5EFF84"><stroke color="#004F09" joins="miter" thickness="3">x'
            .. upgrade.upgradeValues[math.min(upgrade.level + 1, 10)] ..
            '</stroke></font>'
    end

    if upgrade.level < upgrade.maxLevel then
        upgradeFrame.UpgradePurchaseContainer.Price.Text = upgrade.costs[upgrade.level + 1]
    else
        upgradeFrame.UpgradePurchaseContainer.Price.Visible = false
        upgradeFrame.UpgradePurchaseContainer.ImageLabel.Visible = false
        upgradeFrame.UpgradePurchaseContainer.UpgradeButton.AutoButtonColor = false
        upgradeFrame.UpgradePurchaseContainer.UpgradeButton.Active = false
        upgradeFrame.UpgradePurchaseContainer.UpgradeButton.TextLabel.Text = "MAXED"
    end 
end


--[[
    Opens the upgrades gui
]]--
function UpgradeModule:OpenUpgradesGui()
    if not upgradesBackground.Visible then
        
        -- the ui doesn't have a size of 0 because it is kept at a normal size (this allows the ui to be able to be resized even when it's hidden (if the player resizes it's game window))
        local upgradesOriginalSize : UDim2 = upgradesBackground.Size
        upgradesBackground.Size = UDim2.new(0,0,0,0)
        
        self.utility.BlurBackground(true)

        upgradesBackground.Visible = true
        
        upgradesBackground:TweenSize(
            upgradesOriginalSize,
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Linear,
            UPGRADES_TWEEN_DURATION
        )

        -- fire server to upgrade on upgrade button click
        for _,upgradeBackground : Frame | UIListLayout in ipairs(upgradesContainer:GetChildren()) do
            if upgradeBackground:IsA("Frame") then
                table.insert(
                    self.upgradeButtonConnections,
                    upgradeBackground.UpgradePurchaseContainer.UpgradeButton.MouseButton1Down:Connect(function()
                        local upgrade : upgrade = UpgradeRF:InvokeServer(upgradeBackground.LayoutOrder)
                        if upgrade then
                            self:UpdateUpgradeUI(upgradeBackground, upgrade)
                        end
                    end)
                )
            end
        end
        
        local upgradesCloseConnection : RBXScriptConnection
        upgradesCloseConnection = upgradesCloseButton.MouseButton1Down:Connect(function()
            upgradesCloseConnection:Disconnect()
            self:CloseUpgradesGui()
        end)
    end
end


--[[
    Closes the upgrades gui
]]--
function UpgradeModule:CloseUpgradesGui()
    for _,upgradeButtonConnection : RBXScriptConnection in pairs(self.upgradeButtonConnections) do
        upgradeButtonConnection:Disconnect()
    end
    table.clear(self.upgradeButtonConnections)

    self.utility.BlurBackground(false)

    if upgradesBackground.Visible then
        local upgradesOriginalSize : UDim2 = upgradesBackground.Size

        upgradesBackground:TweenSize(
            UDim2.new(0,0,0,0),
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Linear,
            UPGRADES_TWEEN_DURATION,
            false,
            function()
                upgradesBackground.Visible = false
                upgradesBackground.Size = upgradesOriginalSize
            end
        )
    end
end


return UpgradeModule