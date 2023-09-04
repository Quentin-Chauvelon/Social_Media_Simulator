local ServerScriptService = game:WaitForChild("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoughtGamePassRE : RemoteEvent = ReplicatedStorage:WaitForChild("BoughtGamePass")

local Types = ServerScriptService:WaitForChild("Types")

export type GamepassModule = {
    gamePasses : GamePasses,
    boughtCoinsMultiplier : boolean,
    boughtFollowersMultiplier : boolean,
    new : () -> GamepassModule,
    PlayerBoughtGamePass : (self : GamepassModule, gamePassId : number, p : Types.PlayerModule) -> nil,
    LoadOwnedGamePasses : (self : GamepassModule) -> nil,
    GetCoinsMultiplier : (self : GamepassModule) -> number,
    GetFollowersMultiplier : (self : GamepassModule) -> number,
    OnLeave : (self : GamepassModule) -> nil
}

type GamePasses = {
    SpaceCase : number
}


local GamepassModule : GamepassModule = {}
GamepassModule.__index = GamepassModule


function GamepassModule.new()
    local gamepassModule : GamepassModule = {}

    gamepassModule.gamePasses = {
        SpaceCase = 249101309
    }

    gamepassModule.boughtCoinsMultiplier = false
    gamepassModule.boughtFollowersMultiplier = false

    -- TODO : check if the player owns the game pass to set the variables above

    return setmetatable(gamepassModule, GamepassModule)
end


--[[
    Applies the effect of the game pass the player bought

    @param gamePassId : number, the id of the game pass the player bought
    @param p : PlayerModule, the player object representing the player
]]--
function GamepassModule:PlayerBoughtGamePass(gamePassId : number, p : Types.PlayerModule)
    local isGamePassPurchaseSuccesfull : boolean = false
    
    if gamePassId == self.gamePasses.SpaceCase then
        p.caseModule:BuyCase("Space", p)
        isGamePassPurchaseSuccesfull = true
    end

    -- if the purchase of the game pass was succesful, fire the client to make changes locally if needed
    if isGamePassPurchaseSuccesfull then
        BoughtGamePassRE:FireClient(p.player, gamePassId)
    end
end


--[[
    Loads the effects of the game passes the player owns on join

    @param p : PlayerModule, the player object representing the player
]]--
function GamepassModule:LoadOwnedGamePasses(p : Types.PlayerModule)
    for _,gamePassId : number in pairs(self.gamePasses) do

        if gamePassId == self.gamePasses.SpaceCase then
            -- if the case is not equipped, do not call the BoughtGamePass function otherwise it is going to equip it (so only fire the event to update the ui)
            if p.caseModule.equippedCase == "Space" then
                self:PlayerBoughtGamePass(gamePassId, p)
            end

        -- for all other game passes, simply call the BoughtGamePass function
        else
            self:PlayerBoughtGamePass(gamePassId, p)
        end
    end
end


function GamepassModule:GetCoinsMultiplier()
    return self.boughtCoinsMultiplier and 2 or 0
end


function GamepassModule:GetFollowersMultiplier()
    return self.boughtFollowersMultiplier and 2 or 0
end


function GamepassModule:OnLeave()
	setmetatable(self, nil)
	self = nil
end


return GamepassModule