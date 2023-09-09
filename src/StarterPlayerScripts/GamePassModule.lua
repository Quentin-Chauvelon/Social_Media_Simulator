local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local lplr : Player = Players.LocalPlayer


export type GamePassModule = {
    gamePasses : GamePasses,
    ownedGamePasses : {[GamePasses] : ownedGamePass},
    LoadGamePasses : () -> nil,
    UserOwnsGamePass : (gamePassId : number) -> (boolean, boolean),
    PlayerOwnsGamePass : (gamePassId : number) -> boolean,
    PromptGamePassPurchase : (gamePassId : number) -> nil,
    PlayerBoughtGamePass : (gamePassId : number) -> nil
}

type GamePasses = {
    SpaceCase : number,
    OpenThreeEggs : number,
    OpenSixEggs : number,
}

type ownedGamePass = {
    loaded : boolean,
    owned : boolean
}


local GamePassModule : GamePassModule = {}
GamePassModule.__index = GamePassModule


-- Game passes enum
GamePassModule.gamePasses = {
    SpaceCase = 249101309,
    OpenThreeEggs = 252411712,
    OpenSixEggs = 252412855
}

-- list of all the game passes
-- the first value is a boolean representing if the server could be contacted to load the ownership
-- the second value is a boolean representing if the player actually owns the game pass
GamePassModule.ownedGamePasses = {
    [GamePassModule.gamePasses.SpaceCase] = {loaded = false, owned = false},
    [GamePassModule.gamePasses.OpenThreeEggs] = {loaded = false, owned = false},
    [GamePassModule.gamePasses.OpenSixEggs] = {loaded = false, owned = false}
}


--[[
    Contacts the server to know if the player owns the game pass matching the given id

    @param gamePassId : number, the id of the game pass to check ownership from the player
    @return (boolean, boolean),
        The first value will be false if the call to the server errored and true otherwise.
        The second value will be true if the player owns the game pass and false otherwise
]]--
function GamePassModule.UserOwnsGamePass(gamePassId : number) : (boolean, boolean)
    local ownsPass : boolean = false

    local success,_ = pcall(function()
        ownsPass = MarketplaceService:UserOwnsGamePassAsync(lplr.UserId, gamePassId)
    end)

    return success, (success and ownsPass or false)
end


--[[
    Loads all the game passes to know which one the player owns
]]--
function GamePassModule.LoadGamePasses()
    for _, gamePassId : number in pairs(GamePassModule.gamePasses) do
        local loaded : boolean, owned : boolean = GamePassModule.UserOwnsGamePass(gamePassId)
        
        GamePassModule.ownedGamePasses[gamePassId].loaded = loaded
        GamePassModule.ownedGamePasses[gamePassId].owned = owned
    end
end


--[[
    Check if the player owns the game pass matching the given id

    @param gamePassId : number, the id of the game pass to check ownership from the player
    @return boolean, true if the player owns the game pass, false otherwise
]]--
function GamePassModule.PlayerOwnsGamePass(gamePassId : number) : boolean
    if GamePassModule.ownedGamePasses[gamePassId].loaded == true then
        return GamePassModule.ownedGamePasses[gamePassId].owned
    else
        local _, ownsGamePass : boolean = GamePassModule.UserOwnsGamePass(gamePassId)
        return ownsGamePass
    end
end


--[[
    Prompts the purchase of the game pass matching the given id

    @param gamePassId : number, the id of the game pass the player wants to purchase
]]--
function GamePassModule.PromptGamePassPurchase(gamePassId : number)
    MarketplaceService:PromptGamePassPurchase(lplr, gamePassId)
end


function GamePassModule.PlayerBoughtGamePass(gamePassId : number)
    print("here")
    GamePassModule.ownedGamePasses[gamePassId].loaded = true
    GamePassModule.ownedGamePasses[gamePassId].owned = true
    print(GamePassModule.ownedGamePasses)
end


return GamePassModule