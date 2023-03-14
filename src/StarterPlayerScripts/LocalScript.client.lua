local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayer = game:GetService("StarterPlayer")

local PlayerClickedRE = ReplicatedStorage:WaitForChild("PlayerClicked")
local PostRE = ReplicatedStorage:WaitForChild("Post")
local LoadingScreenRE = ReplicatedStorage:WaitForChild("LoadingScreen")
local UpgradePostsRE = ReplicatedStorage:WaitForChild("UpgradePosts")
local FollowersRE = ReplicatedStorage:WaitForChild("Followers")
local UnlockPostRF = ReplicatedStorage:WaitForChild("UnlockPost")
local InformationRE = ReplicatedStorage:WaitForChild("Information")
local ParticleRE = ReplicatedStorage:WaitForChild("Particle")

local Promise = require(ReplicatedStorage:WaitForChild("Promise"))
local PostModule = require(StarterPlayer:WaitForChild("StarterPlayerScripts"):WaitForChild("PostModule"))

local lplr = Players.LocalPlayer
local currentCamera = workspace.CurrentCamera

local menu : ScreenGui = lplr.PlayerGui:WaitForChild("Menu")
local followersText : TextLabel = menu:WaitForChild("FollowersContainer"):WaitForChild("FollowersText")
local informationText : TextLabel = menu:WaitForChild("Information")

local blurEffect : BlurEffect = game:GetService("Lighting"):WaitForChild("Blur")
local blurWhiteBackground : ScreenGui = lplr.PlayerGui:WaitForChild("BackgroundBlur")

local upgradePosts : ScreenGui = lplr.PlayerGui:WaitForChild("UpgradePosts")
local upgradePostsBackground : Frame = upgradePosts:WaitForChild("Background")
local upgradePostsCloseButton : TextButton = upgradePostsBackground:WaitForChild("Close")
local upgradePostsClickConnection = {}

local UPGRADE_POSTS_TWEEN_DURATION = 0.2


--[[
	Change the camera orientation when the character resets to face the player's phone
	
	@param character : Model, the character that got added
]]--
local function characterAdded(character : Model)
	Promise.new(function(resolve, reject)
		task.wait(0.7)
		resolve()
	end)
	:andThen(function()
		currentCamera.CFrame = CFrame.lookAt(currentCamera.CFrame.Position, currentCamera.CFrame.Position + character:WaitForChild("HumanoidRootPart").CFrame.LookVector)
	end)
end

lplr.CharacterAdded:Connect(characterAdded)

if lplr.Character then
	characterAdded(lplr.Character)
end


--[[
	Fires the server to post when the player clicks or touches the screen
]]--
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not gameProcessed then
		PlayerClickedRE:FireServer()
	end
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
	Display the number of followers the player has on the gui on the right of the screen 
	
	@param followers : number, the number of followers the player has
]]--
FollowersRE.OnClientEvent:Connect(function(followers : number)
	followersText.Text = followers
end)


--[[
	Display the given text at the top of the screen for the given duration 
	
	@param text : string, the text to display
	@param duration : number?, the duration in seconds for how long the text should be displayed or default (8)
]]--
InformationRE.OnClientEvent:Connect(function(text : string, duration : number?)
	informationText.Text = text
	
	-- tween (fade in) the text and ui stroke transparency
	TweenService:Create(
		informationText,
		TweenInfo.new(
			1,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.InOut
		),
		{
			TextTransparency = 0
		}
	)
	:Play()
	
	TweenService:Create(
		informationText.UIStroke,
		TweenInfo.new(
			1,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.InOut
		),
		{
			Transparency = 0
		}
	)
	:Play()
		
	Promise.new(function(resolve)
		task.wait(duration or 8)
		resolve()
	end)
	:andThen(function()
		
		-- tween (fade out) the text and ui stroke transparency
		TweenService:Create(
			informationText,
			TweenInfo.new(
				1,
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.InOut
			),
			{
				TextTransparency = 1
			}
		)
		:Play()

		TweenService:Create(
			informationText.UIStroke,
			TweenInfo.new(
				1,
				Enum.EasingStyle.Linear,
				Enum.EasingDirection.InOut
			),
			{
				Transparency = 1
			}
		)
		:Play()
	end)
end)


--[[
	Play the rainbow firework particle effect around the player 
]]--
ParticleRE.OnClientEvent:Connect(function()
	local character : Model? = lplr.Character
	if character then

		-- "ding" sound
		local sound : Sound = Instance.new("Sound")
		sound.SoundId = "rbxassetid://826129174"
		sound.Parent = character.PrimaryPart

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
		
		sound:Play()
		
		Promise.new(function(resolve)
			task.wait(3)
			resolve()
		end)
		:andThen(function()
			for _,particleEmitter in pairs(particleEmitters) do
				particleEmitter:Destroy()
			end
			
			sound:Destroy()
		end)
	end
end)


--[[
	Blur the background and displays a semi-transparent white frame in the background (it helps have
	a better focus on the displayed gui)
	
	@param visible : boolean, true if the ui should be displayed, false otherwise
]]--
local function BlurBackground(enabled : boolean)
	blurEffect.Enabled = enabled
	blurWhiteBackground.Enabled = enabled
end


local function CloseUpgradePostsGui()
	-- disconnect all the clicks connection from the upgrade posts gui
	for _,upgradePostClickConnection : RBXScriptConnection in pairs(upgradePostsClickConnection) do
		upgradePostClickConnection:Disconnect()
	end
	

	upgradePostsClickConnection = {}

	Promise.new(function(resolve)
		upgradePostsBackground:TweenSize(
			UDim2.new(0,0,0,0),
			Enum.EasingDirection.InOut,
			Enum.EasingStyle.Linear,
			UPGRADE_POSTS_TWEEN_DURATION
		)

		task.wait(UPGRADE_POSTS_TWEEN_DURATION)
		resolve()
	end)
	:andThen(function()
		upgradePosts.Enabled = false
	end)
end


--[[
	Display or hide the upgrade posts gui
	
	@param visible : boolean, true if the gui should be displayed, false otherwise
]]--
UpgradePostsRE.OnClientEvent:Connect(function(visible : boolean)
	BlurBackground(visible)
	
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
						
						for _,v in ipairs(upgradePostsBackground:WaitForChild("Layout"):GetChildren()) do
							if v:IsA("ImageButton") and v.LayoutOrder <= upgradePost.LayoutOrder then
								
								if v:FindFirstChild("Lock") then
									v.Lock:Destroy()
								end
								
								if v:FindFirstChild("UpgradeName") then
									v.UpgradeName:Destroy()
								end

								v.Price.Text = v.Name

								v.Active = false
								v.AutoButtonColor = false
							end
						end
					end
				end))
			end
		end
		
		-- listen to the click to close the gui
		table.insert(upgradePostsClickConnection, upgradePostsCloseButton.MouseButton1Down:Connect(function()
			BlurBackground(false)
			
			CloseUpgradePostsGui()
		end))
		
	elseif not visible and upgradePosts.Enabled then
		CloseUpgradePostsGui()
	end
end)


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