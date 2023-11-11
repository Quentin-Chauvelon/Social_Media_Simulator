local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Player = require(ServerScriptService:WaitForChild("Player"))
local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local DeveloperProductModule = require(ServerScriptService:WaitForChild("DeveloperProductModule"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))
local LeaderboardModule = require(ServerScriptService:WaitForChild("LeaderboardModule"))
local QuestModule = require(ServerScriptService:WaitForChild("QuestModule"))
local GroupModule = require(ServerScriptService:WaitForChild("GroupModule"))
local EventsModule = require(ServerScriptService:WaitForChild("EventsModule"))

local UpdateFollowersBE : BindableEvent = ServerStorage:WaitForChild("UpdateFollowers")
local UpdateCoinsBE : BindableEvent = ServerStorage:WaitForChild("UpdateCoins")

local PlayerClickedRE : RemoteEvent = ReplicatedStorage:WaitForChild("PlayerClicked")
local UnlockPostRF : RemoteFunction = ReplicatedStorage:WaitForChild("UnlockPost")
local OpenEggRF : RemoteFunction = ReplicatedStorage:WaitForChild("OpenEgg")
local UpgradePostsRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpgradePosts")
local FollowersRE : RemoteEvent = ReplicatedStorage:WaitForChild("Followers")
local CoinsRE : RemoteEvent = ReplicatedStorage:WaitForChild("Coins")
local InformationRE : RemoteEvent = ReplicatedStorage:WaitForChild("InformationNotification")
local ParticleRE : RemoteEvent = ReplicatedStorage:WaitForChild("Particle")
local CollectPlayTimeRewardRF : RemoteFunction = ReplicatedStorage:WaitForChild("CollectPlayTimeReward")
local ListCustomPostsRE : RemoteEvent = ReplicatedStorage:WaitForChild("ListCustomPosts")
local SaveCustomPostRF : RemoteFunction = ReplicatedStorage:WaitForChild("SaveCustomPost")
local UpgradeRF : RemoteFunction = ReplicatedStorage:WaitForChild("Upgrade")
local RebirthRE : RemoteEvent = ReplicatedStorage:WaitForChild("Rebirth")
local CaseRF : RemoteFunction = ReplicatedStorage:WaitForChild("Case")
local PetsRE : RemoteEvent = ReplicatedStorage:WaitForChild("Pets")
local PlayerLoadedRE : RemoteEvent = ReplicatedStorage:WaitForChild("PlayerLoaded")
local EquipPetRF : RemoteFunction = ReplicatedStorage:WaitForChild("EquipPet")
local EquipBestPetsRF : RemoteFunction = ReplicatedStorage:WaitForChild("EquipBestPets")
local DeletePetRF : RemoteFunction = ReplicatedStorage:WaitForChild("DeletePet")
local DeleteUnequippedPetsRF : RemoteFunction = ReplicatedStorage:WaitForChild("DeleteUnequippedPets")
local CraftPetRF : RemoteFunction = ReplicatedStorage:WaitForChild("CraftPet")
local UpgradePetRF : RemoteFunction = ReplicatedStorage:WaitForChild("UpgradePet")
local CreateQuestRE : RemoteEvent = ReplicatedStorage:WaitForChild("CreateQuest")
local ClaimQuestRewardRF : RemoteFunction = ReplicatedStorage:WaitForChild("ClaimQuestReward")
local UpdateQuestProgressRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpdateQuestProgress")
local UpdateNextEventRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpdateNextEvent")
local TimeLeftBeforeEventStartRE : RemoteEvent = ReplicatedStorage:WaitForChild("TimeLeftBeforeEventStart")

local LeaderboardsDataBF : BindableFunction = game:GetService("ServerStorage"):WaitForChild("LeaderboardsData")


DataStore2.Combine("SMS", "totalTimePlayed")


local upgradePostsRequiredFollowers : {number} = {100, 100, 1_000, 5_000, 25_000, math.huge, math.huge} -- last 2 types have a math.huge price because they can't be bought for now (their price should be 200k and 2M)

local playersReady : Folder = ReplicatedStorage:WaitForChild("PlayersReady")

local players : {Player.PlayerModule} = {}


export type ServerModule = {
	onJoin : (plr : Player) -> nil,
	onLeave : (playerName : string) -> nil
}


local ServerModule : ServerModule = {}


LeaderboardModule.new()

LeaderboardsDataBF.OnInvoke = function(playerName : string, leaderboardType : string)
	local p : Player.PlayerModule = players[playerName]
	if p then

		if leaderboardType == "followers" then
			return p.followers
		elseif leaderboardType == "rebirths" then
			return p.rebirthModule.rebirthLevel
		elseif leaderboardType == "timePlayed" then

			-- every time the event is called, increase the time played by 2 minutes and save it
			p.totalTimePlayed += 2
			DataStore2("totalTimePlayed", p.player):Increment(2, p.totalTimePlayed)

			return p.totalTimePlayed
		end
	end

	return 0
end


EventsModule.StartEventsLoop()


local function PlayerReachedFollowerGoal(p : Player.PlayerModule)
	-- fire the client to display the congratulations text
	InformationRE:FireClient(p.player, "Congratulations! You reached " .. tostring(p.nextFollowerGoal) .. " followers!", 8)

	-- fire the client for a rainbow firework of particles around the player and play the "ding" sound
	ParticleRE:FireClient(p.player)

	p.nextFollowerGoal = math.pow(10, math.ceil(math.log10(p.followers + 1))) -- if the player is at 100 followers exactly, the next follower goal will be 100 when it should 1000, so add 1 to the followers count of the player to prevent that)

	p.plotModule.phone.FollowerGoal.Goal.SurfaceGui.GoalText.Text = tostring(p.nextFollowerGoal .. " followers")
end


PlayerLoadedRE.OnServerEvent:Connect(function(player)
	local p : Player.PlayerModule = players[player.Name]
	if p then
		p.isLoaded = true
	end
end)


--[[
	When a player joins, instantiates everything that will be needed for them

	@param plr : Player, the player who joined the game
]]--
function ServerModule.onJoin(plr : Player)
	local p : Player.PlayerModule = Player.new(plr)
	p.groupModule = GroupModule.new(p)

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

	-- equip the player's case
	p.caseModule:EquipCase(p)

	-- use all the potions to give the effects to the player
	p.potionModule:UseAllActivePotions(p)

	-- update the followers multiplier
	p:UpdateFollowersMultiplier()

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
			local petsFolder : Folder = Instance.new("Folder")
			petsFolder.Name = "Pets"
			petsFolder.Parent = character

			Promise.new(function(resolve)
				task.wait(0.5)
				resolve()
			end)
			:andThen(function()

				character.PrimaryPart.CFrame = CFrame.lookAt(p.plotModule.phone.TeleportPart.Position, p.plotModule.phone.PrimaryPart.Position)

				-- if the player resetted his character, recreate all the attachments (check if it doesn't exist first because when the player joins the attachments can be created before this function runs and we don't want to create them twice)
				if character.HumanoidRootPart and not character.HumanoidRootPart:FindFirstChild("PetAttachment") then
					-- create the attachments, turn them and loads the pets
					p.petModule:CreatePetAttachments()
					p.petModule:RotateAttachmentsTowardsPlayer(p.plotModule.phone.PrimaryPart.Position)
					p.petModule.currentlyEquippedPets = 0
					p.petModule:LoadEquippedPets()
				end
			end)

			local p : Player.PlayerModule = players[plr.Name]
			if p then
				p.upgradeModule:ApplyUpgrade(p, p.upgradeModule.upgrades[1])
			end
		end)
	)

	if plr.Character then
		plr.Character.PrimaryPart.CFrame = CFrame.new(p.plotModule.phone.TeleportPart.Position, p.plotModule.phone.PrimaryPart.Position)

		-- if the player resetted his character, recreate all the attachments (check if it doesn't exist first because when the player joins the attachments can be created before this function runs and we don't want to create them twice)
		if plr.Character.HumanoidRootPart and not plr.Character.HumanoidRootPart:FindFirstChild("PetAttachment") then
			-- create the attachments, turn them and loads the pets
			p.petModule:CreatePetAttachments()
			p.petModule:RotateAttachmentsTowardsPlayer(p.plotModule.phone.PrimaryPart.Position)
			p.petModule:LoadEquippedPets()
		end

		local petsFolder : Folder = Instance.new("Folder")
		petsFolder.Name = "Pets"
		petsFolder.Parent = plr.Character
	end


	local followersStore = DataStore2("followers", plr)
	-- callback on followers store update
	followersStore:OnUpdate(function()
		p.followers = followersStore:Get(p.followers)

		-- fire the client to display the number of followers the player has
		FollowersRE:FireClient(p.player, p.followers)

		-- if p.followers >= p.nextFollowerGoal then
		-- 	PlayerReachedFollowerGoal(p)
		-- end

		p.plotModule.followerGoal.Size = UDim2.new(0.7,0, ((p.followers / p.nextFollowerGoal) * 0.97), 0) -- multiply by 0.97 because we don't want the frame to be 1 in y scale, we want it to go up to 0.97
	end)


	local coinsStore = DataStore2("coins", plr)
	-- callback on coins store update
	coinsStore:OnUpdate(function()
		p.coins = coinsStore:Get(p.coins)

		-- fire the client to display the number of coins the player has
		CoinsRE:FireClient(p.player, p.coins)
	end)

	local playerReady : BoolValue = Instance.new("BoolValue")
	playerReady.Name = plr.Name
	playerReady.Value = true
	playerReady.Parent = playersReady

	local hideLoadingScreen : BoolValue = Instance.new("BoolValue")
	hideLoadingScreen.Name = "HideLoadingScreen"
	hideLoadingScreen.Value = false
	hideLoadingScreen.Parent = plr

	-- wait for the player to be fully loaded before firing events
	Promise.new(function(resolve)
		repeat
			RunService.Heartbeat:Wait()
		until p.isLoaded == true

		-- fire the client to load the owned pets
		PetsRE:FireClient(plr, p.petModule.ownedPets, true)

		-- fire the followers and coins events once at the start to display the numbers
		FollowersRE:FireClient(plr, p.followers)
		CoinsRE:FireClient(plr, p.coins)

		-- fire the upgrade posts remote event to load the ui for the types the player already owns
		UpgradePostsRE:FireClient(plr, p.postModule.level)

		-- fire the client to load the next event
		UpdateNextEventRE:FireClient(plr, EventsModule.nextEvent)
		TimeLeftBeforeEventStartRE:FireClient(plr, (EventsModule.timeBeforeNextEvent - os.time()) / 60)

		-- load the effect of the game passes the player owns
		p.gamepassModule:LoadOwnedGamePasses(p)

		if p.gamepassModule:PlayerOwnsGamePass(p.gamepassModule.gamePasses.SpaceCase) then
			p.caseModule.ownedCases["Space"] = true
		end

		-- update the friends boost of all the player's friends that are online
		local onlineFriends : {string} = p.friendsModule:GetOnlineFriends()
		for _,friendName : string in pairs(onlineFriends) do


			-- add a friend for each friend already connected
			local friendP : Player.PlayerModule = players[friendName]
			if friendP then
				-- add all the friends for the player that joined
				p.friendsModule:FriendJoined()

				friendP.friendsModule:FriendJoined()

				-- update the multipliers
				friendP:UpdateFollowersMultiplier()
				friendP:UpdateCoinsMultiplier()
			end
		end

		-- update the followers and coins multiplier of the player in case he had friends online
		p:UpdateFollowersMultiplier()
		p:UpdateCoinsMultiplier()

		p.questModule = QuestModule.new(p)

		local averageFollowersPerSecond : NumberValue = Instance.new("NumberValue")
		averageFollowersPerSecond.Name = "AverageFollowersPerSecond"
		averageFollowersPerSecond.Value = p.questModule.averageFollowersPerSecond
		averageFollowersPerSecond.Parent = p.player

		local averageCoinsPerSecond : NumberValue = Instance.new("NumberValue")
		averageCoinsPerSecond.Name = "AverageCoinsPerSecond"
		averageCoinsPerSecond.Value = p.questModule.averageCoinsPerSecond
		averageCoinsPerSecond.Parent = p.player

		hideLoadingScreen.Value = true

		resolve()
	end)
end


--[[
	When a payer leaves, remove everything that is not needed anymore

	@param playerName : string, the name of the player who is leaving
]]--
function ServerModule.onLeave(playerName)
	local p : Player.PlayerModule = players[playerName]

	-- remove the player module from the server module
	if p then
		local onlineFriends : {string} = p.friendsModule:GetOnlineFriends()
		for _,friendName : string in pairs(onlineFriends) do
			local p : Player.PlayerModule = players[friendName]
			if p then
				p.friendsModule:FriendLeft()

				-- update the multipliers
				p:UpdateFollowersMultiplier()
				p:UpdateCoinsMultiplier()
			end
		end

		p:OnLeave()

		players[playerName] = nil

		if playersReady:FindFirstChild(playerName) then
			playersReady[playerName]:Destroy()
		end
	end
end


--[[
	Updates the amount of followers the player has

	@param playerName : string, the name of the player
	@param amount : number, the amount of followers to add
	@param useMultiplier : boolean?, if true, the amount will be multiplied by the followers multiplier of the player
]]
UpdateFollowersBE.Event:Connect(function(playerName : string, amount : number, useMultiplier : boolean?)
	if useMultiplier then
		local p : Player.PlayerModule = players[playerName]
		if p then
			p:UpdateFollowersAmount(amount)
		end

	else
		local p : Player.PlayerModule = players[playerName]
		if p then
			p.followers += amount
			DataStore2("followers", p.player):Increment(amount, p.followers)
			p.player.leaderstats.Followers.Value = p.followers
		end
	end
end)



--[[
	Updates the amount of coins the player has

	@param playerName : string, the name of the player
	@param amount : number, the amount of coins to add
	@param useMultiplier : boolean?, if true, the amount will be multiplied by the coins multiplier of the player
]]
UpdateCoinsBE.Event:Connect(function(playerName : string, amount : number, useMultiplier : boolean?)
	if useMultiplier then
		local p : Player.PlayerModule = players[playerName]
		if p then
			p:UpdateCoinsAmount(amount)
		end

	else
		local p : Player.PlayerModule = players[playerName]
		if p then
			p.coins += amount
			DataStore2("coins", p.player):Increment(amount, p.coins)
			p.player.leaderstats.Coins.Value = p.coins
		end
	end
end)


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
				-- increment the saved level
				DataStore2("level", plr):Set(post)

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
		return p.playTimeRewards:CollectReward(p)
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

	@param plr : Player, the player who clicked the rebirth button
]]--
RebirthRE.OnServerEvent:Connect(function(plr : Player)
	local p : Player.PlayerModule = players[plr.Name]
	if p then
		local rebirthSuccessful : boolean = p.rebirthModule:TryRebirth(p.followers, p.player)
		if rebirthSuccessful then
			p.followers = 0

			-- reset the followers count
			DataStore2("followers", plr):Set(0)

			p:UpdateFollowersMultiplier()

			RebirthRE:FireClient(plr)
		end
	end
end)


--[[
	Fires when the player wants to buy a case

	@param plr : Player, the player who wants to buy a case
	@param color : string?, the color of the case the player wants to buy, or nil if it's the first time firing the event
]]--
CaseRF.OnServerInvoke = function(plr : Player, color : string?)
	local p : Player.PlayerModule = players[plr.Name]
	if p then

		-- if it's the first time the player fires the event, return the list of owned cases
		if not p.caseModule.dataSent and not color then
			p.caseModule.dataSent = true
			return p.caseModule:GetOwnedCases()
		end

		-- the player tries to buy the case (or equip it if he already owns it)
		if color and typeof(color) == "string" and (color ~= "Space" or p.caseModule.ownedCases["Space"] == true) then
			return p.caseModule:BuyCase(color, p)
		end

		return false
	end
end


--[[
	Fires when the player wants to open an egg

	@param plr : Player, the player who wants to open an egg
	@param eggId : number, the id of the egg the player wants to open
	@param numberOfEggs : number, the number of eggs the player is trying to open at once (1, 3 or 6 (3 and 6 are gamepasses))
	@retunr {pet}, the table containing the information about the pets the player got from the egg
]]--
OpenEggRF.OnServerInvoke = function(plr : Player, eggId : number, numberOfEggs : number) : {}
	if eggId and numberOfEggs and typeof(eggId) == "number" and typeof(numberOfEggs) == "number" then

		local p : Player.PlayerModule = players[plr.Name]
		if p then

			-- open 1 egg (default opening method)
			if numberOfEggs == 1 then
				return p.petModule:OpenEggs(p, eggId, 1)

			-- open 3 eggs (game pass)
			elseif numberOfEggs == 3 then
				if p.gamepassModule:PlayerOwnsGamePass(p.gamepassModule.gamePasses.Open3Eggs) then
					return p.petModule:OpenEggs(p, eggId, 3)
				end

			-- open 6 eggs (game pass)
			else
				if p.gamepassModule:PlayerOwnsGamePass(p.gamepassModule.gamePasses.Open6Eggs) then
					return p.petModule:OpenEggs(p, eggId, 6)
				end
			end
		end
	end

	return {}
end


--[[
    Fires when the player wants to equip a pet

	@param plr : Player, the player who wants to equip a pet
	@param identifier : string, the identifier of the pet
    @param size : number, the size of the pet
    @param upgrade : number, the upgrade applied to the pet
	@return
		boolean : true if the player could equip a pet, false otherwise (success)
        boolean : true if the pet is equipped, false otherwise (equipped)
]]--
EquipPetRF.OnServerInvoke = function(plr : Player, id : number) : (boolean, boolean)
	if id and typeof(id) == "number" then

		local p : Player.PlayerModule = players[plr.Name]
		if p then
			local success : boolean, equipped : boolean = p.petModule:EquipPet(id, true)

			p:UpdateFollowersMultiplier()

			return success, equipped
		end
	end

	return false, false
end


--[[
	Fires when the player clicks on the equip best pets button

	@param plr : Player, the player who wants to equip the best pets
	@return {number}, a list of the pets that got equipped
]]--
EquipBestPetsRF.OnServerInvoke = function(plr : Player) : {number}
	local p : Player.PlayerModule = players[plr.Name]
	if p then
		local equippedPetsIds : {number} = p.petModule:EquipBest()

		p:UpdateFollowersMultiplier()

		return equippedPetsIds
	end

	return {}
end


--[[
	Fires when the player wants to delete a pet

	@param plr : Player, the player who wants to delete a pet
	@param id : number, the id of the pet to delete
	@return boolean, true if the pet could be deleted, false otherwise
]]
DeletePetRF.OnServerInvoke = function(plr : Player, id : number) : boolean
	if id and typeof(id) == "number" then

		local p : Player.PlayerModule = players[plr.Name]
		if p then
			local success : boolean = p.petModule:DeletePet(id)

			p:UpdateFollowersMultiplier()

			return success
		end
	end

	return false
end


--[[
	Fires when the player wnats to delete all unequipped pets

	@param plr : Player, the player who wants to delete all unequipped pets
	@return {pet}, a table containing the pets left the player owns (new table of pets after deletion)
]]
DeleteUnequippedPetsRF.OnServerInvoke = function(plr : Player) : {}
	local p : Player.PlayerModule = players[plr.Name]
	if p then
		return p.petModule:DeleteUnequippedPets()
	end

	return {}
end


--[[
	Fires when the player wants to craft his pet into a bigger one

	@param plr : Player, the player who wants to craft his pet
	@param id : number, the id of the pet to craft
	@return boolean, true if the pet could be crafted, false otherwise
]]
CraftPetRF.OnServerInvoke = function(plr : Player, id : number) : boolean
	if id and typeof(id) == "number" then
		local p : Player.PlayerModule = players[plr.Name]
		if p then
			local success : boolean = p.petModule:CraftPet(id)

			p:UpdateFollowersMultiplier()

			return success
		end
	end

	return false
end


--[[
	Tries to upgrade the given pet with the given upgrade type

	@param plr : Player, the player who wants to upgrade his pet
	@param id : number, the id of the pet to upgrade
	@param upgradeType : number, the upgrade type the player wants to upgrade his pet to (shiny, rainbow)
	@param numberOfPetsInMachine : number, the number of pets the player put in the machine, used to know the odds of the upgrade succeeding
	@return
		boolean, true if the upgrade succeeded, false otherwise
		{pets}, a table containing the pets the player owns (new table of pets after upgrade)
]]
UpgradePetRF.OnServerInvoke = function(plr : Player, id : number, upgradeType : number, numberOfPetsInMachine : number) : (boolean, {})
	if id and upgradeType and numberOfPetsInMachine and typeof(id) == "number" and typeof(upgradeType) == "number" and typeof(numberOfPetsInMachine) == "number" then

		-- upgrade type can only be shiny (1) or rainbow (2), (pets can't be upgraded to magic via the remote function since it's a developer product)
		if upgradeType < 1 or upgradeType > 2 then return false, {} end

		-- the player can only put up to 5 pets in the machine
		if numberOfPetsInMachine < 0 or numberOfPetsInMachine > 5 then return false, {} end

		local p : Player.PlayerModule = players[plr.Name]
		if p then
			local success : boolean = p.petModule:UpgradePet(id, upgradeType, numberOfPetsInMachine)

			p:UpdateFollowersMultiplier()

			return success, p.petModule.ownedPets
		end
	end

	return false, {}
end


--[[
	This event is fired everytime before purchasing a magic upgrade, otherwise when the purchase succeeds, we have no way of knowing which pet to upgrade, hence why we save the pet id
]]--
PetsRE.OnServerEvent:Connect(function(plr : Player, petId : number)
	if petId and typeof(petId) == "number" then
		local p : Player.PlayerModule = players[plr.Name]
		if p then
			p.petModule.magicUpgradePetId = petId
		end
	end
end)


--[[
	Tries to claim the reward for the quest matching the given id

	@param plr : Player, the player who wants to claim the reward
	@param id : number, the id of the quest to claim the reward for
	@return boolean, true if the reward could be claimed, false otherwise
]]--
ClaimQuestRewardRF.OnServerInvoke = function(plr : Player, id : number) : boolean
	if id and typeof(id) == "number" then
		local p : Player.PlayerModule = players[plr.Name]
		if p then
			return p.questModule:ClaimReward(p, id)
		end
	end
end


--[[
	Fired to tell the server if it should fire the client to update the progress of the quests

	@param plr : Player, the player for whom to update the progress
	@param updateProgress : boolean, true if the server should fire the client to update the progress, false to stop
]]--
UpdateQuestProgressRE.OnServerEvent:Connect(function(plr : Player, updateProgress : boolean)
	if updateProgress ~= nil and typeof(updateProgress) == "boolean" then
		local p : Player.PlayerModule = players[plr.Name]
		if p then
			p.questModule.updateUIProgress = updateProgress
		end
	end
end)


--[[
	Apply an upgrade when the player buys a developer product
]]--
MarketplaceService.ProcessReceipt = function(receiptInfo : table) : Enum.ProductPurchaseDecision
	if receiptInfo and receiptInfo.PlayerId then

		local playerName : string = Players:GetNameFromUserIdAsync(receiptInfo.PlayerId)
		if playerName then

			local p : Player.PlayerModule = players[playerName]
			if p then
				ParticleRE:FireClient(p.player)

				return DeveloperProductModule.BoughtDeveloperProduct(receiptInfo, p)
			end
		end
	end
end


--[[
	Apply an effect when the player buys a game pass
]]--
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player : Player, purchasedPassID : number, purchaseSuccess : boolean)
	if purchaseSuccess then
		local p : Player.PlayerModule = players[player.Name]
		if p then
			ParticleRE:FireClient(p.player)

			p.gamepassModule:PlayerBoughtGamePass(purchasedPassID, p)
		end
	end
end)


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


--[[
	Coroutine running every few seconds to save the players quests progress
	Also, refreshes the quest if it's past midnight
]]--
coroutine.wrap(function()
	local today : number = os.date("%j")

	while true do
		for _,p : Player.PlayerModule in pairs(players) do
			if p.questModule then
				p.questModule:SaveQuests(p.player)
				task.wait(2)

				-- if the player played past midnight, refresh the quests
				if os.date("%j") ~= today then
					today = os.date("%j")

					-- create an empty quest to signal the client to delete the previous quests
					CreateQuestRE:FireClient(p.player)

					p.alreadyPlayedToday = false -- set alreadyPlayedToday to false to recreate the quests
					p.questModule = QuestModule.new(p)
					p.alreadyPlayedToday = true

					-- update the last played time to today
					p.lastPlayed = os.time()
					DataStore2("lastPlayed", p.player):Set(p.lastPlayed)
				end
			end
		end

		task.wait(2)
	end
end)()


-- once the server has finished loading, we change the IsServerReady value to true to tell all clients that it is ready
if not ReplicatedStorage:WaitForChild("IsServerReady").Value then
	ReplicatedStorage.IsServerReady.Value = true
end


return ServerModule