local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage:WaitForChild("Promise"))

local MostFollowersDataStore : OrderedDataStore = DataStoreService:GetOrderedDataStore("MostFollowers1")
local MostRebirthsDataStore : OrderedDataStore = DataStoreService:GetOrderedDataStore("MostRebirths1")
local MostPlayedDataStore : OrderedDataStore = DataStoreService:GetOrderedDataStore("MostPlayed1")

local LeaderboardsDataBF : BindableFunction = game:GetService("ServerStorage"):WaitForChild("LeaderboardsData")

local leaderboardsNormalEntry : Frame = ReplicatedStorage:WaitForChild("LeaderboardNormalEntry")
local leaderboardTop3Entry : Frame = ReplicatedStorage:WaitForChild("LeaderboardTop3Entry")

local leaderboardsFolder : Folder = workspace:WaitForChild("Leaderboards")
local mostFollowersLeaderboardContainer : ScrollingFrame = leaderboardsFolder:WaitForChild("MostFollowersLeaderboard"):WaitForChild("LeaderboardDisplay"):WaitForChild("SurfaceGui"):WaitForChild("Background"):WaitForChild("LeaderboardContainer")
local mostRebirthsLeaderboardContainer : ScrollingFrame = leaderboardsFolder:WaitForChild("MostRebirthsLeaderboard"):WaitForChild("LeaderboardDisplay"):WaitForChild("SurfaceGui"):WaitForChild("Background"):WaitForChild("LeaderboardContainer")
local mostPlayedLeaderboardContainer : ScrollingFrame = leaderboardsFolder:WaitForChild("MostPlayedLeaderboard"):WaitForChild("LeaderboardDisplay"):WaitForChild("SurfaceGui"):WaitForChild("Background"):WaitForChild("LeaderboardContainer")
local timeUntilNextRefresh : NumberValue = leaderboardsFolder:WaitForChild("RefreshTime"):WaitForChild("TimeUntilNextRefresh")
local timeUntilNextRefreshText : TextLabel = leaderboardsFolder.RefreshTime:WaitForChild("RefreshDisplay"):WaitForChild("SurfaceGui"):WaitForChild("TimeUntilNextRefresh")

local dancingNPC1 : Model = workspace.Leaderboards:WaitForChild("Podium"):WaitForChild("DancingNPC1")
local dancingNPC2 : Model = workspace.Leaderboards.Podium:WaitForChild("DancingNPC2")
local dancingNPC3 : Model = workspace.Leaderboards.Podium:WaitForChild("DancingNPC3")

local dancingAnimation : Animation = Instance.new("Animation")
dancingAnimation.AnimationId = "rbxassetid://4049037604" -- or 507771019

-- make all the NPCs dance
for _,dancingNPC : Model in pairs({dancingNPC1, dancingNPC2, dancingNPC3}) do
    local humanoid = dancingNPC:FindFirstChildOfClass("Humanoid")
	if humanoid then
		-- need to use animation object for server access
		local animator = humanoid:FindFirstChildOfClass("Animator")
		if animator then
			local animationTrack = animator:LoadAnimation(dancingAnimation)
			animationTrack:Play()
		end
	end
end


type LeaderboardEntry  = {[number] : LeaderboardEntryData}

type LeaderboardEntryData = {
    username : string,
    value : number
}

type LeaderboardInformation = {
    id : number,
    orderedDataStore : OrderedDataStore,
    leaderboardContainer : ScrollingFrame,
    valueFormat : string,
    abbreviate : boolean,
}

export type LeaderboardModule = {
    leaderbordsPromise : Promise.Promise,
    nextRefreshPromise : Promise.Promise,
    new : () -> LeaderboardModule,
    UpdateLeaderboard : (leaderboard : LeaderboardInformation, leaderboardData : LeaderboardEntry) -> nil,
    GetTopPlayersForAllLeaderboards : () -> nil,
    GetTopPlayersForLeaderboard : (leaderboard : LeaderboardInformation) -> nil,
    SavePlayersDataForAllLeaderboards : () -> nil,
    SavePlayersDataForLeaderboard : (orderedDataStore : OrderedDataStore, leaderboardType : string) -> nil,
    UpdateNextRefreshTime : (nextRefreshTime : number) -> nil,
    AbbreviateNumber : (number) -> string
}


local leaderboardsTypes = {
    MostFollowers = 0,
    MostRebirths = 1,
    MostPlayed = 2
}

local leaderboards : {[number] : LeaderboardInformation} = {
    [leaderboardsTypes.MostFollowers] = {
        id = 0,
        orderedDataStore = MostFollowersDataStore,
        leaderboardContainer = mostFollowersLeaderboardContainer,
        valueFormat = "%s",
        abbreviate = true
    },
    [leaderboardsTypes.MostRebirths] = {
        id = 1,
        orderedDataStore = MostRebirthsDataStore,
        leaderboardContainer = mostRebirthsLeaderboardContainer,
        valueFormat = "%d",
        abbreviate = false
    },
    [leaderboardsTypes.MostPlayed] = {
        id = 2,
        orderedDataStore = MostPlayedDataStore,
        leaderboardContainer = mostPlayedLeaderboardContainer,
        valueFormat = "%.1fh",
        abbreviate = false
    }
}

local NUMBER_ABBREVIATIONS : {[string] : number} = {["k"] = 4, ["M"] = 7, ["B"] = 10, ["T"] = 13, ["Qa"] = 16, ["Qi"] = 19, ["s"] = 22, ["S"] = 25, ["o"] = 28, ["n"] = 31, ["d"] = 34}


local LeaderboardModule : LeaderboardModule = {}
LeaderboardModule.__index = LeaderboardModule


function LeaderboardModule.new()
    -- promise to update the leaderboard and save to datastores
    LeaderboardModule.promise = Promise.new(function()
        while true do
            LeaderboardModule.GetTopPlayersForAllLeaderboards()
            LeaderboardModule.UpdateNextRefreshTime(120)

            task.wait(60)

            LeaderboardModule.SavePlayersDataForAllLeaderboards()
        end
    end)

    -- promise that will update the time until next refresh timer
    LeaderboardModule.nextRefreshPromise = Promise.new(function()
        while true do
            if timeUntilNextRefresh.Value > 0 then
                timeUntilNextRefreshText.Text = string.format("Leaderboards refresh in: %dm %ds", timeUntilNextRefresh.Value / 60, timeUntilNextRefresh.Value % 60)

                timeUntilNextRefresh.Value -= 1
            else
                timeUntilNextRefreshText.Text = "Refreshing leaderboards..."
            end

            task.wait(1)
        end
    end)
end


--[[
    Updates the leaderboard of the given frame with the given data

    @param leaderboard : LeaderboardInformation, the leaderboard to update
    @param rank : number, the rank of the player
    @param userId : number, the user id of the player
    @param username : string, the username of the player
    @param value : number, the value for the leaderboard
]]--
function LeaderboardModule.UpdateLeaderboard(leaderboard : LeaderboardInformation, rank : number, userId : number, username : string, value : number)
    local leaderboardEntryFrameClone : Frame

    if rank <= 3 then
        leaderboardEntryFrameClone = leaderboardTop3Entry:Clone()

        -- set the player's thumbnail
        pcall(function()
            leaderboardEntryFrameClone.Thumbnail.Image = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size60x60)
        end)

        -- update the ui stroke color based on the rank of the player
        if rank == 1 then
            leaderboardEntryFrameClone.Thumbnail.UIStroke.Color = Color3.fromRGB(255, 215, 0)

            if leaderboard.id == leaderboardsTypes.MostFollowers then
                -- update the dancing npc appearance to match the player
                pcall(function()
                    dancingNPC1.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(userId))
                end)

                dancingNPC1.Tags.Container.PlayerName.Text = username
                dancingNPC1.Tags.Container.Value.Text = LeaderboardModule.AbbreviateNumber(value)
            end

        elseif rank == 2 then
            leaderboardEntryFrameClone.Thumbnail.UIStroke.Color = Color3.fromRGB(168, 169, 173)

            if leaderboard.id == leaderboardsTypes.MostFollowers then
                -- update the dancing npc appearance to match the player
                pcall(function()
                    dancingNPC2.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(userId))
                end)

                dancingNPC2.Tags.Container.PlayerName.Text = username
                dancingNPC2.Tags.Container.Value.Text = LeaderboardModule.AbbreviateNumber(value)
            end

        elseif rank == 3 then
            leaderboardEntryFrameClone.Thumbnail.UIStroke.Color = Color3.fromRGB(205, 127, 50)

            if leaderboard.id == leaderboardsTypes.MostFollowers then
                -- update the dancing npc appearance to match the player
                pcall(function()
                    dancingNPC3.Humanoid:ApplyDescription(Players:GetHumanoidDescriptionFromUserId(userId))
                end)

                dancingNPC3.Tags.Container.PlayerName.Text = username
                dancingNPC3.Tags.Container.Value.Text = LeaderboardModule.AbbreviateNumber(value)
            end
        end

    else
        leaderboardEntryFrameClone = leaderboardsNormalEntry:Clone()

        -- update the rank
        leaderboardEntryFrameClone.Rank.Text = "#" .. tostring(rank)
    end

    -- update the username
    leaderboardEntryFrameClone.InformationContainer.PlayerName.Text = #username ~= 0 and username or "Loading..."

    -- format the value according to the leaderboard's format
    if leaderboard.id == leaderboardsTypes.MostFollowers then
        leaderboardEntryFrameClone.InformationContainer.Value.Text = string.format(leaderboard.valueFormat, LeaderboardModule.AbbreviateNumber(value))
    elseif leaderboard.id == leaderboardsTypes.MostRebirths then
        leaderboardEntryFrameClone.InformationContainer.Value.Text = string.format(leaderboard.valueFormat, value)
    elseif leaderboard.id == leaderboardsTypes.MostPlayed then
        leaderboardEntryFrameClone.InformationContainer.Value.Text = string.format(leaderboard.valueFormat, (value / 60))
    end

    leaderboardEntryFrameClone.LayoutOrder = rank
    leaderboardEntryFrameClone.Parent = leaderboard.leaderboardContainer
end


--[[
    Updates all the leaderboards
]]--
function LeaderboardModule.GetTopPlayersForAllLeaderboards()
    LeaderboardModule.GetTopPlayersForLeaderboard(leaderboards[0])
	LeaderboardModule.GetTopPlayersForLeaderboard(leaderboards[2])
	LeaderboardModule.GetTopPlayersForLeaderboard(leaderboards[1])
end


--[[
    Updates the most followers leaderboard
]]--
function LeaderboardModule.GetTopPlayersForLeaderboard(leaderboard : LeaderboardInformation)
    local pages : DataStorePages = leaderboard.orderedDataStore:GetSortedAsync(false, 100)

    local firstPage = pages:GetCurrentPage()

    -- clear the leaderboard
    for _,leaderboardEntry : GuiObject in ipairs(leaderboard.leaderboardContainer:GetChildren()) do
        if leaderboardEntry:IsA("Frame") then
            leaderboardEntry:Destroy()
        end
    end

    for rank : number, data in pairs(firstPage) do
        local userId : number = data.key
        local value : number = data.value

        local username : string = ""
        pcall(function()
            username = Players:GetNameFromUserIdAsync(userId)
        end)

        LeaderboardModule.UpdateLeaderboard(leaderboard, rank, userId, username, value)
    end

end


--[[
    Save the data of all players for all the leaderboards
]]--
function LeaderboardModule.SavePlayersDataForAllLeaderboards()
    
    LeaderboardModule.UpdateNextRefreshTime(60)
    task.wait(15)

    LeaderboardModule.SavePlayersDataForLeaderboard(MostFollowersDataStore, "followers")

    LeaderboardModule.UpdateNextRefreshTime(45)
    task.wait(15)
    
    LeaderboardModule.SavePlayersDataForLeaderboard(MostRebirthsDataStore, "rebirths")
    
    LeaderboardModule.UpdateNextRefreshTime(30)
    task.wait(15)
    
    LeaderboardModule.SavePlayersDataForLeaderboard(MostPlayedDataStore, "timePlayed")

    LeaderboardModule.UpdateNextRefreshTime(15)
    task.wait(15)
end


--[[
    Save data of all players for the most followers leaderboard
]]--
function LeaderboardModule.SavePlayersDataForLeaderboard(orderedDataStore : OrderedDataStore, leaderboardType : string)
    for _,plr : Player in pairs(Players:GetPlayers()) do
        -- don't count myself in the leadebroards
        if plr.UserId == 551795307 or plr.UserId == 1651476952 then
            continue
        end

        local value : number = LeaderboardsDataBF:Invoke(plr.Name, leaderboardType)

        pcall(function()
            orderedDataStore:SetAsync(tostring(plr.UserId), value)
        end)
    end
end


--[[
    Updates the time left before the next leaderboards refresh

    @param nextRefreshTime : number, the time in seconds before the next refresh
]]--
function LeaderboardModule.UpdateNextRefreshTime(nextRefreshTime : number)
    timeUntilNextRefresh.Value = nextRefreshTime
end


--[[
    Abbreviates the given number

    @param number : number, the number to abbreviate
    @return string, the abbreviated number
]]--
function LeaderboardModule.AbbreviateNumber(number : number) : string
    local text : string = tostring(string.format("%.f",math.floor(number)))

    local chosenAbbreviation : string
        for abbreviation : string, digit : number in pairs(NUMBER_ABBREVIATIONS) do
            if (#text >= digit and #text < (digit + 3)) then
                chosenAbbreviation = abbreviation
                break
        end
    end

    if (chosenAbbreviation and chosenAbbreviation ~= 0) then
        local digits : number = NUMBER_ABBREVIATIONS[chosenAbbreviation]

        local rounded : number = math.floor(number / 10 ^  (digits - 2)) * 10 ^  (digits - 2)
        return string.format("%.1f", rounded / 10 ^ (digits - 1)) .. chosenAbbreviation
    else
        return tostring(number)
    end
end


return LeaderboardModule