local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local PlotModule = require(ServerScriptService:WaitForChild("PlotModule"))
local PostModule = require(ServerScriptService:WaitForChild("PostModule"))
local CustomPost = require(ServerScriptService:WaitForChild("CustomPost"))
local PlayTimeRewards = require(ServerScriptService:WaitForChild("PlayTimeRewards"))
local UpgradeModule = require(ServerScriptService:WaitForChild("UpgradeModule"))
local RebirthModule = require(ServerScriptService:WaitForChild("RebirthModule"))
local CaseModule = require(ServerScriptService:WaitForChild("CaseModule"))
local PotionModule = require(ServerScriptService:WaitForChild("PotionModule"))
local PetModule = require(ServerScriptService:WaitForChild("PetModule"))
local FriendsModule = require(ServerScriptService:WaitForChild("FriendsModule"))
local GroupModule = require(ServerScriptService:WaitForChild("GroupModule"))
local QuestModule = require(ServerScriptService:WaitForChild("QuestModule"))
local SpinningWheelModule = require(ServerScriptService:WaitForChild("SpinningWheelModule"))
local EmojisReactionsModule = require(ServerScriptService:WaitForChild("EmojisReactionsModule"))
local GamepassModule = require(ServerScriptService:WaitForChild("GamepassModule"))
local Maid = require(ReplicatedStorage:WaitForChild("Maid"))

DataStore2.Combine("SMS", "followers", "coins", "lastPlayed")

local lastUpdate : number = os.time({year = 2023, month = 11, day = 18, hour = 22, min = 30, sec = 00})


export type PlayerModule = {
	player : Player,
	isLoaded : boolean,
	isPremium : boolean,
	followers : number,
	nextFollowerGoal : number,
	coins : number,
	followersMultiplier : number,
	coinsMultiplier : number,
	lastPlayed : number,
	displayChangelog : boolean,
	alreadyPlayedToday : boolean,
	totalTimePlayed : number,
	getXFollowersQuest : (followers : number) -> nil | nil,
	getXCoinsQuest : (coins : number) -> nil | nil,
	plotModule : PlotModule.PlotModule,
	postModule : PostModule.PostModule,
	upgradeModule : UpgradeModule.UpgradeModule,
	customPosts : CustomPost.CustomPost,
	playTimeRewards : PlayTimeRewards.PlayTimeRewards,
	rebirthModule : RebirthModule.RebirthModule,
	caseModule : CaseModule.CaseModule,
	potionModule : PotionModule.PotionModule,
	petModule : PetModule.PetModule,
	friendsModule : FriendsModule.FriendsModule,
	groupModule : GroupModule.GroupModule,
	questModule : QuestModule.QuestModule,
	spinningWheelModule : SpinningWheelModule.SpinningWheelModule,
	emojisReactionsModule : EmojisReactionsModule.EmojisReactionsModule,
	gamepassModule : GamepassModule.GamepassModule,
	maid : Maid.Maid,
	new : (plr : Player) -> PlayerModule,
	UpdateFollowersMultiplier : (self : PlayerModule) -> nil,
	UpdateCoinsMultiplier : (self : PlayerModule) -> nil,
	HasEnoughFollowers : (self : PlayerModule, amount : number) -> boolean,
	UpdateFollowersAmount : (self : PlayerModule, amount : number) -> nil,
	SetFollowersAmount : (self : PlayerModule, amount : number) -> nil,
	HasEnoughCoins : (self : PlayerModule, amount : number) -> boolean,
	UpdateCoinsAmount : (self : PlayerModule, amount : number) -> nil,
	SetCoinsAmount : (self : PlayerModule, amount : number) -> nil,
	UpdateAutopostInterval : (self : PlayerModule) -> nil,
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
	p.isLoaded = false
	p.isPremium = plr.MembershipType == Enum.MembershipType.Premium

	--DataStore2("followers", plr):Set(nil)
	--DataStore2("coins", plr):Set(nil)
	-- DataStore2("lastPlayed", p.player):Set(nil)

	p.followers = DataStore2("followers", plr):Get(0)
	p.nextFollowerGoal = math.pow(10, math.ceil(math.log10(p.followers))) -- find the next power of 10

	-- the above formula will output 0 if p.followers == 0, so if the result is under 100, we set it to 100
	if p.nextFollowerGoal < 100 then
		p.nextFollowerGoal = 100
	end

	p.coins = DataStore2("coins", plr):Get(0)

	p.followersMultiplier = 1
	p.coinsMultiplier = 1

	p.lastPlayed = DataStore2("lastPlayed", p.player):Get(0)
	if os.date("%j") == os.date("%j", p.lastPlayed) then
		p.alreadyPlayedToday = true
	else
		p.alreadyPlayedToday = false
	end

	p.displayChangelog = p.lastPlayed <= lastUpdate
	print(p.lastPlayed, lastUpdate, p.displayChangelog)

	DataStore2("lastPlayed", p.player):Set(os.time())

	p.totalTimePlayed = DataStore2("totalTimePlayed", p.player):Get(0)

	p.getXFollowersQuest = nil
	p.getXCoinsQuest = nil

	p.plotModule = PlotModule.new()

	p.postModule = PostModule.new(plr)

	p.upgradeModule = UpgradeModule.new(plr)

	p.customPosts = CustomPost.new(plr, p.postModule)

	p.playTimeRewards = PlayTimeRewards.new(plr)
	p.playTimeRewards:LoadData()
	p.playTimeRewards:StartTimer()

	p.rebirthModule = RebirthModule.new(plr)
	p.rebirthModule:UpdateFollowersNeededToRebirth()

	p.caseModule = CaseModule.new(plr)

	p.potionModule = PotionModule.new(plr)

	p.petModule = PetModule.new(plr)

	p.spinningWheelModule = SpinningWheelModule.new(plr)
	-- give a free spin if the player hasn't played today
	if not p.alreadyPlayedToday then
		p.spinningWheelModule:GiveFreeSpin("normal")
		p.spinningWheelModule:GiveFreeSpin("normal")
	end

	p.emojisReactionsModule = EmojisReactionsModule.new(p)

	p.friendsModule = FriendsModule.new(plr)

	--p.coins = DataStore2("coins", plr):Get(0)

	p.maid = Maid.new()

	-- create the followers and coins number values
	local statsFolder = Instance.new("Folder")
	statsFolder.Name = "leaderstats"
	statsFolder.Parent = plr

	local followerValue : NumberValue = Instance.new("NumberValue")
	followerValue.Name = "Followers"
	followerValue.Value = p.followers
	followerValue.Parent = statsFolder

	local coinsValue : NumberValue = Instance.new("NumberValue")
	coinsValue.Name = "Coins"
	coinsValue.Value = p.coins
	coinsValue.Parent = statsFolder

	local rebirthValue : NumberValue = Instance.new("NumberValue")
	rebirthValue.Name = "Rebirth"
	rebirthValue.Value = p.rebirthModule.rebirthLevel
	rebirthValue.Parent = statsFolder

	local vip : BoolValue = Instance.new("BoolValue")
	vip.Name = "VIP"
	vip.Parent = plr

	p.gamepassModule = GamepassModule.new(plr)

	return setmetatable(p, Player)
end


--[[
	Updates the followers multiplier by adding all the differents multipliers together
]]--
function Player:UpdateFollowersMultiplier()
	self.followersMultiplier =
		1 *
		(1 + self.upgradeModule.followersMultiplier) *
		(1 + self.rebirthModule.followersMultiplier) *
		(1 + self.potionModule.followersMultiplier) *
		(1 + self.petModule.followersMultiplier) *
		(1 + self.friendsModule.followersMultiplier) *
		self.gamepassModule:GetFollowersMultiplier()

	-- print("followers multiplier", self.followersMultiplier, self.upgradeModule.followersMultiplier, self.rebirthModule.followersMultiplier, self.potionModule.followersMultiplier, self.petModule.followersMultiplier, self.friendsModule.followersMultiplier, self.gamepassModule:GetFollowersMultiplier())
end


--[[
	Updates the coins multiplier by adding all the differents multipliers together
]]--
function Player:UpdateCoinsMultiplier()
	self.coinsMultiplier =
		1 *
		(1 + self.upgradeModule.coinsMultiplier) *
		(1 + self.potionModule.coinsMultiplier) *
		(1 + self.friendsModule.coinsMultiplier) *
		self.gamepassModule:GetCoinsMultiplier()

	-- print("coins multiplier", self.coinsMultiplier, self.upgradeModule.coinsMultiplier, self.potionModule.coinsMultiplier, self.friendsModule.coinsMultiplier, self.gamepassModule:GetCoinsMultiplier())
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
function Player:UpdateFollowersAmount(amount : number)
	local increment : number = if amount <= 0 then amount else math.round(amount * self.followersMultiplier)

	-- update get X followers quest
	if increment > 0 and self.getXFollowersQuest then
		self.getXFollowersQuest(increment)
	end

	self.followers += increment
	DataStore2("followers", self.player):Increment(increment, self.followers)

	self.player.leaderstats.Followers.Value = self.followers
end


--[[
	Sets the amount of followers to the given amount

	@param amount : number, the amount which to set followers to
]]--
function Player:SetFollowersAmount(amount : number)
	self.followers = amount
	DataStore2("followers", self.player):Set(self.followers)
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
	local increment : number = if amount <= 0 then amount else math.round(amount * self.coinsMultiplier)

	self.coins += increment

	-- update get X coins quest
	if increment > 0 and self.getXCoinsQuest then
		self.getXCoinsQuest(increment)
	end

	DataStore2("coins", self.player):Increment(increment, self.coins)

	self.player.leaderstats.Coins.Value = self.coins
end


--[[
	Sets the amount of coins to the given amount

	@param amount : number, the amount which to set coins to
]]--
function Player:SetCoinsAmount(amount : number)
	self.coins = amount
	DataStore2("coins", self.player):Set(self.coins)
end


--[[

]]--
function Player:UpdateAutopostInterval()
	local upgrade : UpgradeModule.upgrade = self.upgradeModule.upgrades[2]

	self.postModule.autoPostInterval =
		math.max(
			3_000 -
			(upgrade.baseValue + upgrade.upgradeValues[upgrade.level]) -
			(self.caseModule.speedBoost) -
			(self.potionModule.speedBoost),
			220
		)
	-- print("new autopost invertal: ", self.postModule.autoPostInterval, "(", (upgrade.baseValue + upgrade.upgradeValues[upgrade.level]), ", ", self.caseModule.speedBoost, ", ", self.potionModule.speedBoost, ")")
end


--[[
	When a player leaves, remove all their connections and remove them from the module metatable
]]--
function Player:OnLeave()

	-- save the lastplayed value of on leave in case the player started playing yesterday but kept playing until today
	self.lastPlayed = os.time()
	DataStore2("lastPlayed", self.player):Set(self.lastPlayed)

	-- remove the plot for the player
	self.plotModule:OnLeave()

	self.postModule:OnLeave()

	self.customPosts:OnLeave()

	self.upgradeModule:OnLeave()

	self.playTimeRewards:OnLeave()

	self.gamepassModule:OnLeave()

	self.potionModule:OnLeave()

	self.caseModule:OnLeave()

	self.rebirthModule:OnLeave()

	self.petModule:OnLeave()

	self.friendsModule:OnLeave()

	self.groupModule:OnLeave()

	if self.questModule then
		self.questModule:OnLeave()
	end

	-- clean all the connections
	self.maid:DoCleaning()

	setmetatable(self, nil)
	self = nil
end


return Player