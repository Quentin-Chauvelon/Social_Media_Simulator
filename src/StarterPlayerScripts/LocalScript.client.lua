local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local SocialService = game:GetService("SocialService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local PlayerClickedRE : RemoteEvent = ReplicatedStorage:WaitForChild("PlayerClicked")
local FollowersRE : RemoteEvent = ReplicatedStorage:WaitForChild("Followers")
local coinsRE : RemoteEvent = ReplicatedStorage:WaitForChild("Coins")
local PostRE : RemoteEvent = ReplicatedStorage:WaitForChild("Post")
local UpgradePostsRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpgradePosts")
local UnlockPostRF : RemoteFunction = ReplicatedStorage:WaitForChild("UnlockPost")
local ParticleRE : RemoteEvent = ReplicatedStorage:WaitForChild("Particle")
local RebirthRE : RemoteEvent = ReplicatedStorage:WaitForChild("Rebirth")
local PlayTimeRewardsTimerSyncRE : RemoteEvent = ReplicatedStorage:WaitForChild("PlayTimeRewardsTimerSync")
local DisplayPotionsRE : RemoteEvent = ReplicatedStorage:WaitForChild("DisplayPotions")
local BoughtGamePassRE : RemoteEvent = ReplicatedStorage:WaitForChild("BoughtGamePass")
local PetsRE : RemoteEvent = ReplicatedStorage:WaitForChild("Pets")
local PlayerLoadedRE : RemoteEvent = ReplicatedStorage:WaitForChild("PlayerLoaded")
local UpdateFriendsBoostRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpdateFriendsBoost")
local GroupChestRewardRE : RemoteEvent = ReplicatedStorage:WaitForChild("GroupChestReward")
local CreateQuestRE : RemoteEvent = ReplicatedStorage:WaitForChild("CreateQuest")
local UpdateStreakRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpdateStreak")
local UpdateQuestProgressRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpdateQuestProgress")
local UpdateNextEventRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpdateNextEvent")
local TimeLeftBeforeEventStartRE : RemoteEvent = ReplicatedStorage:WaitForChild("TimeLeftBeforeEventStart")
local EventCountdownRE : RemoteEvent = ReplicatedStorage:WaitForChild("EventCountdown")
local StartEventRE : RemoteEvent = ReplicatedStorage:WaitForChild("StartEvent")
local CollectedEventCoinRE : RemoteEvent = ReplicatedStorage:WaitForChild("CollectedEventCoin")
local SpinWheelRE : RemoteEvent = ReplicatedStorage:WaitForChild("SpinWheel")
local SwitchWheelRE : RemoteEvent = ReplicatedStorage:WaitForChild("SwitchWheel")
local UpdateFreeSpinsRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpdateFreeSpins")
local UnlockEmojiReactionRE : RemoteEvent = ReplicatedStorage:WaitForChild("UnlockEmojiReaction")
local DisplayChangelogRE : RemoteEvent = ReplicatedStorage:WaitForChild("DisplayChangelog")

local lplr = Players.LocalPlayer

-- wait for the server to be ready before loading in the client
repeat RunService.Heartbeat:Wait()
until
	ReplicatedStorage:FindFirstChild("IsServerReady") and
	ReplicatedStorage.IsServerReady.Value and
	ReplicatedStorage.PlayersReady:WaitForChild(lplr.Name)

local Promise = require(ReplicatedStorage:WaitForChild("Promise"))
local GuiTabsModule = require(StarterPlayer:WaitForChild("StarterPlayerScripts"):WaitForChild("GuiTabsModule"))
local PostModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("PostModule"))
local PlayTimeRewards = require(StarterPlayer.StarterPlayerScripts:WaitForChild("PlayTimeRewards"))
local Utility = require(StarterPlayer.StarterPlayerScripts:WaitForChild("Utility"))
local CustomPost = require(StarterPlayer.StarterPlayerScripts:WaitForChild("CustomPost"))
local UpgradeModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("UpgradeModule"))
local RebirthModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("RebirthModule"))
local CaseModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("CaseModule"))
local PotionModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("PotionModule"))
local PetModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("PetModule"))
local LimitedEditionPetsModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("LimitedEditionPetsModule"))
local ShopModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("ShopModule"))
local GroupModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("GroupModule"))
local GamePassModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("GamePassModule"))
local QuestModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("QuestModule"))
local EventsModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("EventsModule"))
local SpinningWheelModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("SpinningWheelModule"))
local EmojisReactionsModule = require(StarterPlayer.StarterPlayerScripts:WaitForChild("EmojisReactionsModule"))

local currentCamera : Camera = workspace.CurrentCamera

local playerGui : PlayerGui = lplr.PlayerGui

local menu : ScreenGui = playerGui:WaitForChild("Menu")
local menuSideButtons : Frame = menu:WaitForChild("SideButtons")
local friendsBoostButton : TextButton = menu:WaitForChild("FriendsBoost")
local menuFollowersIcon : ImageButton = menu:WaitForChild("TabsContainer"):WaitForChild("FollowersContainer"):WaitForChild("FollowersIcon")
local menuCoinsIcon : ImageButton = menu.TabsContainer:WaitForChild("CoinsContainer"):WaitForChild("CoinsIcon")
local spinningWheelButton : ImageButton = menu.TabsContainer:WaitForChild("Container"):WaitForChild("SpinningWheelButton")


local upgradePosts : ScreenGui = playerGui:WaitForChild("UpgradePosts")
local upgradePostsBackground : Frame = upgradePosts:WaitForChild("Background")
local upgradePostsCloseButton : TextButton = upgradePostsBackground:WaitForChild("Close")
local upgradePostsClickConnection = {}

local playTimeRewardsUI : ScreenGui = playerGui:WaitForChild("PlayTimeRewards")
local allRewardsBackground : Frame = playTimeRewardsUI:WaitForChild("AllRewards"):WaitForChild("Background")
local allRewardsUiGridLayout : UIGridLayout = allRewardsBackground:WaitForChild("UIGridLayout")
local allRewardsFirstReward : Frame = allRewardsBackground:WaitForChild("Reward")
local nextRewardChest : ImageButton = playTimeRewardsUI:WaitForChild("NextReward"):WaitForChild("Chest")
local nextRewardTimer : TextLabel = playTimeRewardsUI.NextReward:WaitForChild("Timer")

local magicUpgradeFloatingCircle : UnionOperation = workspace:WaitForChild("PetsUpgradesMachine"):WaitForChild("MagicMachine"):WaitForChild("FloatingCircle")
local rainbowUpgradeCircle : UnionOperation = workspace:WaitForChild("PetsUpgradesMachine"):WaitForChild("RainbowMachine"):WaitForChild("Circle")
local rainbowUpgradeColoredParts : UnionOperation = workspace:WaitForChild("PetsUpgradesMachine"):WaitForChild("RainbowMachine"):WaitForChild("Model"):WaitForChild("Colored")

local angelEggCloud : Part = workspace:WaitForChild("Eggs"):WaitForChild("AngelEgg"):WaitForChild("Cloud")

local UPGRADE_POSTS_TWEEN_DURATION : number = 0.2

local playTimeRewards


Utility.new()

GuiTabsModule.new(Utility)

CustomPost.new(Utility)

local upgradeModule : UpgradeModule.UpgradeModule = UpgradeModule.new(Utility)
upgradeModule:LoadUpgrades()

local rebirthModule : RebirthModule.RebirthModule = RebirthModule.new(Utility)
rebirthModule:UpdateFollowersNeededToRebirth()

CaseModule.new(Utility)

local potionModule : PotionModule.PotionModule = PotionModule.new(Utility)

local petModule : PetModule.PetModule = PetModule.new(Utility)

LimitedEditionPetsModule.new(Utility)

local shopModule : ShopModule.ShopModule = ShopModule.new(Utility)

local groupModule : GroupModule.GroupModule = GroupModule.new(Utility)

local questModule : QuestModule.QuestModule = QuestModule.new(Utility)

local eventsModule : EventsModule.EventsModule = EventsModule.new(Utility)

local spinningWheelModule : SpinningWheelModule.SpinningWheelModule = SpinningWheelModule.new(Utility)

local emojisReactionsModule : EmojisReactionsModule.EmojisReactionsModule = EmojisReactionsModule.new(Utility)


GamePassModule.LoadGamePasses()

-- load and apply effects of the game passes if the player owns them
if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.EquipFourMorePets) then
	petModule.maxEquippedPets = 7
	petModule:UpdateNumberOfEquippedPets()
end

if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.PlusHundredAndFiftyInventoryCapacity) then
	petModule.maxInventoryCapacity = 200
	petModule:UpdateUsedCapacity()
end

-- update the odds of the eggs (ui) if the player owns one of the luck game passes
if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.BasicLuck) then
	petModule:UpdateEggsOdds(1)
end

if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.GoldenLuck) then
	petModule:UpdateEggsOdds(2)
end


-- store all upgrades posts UIStroke in a table to change them easily later
local upgradePostsGuiUIStroke : {UIStroke} = {}
for _,v : Instance in ipairs(upgradePostsBackground:GetDescendants()) do
	if v:IsA("UIStroke") then
		table.insert(upgradePostsGuiUIStroke, v)
	end
end

Utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
	-- change the thickness of all the UIStrokes
	local thickness : number = Utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 2, 5)
	for _,uiStroke : UIStroke in pairs(upgradePostsGuiUIStroke) do
		uiStroke.Thickness = thickness
	end
end)


-- store all playtime rewards UIStroke in a table to change them easily later
local playtimeRewardsGuiUIStroke : {UIStroke} = {}
for _,v : Instance in ipairs(playTimeRewardsUI:GetDescendants()) do
	if v:IsA("UIStroke") then
		table.insert(playtimeRewardsGuiUIStroke, v)
	end
end

-- resize playtime rewards
Utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
	-- resize the next reward timer (at the top of the screen) when the screen size changes
	nextRewardTimer.TextSize = nextRewardChest.AbsoluteSize.Y / 3
	nextRewardTimer.Position = UDim2.new(0, 0, 1, nextRewardTimer.AbsoluteSize.Y / 2)

	-- resize the all rewards uigridlayout cell padding (to evenly space out all the rewards)
	allRewardsUiGridLayout.CellPadding = UDim2.new(
		UDim.new(0.03,0),
		UDim.new(0, (allRewardsBackground.AbsoluteSize.Y - (allRewardsFirstReward.AbsoluteSize.Y * 3)) / 4)
	)

	-- resize all the rewards in the all rewards frame
	for _,reward : Frame | UIGridLayout | UICorner in ipairs(allRewardsBackground:GetChildren()) do
		if reward:IsA("Frame") then
			reward.Timer.TextSize = reward.AbsoluteSize.Y / 3
			reward.Timer.Position = UDim2.new(0, 0, 1, reward.Timer.AbsoluteSize.Y / 2)
		end
	end

	-- change the thickness of all the UIStrokes
	local thickness : number = Utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 2, 5)
	for _,uiStroke : UIStroke in pairs(playtimeRewardsGuiUIStroke) do
		uiStroke.Thickness = thickness
	end
end)


-- move the side buttons up if the player is using a mobile device, otherwise the shop button is too close to the joystick and it can be misclicked easily
if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled and not UserInputService.GamepadEnabled and not GuiService:IsTenFootInterface() then
	menuSideButtons.AnchorPoint = Vector2.new(0,0.75)
	menuSideButtons.Size = UDim2.new(0.2, 0, 0.4, 0)

	menuSideButtons.UIGridLayout.CellSize = UDim2.new(0.25, 0, 0.25, 0)
	menuSideButtons.UIGridLayout.CellPadding = UDim2.new(0.08, 0, 0.03, 0)
end

-- resize the menu side buttons UI stroke
Utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
	local thickness : number = Utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 2, 5)

	for _,menuSideButton : GuiObject in ipairs(menuSideButtons:GetChildren()) do
		if menuSideButton:IsA("ImageButton") then
			menuSideButton.UIStroke.Thickness = thickness
			menuSideButton.TextLabel.UIStroke.Thickness = thickness
		end
	end
end)


for _,menuSideButton : GuiObject in ipairs(menuSideButtons:GetChildren()) do
	if menuSideButton:IsA("ImageButton") then
		menuSideButton.MouseEnter:Connect(function()

			-- tweens to scale the button up and down on mouse enter and mouse leave
			local mouseEnterTween : Tween = TweenService:Create(
				menuSideButton.UIScale,
				TweenInfo.new(
					0.15,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.InOut
				),
				{Scale = 1.15}
			)

			local mouseLeaveTween : Tween = TweenService:Create(
				menuSideButton.UIScale,
				TweenInfo.new(
					0.15,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.InOut
				),
				{Scale = 1}
			)

			menuSideButton.MouseEnter:Connect(function()
				mouseEnterTween:Play()
			end)

			menuSideButton.MouseLeave:Connect(function()
				mouseLeaveTween:Play()
			end)
		end)
	end
end

-- tweens to scale the spinning wheel button up and down on mouse enter and mouse leave
local mouseEnterTween : Tween = TweenService:Create(
	spinningWheelButton.UIScale,
	TweenInfo.new(
		0.15,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut
	),
	{Scale = 1.15}
)

local mouseLeaveTween : Tween = TweenService:Create(
	spinningWheelButton.UIScale,
	TweenInfo.new(
		0.15,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut
	),
	{Scale = 1}
)

spinningWheelButton.MouseEnter:Connect(function()
	mouseEnterTween:Play()
end)

spinningWheelButton.MouseLeave:Connect(function()
	mouseLeaveTween:Play()
end)



--[[
	Change the camera orientation when the character resets to face the player's phone

	@param character : Model, the character that got added
]]--
local function characterAdded(character : Model)
	Promise.new(function(resolve)
		task.wait(0.7)
		resolve()
	end)
	:andThen(function()
		currentCamera.CameraType = Enum.CameraType.Scriptable
		currentCamera.CFrame = character.Head.CFrame
		currentCamera.CameraType = Enum.CameraType.Custom
	end)
end


lplr.CharacterAdded:Connect(characterAdded)

if lplr.Character then
	characterAdded(lplr.Character)
end


local followerValue : NumberValue = lplr:WaitForChild("leaderstats"):WaitForChild("Followers")
local coinsValue : NumberValue = lplr:WaitForChild("leaderstats"):WaitForChild("Coins")


-- when player clicks on the followers or coins icon in the menu, redirect them to the shop section corresponding to the button they clicked
menuFollowersIcon.MouseButton1Down:Connect(function()
	shopModule:OpenGui()
	task.wait(0.4)
	shopModule:ScrollToSection("Followers")
end)

menuCoinsIcon.MouseButton1Down:Connect(function()
	shopModule:OpenGui()
	task.wait(0.4)
	shopModule:ScrollToSection("Coins")
end)


-- rotate the magic upgrade floating circle indefinitely
TweenService:Create(
	magicUpgradeFloatingCircle,
	TweenInfo.new(
		4,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.InOut,
		math.huge
	),
	{Orientation = magicUpgradeFloatingCircle.Orientation + Vector3.new(0,360,0)}
):Play()


-- rainbow circle
coroutine.wrap(function()
	while true do
		for i=0,1,0.01 do
			rainbowUpgradeCircle.Color = Color3.fromHSV(i,0.67,1)
			rainbowUpgradeColoredParts.Color = Color3.fromHSV(i,0.67,1)

			for _=1,10 do
				RunService.Heartbeat:Wait()
			end
		end

		task.wait(1)
	end
end)()

-- TweenService:Create(
-- 	magicUpgradeFloatingCircle,
-- 	TweenInfo.new(
-- 		0.8,
-- 		Enum.EasingStyle.Linear,
-- 		Enum.EasingDirection.InOut,
-- 		math.huge,
-- 		true
-- 	),
-- 	{Position = magicUpgradeFloatingCircle.Position + Vector3.new(0,1,0)}
-- ):Play()

TweenService:Create(
	angelEggCloud,
	TweenInfo.new(
		1.5,
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.InOut,
		math.huge,
		true
	),
	{Position = angelEggCloud.Position - Vector3.new(0,1,0)}
):Play()


--[[
	Fires the server to post when the player clicks or touches the screen
]]--
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not gameProcessed then
		PlayerClickedRE:FireServer()
	end
end)


FollowersRE.OnClientEvent:Connect(function(followers : number)
	followerValue.Value = followers
	GuiTabsModule.UpdateFollowers(followers)
end)


coinsRE.OnClientEvent:Connect(function(coins : number)
	coinsValue.Value = coins
	GuiTabsModule.UpdateCoins(coins)
end)



--[[
	Update the phone UI when the player posts

	@param postType : string, the type of the post
	@param screen : Frame, the screen on which to post
	@param plr : Player, the player who posts (not necessarily the localPlayer in case of a dialog for example)
	@param message : string, the message to post
	@param start : boolean, true if this post if the very first of a dialog or reply, false otherwise
]]--
PostRE.OnClientEvent:Connect(function(postType : string, screen : Frame, plr : Player, message : string, start : boolean)
	PostModule:Post(postType, screen, plr, message, start)
end)


--[[
	Play the rainbow firework particle effect around the player
]]--
ParticleRE.OnClientEvent:Connect(function()
	local character : Model? = lplr.Character
	if character then

		local particleEmittersColors : {Color3} = {
			Color3.new(1,0,0),
			Color3.new(1,1,0),
			Color3.new(0,1,0),
			Color3.new(0,1,1),
			Color3.new(0,0,1),
			Color3.new(1,0,1)
		}

		-- add the particle emitters to the table to emit and detroy the easily
		local particleEmitters : {ParticleEmitter} = {}

		-- create the particles emitters
		for i=1,6 do
			local particleEmitter = Instance.new("ParticleEmitter")
			particleEmitter.Enabled = false
			particleEmitter.Color = ColorSequence.new(particleEmittersColors[i])
			particleEmitter.LightEmission = 0.4
			particleEmitter.LightInfluence = 0
			particleEmitter.Size = NumberSequence.new(0.5)
			particleEmitter.Lifetime = NumberRange.new(0.5, 0.7)
			particleEmitter.Speed = NumberRange.new(35, 45)
			particleEmitter.SpreadAngle = Vector2.new(180, 180)
			particleEmitter.Drag = 1

			table.insert(particleEmitters, particleEmitter)
			particleEmitter.Parent = character.PrimaryPart
		end

		for _,particleEmitter : ParticleEmitter in pairs(particleEmitters) do
			particleEmitter:Emit(30)
		end

		Utility.PlayDingSound()

		Promise.new(function(resolve)
			task.wait(3)
			resolve()
		end)
		:andThen(function()
			for _,particleEmitter in pairs(particleEmitters) do
				particleEmitter:Destroy()
			end
		end)
	end
end)


local function CloseUpgradePostsGui()
	-- disconnect all the clicks connection from the upgrade posts gui
	for _,upgradePostClickConnection : RBXScriptConnection in pairs(upgradePostsClickConnection) do
		upgradePostClickConnection:Disconnect()
	end
	table.clear(upgradePostsClickConnection)

	upgradePostsBackground:TweenSize(
		UDim2.new(0,0,0,0),
		Enum.EasingDirection.InOut,
		Enum.EasingStyle.Linear,
		UPGRADE_POSTS_TWEEN_DURATION,
		true,
        function()
			upgradePosts.Enabled = false
        end
	)
end


--[[
	Updates all the owned post types ui that are less than or equal to the given level to display them as owned

	@param level : number, the level of post types the player owns
]]--
local function UpdateOwnedPostTypes(level : number)
	for _,v in ipairs(upgradePostsBackground:WaitForChild("Layout"):GetChildren()) do
		if v:IsA("ImageButton") and v.LayoutOrder <= level then

			if v:FindFirstChild("Lock") then
				v.Lock:Destroy()
			end

			if v:FindFirstChild("PriceContainer") then
				v.PriceContainer:Destroy()
			end

			v.UpgradeName.Visible = true

			-- change the color of the button
			v.BackgroundColor3 = Color3.fromRGB(67, 231, 58)
			v.UIStroke.Color = Color3.fromRGB(29, 97, 24)

			v.Active = false
			v.AutoButtonColor = false
		end
	end
end


--[[
	Display or hide the upgrade posts gui

	@param visible : boolean | number, true if the gui should be displayed, false otherwise. It can also be a number (on first fire only) to load the ui for the already owned post types
]]--
UpgradePostsRE.OnClientEvent:Connect(function(visible : boolean | number)

	if typeof(visible) == "boolean" then
		Utility.BlurBackground(visible)

		if visible and not upgradePosts.Enabled then
			upgradePosts.Enabled = true

			upgradePostsBackground:TweenSize(
				UDim2.new(0.5,0,0.5,0),
				Enum.EasingDirection.InOut,
				Enum.EasingStyle.Linear,
				UPGRADE_POSTS_TWEEN_DURATION
			)

			-- listen to all the clicks to upgrade the post
			for _,upgradePost in ipairs(upgradePostsBackground:WaitForChild("Layout"):GetChildren()) do
				if upgradePost:IsA("ImageButton") and upgradePost.Active then
					table.insert(upgradePostsClickConnection, upgradePost.MouseButton1Down:Connect(function()

						-- when the player clicks, fire the server to check if the player has enough followers
						-- and then if it's the case, unlock all previous post types on the gui
						if UnlockPostRF:InvokeServer(upgradePost.LayoutOrder) then
							-- update all the owned post types ui to display them as owned
							UpdateOwnedPostTypes(upgradePost.LayoutOrder)
						end
					end))
				end
			end

			-- listen to the click to close the gui
			table.insert(upgradePostsClickConnection, upgradePostsCloseButton.MouseButton1Down:Connect(function()
				Utility.BlurBackground(false)
				CloseUpgradePostsGui()
			end))

		elseif not visible and upgradePosts.Enabled then
			CloseUpgradePostsGui()
		end

	elseif typeof(visible) == "number" then
		UpdateOwnedPostTypes(visible)
	end
end)


local experienceInviteOptions : ExperienceInviteOptions = Instance.new("ExperienceInviteOptions")
experienceInviteOptions.PromptMessage = "Get +20% followers and coins for each friend on your server"
experienceInviteOptions.InviteMessageId = "52e070a6-6065-d74c-b9d3-9f39a42bee55"

-- invite friends
friendsBoostButton.MouseButton1Down:Connect(function()
	pcall(function()
		if SocialService:CanSendGameInviteAsync(lplr) then
			SocialService:PromptGameInvite(lplr, experienceInviteOptions)
		end
	end)
end)


-- remove the red upgrade posts part for all the phones except the one that is assigned to the player
for _,plot : Model in ipairs(workspace:WaitForChild("Plots"):GetChildren()) do
	if plot:WaitForChild("Owner").Value ~= lplr.Name then
		plot.UpgradePosts:Destroy()
	end
end


-- remove last posts if there is more than one (might happens at the start while the player is loading)
-- also load the upgrade post billboard gui
coroutine.wrap(function()

	task.wait(5)

	-- add the upgrade post billboard gui to the player's plot only
	for _,plot : Model in ipairs(workspace.Plots:GetChildren()) do
		if plot.Owner.Value == lplr.Name then

			local billboardGui = Instance.new("BillboardGui")
			billboardGui.StudsOffset = Vector3.new(0,5,0)
			billboardGui.LightInfluence = 0
			billboardGui.Size = UDim2.new(10,0,2,0)
			billboardGui.MaxDistance = 40

			local textLabel = Instance.new("TextLabel")
			textLabel.AnchorPoint = Vector2.new(0.5,0)
			textLabel.BackgroundTransparency = 1
			textLabel.Position = UDim2.new(0.5,0,0,0)
			textLabel.Size = UDim2.new(0.9,0,0.9,0)
			textLabel.Font = Enum.Font.FredokaOne
			textLabel.Text = "Upgrade posts"
			textLabel.TextColor3 = Color3.new(1,1,1)
			textLabel.TextScaled = true

			local uiStroke = Instance.new("UIStroke")
			uiStroke.Thickness = 3

			uiStroke.Parent = textLabel
			textLabel.Parent = billboardGui
			billboardGui.Parent = plot.UpgradePosts.Part
		end
	end

	task.wait(5)

	local lastPosts = {}

	for _,phone : Model in ipairs(workspace:WaitForChild("Plots"):GetChildren()) do
		if phone:FindFirstChild("Owner") and phone.Owner.Value == lplr.Name then
			for _,post : Frame in ipairs(phone.PhoneModel.Screen.ScreenUI.Background.App:GetChildren()) do
				if post.Name == "LastPot" then
					table.insert(lastPosts, post)
				end
			end
		end
	end

	if #lastPosts > 1 then
		lastPosts[1]:Destroy()
	end
end)()


--[[
	Sync the timePlayedToday when the server fires the event.
	If playTimeRewards hasn't been defined yet, instantiate it and start the timer
]]--
PlayTimeRewardsTimerSyncRE.OnClientEvent:Connect(function(timePlayedToday : number)
	if not playTimeRewards then
		-- wait for next reward to exist so that we know what the next reward is
		lplr:WaitForChild("NextReward")

		-- display the play time rewards ui
		playTimeRewardsUI.Enabled = true

		playTimeRewards = PlayTimeRewards.new(timePlayedToday, nextRewardTimer)
		playTimeRewards:StartTimer()
		playTimeRewards:NextRewardClick()
	end

	playTimeRewards:SyncTimer(timePlayedToday)
end)


--[[
	Update the rebirth gui when the player rebirths
]]
RebirthRE.OnClientEvent:Connect(function()
	-- increase the rebirth level for the player
	rebirthModule.level += 1

	-- update the amount of followers needed to rebirth the next time
	rebirthModule:UpdateFollowersNeededToRebirth()

	-- update the gui to update the values of the upgrades and progress
	rebirthModule:UpdateGui()
end)


--[[
	Displays all the active potions for the player
]]
DisplayPotionsRE.OnClientEvent:Connect(function(activePotions : {PotionModule.potion})
	-- variable to know if they were potions active last time the event fired
	-- used to know if we should start the promise that is going to count down and update the time left for all potions
	local noActivePotionsBefore : boolean = #potionModule.activePotions == 0 and #activePotions ~= 0

	-- multiply the time left by 60 to turn it into seconds so that the timer can be more accurate
	for i,_ in pairs(activePotions) do
		activePotions[i].timeLeft *= 60
	end

	potionModule.activePotions = activePotions
    potionModule:DisplayActivePotions()

	if noActivePotionsBefore then
		potionModule:StartPotionsTimer()
	end
end)


--[[
	Load the owned pets

	@param pets : {pet}, a table of pets to add to the player's inventory
	@param deletePreviousPets : boolean, indicates whether or not we should override the ownedPets table (on join or delete unequipped) or simply add them to the table (on limited edition pet purchase)
]]--
PetsRE.OnClientEvent:Connect(function(pets : {PetModule.pet}, deletePreviousPets : boolean)
	if deletePreviousPets then
    	petModule.ownedPets = pets
	else
		for _,pet : PetModule.pet in pairs(pets) do
			table.insert(petModule.ownedPets, pet)
		end
	end

	petModule.currentlyEquippedPets = 0

	-- count the number of pets the player has equipped
	for _,pet : PetModule.pet in pairs(pets) do
		if pet.equipped then
			petModule.currentlyEquippedPets += 1
		end
	end

	if deletePreviousPets then
		petModule:RecreatePetsInventory()
	else
		petModule:AddPetsToInventory(pets)
	end
	petModule:UpdateNumberOfEquippedPets()

	if playerGui:WaitForChild("Pets"):WaitForChild("InventoryBackground"):WaitForChild("UpgradesMachineDetails").Visible then
		petModule:OpenUpgradesMachineGui()
	end
end)


--[[
	Called whenever the player buys a game pass to make changes locally (mainly to the ui) if needed
]]--
BoughtGamePassRE.OnClientEvent:Connect(function(gamePassId : number)
	GamePassModule.PlayerBoughtGamePass(gamePassId)

	shopModule:UpdateGamePassOwnership(gamePassId)

	if gamePassId == GamePassModule.gamePasses.SpaceCase then
		CaseModule:CaseBoughtSuccessfully("Space")

	elseif gamePassId == GamePassModule.gamePasses.EquipFourMorePets then
		petModule.maxEquippedPets = 7
		petModule:UpdateNumberOfEquippedPets()

	elseif gamePassId == GamePassModule.gamePasses.PlusHundredAndFiftyInventoryCapacity then
		petModule.maxInventoryCapacity = 200
		petModule:UpdateUsedCapacity()

	elseif gamePassId == GamePassModule.gamePasses.BasicLuck then
		petModule:UpdateEggsOdds(1)

	elseif gamePassId == GamePassModule.gamePasses.GoldenLuck then
		petModule:UpdateEggsOdds(2)
	end
end)


--[[
	Updates the friend's boost based on the number of friends online

	@param numberOfFriendsOnline : number, the number of the player's friends that are online
]]--
UpdateFriendsBoostRE.OnClientEvent:Connect(function(numberOfFriendsOnline : number)
	friendsBoostButton.Text = string.format("Friends boost: %.f%%", (0.2 * numberOfFriendsOnline * 100))
end)


--[[
	Fired when the player collects the group reward chest to display the ui
]]--
GroupChestRewardRE.OnClientEvent:Connect(function()
    groupModule:CollectReward()
end)


--[[
	Adds a quest to the ui

	@param quest : Quest, the quest to add
]]--
CreateQuestRE.OnClientEvent:Connect(function(quest : QuestModule.Quest)
	if quest then
		questModule:AddQuest(quest)
	else
		questModule:DeleteAllQuests()
	end
end)


--[[
	Updates the streak to match the given number

	@param streak : number, the new streak value
]]--
UpdateStreakRE.OnClientEvent:Connect(function(streak : number)
	questModule:UpdateStreak(streak)
end)


--[[
	Updates the progress of the quest matching the given id

	@param id : number, the id of the quest to update
	@param progress : number, the new progress for the quest
]]--
UpdateQuestProgressRE.OnClientEvent:Connect(function(id : number, progress : number)
	questModule:UpdateProgress(id, progress)
end)


--[[
	Updates the next event information

	@param event : Event, the next event to update to
]]--
UpdateNextEventRE.OnClientEvent:Connect(function(event : {})
	eventsModule:UpdateNextEvent(event)
end)


--[[
	Updates the time left before the event starts

	@param timeLeft : number, the time left before the event starts
]]--
TimeLeftBeforeEventStartRE.OnClientEvent:Connect(function(timeLeft : number)
	eventsModule:DisplayTimeLeftBeforeEventStart(timeLeft)
end)


--[[
	Starts the countdown with the given duration

	@param text : string, the text to display in the countdown
	@param duration : number, the duration of the countdown
]]--
EventCountdownRE.OnClientEvent:Connect(function(text : string, duration : number)
	eventsModule.timeBeforeNextEvent = duration
	eventsModule:StartCountdown(text, duration)
end)


--[[
	Starts the event
]]--
StartEventRE.OnClientEvent:Connect(function()
	eventsModule:StartEvent()
end)


--[[
	Updates the event followers/coins gained

	@param gain : number, the number of followers/coins gained
]]--
CollectedEventCoinRE.OnClientEvent:Connect(function(gain : number)
	eventsModule:CollectedEventCoin(gain)
end)


--[[
	Spins the wheel with the given reward

	@param rewardId : number, the id of the reward to give to the player
]]--
SpinWheelRE.OnClientEvent:Connect(function(rewardId : number)
	spinningWheelModule:SpinWheel(rewardId)
end)


--[[
	Switches the wheel to the given one

	@param wheel : string, the wheel to switch to
]]--
SwitchWheelRE.OnClientEvent:Connect(function(wheel : string)
	spinningWheelModule:SwitchWheel(wheel)
end)


--[[
	Updates the free spins left for the player

	@param normalFreeSpins : number, the number of normal free spins left
	@param crazyFreeSpins : number, the number of crazy free spins left
]]--
UpdateFreeSpinsRE.OnClientEvent:Connect(function(normalFreeSpins : number, crazyFreeSpins : number)
	spinningWheelModule.normalFreeSpinsLeft = normalFreeSpins
	spinningWheelModule.crazyFreeSpinsLeft = crazyFreeSpins

	spinningWheelModule:UpdateFreeSpinUI()
end)


DisplayChangelogRE.OnClientEvent:Connect(function()
	local changelogScreenGui : ScreenGui = lplr.PlayerGui:WaitForChild("Changelog")
	changelogScreenGui.Enabled = true

	local closeConnection : RBXScriptConnection
	closeConnection = changelogScreenGui:WaitForChild("Background"):WaitForChild("Close").MouseButton1Down:Connect(function()
		closeConnection:Disconnect()
		closeConnection = nil
		changelogScreenGui:Destroy()
	end)
end)


--[[
	Unlocks the given emojis

	@param emoji : {string}, the emojis to unlock
]]
UnlockEmojiReactionRE.OnClientEvent:Connect(function(emojis : {string})
	emojisReactionsModule:UnlockEmojis(emojis)
end)


-- add the vip tag before the player message if they are vip
TextChatService.OnIncomingMessage = function(message: TextChatMessage)
	local properties : TextChatMessageProperties = Instance.new("TextChatMessageProperties")

	if message.TextSource then
		local player : Player = Players:GetPlayerByUserId(message.TextSource.UserId)
		if player and player:FindFirstChild("VIP") and player.VIP.Value then
			properties.PrefixText = "<font color='##F5DE30'>[VIP]</font> " .. message.PrefixText
		end
	end

	return properties
end


if not game:IsLoaded() then
	game.Loaded:Wait()
end
-- fire the server once the client is loaded
PlayerLoadedRE:FireServer()