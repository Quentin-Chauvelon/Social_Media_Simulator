local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(script.Parent:WaitForChild("Utility"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))

local lplr = Players.LocalPlayer

local RebirthRE : RemoteEvent = ReplicatedStorage:WaitForChild("Rebirth")

local playerGui : PlayerGui = lplr.PlayerGui

local rebirthOpenButton : ImageButton = playerGui:WaitForChild("Menu"):WaitForChild("SideButtons"):WaitForChild("RebirthButton")
local rebirthsScreenGui : ScreenGui = playerGui:WaitForChild("Rebirths")
local rebirthsBackground : Frame = rebirthsScreenGui:WaitForChild("Background")
local rebirthCloseButton : ImageButton = rebirthsBackground:WaitForChild("Close")
local rebirthsContentContainer : Frame = rebirthsBackground:WaitForChild("ContentContainer")
local followersResetText : TextLabel = rebirthsContentContainer:WaitForChild("FollowersResetContainer"):WaitForChild("OldFollowersCount"):WaitForChild("CountText")
local followersUpgradeOldText : TextLabel = rebirthsContentContainer:WaitForChild("FollowersUpgradeContainer"):WaitForChild("OldFollowersBonus"):WaitForChild("CountText")
local followersUpgradeNewText : TextLabel = rebirthsContentContainer:WaitForChild("FollowersUpgradeContainer"):WaitForChild("NewFollowersBonus"):WaitForChild("CountText")
local coinsUpgradeOldText : TextLabel = rebirthsContentContainer:WaitForChild("CoinsUpgradeContainer"):WaitForChild("OldCoinsBonus"):WaitForChild("CountText")
local coinsUpgradeNewText : TextLabel = rebirthsContentContainer:WaitForChild("CoinsUpgradeContainer"):WaitForChild("NewCoinsBonus"):WaitForChild("CountText")
local progressBar : Frame = rebirthsContentContainer:WaitForChild("ProgressBarContainer"):WaitForChild("ProgressBar")
local progressBarText : TextLabel = rebirthsContentContainer.ProgressBarContainer:WaitForChild("ProgressBarText")
local rebirthButtons : Frame = rebirthsContentContainer:WaitForChild("RebirthButtons")
local devProductRebirthButton : TextButton = rebirthButtons:WaitForChild("DevProductRebirthButton")
local devProductRebirthButtonText : TextLabel = devProductRebirthButton:WaitForChild("TextLabel")
local rebirthButton : TextButton = rebirthButtons:WaitForChild("RebirthButton")
local rebirthButtonOuterBorder : UIStroke = rebirthButton:WaitForChild("OuterBorder")
local rebirthButtonTextBorder : UIStroke = rebirthButton:WaitForChild("TextBorder")

local followersNeededToRebirth : {number} = {
    100,
    225,
    375,
    550,
    900,
    1500,
    2100,
    3000,
    4250,
    5600,
    7300,
    9700,
    12500,
    16000,
    21000,
    28000,
    34000,
    41000,
    49000,
    63500,
    75500,
    87000,
    100000,
    116500,
    133500,
    152000,
    172500,
    194500,
    218800,
    265500,
    296000,
    330000,
    364000,
    403000,
    444000,
    487000,
    534500,
    584500,
    637000,
    747000,
    811000,
    879000,
    951000,
    1027000,
    1107000,
    1191500,
    1280000,
    1373500,
    1471500,
    1687000,
    1802000,
    1923000,
    2049500,
    2181500,
    2319500,
    2463500,
    2613500,
    2770000,
    293300,
    3310000,
    3497000,
    3692500,
    3895000,
    4106000,
    4324000,
    4550000,
    4785000,
    5028000,
    5280000,
    5886000,
    6172000,
    6467000,
    6772500,
    7087500,
    7413000,
    7748000,
    8095500,
    8451000,
    8819000,
    9738500,
    10151500,
    10576500,
    11013000,
    11464000,
    11926500,
    12402000,
    12890000,
    13392000,
    13908000,
    15239500,
    15813000,
    16401000,
    17005000,
    17624000,
    18258500,
    18909000,
    19575500,
    20258000,
    20957500,
    22814000
}

local REBIRTH_DEV_PRODUCT_ID : number = 1650523473 -- ID for the rebirth's developer product


export type RebirthModule = {
    level : number,
    utility : Utility.Utility,
    followersNeededToRebirth : number,
    updateGuiPromise : {},
    new : (utility : Utility.Utility) -> RebirthModule,
    UpdateFollowersNeededToRebirth : (self : RebirthModule) -> nil,
    OpenGui : (self : RebirthModule) -> nil,
    UpdateGui : (self : RebirthModule) -> nil,
    CloseGui : (self : RebirthModule) -> nil,
}


local RebirthModule : RebirthModule = {}
RebirthModule.__index = RebirthModule


function RebirthModule.new(utility : Utility.Utility)
    local rebirthModule : RebirthModule = {}

    rebirthModule.level = lplr:WaitForChild("leaderstats"):WaitForChild("Rebirth").Value
    rebirthModule.utility = utility
    rebirthModule.followersNeededToRebirth = 0
    
    -- store all UIStroke in a table to change them easily later
    local rebirthsGuiUIStroke : {UIStroke} = {}
    for _,v : Instance in ipairs(rebirthsContentContainer:GetDescendants()) do
        if v:IsA("UIStroke") then
            table.insert(rebirthsGuiUIStroke, v)
        end
    end

    utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
        rebirthsBackground.Size = UDim2.new(utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 0.6, 0.5), 0, 0.7, 0)

        local thickness : number = utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 2, 5)
        for _,uiStroke : UIStroke in ipairs(rebirthsGuiUIStroke) do
            uiStroke.Thickness = thickness
        end

        devProductRebirthButtonText.TextSize = devProductRebirthButton.AbsoluteSize.Y
        devProductRebirthButtonText.Size = UDim2.new(
            0,
            TextService:GetTextSize(
                devProductRebirthButtonText.Text,
                devProductRebirthButtonText.TextSize,
                Enum.Font.FredokaOne,
                Vector2.new(1000, 1000)
            ).X + 20,
            0.9,
            0
        )
    end)

    table.insert(utility.guisToClose, rebirthsBackground)

    -- open the gui when clicking on the rebirth button
    rebirthOpenButton.MouseButton1Down:Connect(function()
        rebirthModule:OpenGui()
    end)

    
    -- fire the client when the player clicks the button to rebirth
    rebirthButton.MouseButton1Down:Connect(function()
        if lplr.leaderstats.Followers.Value >= rebirthModule.followersNeededToRebirth then
            -- fire the server to rebirth
            RebirthRE:FireServer()
        end
    end)


    -- player wants to rebirth with robux
    devProductRebirthButton.MouseButton1Down:Connect(function()
        MarketplaceService:PromptProductPurchase(lplr, REBIRTH_DEV_PRODUCT_ID)
    end)

    return setmetatable(rebirthModule, RebirthModule)
end


--[[
	Updates the amount of followers needed to rebirth based on the rebirth level of the player
]]--
function RebirthModule:UpdateFollowersNeededToRebirth()
    local nextRebirthLevel : number = lplr:WaitForChild("leaderstats"):WaitForChild("Rebirth").Value + 1

    -- if the player's rebirth level is less than 100, take the value from the table, otherwise use the formula to calculate the amount needed
    if followersNeededToRebirth[nextRebirthLevel] then
        self.followersNeededToRebirth = followersNeededToRebirth[nextRebirthLevel]
    else
        self.followersNeededToRebirth = 1000 * math.round((2.35085 * (math.pow(nextRebirthLevel, 3.34297)) + 359.514) * (1 + math.floor(nextRebirthLevel / 10) / 10) / 1000)
    end
end


--[[
	Opens the rebirth gui
]]--
function RebirthModule:OpenGui()
    -- open the gui
    if self.utility.OpenGui(rebirthsBackground) then

        -- set the close gui connection (only do it if the gui was not already open, otherwise multiple connection exist and it is called multiple times)
        self.utility.SetCloseGuiConnection(rebirthCloseButton, function()
            self:CloseGui()
        end)
    end

    -- update the upgrades values + start upgrading the follower every few frames
    self:UpdateGui()
end


--[[
	Updates the gui (follower count, button color...) every few frames until the player closes the gui
]]--
function RebirthModule:UpdateGui()
    self.updateGuiPromise = Promise.new(function(resolve)
        -- update the followers upgrade boost values
        followersUpgradeOldText.Text = tostring(lplr.leaderstats.Rebirth.Value * 10) .. "%"
        followersUpgradeNewText.Text = tostring((lplr.leaderstats.Rebirth.Value + 1) * 10) .. "%"

        -- update the coins upgrade boost values
        coinsUpgradeOldText.Text = string.format("%.2f", tostring(0.05 + (lplr.leaderstats.Rebirth.Value / 100))) .. "%"
        coinsUpgradeNewText.Text = string.format("%.2f", tostring(0.05 + ((lplr.leaderstats.Rebirth.Value + 1) / 100))) .. "%"

        while rebirthsBackground.Visible do
            local followersValue : number = lplr.leaderstats.Followers.Value

            -- change the button color based on if the player has enough followers to rebirth
            if followersValue >= self.followersNeededToRebirth then
                rebirthButton.AutoButtonColor = true
                rebirthButton.BackgroundColor3 = Color3.fromRGB(255, 212, 52)
                rebirthButtonOuterBorder.Color = Color3.fromRGB(198, 139, 43)
                rebirthButton.TextColor3 = Color3.new(1,1,1)
                rebirthButtonTextBorder.Color = Color3.fromRGB(255, 180, 56)
            else
                rebirthButton.AutoButtonColor = false
                rebirthButton.BackgroundColor3 = Color3.fromRGB(217, 217, 217)
                rebirthButtonOuterBorder.Color = Color3.fromRGB(166, 166, 166)
                rebirthButton.TextColor3 = Color3.fromRGB(130, 130, 130)
                rebirthButtonTextBorder.Color = Color3.fromRGB(235, 235, 235)
            end

            -- change the amount of followers text
            followersResetText.Text = self.utility.AbbreviateNumber(lplr.leaderstats.Followers.Value)

            -- change the progress bar text and progress
            progressBar.Size = UDim2.new(math.min(followersValue / self.followersNeededToRebirth, 1), 0, 1, 0)
            progressBarText.Text = string.format("%s/%s (%d%%)", self.utility.AbbreviateNumber(followersValue), self.utility.AbbreviateNumber(self.followersNeededToRebirth), math.round(math.min((followersValue / self.followersNeededToRebirth) * 100, 100)))

            for _=1,5 do
                RunService.Heartbeat:Wait()
            end
        end

        resolve()
    end)
end


--[[
	Closes the gui
]]--
function RebirthModule:CloseGui()
    self.utility.CloseGui(rebirthsBackground)
end


return RebirthModule