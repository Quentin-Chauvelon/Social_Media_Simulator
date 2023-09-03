local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(script.Parent:WaitForChild("Utility"))

local FollowersRE : RemoteEvent = ReplicatedStorage:WaitForChild("Followers")
local coinsRE : RemoteEvent = ReplicatedStorage:WaitForChild("Coins")

local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local menu : ScreenGui = playerGui:WaitForChild("Menu")

local followersContainer : Frame = menu:WaitForChild("TabsContainer"):WaitForChild("FollowersContainer")
local followersText : TextLabel = followersContainer:WaitForChild("FollowersText")

local coinsContainer : Frame = menu.TabsContainer:WaitForChild("CoinsContainer")
local coinsText : TextLabel = coinsContainer:WaitForChild("CoinsText")


export type GuiTabsModule = {
    new : (utility : Utility.Utility) -> GuiTabsModule,
	UpdateFollowers : (followers : number) -> nil,
	UpdateCoins : (coins : number) -> nil
}


local GuiTabsModule : GuiTabsModule = {}
GuiTabsModule.__index = GuiTabsModule


function GuiTabsModule.new(utility : Utility.Utility)
    -- utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
    --     followersContainer.Size = UDim2.new(Utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 0.2, 0.2), 0, 0.09, 0)
    --     coinsContainer.Size = UDim2.new(Utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 0.2, 0.2), 0, 0.09, 0)
    -- end)
end


--[[
	Display the number of followers the player has on the gui on the right of the screen 
	
	@param followers : number, the number of followers the player has
]]--
function GuiTabsModule.UpdateFollowers(followers : number)
	followersText.Text = Utility.AbbreviateNumber(followers)
end


--[[
	Display the number of coins the player has on the gui on the right of the screen 
	
	@param coins : number, the number of coins the player has
]]--
function GuiTabsModule.UpdateCoins(coins : number)
	coinsText.Text = Utility.AbbreviateNumber(coins)
end

return GuiTabsModule