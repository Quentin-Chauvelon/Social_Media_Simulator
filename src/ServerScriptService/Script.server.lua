local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerModule = require(ServerScriptService:WaitForChild("ServerModule"))
local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))


local testing : boolean = false

if testing then
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local DeleteDataTestRF : RemoteFunction = Instance.new("RemoteFunction")
	DeleteDataTestRF.Name = "DeleteDataTest"
	DeleteDataTestRF.Parent = ReplicatedStorage
	
	DeleteDataTestRF.OnServerInvoke = function(plr : Player, dataStore : string)
		DataStore2(dataStore, plr):Set(nil)
		return true
	end
end


Players.PlayerAdded:Connect(function(plr : Player)
	if testing then
		if #Players:GetPlayers() == 1 and plr.UserId == 551795307 then
			DataStore2("customPosts", plr):Set(nil)
		end
	end

	ServerModule.onJoin(plr)
end)


Players.PlayerRemoving:Connect(function(plr : Player)
	ServerModule.onLeave(plr.Name)
end)



--[[
	BUGS
	information notification is ugly (text too small + too long ? responsive?)

	IMPORTANT

	IMPROVEMENTS
	TODO players can buy colors for their phones (back)
	TODO light/dark mode
	TODO list all images to make
	TODO hide guildname if there is none
	TODO utility module to bind ui to the events (MouseEnterScaleUp and MouseEnterScaleDown)
	TODO make a utility function to tween all the ui on click (for those where it's a simple tween (bigger/smaller)), will help improve readability especially because the promise takes at least 5 lines
	TODO make the rewards play time work (rewards not attributed so far)
	TODO playTimeRewards responsive
	TODO playTimeRewards random rewards or always the same (advantages of always having the same rewards: players know what the play for and if they really want something in particular, they are going to play longer to get it)
	
	change the followers gui text color (the gradient is too weird?)
	change the followers gui z-index so that it's behind the other uis (custom post for example)
	reduce the size of the followers gui a little bit ?
	play time rewards animation sometimes stopping for no reason (reset orientation to 0 after collecting the reward so that it doesn't stay stuck)
]]--