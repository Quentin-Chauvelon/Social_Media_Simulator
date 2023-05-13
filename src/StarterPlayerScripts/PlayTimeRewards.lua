local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Promise = require(ReplicatedStorage:WaitForChild("Promise"))

local CollectPlayTimeRewardRF : RemoteFunction = ReplicatedStorage:WaitForChild("CollectPlayTimeReward")

local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local playTimeRewardsUI : ScreenGui = playerGui:WaitForChild("PlayTimeRewards")
local allRewards : Frame = playTimeRewardsUI:WaitForChild("AllRewards")
local nextRewardChest : ImageButton = playTimeRewardsUI:WaitForChild("NextReward"):WaitForChild("Chest")
local collectedReward : Frame = playTimeRewardsUI:WaitForChild("CollectedReward")

local defaultRewards : {number} = {120, 300, 600, 900, 1_500, 2_400, 3_600, 5_400, 7_200, 10_800, 14_400, 18_000}


export type PlayTimeRewards = {
    timePlayedToday : number,
    nextReward : number,
    isNextRewardReady : boolean,
    nextRewardTimer : TextLabel,
    promise : Promise.Promise,
    tweenChest : Promise.Promise,
    new : (timePlayedToday : number, nextRewardTimer : TextLabel) -> PlayTimeRewards,
    FormatTimeForTimer : (self : PlayTimeRewards, timeUntilNextReward : number) -> string,
    NextRewardClick : (self : PlayTimeRewards) -> nil,
    StartTimer : (self : PlayTimeRewards) -> nil,
    SyncTimer : (timePlayedToday : number) -> nil,
}

type PlayTimeReward = {
    reward : string,
    value : number
}


local PlayTimeRewards : PlayTimeRewards = {}
PlayTimeRewards.__index = PlayTimeRewards


--[[
    Creates the playTimeRewards table

    @param timePlayedToday : number, the amount of time the player has played today (when the server first fire the event to sync the timer)
    @param nextRewardTimer : TextLabel, the text label to update when the timer changes (every second)
]]--
function PlayTimeRewards.new(timePlayedToday : number, nextRewardTimer : TextLabel)
    local playTimeRewards = {}

    playTimeRewards.timePlayedToday = timePlayedToday
    playTimeRewards.nextReward = lplr.NextReward.Value
    playTimeRewards.isNextRewardReady = false

    playTimeRewards.nextRewardTimer = nextRewardTimer

    return setmetatable(playTimeRewards, PlayTimeRewards)
end


--[[
    Formats the given time to mm:ss

    @param timePlayedToday : number, the amount to format in seconds
    @return string, the formatted time
]]--
local function FormatTimeForTimer(timeUntilNextReward : number) : string
    local min : number | string = math.floor(timeUntilNextReward / 60)
    local sec : number | string = timeUntilNextReward % 60

    if min < 0 or sec < 0 then
        return "00:00"
    end

    min = min < 10 and "0" .. tostring(min) or tostring(min)
    sec = sec < 10 and "0" .. tostring(sec) or tostring(sec)

    return min .. ":" .. sec
end


--[[
    Detects the click on the next reward chest at the top of the screen.
    Either collects the reward, or show the time left to get all rewards
]]--
function PlayTimeRewards:NextRewardClick()
    nextRewardChest.MouseButton1Down:Connect(function()
        local reward : PlayTimeReward = CollectPlayTimeRewardRF:InvokeServer()

        -- if there was a reward to collect
        if reward then
            self.isNextRewardReady = false
            self.nextReward = lplr.NextReward.Value

            self:StartTimer()

            if reward.reward == "followers" then
                collectedReward.Reward.Image = ""
                collectedReward.Reward.TextLabel.TextColor3 = Color3.fromRGB(209, 44, 255)

            elseif reward.reward == "coins" then
                collectedReward.Reward.Image = ""
                collectedReward.Reward.TextLabel.TextColor3 = Color3.fromRGB(255, 251, 36)
            end

            collectedReward.Reward.TextLabel.Text = tostring(reward.value)
            
            -- since self.nextReward is equal to the next reward and we want the previous one, we take it from the table
            local timePlayed : number = 0
            for i,v : number in pairs(defaultRewards) do

                if v == self.nextReward then
                    -- if i is equal to 1, return the first value of the table since we can't return the 0th value
                    timePlayed = (i > 1) and defaultRewards[i - 1] or defaultRewards[1]
                end
            end

            -- if the value couldn't be found, which would happen if nextReward is equal to math.huge (when the players has collected all the rewards), we return the last value
            if timePlayed == 0 then
                timePlayed = defaultRewards[#defaultRewards]
            end
            
            -- make the tick image visible and hide the timer in the all rewards frame, run this before updating self.nextReward
            for _,reward : Frame | UIGridLayout | UICorner in ipairs(allRewards.Background:GetChildren()) do
                if reward:IsA("Frame") and reward:GetAttribute("TimePlayed") == timePlayed then
                    reward.Timer.Visible = false
                    reward.Collected.Visible = true
                end
            end

            collectedReward.Visible = true
            collectedReward:TweenSize(UDim2.new(0.8, 0, 0.8, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)

            -- tween to spin the background foverer
            local backgroundTween : Tween = TweenService:Create(
                collectedReward.Background,
                TweenInfo.new(
                    8,
                    Enum.EasingStyle.Linear,
                    Enum.EasingDirection.InOut,
                    math.huge
                ),
                {
                    Rotation = collectedReward.Background.Rotation + 360
                }
            )
            backgroundTween:Play()

            -- detect when the player clicks the collect button to collect the reward
            local collectClick : RBXScriptConnection
            collectClick = collectedReward.Collect.MouseButton1Down:Connect(function()
                -- disconnect the event
                collectClick:Disconnect()

                collectedReward:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, 0.5)

                -- hide the collectedReward frame after the tween is completed
                Promise.new(function(resolve)
                    task.wait(0.5)

                    -- hide the frame
                    collectedReward.Visible = false

                    -- cancel the background spinning tween
                    backgroundTween:Cancel()

                    resolve()
                end)
            end)

        -- else if there is no reward to collect, display all the times left for all rewards
        else
                
            -- if the frame is hidden, display it
            if not allRewards.Visible then
                allRewards.Visible = true
                allRewards:TweenPosition(UDim2.new(0.5, 0, 0, 5), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.3)

                Promise.new(function(resolve)
                    local closeClickedConnection : RBXScriptConnection
                    closeClickedConnection = allRewards.Close.MouseButton1Down:Connect(function()
                        -- disconnect the event
                        closeClickedConnection:Disconnect()
                        
                        allRewards:TweenPosition(UDim2.new(0.5, 0, -1, 0), Enum.EasingDirection.InOut, Enum.EasingStyle.Quad, 0.3)

                        resolve()
                    end)

                    while true do
                        -- change the tween time of all the frames
                        for _,reward : Frame | UIGridLayout | UICorner in ipairs(allRewards.Background:GetChildren()) do
                            if reward:IsA("Frame") and reward.Timer.Visible then
                                reward.Timer.Text = FormatTimeForTimer(reward:GetAttribute("TimePlayed") - self.timePlayedToday)
                            end
                        end

                        task.wait(1)
                    end
                end)
                :finally(function()
                    -- hide the frame after the tween completes
                    Promise.new(function(resolve)
                        task.wait(0.3)
                        allRewards.Visible = false
                        
                        resolve()
                    end)
                end
                )
            end
        end
    end)
end


--[[
    Creates a promise and start the timer (update the timePlayedToday variable every second)
]]--
function PlayTimeRewards:StartTimer()
    -- if the player already got all the rewards, don't create the promise
    if self.timePlayedToday > 18_000 then return end

    self.promise = Promise.new(function(resolve)

        while true do
            task.wait(1)
            
            -- only keep counting if the reward can't be collected yet
            if not self.isNextRewardReady then
                self.timePlayedToday  += 1
                self.nextRewardTimer.Text = FormatTimeForTimer(self.nextReward - self.timePlayedToday)
                
                -- if the text is hidden, show it (happens after collecting the reward where we need to wait for the first sync before showing the text)
                if not self.nextRewardTimer.Visible then
                    self.nextRewardTimer.Visible = true
                end
                
                -- if the player got all the rewards, stop the promise
                if self.timePlayedToday > 18_000 then
                    resolve()
                end
            end
        end
    end)
end


--[[
    Every 15 seconds, the server fires the client to sync the timer (in case the client would be off by a few seconds)
]]--
function PlayTimeRewards:SyncTimer(timePlayedToday : number)
    self.timePlayedToday = timePlayedToday

    -- if the reward is ready to be collected
    if timePlayedToday >= self.nextReward then
        self.isNextRewardReady = true
        
        -- stop the promise
        self.promise:cancel()

        -- hide the timer text
        self.nextRewardTimer.Visible = false

        -- shake the chest
        self.tweenChest = Promise.new(function(resolve)
            local tweenInfo : TweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true)

            local leftShakeTween : Tween = TweenService:Create(
                nextRewardChest,
                tweenInfo,
                {Rotation = -8}
            )

            local rightShakeTween : Tween = TweenService:Create(
                nextRewardChest,
                tweenInfo,
                {Rotation = 8}
            )

            -- shake the chest repeatedly until the player collects the reward
            repeat
                leftShakeTween:Play()
                leftShakeTween.Completed:Wait()

                rightShakeTween:Play()
                rightShakeTween.Completed:Wait()

                leftShakeTween:Play()
                leftShakeTween.Completed:Wait()

                task.wait(5)
            until not self.isNextRewardReady

            resolve()
        end)

        self.nextReward = lplr.NextReward.Value
    end
end


return PlayTimeRewards