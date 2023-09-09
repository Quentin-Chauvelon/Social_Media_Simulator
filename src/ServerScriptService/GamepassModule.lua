local ServerScriptService = game:WaitForChild("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoughtGamePassRE : RemoteEvent = ReplicatedStorage:WaitForChild("BoughtGamePass")

local Types = ServerScriptService:WaitForChild("Types")

export type GamepassModule = {
    gamePasses : GamePasses,
    boughtCoinsMultiplier : boolean,
    boughtFollowersMultiplier : boolean,
    boughtOpen3Eggs : boolean,
    boughtOpen6Eggs : boolean,
    new : () -> GamepassModule,
    PlayerBoughtGamePass : (self : GamepassModule, gamePassId : number, p : Types.PlayerModule) -> nil,
    LoadOwnedGamePasses : (self : GamepassModule) -> nil,
    GetCoinsMultiplier : (self : GamepassModule) -> number,
    GetFollowersMultiplier : (self : GamepassModule) -> number,
    OnLeave : (self : GamepassModule) -> nil
}

type GamePasses = {
    SpaceCase : number,
    Open3Eggs : number,
    Open6Eggs : number
}


local GamepassModule : GamepassModule = {}
GamepassModule.__index = GamepassModule


function GamepassModule.new()
    local gamepassModule : GamepassModule = {}

    gamepassModule.gamePasses = {
        SpaceCase = 249101309,
        Open3Eggs = 252411712,
        Open6Eggs = 252412855
    }

    gamepassModule.boughtCoinsMultiplier = false
    gamepassModule.boughtFollowersMultiplier = false
    gamepassModule.boughtOpen3Eggs = true
    gamepassModule.boughtOpen6Eggs = true

    -- TODO : check if the player owns the game pass to set the variables above

    return setmetatable(gamepassModule, GamepassModule)
end


--[[
    Applies the effect of the game pass the player bought

    @param gamePassId : number, the id of the game pass the player bought
    @param p : PlayerModule, the player object representing the player
]]--
function GamepassModule:PlayerBoughtGamePass(gamePassId : number, p : Types.PlayerModule)
    local isGamePassPurchaseSuccesfull : boolean = true
    
    if gamePassId == self.gamePasses.SpaceCase then
        p.caseModule:BuyCase("Space", p)
    
    elseif gamePassId == self.gamePasses.Open3Eggs then
        self.boughtOpen3Eggs = true
    
    elseif gamePassId == self.gamePasses.Open6Eggs then
        self.boughtOpen6Eggs = true
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

        -- if the player owns the game pass
        if MarketplaceService:UserOwnsGamePassAsync(p.player.UserId, gamePassId) then
            
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