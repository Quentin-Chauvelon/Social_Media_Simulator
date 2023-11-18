local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(script.Parent:WaitForChild("Utility"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))

local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local menuScreenGui : ScreenGui = playerGui:WaitForChild("Menu")
local menuFollowersIcon : ImageLabel = menuScreenGui:WaitForChild("TabsContainer"):WaitForChild("FollowersContainer"):WaitForChild("FollowersIcon")
local menuCoinsIcon : ImageLabel = menuScreenGui:WaitForChild("TabsContainer"):WaitForChild("CoinsContainer"):WaitForChild("CoinsIcon")
local nextEventBackground : Frame = menuScreenGui.TabsContainer:WaitForChild("Container"):WaitForChild("NextEvent")
local nextEventIcon : ImageLabel = nextEventBackground:WaitForChild("Icon")
local nextEventTimer : TextLabel = nextEventBackground:WaitForChild("Timer")

local eventsScreenGui : ScreenGui = playerGui:WaitForChild("Events")

local timeLeftBeforeStart : TextLabel = eventsScreenGui:WaitForChild("TimeLeftBeforeStart")

local countdownProgressBarContainer : CanvasGroup = eventsScreenGui:WaitForChild("CountdownProgressBarContainer")
local countdownProgressBar : Frame = countdownProgressBarContainer:WaitForChild("ProgressBar")
local countdownTimer : TextLabel = countdownProgressBarContainer:WaitForChild("Timer")

local collectedContainer : Frame = eventsScreenGui:WaitForChild("CollectedContainer")
local collectedText : TextLabel = collectedContainer:WaitForChild("Collected")
local collectedIcon : ImageLabel = collectedContainer:WaitForChild("Icon")

local rainEventCoins : Folder = workspace:WaitForChild("RainEventCoins")
local eventIconsTweens : Folder = eventsScreenGui:WaitForChild("EventIconsTweens")


type Event = {
    id : number,
    name : string,
    duration : number,
    startEvent : () -> nil,
    backgroundColor : Color3,
    borderColor : Color3,
    progressBarColor : Color3,
    eventIcon : string
}

export type EventsModule = {
    timeBeforeNextEvent : number,
    eventInProgress : boolean,
    coinsCollected : number,
    nextEvent : Event,
    updateTimeLeftBeforeEventStartPromise : Promise.Promise,
    countdownPromise : Promise.Promise,
    new : (utility : Utility.Utility) -> EventsModule,
    UpdateNextEvent : (self : EventsModule, event : Event) -> nil,
    DisplayTimeLeftBeforeEventStart : (self : EventsModule, timeLeft : number) -> nil,
    StartCountdown : (self : EventsModule, text : string, duration : number) -> nil,
    CollectedEventCoin : (self : EventsModule, gain : number) -> nil,
    StartEvent : (self : EventsModule) -> nil,
    EndEvent : (self : EventsModule) -> nil
}


local EventsModule : EventsModule = {}
EventsModule.__index = EventsModule


function EventsModule.new(utility : Utility.Utility)
    local eventsModule : EventsModule = setmetatable({}, EventsModule)

    eventsModule.timeBeforeNextEvent = 0
    eventsModule.eventInProgress = false
    eventsModule.coinsCollected = 0
    eventsModule.nextEvent = nil

    eventsModule.updateTimeLeftBeforeEventStartPromise = nil
    eventsModule.countdownPromise = nil

    eventsModule.utility = utility

    eventsModule.updateTimeLeftBeforeEventStartPromise = Promise.new(function()
        while true do
            nextEventTimer.Text = string.format("%02d:%02d", math.floor(eventsModule.timeBeforeNextEvent / 60), eventsModule.timeBeforeNextEvent % 60)

            if not eventsModule.eventInProgress and eventsModule.timeBeforeNextEvent > 0 then
                eventsModule.timeBeforeNextEvent -= 1
            end

            task.wait(1)
        end
    end)

    return eventsModule
end


--[[
    Updates the next event and its UI elements.

    @param event The event to update to
]]--
function EventsModule:UpdateNextEvent(event : Event)
    if self.nextEvent then
        self:EndEvent()
    end

    self.nextEvent = event
    self.timeBeforeNextEvent = 615 -- 10m15s

    if nextEventBackground then
        nextEventBackground.BackgroundColor3 = event.backgroundColor
        nextEventBackground.UIStroke.Color = event.borderColor
        nextEventIcon.Image = event.eventIcon
    end
end


--[[
    Displays the time left before an event starts.

    @param timeLeft : number, the time left in minutes before the event starts.
]]--
function EventsModule:DisplayTimeLeftBeforeEventStart(timeLeft : number)
    self.timeBeforeNextEvent = timeLeft * 60

    timeLeftBeforeStart.TextColor3 = self.nextEvent.backgroundColor
    timeLeftBeforeStart.UIStroke.Color = self.nextEvent.borderColor
    timeLeftBeforeStart.Text = string.format("%s event starting in %d minutes", self.nextEvent.name, timeLeft)

    timeLeftBeforeStart.Visible = true
    task.wait(12)
    timeLeftBeforeStart.Visible = false
end


--[[
    Starts a countdown for the next event with the given duration.

    @param text : string, The text to display in the countdown.
    @param duration : number, The duration of the countdown in seconds.
]]--
function EventsModule:StartCountdown(text : string, duration : number)
    -- if a promise is already running, cancel it
    if self.countdownPromise then
        self.countdownPromise:cancel()
        self.countdownPromise = nil
    end

    countdownProgressBarContainer.BackgroundColor3 = self.nextEvent.backgroundColor
    countdownProgressBarContainer.UIStroke.Color = self.nextEvent.borderColor
    countdownProgressBar.BackgroundColor3 = self.nextEvent.progressBarColor
    countdownTimer.UIStroke.Color = self.nextEvent.borderColor
    countdownProgressBar.Size = UDim2.new(0,0,1,0)

    -- Fade in
    countdownProgressBarContainer.Visible = true
    TweenService:Create(
        countdownProgressBarContainer,
        TweenInfo.new(
            1,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut
        ),
        { GroupTransparency = 0 }
    ):Play()

    countdownProgressBar:TweenSize(
        UDim2.new(1,0,1,0),
        Enum.EasingDirection.InOut,
        Enum.EasingStyle.Linear,
        duration
    )

    self.countdownPromise = Promise.new(function(resolve)
        for timeLeft = duration, 0, -1 do
            countdownTimer.Text = string.format(text, self.nextEvent.name, timeLeft)
            task.wait(1)
        end

        resolve()
    end)
    :andThen(function()
        self.countdownPromise = nil

        --Fade out
        TweenService:Create(
            countdownProgressBarContainer,
            TweenInfo.new(
                1,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.InOut
            ),
            { GroupTransparency = 1 }
        ):Play()

        task.wait(1)
        countdownProgressBarContainer.Visible = false
    end)
end


--[[
    Increases the coins collected by the player and updates the collectedText UI element.
    @param gain : number, The amount of coins gained.
]]--
function EventsModule:CollectedEventCoin(gain : number)
    self.coinsCollected += gain

    collectedText.Text = string.format("Collected: %s", self.utility.AbbreviateNumber(self.coinsCollected))
end


--[[ 
    Starts the event and updates the UI elements to reflect the next event.
    Then, it starts a coroutine that loops through all the coins to rotate them.
    If a coin is transparent, it means it has just been created, so we tween its size and position to add a growing effect.
    Finally, it starts a countdown for the event duration.
]]--
function EventsModule:StartEvent()
    self.eventInProgress = true

    collectedText.TextColor3 = self.nextEvent.backgroundColor
    collectedText.UIStroke.Color = self.nextEvent.borderColor
    collectedIcon.Image = self.nextEvent.eventIcon
    collectedContainer.Visible = true

    coroutine.wrap(function()
        while true do
            -- Loop through all the coins in the folder and rotate them
            for _,coin : Part in ipairs(rainEventCoins:GetChildren()) do
                coin.CFrame = coin.CFrame * CFrame.Angles(0, math.rad(1), 0)

                if coin.Transparency == 1 then
                    coin.Transparency = 0

                    TweenService:Create(
                        coin,
                        TweenInfo.new(
                            0.5,
                            Enum.EasingStyle.Linear,
                            Enum.EasingDirection.InOut
                        ),
                        {
                            Size = Vector3.new(0.2,5,5),
                            Position = coin.Position + Vector3.new(0,2,0),
                        }
                    ):Play()
                end
            end

            RunService.Heartbeat:Wait()
        end
    end)()

    self:StartCountdown("%s event ends in %d seconds", self.nextEvent.duration)
end


--[[
    Ends the event and resets the UI elements.
]]--
function EventsModule:EndEvent()
    self.eventInProgress = false
    self.coinsCollected = 0

    if self.countdownPromise then
        self.countdownPromise:cancel()
        self.countdownPromise = nil
    end

    local TWEEN_DURATION : number = 0.5
    local DELAY : number = 0.1

    for _=1,8 do
        local icon : ImageLabel = Instance.new("ImageLabel")
        icon.BackgroundTransparency = 1
        icon.Position = UDim2.new(0, collectedIcon.AbsolutePosition.X, 0, collectedIcon.AbsolutePosition.Y)

        if self.nextEvent.id == 1 then
            icon.Size = UDim2.new(0, menuFollowersIcon.AbsoluteSize.X, 0, menuFollowersIcon.AbsoluteSize.Y)
        else
            icon.Size = UDim2.new(0, menuCoinsIcon.AbsoluteSize.X, 0, menuCoinsIcon.AbsoluteSize.Y)
        end
        icon.Image = self.nextEvent.eventIcon

        local uiAspectRatioConstraint : UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
        uiAspectRatioConstraint.Parent = icon

        icon.Parent = eventIconsTweens

        local target : UDim2
        if self.nextEvent.id == 1 then
            target = UDim2.new(0, menuFollowersIcon.AbsolutePosition.X, 0, menuFollowersIcon.AbsolutePosition.Y)
        else
            target = UDim2.new(0, menuCoinsIcon.AbsolutePosition.X, 0, menuCoinsIcon.AbsolutePosition.Y)
        end

        icon:TweenPosition(
            target,
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Linear,
            TWEEN_DURATION
        )

        task.wait(DELAY)
    end

    task.wait((TWEEN_DURATION + DELAY) * 8)

    eventIconsTweens:ClearAllChildren()
    collectedText.Text = "Collected: 0"
    collectedContainer.Visible = false
end


return EventsModule