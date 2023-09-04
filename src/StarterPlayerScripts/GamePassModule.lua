local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local lplr : Player = Players.LocalPlayer


export type GamePassModule = {
    PlayerOwnsGamePass : (gamePassId : number) -> boolean,
    PromptGamePassPurchase : (gamePassId : number) -> nil
}


type GamePasses = {
    SpaceCase : number
}


local GamePassModule : GamePassModule = {}
GamePassModule.__index = GamePassModule


-- enumeration that allows to use the name of the gamepass instead of the id when calling the functions (easier and more readable)
local gamePasses : GamePasses = {
    SpaceCase = 249101309
}
GamePassModule.gamePasses = gamePasses


--[[
    Check if the player owns the game pass matching the given id

    @param gamePassId : number, the id of the game pass to check ownership from the player
    @return boolean, true if the player owns the game pass, false otherwise
]]--
function GamePassModule.PlayerOwnsGamePass(gamePassId : number) : boolean
    local ownsPass : boolean = false

    local success,_ = pcall(function()
		ownsPass = MarketplaceService:UserOwnsGamePassAsync(lplr.UserId, gamePassId)
	end)

	if not success then
		return true
	end

    return ownsPass
end


--[[
    Prompts the purchase of the game pass matching the given id

    @param gamePassId : number, the id of the game pass the player wants to purchase
]]--
function GamePassModule.PromptGamePassPurchase(gamePassId : number)
    MarketplaceService:PromptGamePassPurchase(lplr, gamePassId)
end


return GamePassModule