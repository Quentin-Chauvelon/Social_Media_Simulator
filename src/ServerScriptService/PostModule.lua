local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PostRE : RemoteEvent = ReplicatedStorage:WaitForChild("Post")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local Types = require(ServerScriptService:WaitForChild("Types"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))

DataStore2.Combine("SMS", "level", "postStats")


local defaultPostStats = {
	autoPostInterval = 3 * 1_000, -- this value is also defined in ServerScriptService/UpgradeModule.lua:25 (in upgrade.baseValue)
	clickPostInterval = 0.22 * 1_000
}


local react = {
	"http://www.roblox.com/asset/?id=14903935253",
	"http://www.roblox.com/asset/?id=14904048436",
	"http://www.roblox.com/asset/?id=14904049332",
	"http://www.roblox.com/asset/?id=14904050234",
	"http://www.roblox.com/asset/?id=14904051238",
	"http://www.roblox.com/asset/?id=14904052428",
	"http://www.roblox.com/asset/?id=14904053317",
	"http://www.roblox.com/asset/?id=14904054232",
	"http://www.roblox.com/asset/?id=14904055361",
	"http://www.roblox.com/asset/?id=14904056263",
	"http://www.roblox.com/asset/?id=14904057761",
	"http://www.roblox.com/asset/?id=14904058658",
	"http://www.roblox.com/asset/?id=14904059485"
}
local numberOfReact : number = #react


local followersGained : {number} = { -- average = 2.248
	4000, -- 1
	2500, -- 2
	1500, -- 3
	1000, -- 4
	500, -- 5
	200, -- 6
	100, -- 7
	50, -- 8
	20, -- 9
	1 -- 10
}


-- calculate the overall weight of the table
local followersGainedWeight : number = 0
for _, chance : number in pairs(followersGained) do
	followersGainedWeight += chance
end


--[[
	Return a random player different from the given player
	
	@param plr : Player, the player whose the random player must be different from
]]--
local function GetRandomPlayer(plr : Player)
	local playersList = Players:GetPlayers()
	local numberOfPlayers : number = #playersList

	if numberOfPlayers == 1 then
		return plr
	end

	local randomPlayer : Player
	repeat
		randomPlayer = playersList[math.random(1, numberOfPlayers)]
	until randomPlayer ~= plr

	return randomPlayer
end


--[[
	Gets a random amount of followers based on the weighted table of chance (followersGained).
	40% chance of getting 1 follower while only 0.1% chance of getting 10 followers
	
	@return number, the random amount of followers
]]--
local function GetRandomFollowerAmount() : number
	local weight : number = 0
	local randomNumber = math.random(1, followersGainedWeight)

	for amount : number, chance : number in pairs(followersGained) do
		weight += chance

		if weight >= randomNumber then
			return amount
		end
	end
end


export type PostModule = {
    nextAutoPost : number,
	nextClickPost : number,
	autoPostInterval : number,
	clickPostInterval : number,
	dialog : {},
	currentState : string,
	level : number,
	postedLastTime : boolean,
	postStates : {},
	posts : {(number) -> string},
	dialogs : {(number) -> (string, {string})},
	replies : {(number) -> (string, {string})},
	numberOfPosts : number,
	numberOfDialogs : number,
	numberOfReplies : number,
	autoClickerPromise : Promise.Promise,
	postXTimesQuest : () -> nil | nil,
	new : (plr : Player) -> PostModule,
	GenerateDialog : (self : PostModule, p : Types.PlayerModule, tableToUse : string) -> nil,
    Post : (self : PostModule, p : Types.PlayerModule) -> nil,
    PlayerClicked : (self : PostModule, p : Types.PlayerModule) -> nil,
    GenerateStateMachine : (self : PostModule) -> nil,
	StartAutoClicker : (self : PostModule, p : Types.PlayerModule) -> nil,
    OnLeave : (self : PostModule) -> nil
}


local PostModule : PostModule = {}
PostModule.__index = PostModule


function PostModule.new(plr : Player)
	local postModule : PostModule = {}

	local postStats = DataStore2("postStats", plr):Get(defaultPostStats)
	
	-- DataStore2("level", plr):Set(nil)
	
	postModule.nextAutoPost = 0
	postModule.nextClickPost = 0
	postModule.autoPostInterval = defaultPostStats.autoPostInterval
	postModule.clickPostInterval = postStats.clickPostInterval

	postModule.dialog = {}
	postModule.currentState = "post"
	postModule.level = DataStore2("level", plr):Get(1)
	postModule.postedLastTime = true -- indicates if the player posted (post, dialog, reply...) or not (like, react) the very last time something was done
	postModule.postStates = {}

	postModule.posts = {
		function () return "Hi!" end,
		function () return "Hello world!" end,
		function () return "Mom! I'm famous!" end,
		function () return "Roses are red,\nViolets are blue,\nSugar is sweet,\nAnd so are you." end,
		function () return "Let's go play Adopt me" end,
		function () return "I love Roblox" end,
		function () return "I love Social Media Simulator!" end,
		function () return "Social Media Simulator is the best game ever!" end,
		function () return "Have a nice day." end,
		function () return "If at first you don't succeed, try again." end,
		function () return "Never forget that someone cares for you." end,
		function () return "Bonjour" end,
		function () return "Hola" end,
		function () return "Tip: You can create your own posts" end,
		function () return "Tip: Tap the screen to post faster" end,
		function () return "Do you all like pizzas?" end,
		function () return "My favourite food is pasta." end,
		function () return "You have a 5% chance of seeing this" end,
		function (p : number) return string.format("I have %s followers.", p.followers) end,
		function (p : number) return string.format("I have %s coins.", p.coins) end,
		function (p : number) return string.format("I'm rebirth %s.", p.rebirthModule.rebirthLevel) end
	}
	
	
	postModule.dialogs = {
		function () return "How are you?", {"Fine", "Good", "Not bad", "I'm doing well", "I've been better", "Great"} end,
		function () return "Have a nice day.", {"Thanks", "You too.", "Thanks, you too!"} end,
		function (playerName : number) return string.format("@%s do you want to be friends?", playerName), {"Yes", "No", "Sure", "Why not"} end,
		function () return "Let's go play Adopt me", {"Alright", "No", "Ok, let's go", "In 2 minutes", "Let me just finish something before"} end,
		function () return "I love Roblox", {"Same", "Me too!", "♥", "I ♥ it too", "I love it too"} end,
		function () return "What is your favourite food?", {"Pasta", "Pizza", "Ice cream", "I love pasta", "I love pizza", "I love ice cream", "Mine is pasta", "Mine is pizza", "Mine is ice cream"} end,
		function () return "What is your favourite sport?", {"Basketball", "Football", "Soccer", "Golf", "Baseball"} end
	}
	
	
	postModule.replies = {
		function () return "Mom! I'm famous!", {"No"} end,
		function () return "Social Media Simulator is the best game!", {"Agreed", "For sure", "Yes", "No"} end,
		function (p : number) return string.format("I have %s followers", p.followers), {"Wow", "Impressive", "Great", string.format("I have %s", p.followers), "That's it?", "ez"} end,
		function (p : number) return string.format("I have %s coins", p.coins), {"Wow", "Impressive", "Great", string.format("I have %s", p.coins), "That's it?", "ez"} end,
		function (p : number) return string.format("I'm rebirth %s", p.rebirthModule.rebirthLevel), {"Wow", "Impressive", "Great", string.format("I am rebirth %s", p.rebirthModule.rebirthLevel), "That's it?", "ez"} end
	}

	postModule.numberOfPosts = #postModule.posts
	postModule.numberOfDialogs = #postModule.dialogs
	postModule.numberOfReplies = #postModule.replies

	postModule.autoClickerPromise = nil

	postModule.postXTimesQuest = nil

	return setmetatable(postModule, PostModule)
end


--[[
	Generates a random dialog or reply using the given table for the given player module
	
	@param p, the player module
	@param tableToUse : string, a string indicated the table to use to generate the dialog
]]--
function PostModule:GenerateDialog(p : Types.PlayerModule, tableToUse : string)
	
	local startPhrase : string, possibleAnswers : {string}
	if tableToUse == "dialog" then
		startPhrase, possibleAnswers = self.dialogs[math.random(1, self.numberOfDialogs)](GetRandomPlayer(p.player).Name)
	else
		startPhrase, possibleAnswers = self.replies[math.random(1, self.numberOfReplies)](p)
	end
	
	-- random boolean to know if a random player starts the dialog or answers
	local randomPlayerStarting : boolean = math.random() > 0.5 and true or false

	self.dialog = {{possibleAnswers[math.random(1, #possibleAnswers)], randomPlayerStarting}, {startPhrase, not randomPlayerStarting}}
end


--[[
	Goes to a random possible state from the last one, take a random sentence from that state and
	fires to the client to update the phone UI
]]--
function PostModule:Post(p : Types.PlayerModule)
	local plr : Player = p.player
	local nextState : string = self.currentState

	p:UpdateFollowersAmount(GetRandomFollowerAmount())

	p.plotModule.popSound:Play()

	-- update the quest's progress when the player posts
	if self.postXTimesQuest then
		self.postXTimesQuest()
	end

	local randomNumber : number = math.random()
	
	-- if the player has a rebirth level less than 100, then we calculate the odds of getting 1 coin
	if p.rebirthModule.rebirthLevel < 100 then
		if randomNumber <= 0.05 + (p.rebirthModule.rebirthLevel / 100) then
			p:UpdateCoinsAmount(1)
		end

	-- if the player has a rebirth level greater than 100, then we calculate the odds of getting 1 or more coin
	else
		local coinsToAdd : number = 0
		for i=p.rebirthModule.rebirthLevel, 0, -100 do
			if i > 100 then
				coinsToAdd += 1
			else
				if randomNumber <= (i % 100) / 100 then
					coinsToAdd += 1
				end
			end
		end

		if coinsToAdd >= 1 then
			p:UpdateCoinsAmount(coinsToAdd)
		end
	end


	-- 1/3 chance of liking or reacting (not using a state for these, because we can't change state if we are in the middle
	-- of a dialog or reply which means that we could never like or react to the first post of a dialog or reply)
	if self.postedLastTime then
		if self.level >= 4 then

			if randomNumber > 0.5 then

				-- instead of picking a random number again for a 50/50 chance of liking or reacting, we reuse the randum number
				-- used before (and since it can't be less than 0.5 50/50 is 0.75)
				if self.level >= 5 and randomNumber > 0.75 then
					PostRE:FireAllClients("react", p.plotModule.screen, plr, react[math.random(1, numberOfReact)])
				else
					PostRE:FireAllClients("like", p.plotModule.screen, plr)
				end

				self.postedLastTime = false

				return
			end
		end
	else
		self.postedLastTime = true
	end	

	-- if the dialog table is not empty, it means that there is a dialog or reply going on, so we don't want to change the state
	if #self.dialog == 0 then
		nextState = self.postStates[self.currentState][math.random(1, #self.postStates[self.currentState])]
	end

	self.currentState = nextState

	if nextState == "post" then
		local post : string = self.posts[math.random(1, self.numberOfPosts)](p)

		PostRE:FireAllClients("post", p.plotModule.screen, plr, post)

	elseif nextState == "reply" then
		if #self.dialog == 0 then
			self:GenerateDialog(p, "reply")
		end

		local dialogMessage, randomPlayerStarting = unpack(self.dialog[#self.dialog])

		if randomPlayerStarting then
			PostRE:FireAllClients("reply", p.plotModule.screen, GetRandomPlayer(p.player), dialogMessage, #self.dialog > 1)
		else
			PostRE:FireAllClients("reply", p.plotModule.screen, p.player, dialogMessage, #self.dialog > 1)
		end

		table.remove(self.dialog, #self.dialog)

	elseif nextState == "dialog" then
		if #self.dialog == 0 then
			self:GenerateDialog(p, "dialog")
		end

		local dialogMessage, randomPlayerStarting = unpack(self.dialog[#self.dialog])

		if randomPlayerStarting then
			PostRE:FireAllClients("dialog", p.plotModule.screen, GetRandomPlayer(p.player), dialogMessage, #self.dialog > 1)
		else
			PostRE:FireAllClients("dialog", p.plotModule.screen, p.player, dialogMessage, #self.dialog > 1)
		end

		table.remove(self.dialog, #self.dialog)
	end
end


--[[
	When a player clicks or touches the screen, check if the cooldown is over to post
	
	@param p, the player Module
]]--
function PostModule:PlayerClicked(p : Types.PlayerModule)
	local now : number = math.round(tick() * 1_000)

	-- if it has been enough time (clickPostInterval) and the autoPostInterval is not about to post (do not fire if now = nextAutoPost +- clickPostInterval, otherwise it fires too fast and the phone ui glitches)
	if self and now >= self.nextClickPost and now < (self.nextAutoPost - self.clickPostInterval) and now > (self.nextAutoPost - self.autoPostInterval + self.clickPostInterval) then
		self.nextClickPost = now + self.clickPostInterval

		self:Post(p)
	end
end


--[[
	Generates the state machine (states + transitions) the player can use based on the level he is at
]]--
function PostModule:GenerateStateMachine()
	local level : number = self.level

	if level == 1 then
		self.postStates = {
			post = {"post"}
		}

	elseif level == 2 then
		self.postStates = {
			post = {"post", "reply"},
			reply = {"post"}
			--replyStarted = {"replyEnded"},
			--replyEnded = {"post", "replyStarted"}
		}

	elseif level >= 3 then
		self.postStates = {
			post = {"post", "reply", "dialog"},
			reply = {"post"},
			dialog = {"post"}
			--post = {"post", "replyStarted", "dialogStarted"},
			--replyStarted = {"replyEnded"},
			--replyEnded = {"post"},
			--dialogStarted = {"dialogEnded"},
			--dialogEnded = {"post"}
		}

		--elseif level == 4 then
		--	self.postStates = {
		--		post = {"post", "reply", "dialog"},
		--		reply = {"post"},
		--		dialog = {"post"}
		--		--post = {"post", "replyStarted", "dialogStarted", "like"},
		--		--replyStarted = {"replyEnded"},
		--		--replyEnded = {"post", "like"},
		--		--dialogStarted = {"dialogEnded"},
		--		--dialogEnded = {"post", "like"},
		--		--like = {"post", "replyStarted", "dialogStarted"}
		--	}

		--elseif level == 5 then
		--	self.postStates = {
		--		post = {"post", "reply", "dialog"},
		--		reply = {"post"},
		--		dialog = {"post"}
		--		--post = {"post", "replyStarted", "dialogStarted", "like", "react"},
		--		--replyStarted = {"replyEnded"},
		--		--replyEnded = {"post", "like", "react"},
		--		--dialogStarted = {"dialogEnded"},
		--		--dialogEnded = {"post", "like", "react"},
		--		--like = {"post", "replyStarted", "dialogStarted"},
		--		--react = {"post", "replyStarted", "dialogStarted"}
		--	}

		--elseif level == 6 then
		--	self.postStates = {
		--		post = {"post", "replyStarted", "dialogStarted", "like", "react", "photo"},
		--		replyStarted = {"replyEnded"},
		--		replyEnded = {"post", "like", "react", "photo"},
		--		dialogStarted = {"dialogEnded"},
		--		dialogEnded = {"post", "like", "react", "photo"},
		--		like = {"post", "replyStarted", "dialogStarted", "photo"},
		--		react = {"post", "replyStarted", "dialogStarted", "photo"},
		--		photo = {"post", "replyStarted", "dialogStarted", "like", "react", "photo"}
		--	}

		--elseif level == 7 then
		--	self.postStates = {
		--		post = {"post", "dialogStarted", "like", "react", "photo", "video"},
		--		replyStarted = {"replyEnded"},
		--		replyEnded = {"post", "like", "react", "photo", "video"},
		--		dialogStarted = {"dialogEnded"},
		--		dialogEnded = {"post", "like", "react", "photo", "video"},
		--		like = {"post", "replyStarted", "dialogStarted", "photo", "video"},
		--		react = {"post", "replyStarted", "dialogStarted", "photo", "video"},
		--		photo = {"post", "replyStarted", "dialogStarted", "like", "react", "photo", "video"},
		--		video = {"post", "replyStarted", "dialogStarted", "like", "react", "photo", "video"}
		--	}
	end
end


--[[
	Starts the auto clicker promise if the player owns the auto clicker gamepass
]]--
function PostModule:StartAutoClicker(p : Types.PlayerModule)
	self.autoClickerPromise = Promise.new(function()
		while true do
			self:PlayerClicked(p)
			RunService.Heartbeat:Wait()
		end
	end)
end


function PostModule:OnLeave()
	if self.autoClickerPromise then
		self.autoClickerPromise:cancel()
	end

	setmetatable(self, nil)
	self = nil
end


return PostModule
