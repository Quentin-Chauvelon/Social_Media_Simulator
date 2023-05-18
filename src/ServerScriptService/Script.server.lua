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

	IMPORTANT


	IMPROVEMENTS
	TODO players can buy colors for their phones (back)
	TODO light/dark mode
	TODO upgradepost responsive
	TODO playTimeRewards responsive
	TODO for all resize on screen size changed, make sure that the ui never has a size of 0, ohterwise it won't work
	TODO use callback instead of promise for tweens
	TODO filterasync all text
	TODO for the resize function, do i need the : if < 480 and if > 1920
	TODO list all images to make
	TODO create all the types (for complex things as well (i.e : Player)) (export type from each module script or require a type module script) (post module incomplete, add some methods) (do it for the loops (i.e : post : {id, posttype, ...})) (only export types that are used in multiple scripts, otherwise declare them in the same script)
	TODO add nostrict ? and then strict ? (what if an exploiter fires a remote event with the wrong argument type)
	TODO thumbnail doesn't seem to be working anymore on the phone when posting + hide guildname if there is none

	TODO: use module for the code inside the local script (post module mainly)
	TODO rework the follower gui (color (outline gradient) and size for mobile) responsivness
	TODO utility module to bind ui to the events (MouseEnterScaleUp and MouseEnterScaleDown)
	TODO make a utility function to tween all the ui on click (for those where it's a simple tween (bigger/smaller)), will help improve readability especially because the promise takes to hide the element takes at least 5 lines


	TEST
]]--