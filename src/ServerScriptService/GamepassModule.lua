export type GamepassModule = {
    boughtCoinsMultiplier : boolean,
    boughtFollowersMultiplier : boolean,
    new : () -> GamepassModule,
    GetCoinsMultiplier : () -> number,
    GetFollowersMultiplier : () -> number,
}


local GamepassModule : GamepassModule = {}
GamepassModule.__index = GamepassModule


function GamepassModule.new()
    local gamepassModule : GamepassModule = {}

    gamepassModule.boughtCoinsMultiplier = false
    gamepassModule.boughtFollowersMultiplier = false

    -- TODO : check if the player owns the game pass to set the variables above

    return setmetatable(gamepassModule, GamepassModule)
end


function GamepassModule:GetCoinsMultiplier()
    return self.boughtCoinsMultiplier and 20 or 0
end


function GamepassModule:GetFollowersMultiplier()
    return self.boughtFollowersMultiplier and 20 or 0
end


return GamepassModule