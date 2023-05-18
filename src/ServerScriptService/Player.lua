local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local PlotModule = require(ServerScriptService:WaitForChild("PlotModule"))
local PostModule = require(ServerScriptService:WaitForChild("PostModule"))
local CustomPost = require(ServerScriptService:WaitForChild("CustomPost"))
local PlayTimeRewards = require(ServerScriptService:WaitForChild("PlayTimeRewards"))
local UpgradeModule = require(ServerScriptService:WaitForChild("UpgradeModule"))
local GamepassModule = require(ServerScriptService:WaitForChild("GamepassModule"))
local Maid = require(ReplicatedStorage:WaitForChild("Maid"))

DataStore2.Combine("SMS", "followers", "coins")


export type PlayerModule = {
	player : Player,
	followers : number,
	nextFollowerGoal : number,
	coins : number,
	followersMultiplier : number,
	coinsMultiplier : number,
	plotModule : PlotModule.PlotModule,
	postModule : PostModule.PostModule,
	upgradeModule : UpgradeModule.UpgradeModule,
	customPosts : CustomPost.CustomPost,
	playTimeRewards : PlayTimeRewards.PlayTimeRewards,
	gamepassModule : GamepassModule.GamepassModule,
	maid : Maid.Maid,
	new : (plr : Player) -> PlayerModule,
	HasEnoughFollowers : (self : PlayerModule, amount : number) -> boolean,
	UpdateFolowersAmount : (self : PlayerModule, amount : number) -> nil,
	HasEnoughCoins : (self : PlayerModule, amount : number) -> boolean,
	UpdateCoinsAmount : (self : PlayerModule, amount : number) -> nil,
	OnLeave : (self : PlayerModule) -> nil
}


local Player : PlayerModule = {}
Player.__index = Player


--[[
	Create a player module when a player joins the game

	@param plr : Player, the player who joined the game
]]--
function Player.new(plr : Player)
	local p = {}

	p.player = plr

	--DataStore2("followers", plr):Set(nil)
	--DataStore2("coins", plr):Set(nil)

	p.followers = DataStore2("followers", plr):Get(0)
	p.nextFollowerGoal = math.pow(10, math.ceil(math.log10(p.followers))) -- find the next power of 10

	-- the above formula will output 0 if p.followers == 0, so if the result is under 100, we set it to 100
	if p.nextFollowerGoal < 100 then
		p.nextFollowerGoal = 100
	end

	p.coins = DataStore2("coins", plr):Get(0)

	p.followersMultiplier = 1
	p.coinsMultiplier = 1

	p.plotModule = PlotModule.new()

	p.postModule = PostModule.new(plr)

	p.upgradeModule = UpgradeModule.new(plr)

	p.customPosts = CustomPost.new(plr, p.postModule)

	p.playTimeRewards = PlayTimeRewards.new(plr)
	p.playTimeRewards:LoadData()
	p.playTimeRewards:StartTimer()

	p.gamepassModule = GamepassModule.new()

	--p.coins = DataStore2("coins", plr):Get(0)

	p.maid = Maid.new()

	return setmetatable(p, Player)
end


--[[
	Returns true if the player has more followers than the given amount

	@param amount : number, the amount of followers to check
	@return boolean, true if the player has enough followers, false otherwise
]]--
function Player:HasEnoughFollowers(amount : number) : boolean
	return self.followers >= amount
end


--[[
	Updates the amount of followers of the player by adding the given amount

	@param amount : number, the amount of followers to add
]]--
function Player:UpdateFolowersAmount(amount : number)
	local increment : number = math.round(amount * self.followersMultiplier)

	self.followers += increment
	DataStore2("followers", self.player):Increment(increment, self.followers)
end


--[[
	Returns true if the player has more coins than the given amount

	@param amount : number, the amount of coins to check
	@return boolean, true if the player has enough coins, false otherwise
]]--
function Player:HasEnoughCoins(amount : number) : boolean
	return self.coins >= amount
end


--[[
	Updates the amount of coins of the player by adding the given amount

	@param amount : number, the amount of coins to add
]]--
function Player:UpdateCoinsAmount(amount : number)
	local increment : number = math.round(amount * self.coinsMultiplier)

	self.coins += increment
	DataStore2("coins", self.player):Increment(increment, self.coins)
end


--[[
	When a player leaves, remove all their connections and remove them from the module metatable
]]--
function Player:OnLeave()

	-- remove the plot for the player
	self.plotModule:OnLeave()

	self.postModule:OnLeave()

	self.customPosts:OnLeave()

	self.playTimeRewards:OnLeave()

	-- clean all the connections
	self.maid:DoCleaning()

	setmetatable(self, nil)
	self = nil
end


return Player