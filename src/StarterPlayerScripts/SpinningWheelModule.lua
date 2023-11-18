local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage:WaitForChild("Promise"))
local Utility = require(script.Parent:WaitForChild("Utility"))

local SpinWheelRE : RemoteEvent = ReplicatedStorage:WaitForChild("SpinWheel")
local SpinWheelEndedRE : RemoteEvent = ReplicatedStorage:WaitForChild("SpinWheelEnded")
local SwitchWheelRE : RemoteEvent = ReplicatedStorage:WaitForChild("SwitchWheel")

local lplr = Players.LocalPlayer

local playerGui = lplr.PlayerGui

local menuScreenGui : ScreenGui = playerGui:WaitForChild("Menu")
local spinningWheelButton : ImageButton = menuScreenGui:WaitForChild("TabsContainer"):WaitForChild("Container"):WaitForChild("SpinningWheelButton")

local spinningWheelScreenGui : ScreenGui = playerGui:WaitForChild("SpinningWheel")
local spinningWheelBackground : Frame = spinningWheelScreenGui:WaitForChild("Background")
local spinningWheelContainer : Frame = spinningWheelScreenGui:WaitForChild("WheelContainer")
local spinningWheelCloseButton : ImageButton = spinningWheelContainer:WaitForChild("Close")
local freeSpinButton : TextButton = spinningWheelContainer:WaitForChild("FreeSpinButton")
local oddsButton : TextButton = spinningWheelContainer:WaitForChild("OddsButton")
local normalWheelFrame : Frame = spinningWheelContainer:WaitForChild("NormalWheel")
local normalSpinningWheel : ImageLabel = normalWheelFrame:WaitForChild("SpinningWheel")
local buyNormalSpinButton : TextButton = normalWheelFrame:WaitForChild("BuyNormalSpin")
local crazyModeButton : TextButton = normalWheelFrame:WaitForChild("CrazyModeButton")
local timeLeftBeforeNextFreeSpin : TextLabel = normalWheelFrame:WaitForChild("TimeLeftBeforeNextFreeSpin")
local crazyWheelFrame : Frame = spinningWheelContainer:WaitForChild("CrazyWheel")
local crazySpinningWheel : ImageLabel = crazyWheelFrame:WaitForChild("SpinningWheel")
local buyCrazySpinButton : TextButton = crazyWheelFrame:WaitForChild("BuyCrazySpin")
local normalModeButton : TextButton = crazyWheelFrame:WaitForChild("NormalModeButton")

local GREEN_BACKGROUND : Color3 = Color3.fromRGB(89, 255, 70)
local GREEN_BORDER : Color3 = Color3.fromRGB(52, 143, 40)
local ORANGE_BACKGROUND : Color3 = Color3.fromRGB(255, 146, 60)
local ORANGE_BORDER : Color3 = Color3.fromRGB(103, 58, 24)
local GRAY_BACKGROUND : Color3 = Color3.fromRGB(186, 186, 186)
local GRAY_BORDER : Color3 = Color3.fromRGB(107, 107, 107)


type WheelReward = {
    id : number,
    startRotation : number,
    endRotation : number,
    petId : number,
    probability : number
}

type Wheel = {
    id : number,
    rewards : {WheelReward},
    spinningWheelFrame : Frame,
    backgroundColor : Color3,
    borderColor : Color3,
    oddsFrame : Frame,
    arrowLoopImageId : string
}


export type SpinningWheelModule = {
    spinning : boolean,
    normalFreeSpinsLeft : number,
    crazyFreeSpinsLeft : number,
    currentWheel : Wheel,
    timerBeforeNextFreeSpinPromise : Promise.Promise,
    buttonsConnections : {RBXScriptConnection},
    oddsCloseConnection : RBXScriptConnection,
    utility : Utility.Utility,
    new : (utility : Utility.Utility) -> SpinningWheelModule,
    GetRewardWithId : (self: SpinningWheelModule, rewardId : number) -> WheelReward,
    SpinWheel : (self: SpinningWheelModule, rewardId : number) -> nil,
    SwitchWheel : (self: SpinningWheelModule, wheel : string) -> nil,
    UpdateFreeSpinUI : (self: SpinningWheelModule) -> nil,
    StartTimerBeforeNextFreeSpin : (self: SpinningWheelModule) -> nil,
    DisplayOdds : (self: SpinningWheelModule) -> nil,
    HideOdds : (self: SpinningWheelModule) -> nil,
    EnableButtons : (self: SpinningWheelModule) -> nil,
    DisableButtons : (self: SpinningWheelModule) -> nil,
    OpenGui : (self: SpinningWheelModule) -> nil,
    CloseGui : (self: SpinningWheelModule) -> nil
}

local normalWheel : Wheel = {
    id = 1,
    rewards = {
        {
            id = 1,
            startRotation = 216,
            endRotation = 288,
            petId = 5,
            probability = 0.35
        },
        {
            id = 2,
            startRotation = 72,
            endRotation = 144,
            petId = 8,
            probability = 0.3
        },
        {
            id = 3,
            startRotation = 0,
            endRotation = 72,
            petId = 11,
            probability = 0.2
        },
        {
            id = 4,
            startRotation = 288,
            endRotation = 360,
            petId = 19,
            probability = 0.1
        },
        {
            id = 5,
            startRotation = 144,
            endRotation = 216,
            petId = 27,
            probability = 0.05
        },
    },
    spinningWheelFrame = normalSpinningWheel,
    backgroundColor = GREEN_BACKGROUND,
    borderColor = GREEN_BORDER,
    oddsFrame = spinningWheelScreenGui:WaitForChild("NormalOddsBackground"),
    arrowLoopImageId = "http://www.roblox.com/asset/?id=15342813247"
}

local crazyWheel : Wheel = {
    id = 2,
    rewards = {
        {
            id = 1,
            startRotation = 216,
            endRotation = 288,
            petId = 23,
            probability = 0.35
        },
        {
            id = 2,
            startRotation = 72,
            endRotation = 144,
            petId = 25,
            probability = 0.3
        },
        {
            id = 3,
            startRotation = 0,
            endRotation = 72,
            petId = 27,
            probability = 0.2
        },
        {
            id = 4,
            startRotation = 288,
            endRotation = 360,
            petId = 28,
            probability = 0.1
        },
        {
            id = 5,
            startRotation = 144,
            endRotation = 216,
            petId = 105,
            probability = 0.05
        },
    },
    spinningWheelFrame = crazySpinningWheel,
    backgroundColor = ORANGE_BACKGROUND,
    borderColor = ORANGE_BORDER,
    oddsFrame = spinningWheelScreenGui:WaitForChild("CrazyOddsBackground"),
    arrowLoopImageId = "http://www.roblox.com/asset/?id=15372592494"
}


local SpinningWheelModule : SpinningWheelModule = {}
SpinningWheelModule.__index = SpinningWheelModule


function SpinningWheelModule.new(utility : Utility.Utility)
    local spinningWheelModule : SpinningWheelModule = setmetatable({}, SpinningWheelModule)

    spinningWheelModule.spinning = false

    spinningWheelModule.normalFreeSpinsLeft = 0
    spinningWheelModule.crazyFreeSpinsLeft = 0

    spinningWheelModule.currentWheel = normalWheel

    spinningWheelModule.timerBeforeNextFreeSpinPromise = nil

    spinningWheelModule.buttonsConnections = {}
    spinningWheelModule.oddsCloseConnection = nil

    spinningWheelModule.utility = utility

    table.insert(utility.guisToClose, spinningWheelContainer)

    spinningWheelButton.MouseButton1Down:Connect(function()
        spinningWheelModule:OpenGui()
    end)

    return spinningWheelModule
end


function SpinningWheelModule:GetRewardWithId(rewardId : number) : WheelReward
    for _,reward : WheelReward in ipairs(self.currentWheel.rewards) do
        if reward.id == rewardId then
            return reward
        end
    end
end



--[[

]]--
function SpinningWheelModule:SpinWheel(rewardId : number)
    local reward : WheelReward = self:GetRewardWithId(rewardId)
    self.spinning = true

    self:DisableButtons()

    local targetRotation = math.random(reward.startRotation, reward.endRotation)

    local tween = TweenService:Create(
        self.currentWheel.spinningWheelFrame,
        TweenInfo.new(
            math.random(9, 11),
            Enum.EasingStyle.Quart,
            Enum.EasingDirection.Out
        ),
        { Rotation = targetRotation + math.random(12,20) * 360 }
    )

    tween:Play()

    tween.Completed:Wait()
    self.currentWheel.spinningWheelFrame.Rotation %= 360

    SpinWheelEndedRE:FireServer()

    self:EnableButtons()
    self:UpdateFreeSpinUI()

    self.spinning = false
end


--[[
    Switches the current wheel to the specified one and updates the UI accordingly.
    @param wheel : string, The name of the wheel to switch to. Can be "normal" or "crazy".
    @param fireEvent : boolean?, Whether to fire the remote event to switch the wheel on the server. Defaults to false
]]--
function SpinningWheelModule:SwitchWheel(wheel : string, fireEvent : boolean?)
    -- hide the odds before changing the current wheel, otherwise it's going to hide the wrong odds frame
    self:HideOdds()

    if not self.spinning then
        if wheel == "normal" then
            self.currentWheel = normalWheel
            crazyWheelFrame.Visible = false
            normalWheelFrame.Visible = true
        elseif wheel == "crazy" then
            self.currentWheel = crazyWheel
            normalWheelFrame.Visible = false
            crazyWheelFrame.Visible = true
        end

        oddsButton.BackgroundColor3 = self.currentWheel.backgroundColor
        oddsButton.BorderUIStroke.Color = self.currentWheel.borderColor
        oddsButton.ContextualUIStroke.Color = self.currentWheel.borderColor

        freeSpinButton.BackgroundColor3 = self.currentWheel.backgroundColor
        freeSpinButton.UIStroke.Color = self.currentWheel.borderColor
        freeSpinButton.FreeText.UIStroke.Color = self.currentWheel.borderColor
        freeSpinButton.SpinningIcon.Image = self.currentWheel.arrowLoopImageId

        if fireEvent then
            SwitchWheelRE:FireServer(wheel)
        end

        self:UpdateFreeSpinUI()
    end
end


--[[
    Updates the UI for the free spin feature based on the current wheel type and the number of free spins left.
    If there are free spins left, the "Free Spin" button is displayed with the number of free spins left and the background color and border color of the current wheel.
    If there are no free spins left, the "Free Spin" button is hidden and the "Buy Normal Spin" and "Buy Crazy Spin" buttons and "Time Left" text are displayed.
]]--
function SpinningWheelModule:UpdateFreeSpinUI()
    local freeSpinsLeft : number
    if self.currentWheel.id == 1 then
        freeSpinsLeft = self.normalFreeSpinsLeft
    else
        freeSpinsLeft = self.crazyFreeSpinsLeft
    end

    if freeSpinsLeft > 0 then
        timeLeftBeforeNextFreeSpin.Visible = false
        buyNormalSpinButton.Visible = false
        buyCrazySpinButton.Visible = false

        freeSpinButton.FreeText.Text = string.format("FREE (%d)", freeSpinsLeft)

        if not self.spinning then
            freeSpinButton.BackgroundColor3 = self.currentWheel.backgroundColor
            freeSpinButton.UIStroke.Color = self.currentWheel.borderColor
            freeSpinButton.FreeText.UIStroke.Color = self.currentWheel.borderColor
        end
        freeSpinButton.Visible = true

    else
        freeSpinButton.Visible = false

        timeLeftBeforeNextFreeSpin.Visible = true
        buyNormalSpinButton.Visible = true
        buyCrazySpinButton.Visible = true
    end
end


--[[
    Starts a timer that counts down to midnight and resolves a Promise when the timer is complete.
]]--
function SpinningWheelModule:StartTimerBeforeNextFreeSpin()
    self.timerBeforeNextFreeSpinPromise = Promise.new(function(resolve)
        local date = os.date("!*t")
        local timeLeft : number = os.difftime(os.time({year = date.year, month = date.month, day = date.day + 1, hour = 0, min = 0, sec = 0}), os.time())

        while spinningWheelContainer.Visible do
            timeLeftBeforeNextFreeSpin.Text = string.format("%0.2i:%0.2i:%0.2i", (timeLeft / 3600) % 60, (timeLeft / 60) % 60, timeLeft % 60)
            timeLeft -= 1

            task.wait(1)
        end

        resolve()
    end)
end


--[[
    Displays the odds frame.
]]--
function SpinningWheelModule:DisplayOdds()
    self.oddsCloseConnection = self.currentWheel.oddsFrame.CloseButton.MouseButton1Down:Connect(function()
        self:HideOdds()
    end)

    self.currentWheel.oddsFrame.Visible = true
    self.currentWheel.oddsFrame:TweenSizeAndPosition(
        UDim2.new(0.35, 0, 0.7, 0),
        UDim2.new(0.5, 0, 0.55, 0),
        Enum.EasingDirection.InOut,
        Enum.EasingStyle.Linear,
        0.2,
        true
    )
end


--[[
    Hides the odds frame.
]]--
function SpinningWheelModule:HideOdds()
    if self.oddsCloseConnection then
        self.oddsCloseConnection:Disconnect()
        self.oddsCloseConnection = nil
    end

    local oddsFrame : Frame = self.currentWheel.oddsFrame
    oddsFrame:TweenSizeAndPosition(
        oddsButton.Size,
        oddsButton.Position,
        Enum.EasingDirection.InOut,
        Enum.EasingStyle.Linear,
        0.2,
        true,
        function()
            oddsFrame.Visible = false
        end
    )
end


--[[
    Enables all buttons in the spinning wheel GUI, changes the background and border colors to green/orange
]]--
function SpinningWheelModule:EnableButtons()
    freeSpinButton.BackgroundColor3 = self.currentWheel.backgroundColor
    freeSpinButton.UIStroke.Color = self.currentWheel.borderColor
    freeSpinButton.FreeText.UIStroke.Color = self.currentWheel.borderColor
    freeSpinButton.SpinningIcon.Image = self.currentWheel.arrowLoopImageId
    freeSpinButton.AutoButtonColor = true

    oddsButton.BackgroundColor3 = self.currentWheel.backgroundColor
    oddsButton.BorderUIStroke.Color = self.currentWheel.borderColor
    oddsButton.ContextualUIStroke.Color = self.currentWheel.borderColor
    oddsButton.AutoButtonColor = true

    normalModeButton.BackgroundColor3 = GREEN_BACKGROUND
    normalModeButton.BorderUIStroke.Color = GREEN_BORDER
    normalModeButton.ContextualUIStroke.Color = GREEN_BORDER
    normalModeButton.AutoButtonColor = true

    crazyModeButton.BackgroundColor3 = ORANGE_BACKGROUND
    crazyModeButton.BorderUIStroke.Color = ORANGE_BORDER
    crazyModeButton.ContextualUIStroke.Color = ORANGE_BORDER
    crazyModeButton.AutoButtonColor = true

    buyNormalSpinButton.BackgroundColor3 = GREEN_BACKGROUND
    buyNormalSpinButton.UIStroke.Color = GREEN_BORDER
    buyNormalSpinButton.TextLabel.UIStroke.Color = GREEN_BORDER
    buyNormalSpinButton.SpinningIcon.Image = "http://www.roblox.com/asset/?id=15342813247"
    buyNormalSpinButton.AutoButtonColor = true

    buyCrazySpinButton.BackgroundColor3 = ORANGE_BACKGROUND
    buyCrazySpinButton.UIStroke.Color = ORANGE_BORDER
    buyCrazySpinButton.TextLabel.UIStroke.Color = ORANGE_BORDER
    buyCrazySpinButton.SpinningIcon.Image = "http://www.roblox.com/asset/?id=15372592494"
    buyCrazySpinButton.AutoButtonColor = true
end


--[[
    Disables all buttons in the spinning wheel GUI, changes the background and border colors to gray.
]]--
function SpinningWheelModule:DisableButtons()
    freeSpinButton.BackgroundColor3 = GRAY_BACKGROUND
    freeSpinButton.UIStroke.Color = GRAY_BORDER
    freeSpinButton.FreeText.UIStroke.Color = GRAY_BORDER
    freeSpinButton.SpinningIcon.Image = "http://www.roblox.com/asset/?id=15372593976"
    freeSpinButton.AutoButtonColor = false

    oddsButton.BackgroundColor3 = GRAY_BACKGROUND
    oddsButton.BorderUIStroke.Color = GRAY_BORDER
    oddsButton.ContextualUIStroke.Color = GRAY_BORDER
    oddsButton.AutoButtonColor = false

    normalModeButton.BackgroundColor3 = GRAY_BACKGROUND
    normalModeButton.BorderUIStroke.Color = GRAY_BORDER
    normalModeButton.ContextualUIStroke.Color = GRAY_BORDER
    normalModeButton.AutoButtonColor = false

    crazyModeButton.BackgroundColor3 = GRAY_BACKGROUND
    crazyModeButton.BorderUIStroke.Color = GRAY_BORDER
    crazyModeButton.ContextualUIStroke.Color = GRAY_BORDER
    crazyModeButton.AutoButtonColor = false

    buyNormalSpinButton.BackgroundColor3 = GRAY_BACKGROUND
    buyNormalSpinButton.UIStroke.Color = GRAY_BORDER
    buyNormalSpinButton.TextLabel.UIStroke.Color = GRAY_BORDER
    buyNormalSpinButton.SpinningIcon.Image = "http://www.roblox.com/asset/?id=15372593976"
    buyNormalSpinButton.AutoButtonColor = false

    buyCrazySpinButton.BackgroundColor3 = GRAY_BACKGROUND
    buyCrazySpinButton.UIStroke.Color = GRAY_BORDER
    buyCrazySpinButton.TextLabel.UIStroke.Color = GRAY_BORDER
    buyCrazySpinButton.SpinningIcon.Image = "http://www.roblox.com/asset/?id=15372593976"
    buyCrazySpinButton.AutoButtonColor = false
end


--[[
    Opens the spinning wheel GUI and sets up the necessary connections and UI elements.
]]--
function SpinningWheelModule:OpenGui()
    if self.utility.OpenGui(spinningWheelContainer) then

        spinningWheelBackground.Visible = true
        spinningWheelBackground.Active = true
        TweenService:Create(
            spinningWheelBackground,
            TweenInfo.new(
                0.2,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.Out
            ),
            { BackgroundTransparency = 0.4 }
        ):Play()

        self.currentWheel.spinningWheelFrame.Visible = true

        self:UpdateFreeSpinUI()

        self:StartTimerBeforeNextFreeSpin()

        table.insert(self.buttonsConnections, normalModeButton.MouseButton1Down:Connect(function()
            if not self.spinning then
                self:SwitchWheel("normal", true)
            end
        end))

        table.insert(self.buttonsConnections, crazyModeButton.MouseButton1Down:Connect(function()
            if not self.spinning then
                self:SwitchWheel("crazy", true)
            end
        end))

        table.insert(self.buttonsConnections, freeSpinButton.MouseButton1Down:Connect(function()
            if not self.spinning then
                SpinWheelRE:FireServer()
            end
        end))

        table.insert(self.buttonsConnections, buyNormalSpinButton.MouseButton1Down:Connect(function()
            if not self.spinning then
                MarketplaceService:PromptProductPurchase(lplr, 1688137977)
            end
        end))

        table.insert(self.buttonsConnections, buyCrazySpinButton.MouseButton1Down:Connect(function()
            if not self.spinning then
                MarketplaceService:PromptProductPurchase(lplr, 1688138251)
            end
        end))

        table.insert(self.buttonsConnections, oddsButton.MouseButton1Down:Connect(function()
            if not self.spinning then
                self:DisplayOdds()
            end
        end))

        -- set the close gui connection (only do it if the gui was not already open, otherwise multiple connection exist and it is called multiple times)
        self.utility.SetCloseGuiConnection(spinningWheelCloseButton, function()
            self:CloseGui()
        end)
    end
end


--[[
    Closes the spinning wheel GUI and clears all button connections.
]]--
function SpinningWheelModule:CloseGui()
    self:HideOdds()

    for _,buttonConnection : RBXScriptConnection in pairs(self.buttonsConnections) do
        buttonConnection:Disconnect()
    end
    table.clear(self.buttonsConnections)

    spinningWheelBackground.Active = false
    TweenService:Create(
        spinningWheelBackground,
        TweenInfo.new(
            0.2,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.Out
        ),
        { BackgroundTransparency = 1 }
    ):Play()

    self.utility.CloseGui(spinningWheelContainer)
end


return SpinningWheelModule