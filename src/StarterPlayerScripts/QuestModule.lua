local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(script.Parent:WaitForChild("Utility"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))

local UpdateQuestProgressRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpdateQuestProgress")
local ClaimQuestRewardRF : RemoteFunction = ReplicatedStorage:WaitForChild("ClaimQuestReward")

local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local menuScreenGui : ScreenGui = playerGui:WaitForChild("Menu")
local questsOpenButton : ImageButton = menuScreenGui:WaitForChild("SideButtons"):WaitForChild("QuestsButton")
local questCompletedNotification : Frame = menuScreenGui:WaitForChild("QuestCompleted")
local questCompletedClaimButton : TextButton = questCompletedNotification:WaitForChild("ClaimButton")
local questCompletedRewardIcon : ImageLabel = questCompletedNotification:WaitForChild("RewardContainer"):WaitForChild("RewardIcon")
local questCompletedRewardText : TextLabel = questCompletedNotification.RewardContainer:WaitForChild("RewardText")

local questsScreenGui : ScreenGui = playerGui:WaitForChild("Quests")
local questsBackground : Frame = questsScreenGui:WaitForChild("Background")
local questsContentContainer : Frame = questsBackground:WaitForChild("ContentContainer")
local questsCloseButton : TextButton = questsBackground:WaitForChild("Close")
local streakContainer : Frame = questsContentContainer:WaitForChild("StreakContainer")
local questsRefreshTime : TextLabel = questsContentContainer:WaitForChild("DailyQuests"):WaitForChild("RefreshTime")
local questsContainer : Frame = questsContentContainer:WaitForChild("QuestsContainer")

local petRewardContainer : Frame = questsScreenGui:WaitForChild("PetReward")
local petRewardBackground : ImageLabel = petRewardContainer:WaitForChild("Background")
local petRewardClaimButton : TextButton = petRewardContainer:WaitForChild("ClaimButton")

local questTemplate : Frame = ReplicatedStorage:WaitForChild("QuestTemplate")


type QuestStatus = {
    Pending : number,
    Completed : number,
    Claimed : number
}

local QuestStatus : QuestStatus = {
    Pending = 0,
    Completed = 1,
    Claimed = 2
}

type QuestRewardType = {
    Followers : number,
    Coins : number
}

local QuestRewardTypes : QuestRewardType = {
    Followers = 0,
    Coins = 1
}

type QuestType = {
    GetXFollowers : number,
    GetXCoins : number,
    UpgradeOnce : number,
    PlayXMinutesToday : number,
    OpenOneEgg : number,
    GetARarePet : number,
    PostXTimes : number,
    CraftOnePetIntoBig : number,
    CraftOnePetIntoHuge : number,
    UpgradeOnePetToShiny : number,
    UpgradeOnePetToRainbow : number
}

local QuestTypes : QuestType = {
    GetXFollowers = 0,
    GetXCoins = 1,
    UpgradeOnce = 2,
    PlayXMinutesToday = 3,
    OpenOneEgg = 4,
    GetARarePet = 5,
    PostXTimes = 6,
    CraftOnePetIntoBig = 7,
    CraftOnePetIntoHuge = 8,
    UpgradeOnePetToShiny = 9,
    UpgradeOnePetToRainbow = 10
}

export type Quest = {
    id : number,
    name : string,
    questType : QuestType,
    progress : number,
    target : number,
    status : QuestStatus,
    rewardValue : number,
    rewardType : QuestRewardType,
    frame : Frame
}

type QuestStreak = {
    lastDayCompleted : number,
    streak : number
}


export type QuestModule = {
    quests : {Quest},
    claimRewardConnections : {RBXScriptConnection},
    refreshQuestsPromise : Promise.Promise,
    utility : Utility.Utility,
    new : () -> QuestModule,
    OpenGui : (self : QuestModule) -> nil,
    AddQuest : (self : QuestModule, quest : Quest) -> nil,
    DeleteAllQuests : (self : QuestModule) -> nil,
    UpdateProgress : (self : QuestModule, id : number, progres : number) -> nil,
    CompleteQuest : (self : QuestModule, id : number) -> nil,
    DisplayQuestCompletedNotification : (self : QuestModule, id : number) -> nil,
    ClaimReward : (self : QuestModule, id : number) -> nil,
    UpdateStreak : (self : QuestModule, streak : number) -> nil,
    CloseGui : (self : QuestModule) -> nil
}


local QuestModule : QuestModule = {}
QuestModule.__index = QuestModule


function QuestModule.new(utility : Utility.Utility)
    local questModule : QuestModule = setmetatable({}, QuestModule)

    questModule.quests = {}
    questModule.claimRewardConnections = {}

    questModule.refreshQuestsPromise = Promise.new(function()
        while true do
            local date = os.date("!*t")
            local timeLeft : number = os.difftime(os.time({year = date.year, month = date.month, day = date.day + 1, hour = 0, min = 0, sec = 0}), os.time())
            -- local timeLeft : number = os.difftime(os.time({year = date.year, month = date.month, day = date.day, hour = date.hour, min = date.min + 1, sec = 0}), os.time())

            -- remove 1 from timeLeft for 60 seconds so that we don't have to recalculate the timeLeft using os functions every second (would be too expensive for no reason)
            for _=60,1,-1 do
                questsRefreshTime.Text = string.format("Refreshes in: %0.2i:%0.2i:%0.2i", (timeLeft / 3600) % 60, (timeLeft / 60) % 60, timeLeft % 60)
                timeLeft -= 1

                task.wait(1)

                if timeLeft <= 0 then
                    questsRefreshTime.Text = "Refreshing quests..."
                    task.wait(15)
                    break
                end
            end
        end
    end)

    questModule.utility = utility

    -- store all UIStroke in a table to change them easily later
    local questsGuiUIStroke : {UIStroke} = {}
    for _,v : Instance in ipairs(questsBackground:GetDescendants()) do
        if v:IsA("UIStroke") then
            table.insert(questsGuiUIStroke, v)
        end
    end

    utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
        local thickness : number = utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 2, 5)
        for _,uiStroke : UIStroke in pairs(questsGuiUIStroke) do
            uiStroke.Thickness = thickness
        end
    end)

    table.insert(utility.guisToClose, questsBackground)

    questsOpenButton.MouseButton1Down:Connect(function()
        questModule:OpenGui()
    end)

    return questModule
end


--[[
    Opens the quest gui
]]--
function QuestModule:OpenGui()
    if self.utility.OpenGui(questsBackground) then
        UpdateQuestProgressRE:FireServer(true)

        for _,quest : Quest in pairs(self.quests) do
            if quest.status == QuestStatus.Completed then
                table.insert(self.claimRewardConnections, quest.frame.ClaimButton.MouseButton1Down:Connect(function()
                    self:ClaimReward(quest.id)
                end))
            end
        end

        -- set the close gui connection (only do it if the gui was not already open, otherwise multiple connection exist and it is called multiple times)
        self.utility.SetCloseGuiConnection(
            questsCloseButton.MouseButton1Down:Connect(function()
                self:CloseGui()
            end)
        )
    end
end


--[[
    Adds the given quest to the quests ui

    @param quest : Quest, the quest to add
]]--
function QuestModule:AddQuest(quest : Quest)
    local questTemmplateClone = questTemplate:Clone()
    questTemmplateClone.Name = string.format("Quest%d", quest.id)
    questTemmplateClone.LayoutOrder = quest.id
    questTemmplateClone.QuestName.Text = quest.name
    questTemmplateClone.ProgressBarContainer.ProgressBar.Size = UDim2.new(quest.progress / quest.target, 0, 1, 0)
    questTemmplateClone.ProgressText.Text = string.format("%d / %d", quest.progress, quest.target)

    if quest.rewardType == QuestRewardTypes.Followers then
        questTemmplateClone.RewardContainer.RewardIcon.Image = "http://www.roblox.com/asset/?id=14109181705"
        questTemmplateClone.RewardContainer.RewardText.TextColor3 = Color3.fromRGB(221, 142, 255)
        questTemmplateClone.RewardContainer.RewardText.UIStroke.Color = Color3.fromRGB(80, 52, 93)
    else
        questTemmplateClone.RewardContainer.RewardIcon.Image = "http://www.roblox.com/asset/?id=14109221821"
        questTemmplateClone.RewardContainer.RewardText.TextColor3 = Color3.fromRGB(255, 212, 52)
        questTemmplateClone.RewardContainer.RewardText.UIStroke.Color = Color3.fromRGB(95, 79, 19)
    end

    questTemmplateClone.RewardContainer.RewardText.Text = self.utility.AbbreviateNumber(quest.rewardValue)

    if quest.status == QuestStatus.Completed then
        questTemmplateClone.ClaimPending.Visible = false
        questTemmplateClone.ClaimButton.Visible = true
    end

    if quest.status == QuestStatus.Claimed then
        questTemmplateClone.ClaimButton.Visible = false
        questTemmplateClone.ClaimPending.Text = "CLAIMED"
        questTemmplateClone.ClaimPending.Visible = true
    end

    quest.frame = questTemmplateClone
    questTemmplateClone.Parent = questsContainer

    table.insert(self.quests, quest)
end


--[[
    Deletes all the quests
]]--
function QuestModule:DeleteAllQuests()
    for _,claimRewardConnection : RBXScriptConnection in pairs(self.claimRewardConnections) do
        claimRewardConnection:Disconnect()
    end
    table.clear(self.claimRewardConnections)

    table.clear(self.quests)

    for _,guiObject : GuiObject in ipairs(questsContainer:GetChildren()) do
        if guiObject:IsA("Frame") then
            guiObject:Destroy()
        end
    end
end


--[[
    Updates the progress of the quest matching the given id

	@param id : number, the id of the quest to update
	@param progress : number, the new progress for the quest
]]--
function QuestModule:UpdateProgress(id : number, progress : number)
    for _,quest : Quest in pairs(self.quests) do
        if quest.id == id and quest.status == QuestStatus.Pending then

            -- cap the progress to the target
            if progress >= quest.target then
                progress = quest.target
                self:CompleteQuest(id)
            end

            quest.progress = progress

            quest.frame.ProgressBarContainer.ProgressBar.Size = UDim2.new(quest.progress / quest.target, 0, 1, 0)

            if quest.questType <= 1 then
                quest.frame.ProgressText.Text = string.format("%s / %s", self.utility.AbbreviateNumber(quest.progress), self.utility.AbbreviateNumber(quest.target))
            else
                quest.frame.ProgressText.Text = string.format("%d / %d", quest.progress, quest.target)
            end
        end
    end
end


--[[
    Completes the quest (show claim button + show notification)

    @param id : number, the id of the completed quest
]]--
function QuestModule:CompleteQuest(id : number)
    for _,quest : Quest in pairs(self.quests) do
        if quest.id == id then
            quest.status = QuestStatus.Completed

            -- if the gui is opened, listen to the claim button click to claim the reward
            if questsBackground.Visible then
                table.insert(self.claimRewardConnections, quest.frame.ClaimButton.MouseButton1Down:Connect(function()
                    self:ClaimReward(quest.id)
                end))
            end

            -- if the gui is closed, display a notification to let the player know a reward is ready to be collected
            if not questsBackground.Visible then
                self:DisplayQuestCompletedNotification(quest.id)
            end

            quest.frame.ClaimPending.Visible = false
            quest.frame.ClaimButton.Visible = true
        end
    end
end


--[[
    Displays the notification for the quest matching the given id

    @param id : number, the id of the quest to display the notification for
]]--
function QuestModule:DisplayQuestCompletedNotification(id : number)
    for _,quest : Quest in pairs(self.quests) do
        if quest.id == id then

            if quest.rewardType == QuestRewardTypes.Followers then
                questCompletedRewardIcon.Image = "http://www.roblox.com/asset/?id=14109181705"
                questCompletedRewardText.TextColor3 = Color3.fromRGB(221, 142, 255)
                questCompletedRewardText.UIStroke.Color = Color3.fromRGB(80, 52, 93)
            else
                questCompletedRewardIcon.Image = "http://www.roblox.com/asset/?id=14109221821"
                questCompletedRewardText.TextColor3 = Color3.fromRGB(255, 212, 52)
                questCompletedRewardText.UIStroke.Color = Color3.fromRGB(95, 79, 19)
            end

            questCompletedRewardText.Text = Utility.AbbreviateNumber(quest.rewardValue)
        end
    end

    questCompletedNotification.Visible = true
    questCompletedNotification:TweenPosition(
        UDim2.new(1.02, 0, 0.1, 0),
        Enum.EasingDirection.InOut,
        Enum.EasingStyle.Quad,
        0.8
    )

    local questCompletedNotificationPromise : Promise.Promise
    local questCompletedNotificationClaimButtonConnection : RBXScriptConnection

    questCompletedNotificationPromise = Promise.new(function(resolve)

        questCompletedNotificationClaimButtonConnection = questCompletedClaimButton.MouseButton1Down:Connect(function()
            self:OpenGui()
            resolve()
        end)

        task.wait(8)
        resolve()
    end)
    :andThen(function()
        questCompletedNotificationPromise = nil
        questCompletedNotificationClaimButtonConnection:Disconnect()
        questCompletedNotificationClaimButtonConnection = nil

        questCompletedNotification:TweenPosition(
            UDim2.new(1.25, 0, 0.1, 0),
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Quad,
            0.8,
            false,
            function()
                task.wait(0.2)
                questCompletedNotification.Visible = false
            end
        )
    end)
end


--[[
    Claims the reward for the quest matching the given id

    @param id : number, the id of the quest for which to claim the reward
]]--
function QuestModule:ClaimReward(id : number)
    for _,quest : Quest in pairs(self.quests) do
        if quest.id == id then
            if quest.status == QuestStatus.Completed then

                local result : boolean = ClaimQuestRewardRF:InvokeServer(id)
                if result then
                    quest.status = QuestStatus.Claimed

                    quest.frame.ClaimButton.Visible = false
                    quest.frame.ClaimPending.Text = "CLAIMED"
                    quest.frame.ClaimPending.Visible = true
                end
            end
        end
    end
end


--[[
    Updates the streak to match the given number

    @param streak : number, the new streak value
]]--
function QuestModule:UpdateStreak(streak : number)
    for _,frame : GuiObject in ipairs(streakContainer:GetChildren()) do
        if frame:IsA("Frame") then

            if frame.LayoutOrder < streak then
                frame.TextLabel.BackgroundColor3 = Color3.fromRGB(108, 221, 48)
                frame.TextLabel.BorderUIStroke.Color = Color3.fromRGB(7, 134, 0)
                frame.TextLabel.TextUIStroke.Color = Color3.fromRGB(7, 134, 0)
                frame.Frame.BackgroundColor3 = Color3.fromRGB(108, 221, 48)

            elseif frame.LayoutOrder == streak then
                frame.TextLabel.BackgroundColor3 = Color3.fromRGB(108, 221, 48)
                frame.TextLabel.BorderUIStroke.Color = Color3.fromRGB(7, 134, 0)
                frame.TextLabel.TextUIStroke.Color = Color3.fromRGB(7, 134, 0)

            else
                frame.TextLabel.BackgroundColor3 = Color3.fromRGB(193, 193, 193)
                frame.TextLabel.BorderUIStroke.Color = Color3.fromRGB(91, 91, 91)
                frame.TextLabel.TextUIStroke.Color = Color3.fromRGB(91, 91, 91)
                frame.Frame.BackgroundColor3 = Color3.fromRGB(193, 193, 193)
            end
        end
    end

    if streak == 7 then
        petRewardContainer.Visible = true
        petRewardContainer:TweenSize(
            UDim2.new(0.8, 0, 0.8, 0),
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Linear,
            0.5
        )

        -- tween to spin the background foverer
        local backgroundTween : Tween = TweenService:Create(
            petRewardBackground,
            TweenInfo.new(
                20,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.InOut,
                math.huge
            ),
            {
                Rotation = petRewardBackground.Rotation + 360
            }
        )
        backgroundTween:Play()

        -- detect when the player clicks the collect button to collect the reward
        local claimClickConnection : RBXScriptConnection
        claimClickConnection = petRewardClaimButton.MouseButton1Down:Connect(function()
            -- disconnect the event
            claimClickConnection:Disconnect()

            petRewardContainer:TweenSize(
                UDim2.new(0, 0, 0, 0),
                Enum.EasingDirection.InOut,
                Enum.EasingStyle.Linear,
                0.5,
                false,
                function()
                    -- hide the frame
                    petRewardContainer.Visible = false

                    -- cancel the background spinning tween
                    backgroundTween:Cancel()
                end
            )
        end)
    end
end


--[[
    CLoses the quest gui
]]--
function QuestModule:CloseGui()
    UpdateQuestProgressRE:FireServer(false)

    for _,claimRewardConnection : RBXScriptConnection in pairs(self.claimRewardConnections) do
        claimRewardConnection:Disconnect()
    end
    table.clear(self.claimRewardConnections)

    self.utility.CloseGui(questsBackground)
end


return QuestModule