local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UpdateFriendsBoostRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpdateFriendsBoost")


export type FriendsModule = {
    numberOfFriendsOnline : number,
    followersMultiplier : number,
    coinsMultiplier : number,
    plr : Player,
    new : (plr : Player) -> FriendsModule,
    FriendJoined : (self : FriendsModule) -> nil,
    FriendLeft : (self : FriendsModule) -> nil,
    GetOnlineFriends : (self : FriendsModule) -> {string},
    OnLeave : (self : FriendsModule) -> nil
}


local function iterPageItems(pages)
	return coroutine.wrap(function()
		local pagenum = 1
		while true do
			for _, item in ipairs(pages:GetCurrentPage()) do
				coroutine.yield(item, pagenum)
			end
			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
			pagenum = pagenum + 1
		end
	end)
end


local FriendsModule : FriendsModule = {}
FriendsModule.__index = FriendsModule


function FriendsModule.new(plr : Player)
    local friendsModule : FriendsModule = {}

    friendsModule.numberOfFriendsOnline = 0

    friendsModule.followersMultiplier = 0
    friendsModule.coinsMultiplier = 0

    friendsModule.plr = plr

    return setmetatable(friendsModule, FriendsModule)
end


--[[
    Fires when a friend joins the game
]]--
function FriendsModule:FriendJoined()
    self.numberOfFriendsOnline += 1

    self.followersMultiplier = 0.2 * self.numberOfFriendsOnline
    self.coinsMultiplier = self.followersMultiplier

    UpdateFriendsBoostRE:FireClient(self.plr, self.numberOfFriendsOnline)
end


--[[
    Fires when a friend leaves the game
]]--
function FriendsModule:FriendLeft()
    self.numberOfFriendsOnline -= 1

    self.followersMultiplier = 0.2 * self.numberOfFriendsOnline
    self.coinsMultiplier = self.followersMultiplier

    UpdateFriendsBoostRE:FireClient(self.plr, self.numberOfFriendsOnline)
end


--[[
    Returns all the player's online friends

    @return {string}, a table of the name of the friends that are online
]]--
function FriendsModule:GetOnlineFriends() : {string}
    local friendsPages : FriendPages = Players:GetFriendsAsync(self.plr.UserId)

    local usernames = {}
    for item,_ in iterPageItems(friendsPages) do
        table.insert(usernames, item.Username)
    end

    return usernames
end


function FriendsModule:OnLeave()
    setmetatable(self, nil)
	self = nil
end


return FriendsModule