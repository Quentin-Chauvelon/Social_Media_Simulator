local PlayTimeRewards = {}
PlayTimeRewards.__index = PlayTimeRewards


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))


--[[
	when a player join call PlayTimeRewards:onJoin() and save p in a table
	when a player leaves call PlayTimeRewards:onLeave() and remove p from the table
	
	start a coroutine, and every 5 seconds? change p.playedTime (loop through all players every 30 seconds? and fire all clients to sync)
	save and everything
	and on the client sync the clock when event fired from the server
	
	each player has it's own coroutine within the playtimerewards instance (promise) in the p object
	every 15 seconds or so, fire the client to sync the timer, and if it's time for a reward, fire the client to tell them
	
	2 mins, then 5, then 10, then 15, then 25, then 40, then 1h, then 1h30, then 2h, then 3h, then 4h and finally 5h
]]--


function PlayTimeRewards.new()
	local playTimeRewards = {}
	
	playTimeRewards.lastDayPlayed = 0
	playTimeRewards.timePlayedToday = 0
	PlayTimeRewards.promise = Promise.new(function()
		while true do
			task.wait(15)
		end
	end)
	
	return setmetatable(playTimeRewards, PlayTimeRewards)
end


return PlayTimeRewards
