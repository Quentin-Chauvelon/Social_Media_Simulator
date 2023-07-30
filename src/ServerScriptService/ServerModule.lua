local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = require(ServerScriptService:WaitForChild("Player"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))
local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))

local PlayerClickedRE : RemoteEvent = ReplicatedStorage:WaitForChild("PlayerClicked")
local UnlockPostRF : RemoteFunction = ReplicatedStorage:WaitForChild("UnlockPost")
local UpgradePostsRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpgradePosts")
local FollowersRE : RemoteEvent = ReplicatedStorage:WaitForChild("Followers")
local CoinsRE : RemoteEvent = ReplicatedStorage:WaitForChild("Coins")
local InformationRE : RemoteEvent = ReplicatedStorage:WaitForChild("InformationNotification")
local ParticleRE : RemoteEvent = ReplicatedStorage:WaitForChild("Particle")
local CollectPlayTimeRewardRF : RemoteFunction = ReplicatedStorage:WaitForChild("CollectPlayTimeReward")
local ListCustomPostsRE : RemoteEvent = ReplicatedStorage:WaitForChild("ListCustomPosts")
local SaveCustomPostRF : RemoteFunction = ReplicatedStorage:WaitForChild("SaveCustomPost")
local UpgradeRF : RemoteFunction = ReplicatedStorage:WaitForChild("Upgrade")
local RebirthRF : RemoteFunction = ReplicatedStorage:WaitForChild("Rebirth")

local upgradePostsRequiredFollowers : {number} = {10, 100, 1_000, 10_000, 100_000, 1_000_000, 10_000_000}

local playersReady : Folder = ReplicatedStorage:WaitForChild("PlayersReady")

local players : {Player.PlayerModule} = {}


export type ServerModule = {
	onJoin : (plr : Player) -> nil,
	onLeave : (playerName : string) -> nil
}


local ServerModule : ServerModule = {}


local function PlayerReachedFollowerGoal(p : Player.PlayerModule)
	-- fire the client to display the congratulations text
	InformationRE:FireClient(p.player, "Congratulations! You reached " .. tostring(p.nextFollowerGoal) .. " followers!", 8)

	-- fire the client for a rainbow firework of particles around the player and play the "ding" sound
	ParticleRE:FireClient(p.player)

	p.nextFollowerGoal = math.pow(10, math.ceil(math.log10(p.followers + 1))) -- if the player is at 100 followers exactly, the next follower goal will be 100 when it should 1000, so add 1 to the followers count of the player to prevent that)

	p.plotModule.phone.FollowerGoal.Goal.SurfaceGui.GoalText.Text = tostring(p.nextFollowerGoal .. " followers")
end


--[[
	When a player joins, instantiates everything that will be needed for them

	@param plr : Player, the player who joined the game
]]--
function ServerModule.onJoin(plr : Player)
	local p : Player.PlayerModule = Player.new(plr)

	-- save the player module on the server module
	players[plr.Name] = p

	if not p.plotModule:AssignPlot(p.player) then
		ServerModule.onLeave(plr)
	end

	-- load the follower goal progress and goal
	p.plotModule.phone.FollowerGoal.Goal.SurfaceGui.GoalText.Text = tostring(p.nextFollowerGoal .. " followers")
	p.plotModule.followerGoal.Size = UDim2.new(0.7,0, ((p.followers / p.nextFollowerGoal) * 0.97), 0)

	-- generate the state machine
	p.postModule:GenerateStateMachine()

	-- detect when player touches the upgrade post part
	p.maid:GiveTask(
		p.plotModule.phone.UpgradePosts.HitBox.Touched:Connect(function(hit)
			if hit.Parent and hit.Name == "HumanoidRootPart" and hit.Parent.Name == p.plotModule.phone.Owner.Value then
				UpgradePostsRE:FireClient(p.player, true)
			end
		end)
	)

	-- detect when player leaves the upgrade post part
	p.maid:GiveTask(
		p.plotModule.phone.UpgradePosts.HitBox.TouchEnded:Connect(function(hit)
			if hit.Parent and hit.Name == "HumanoidRootPart" and hit.Parent.Name == p.plotModule.phone.Owner.Value then
				UpgradePostsRE:FireClient(p.player, false)
			end
		end)
	)

	-- teleport the player once his character is loaded
	p.maid:GiveTask(
		plr.CharacterAdded:Connect(function(character)
			Promise.new(function(resolve)
				task.wait(0.5)
				resolve()
			end)
			:andThen(function()
				character.PrimaryPart.CFrame = CFrame.lookAt(p.plotModule.phone.TeleportPart.Position, p.plotModule.phone.PrimaryPart.Position)
			end)
		end)
	)

	if plr.Character then
		plr.Character.PrimaryPart.CFrame = CFrame.new(p.plotModule.phone.TeleportPart.Position, p.plotModule.phone.PrimaryPart.Position)
	end


	local followersStore = DataStore2("followers", plr)
	-- callback on followers store update
	followersStore:OnUpdate(function()
		p.followers = followersStore:Get(p.followers)

		-- fire the client to display the number of followers the player has
		FollowersRE:FireClient(p.player, p.followers)

		if p.followers >= p.nextFollowerGoal then
			PlayerReachedFollowerGoal(p)
		end

		p.plotModule.followerGoal.Size = UDim2.new(0.7,0, ((p.followers / p.nextFollowerGoal) * 0.97), 0) -- multiply by 0.97 because we don't want the frame to be 1 in y scale, we want it to go up to 0.97
	end)


	local coinsStore = DataStore2("coins", plr)
	-- callback on coins store update
	coinsStore:OnUpdate(function()
		p.coins = coinsStore:Get(p.coins)

		-- fire the client to display the number of coins the player has
		CoinsRE:FireClient(p.player, p.coins)
	end)
	
	-- fire the followers and coins events once at the start to display the numbers
	FollowersRE:FireClient(p.player, p.followers)
	CoinsRE:FireClient(p.player, p.coins)

	local playerReady : BoolValue = Instance.new("BoolValue")
	playerReady.Name = plr.Name
	playerReady.Value = true
	playerReady.Parent = playersReady
end


--[[
	When a payer leaves, remove everything that is not needed anymore

	@param playerName : string, the name of the player who is leaving
]]--
function ServerModule.onLeave(playerName)
	local p : Player.PlayerModule = players[playerName]

	-- remove the player module from the server module
	if p then
		p:OnLeave()

		players[playerName] = nil

		if playersReady:FindFirstChild(playerName) then
			playersReady[playerName]:Destroy()
		end
	end
end


--[[
	Fires when the player clicks or touches the screen to post

	@param plr : Player, the player who is leaving
]]--
PlayerClickedRE.OnServerEvent:Connect(function(plr : Player)
	local p : Player.PlayerModule = players[plr.Name]
	if p then
		p.postModule:PlayerClicked(p)
	end
end)


--[[
	When a player wants to buy a post, we make sure he has enough followers and unlock it

	@param plr : Player, the player who wants to buy the post
	@param post : number, the post (representing the level the player wants to buy)
]]--
UnlockPostRF.OnServerInvoke = function(plr : Player, post : number)
	if typeof(post) == "number" and post > 0 and post < 8 then

		local p : Player.PlayerModule = players[plr.Name]
		if p then

			if p.postModule.level < post and p:HasEnoughFollowers(upgradePostsRequiredFollowers[post]) then
				p.postModule.level = post

				p.postModule:GenerateStateMachine()

				return true
			end
		end
	end

	return false
end


--[[
	Fires when the player clicks the play time rewards and can collect it

	@param plr : Player, the player who clicked the play time rewards button
]]--
CollectPlayTimeRewardRF.OnServerInvoke = function (plr : Player)
	local p : Player.PlayerModule = players[plr.Name]
	if p then
		return p.playTimeRewards:CollectReward()
	end
end


--[[
	Fires when the player is ready to receive and data and wants to get the list of his custom posts

	@param plr : Player, the player who clicked the play time rewards button
]]--
ListCustomPostsRE.OnServerEvent:Connect(function(plr : Player)
	local p : Player.PlayerModule = players[plr.Name]
	if p then
		p.customPosts:GetAllPosts("all")
	end
end)


--[[
	Fires when the player creates a new post or modify an existing one

	@param plr : Player, the player who wants to save a post
	@param postType : string, the type of post the player is saving
	@param text1 : string, the first text of the post
	@param text2 : string, the second text of the post (empty if postType == "post")
	@param id : number?, the id of the post if the player is modifying one, null if he is creating one
]]--
SaveCustomPostRF.OnServerInvoke = function(plr : Player, postType : string?, text1 : string?, text2 : string?, id : number?)
	local p : Player.PlayerModule = players[plr.Name]
	if p then
		if id then
			if postType then
				return p.customPosts:SavePost(p, id, postType, text1, text2)
			else 
				return p.customPosts:DeletePost(id)
			end
		else
			return p.customPosts:CreatePost(postType, text1, text2)
		end
	end
end


--[[
	Fires when the player clicks the upgrade button in the upgrades list ui

	@param plr : Player, the player who clicked the upgrade button
	@param id : nmuber, the id of the upgrade that has been clicked
	@return {upgrade} | upgrade, the upgrades if it's the first time the player fires the event,
	the upgrade corresponding to the id otherwise
]]--
UpgradeRF.OnServerInvoke = function(plr : Player, id : number) : {}
	if id and typeof(id) == "number" then
		local p : Player.PlayerModule = players[plr.Name]
		if p then
			return p.upgradeModule:Upgrade(p, id)
		end
	end

	return {}
end


--[[
	Fires when the player tries to rebirth
]]--
RebirthRF.OnServerInvoke = function(plr : Player)
	local p : Player.PlayerModule = players[plr.Name]
	if p then
		local rebirthSuccessful : boolean = p.rebirthModule:Rebirth(p.followers, p.player)
		if rebirthSuccessful then
			p.followers = 0
			p:UpdateFollowersMultiplier()
			DataStore2("followers", plr):Set(0)
		end

		return rebirthSuccessful
	end
end


--[[
	Post for each player once the cooldown is over
]]--
coroutine.wrap(function()
	while true do

		local now : number = math.round(tick() * 1_000)

		-- for each player if it has been more than autoPostInterval since the last auto post, we post
		for _,p in pairs(players) do
			if now >= p.postModule.nextAutoPost then
				p.postModule.nextAutoPost = now + p.postModule.autoPostInterval

				p.postModule:Post(p)
			end
		end

		RunService.Heartbeat:Wait()
	end
end)()


-- once the server has finished loading, we change the IsServerReady value to true to tell all clients that it is ready
if not ReplicatedStorage:WaitForChild("IsServerReady").Value then
	ReplicatedStorage.IsServerReady.Value = true
end


return ServerModule