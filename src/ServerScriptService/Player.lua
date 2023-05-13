local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local PlotModule = require(ServerScriptService:WaitForChild("PlotModule"))
local PostModule = require(ServerScriptService:WaitForChild("PostModule"))
local CustomPost = require(ServerScriptService:WaitForChild("CustomPost"))
local PlayTimeRewards = require(ServerScriptService:WaitForChild("PlayTimeRewards"))
local Maid = require(ReplicatedStorage:WaitForChild("Maid"))

DataStore2.Combine("SMS", "followers", "coins")


export type PlayerModule = {
	player : Player,
	followers : number,
	nextFollowerGoal : number,
	coins : number,
	plotModule : PlotModule.PlotModule,
	postModule : PostModule.PostModule,
	customPosts : CustomPost.CustomPost,
	playTimeRewards : PlayTimeRewards.PlayTimeRewards,
	maid : Maid.Maid,
	new : (plr : Player) -> PlayerModule,
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

	p.plotModule = PlotModule.new()

	p.postModule = PostModule.new(plr)

	p.customPosts = CustomPost.new(plr, p.postModule)

	p.playTimeRewards = PlayTimeRewards.new(plr)
	p.playTimeRewards:LoadData()
	p.playTimeRewards:StartTimer()

	--p.coins = DataStore2("coins", plr):Get(0)

	p.maid = Maid.new()

	return setmetatable(p, Player)
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
