local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Promise = require(ReplicatedStorage:WaitForChild("Promise"))
local TableUtilities = require(ReplicatedStorage:WaitForChild("TableUtilities"))
local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local Types = require(ServerScriptService:WaitForChild("Types"))
local Rewards = require(script:WaitForChild("Rewards"))

local PlayTimeRewardsTimerSyncRE : RemoteEvent = ReplicatedStorage:WaitForChild("PlayTimeRewardsTimerSync")
local PetsRE : RemoteEvent = ReplicatedStorage:WaitForChild("Pets")


DataStore2.Combine("SMS", "playTimeRewards")

local defaultPlayTimeRewardsStats = {
	lastDayPlayed = 0,
	timePlayedToday = 0
}

local defaultRewards : {number} = {60, 120, 300, 600, 900, 1_200, 1_800, 2_700, 3_600, 5_400, 7_200, 10_800}


export type PlayTimeRewards = {
	lastDayPlayed : number,
	timePlayedToday : number,
	nextRewards : {number},
	rewardToCollect : number,
	promise : Promise.Promise,
	plr : Player,
	new : (Player) -> PlayTimeRewards,
	GetDataToSave : (self : PlayTimeRewards) -> PlayTimeRewardsStats,
	LoadData : (self : PlayTimeRewards) -> nil,
	StartTimer : (self : PlayTimeRewards) -> nil,
	CollectReward : (self : PlayTimeRewards, p : Types.PlayerModule) -> PlayTimeReward,
	OnLeave : (self : PlayTimeRewards) -> nil
}

type PlayTimeRewardsStats = {
	lastDayPlayed : number,
	timePlayedToday : number
}

type PlayTimeReward = {
	reward : string,
	value : number
}


local PlayTimeRewards : PlayTimeRewards = {}
PlayTimeRewards.__index = PlayTimeRewards


function PlayTimeRewards.new(plr : Player)
	local playTimeRewards = {}

	-- DataStore2("playTimeRewards", plr):Set({lastDayPlayed = os.time(), timePlayedToday = 105})
	-- DataStore2("playTimeRewards", plr):Set(nil)
	local playTimeRewardsStats : PlayTimeRewardsStats = DataStore2("playTimeRewards", plr):Get(defaultPlayTimeRewardsStats)
	playTimeRewards.lastDayPlayed = playTimeRewardsStats.lastDayPlayed
	playTimeRewards.timePlayedToday = playTimeRewardsStats.timePlayedToday

	-- table of all the time needed to get a reward
	playTimeRewards.nextRewards = TableUtilities.clone(defaultRewards)
	playTimeRewards.rewardToCollect = 0

	playTimeRewards.plr = plr

	return setmetatable(playTimeRewards, PlayTimeRewards)
end


--[[
	Returns a table that contains the data to save to datastore

	@return {number}, the table containing the data to save
]]--
function PlayTimeRewards:GetDataToSave()
	return {
		lastDayPlayed = self.lastDayPlayed,
		timePlayedToday = self.timePlayedToday
	}
end


--[[
	This function must be called right after PlayTimeRewards.new() since it loads some important things.
	It adds a callback to the store to sync the timer with the client.
	If the player last played yesterday or earlier, it resets the data for a new day
	It removes all the rewards the player has already collected
	It creates a number value defining the next reward, used by the client to know what the next reward is
]]--
function PlayTimeRewards:LoadData()

	-- callback to sync the timer on the client when the datastore updates (every 15 seconds)
	DataStore2("playTimeRewards", self.plr):OnUpdate(function()
		PlayTimeRewardsTimerSyncRE:FireClient(self.plr, self.timePlayedToday)
	end)

	-- if the player didn't already play today, we reset the time played
	if os.date("%j/%y", self.lastDayPlayed) ~= os.date("%j/%y") then
		self.lastDayPlayed = os.time()
		self.timePlayedToday = 0
		self.nextRewards = defaultRewards

		DataStore2("playTimeRewards", self.plr):Set(self:GetDataToSave())
	end

	-- remove all the rewards the player already collected from the nextRewards table
	while #self.nextRewards >= 1 and self.timePlayedToday > self.nextRewards[1] do
		table.remove(self.nextRewards, 1)
	end

	-- create the value indicating what the next reward is (used so that the client knows what the next reward is)
	local nextReward : NumberValue = Instance.new("NumberValue")
	nextReward.Name = "NextReward"
	-- if the player got all the reward, set the next reward to math.huge so that the player can't reach it
	nextReward.Value = #self.nextRewards >= 1 and self.nextRewards[1] or math.huge
	nextReward.Parent = self.plr
end


--[[
	Start counting the time the player spent in the game and give him the rewards when he has played long enough
]]--
function PlayTimeRewards:StartTimer()
	-- update the data store once so that update callback gets called and the client timer is synced with the server
	DataStore2("playTimeRewards", self.plr):Set(self:GetDataToSave())

	self.promise = Promise.new(function(resolve)
		while true do

			-- if the day changed while the player was playing, reset all the values
			if os.date("%j/%y", self.lastDayPlayed) ~= os.date("%j/%y") then
				self.lastDayPlayed = os.time()
				self.timePlayedToday = 0
				self.nextRewards = defaultRewards

				DataStore2("playTimeRewards", self.plr):Set(self:GetDataToSave())
			end

			task.wait(15)
			self.timePlayedToday += 15
			
			DataStore2("playTimeRewards", self.plr):Set(self:GetDataToSave())
			
			-- if the table is empty, stop the promise
			if #self.nextRewards < 1 then
				resolve()
			end
			
			-- if the player has played long enough to get a reward (still check if the table is not empty, even if the promise is resolved before, because sometimes it takes time and code still has time to execute)
			if #self.nextRewards > 0 and self.timePlayedToday >= self.nextRewards[1] then
				-- mark the reward to collect, so that when the client wants to get the reward, we can give it to them
				self.rewardToCollect = self.nextRewards[1]

				-- remove the reward from the table so that the player doesn't collect it again
				table.remove(self.nextRewards, 1)
				
				-- if the player got all the reward, set the next reward to math.huge so that the player can't reach it
				self.plr.NextReward.Value = #self.nextRewards >= 1 and self.nextRewards[1] or math.huge

				resolve()
			end
		end
	end)
end


--[[
	Returns the reward the player should get

	@param p : PlayerModule, the object representing the player
	@return the reward
]]--
function PlayTimeRewards:CollectReward(p : Types.PlayerModule)
	if self.rewardToCollect ~= 0 then
		-- get the reward based on the time the player has played
		local reward : Rewards.Reward = Rewards.GetReward(self.rewardToCollect)

		-- apply the reward
		if reward.reward == "followers" then
			p:UpdateFollowersAmount(reward.value)

		elseif reward.reward == "coins" then
			p:UpdateCoinsAmount(reward.value)

		elseif reward.reward == "pet" then
			local pet : {} = p.petModule:GetPetFromPetId(18)
			if not pet then
				return nil
			end

			-- set the unique id for the pet
			pet.id = p.petModule.nextId
			p.petModule.nextId += 1

			p.petModule:AddPetToInventory(pet)

			-- add the pet to the inventory
			PetsRE:FireClient(p.player, {pet}, false)

		elseif reward.reward == "potion" then
			-- if the potion is a followers and coins potion, we split into two potions
			if reward.value.type == p.potionModule.potionTypes.FollowersCoins then
				p.potionModule:CreateAndUsePotion(p.potionModule.potionTypes.Followers, reward.value.value, reward.value.duration, p)
				p.potionModule:CreateAndUsePotion(p.potionModule.potionTypes.Coins, reward.value.value, reward.value.duration, p)
			else
				p.potionModule:CreateAndUsePotion(reward.value.type, reward.value.value, reward.value.duration, p)
			end
		end

		self.rewardToCollect = 0

		-- restart the timer
		self:StartTimer()

		return reward
	end
end


function PlayTimeRewards:OnLeave()
	-- stop the promise
	self.promise:cancel()

	setmetatable(self, nil)
	self = nil
end


return PlayTimeRewards