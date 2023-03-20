local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local ServerModule = require(ServerScriptService:WaitForChild("ServerModule"))


Players.PlayerAdded:Connect(function(plr : Player)
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


	TEST
]]--