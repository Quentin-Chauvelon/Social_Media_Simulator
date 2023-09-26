local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local lplr : Player = Players.LocalPlayer

local gamepassBillboardSurfaceGui : SurfaceGui = lplr.PlayerGui:WaitForChild("GamePassesBillboard")
local gamepassBillboardImage : ImageLabel = gamepassBillboardSurfaceGui:WaitForChild("Container"):WaitForChild("Image")
local gamepassBillboardTitle : TextLabel = gamepassBillboardSurfaceGui.Container:WaitForChild("Title")
local gamepassBillboardDescription : TextLabel = gamepassBillboardSurfaceGui.Container:WaitForChild("Description")
local gamepassBillboardBuy : TextButton = gamepassBillboardSurfaceGui.Container:WaitForChild("Buy")
local gamepassBillboardPrice : TextLabel = gamepassBillboardBuy:WaitForChild("Price")
local gamepassBillboardOwned : TextLabel = gamepassBillboardSurfaceGui.Container:WaitForChild("Owned")

local gamepassIdBillboard : NumberValue = workspace:WaitForChild("GamePassesBillboard"):WaitForChild("GamePassId")


export type GamePassModule = {
    gamePasses : GamePasses,
    ownedGamePasses : {[GamePasses] : ownedGamePass},
    LoadGamePasses : () -> nil,
    UserOwnsGamePass : (gamePassId : number) -> (boolean, boolean),
    PlayerOwnsGamePass : (gamePassId : number) -> boolean,
    PromptGamePassPurchase : (gamePassId : number) -> nil,
    PlayerBoughtGamePass : (gamePassId : number) -> nil
}

export type GamePasses = {
    VIP : number,
    AutoClicker : number,
    CoinsMultiplier : number,
    FollowersMultiplier : number,
    SpaceCase : number,
    OpenThreeEggs : number,
    OpenSixEggs : number,
    EquipFourMorePets : number,
    PlusHundredAndFiftyInventoryCapacity : number,
    BasicLuck : number,
    GoldenLuck : number
}

type ownedGamePass = {
    loaded : boolean,
    owned : boolean
}

type GamepassInformation = {
    gamepassId : number,
    title : string,
    description : string,
    image : string,
    price : number
}

local gamepassesInformation : {[number] : GamepassInformation} = {}


local GamePassModule : GamePassModule = {}
GamePassModule.__index = GamePassModule


-- Game passes enum
GamePassModule.gamePasses = {
    VIP = 259863695,
    AutoClicker = 259863929,
    CoinsMultiplier = 259864413,
    FollowersMultiplier = 259864174,
    SpaceCase = 259864682,
    OpenThreeEggs = 259865245,
    OpenSixEggs = 259865406,
    EquipFourMorePets = 259864854,
    PlusHundredAndFiftyInventoryCapacity = 259865048,
    BasicLuck = 259865697,
    GoldenLuck = 259865957
}

-- list of all the game passes
-- the first value is a boolean representing if the server could be contacted to load the ownership
-- the second value is a boolean representing if the player actually owns the game pass
GamePassModule.ownedGamePasses = {}

for _,gamePassId : number in pairs(GamePassModule.gamePasses) do
    GamePassModule.ownedGamePasses[gamePassId] = {loaded = false, owned = false}
end


-- update the gamepass billboard with the given gamepass information
local function UpdateGamepassBillboard(gamepassInformation : GamepassInformation)
    -- update the id of the displayed gamepass
    gamepassIdBillboard.Value = gamepassInformation.gamepassId

    gamepassBillboardTitle.Text = gamepassInformation.title
    gamepassBillboardDescription.Text = gamepassInformation.description
    gamepassBillboardImage.Image = "rbxassetid://" .. gamepassInformation.image

    if GamePassModule.PlayerOwnsGamePass(gamepassInformation.gamepassId) then
        gamepassBillboardBuy.Visible = false
        gamepassBillboardOwned.Visible = true
    else
        gamepassBillboardOwned.Visible = false
        gamepassBillboardBuy.Visible = true
        gamepassBillboardPrice.Text = gamepassInformation.price
    end
end


-- prompt the player to buy the gamepass when they click the buy button
gamepassBillboardBuy.MouseButton1Down:Connect(function()
    GamePassModule.PromptGamePassPurchase(gamepassIdBillboard.Value)
end)


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
    -- if the player doesn't already own the game pass
    if not GamePassModule.PlayerOwnsGamePass(gamePassId) then
        MarketplaceService:PromptGamePassPurchase(lplr, gamePassId)
    end
end


function GamePassModule.PlayerBoughtGamePass(gamePassId : number)
    GamePassModule.ownedGamePasses[gamePassId].loaded = true
    GamePassModule.ownedGamePasses[gamePassId].owned = true
end


-- display all gamepasses one by one on the game pass billboard
coroutine.wrap(function()
    while true do
        for _,gamepassId : number in pairs(GamePassModule.gamePasses) do

            -- if the gamepass information has already been found, update the billboard
            if gamepassesInformation[gamepassId] then
                UpdateGamepassBillboard(gamepassesInformation[gamepassId])

            -- otherwise load the information from the server
            else
                local gamepassInformation
                pcall(function()
                    gamepassInformation = MarketplaceService:GetProductInfo(gamepassId, Enum.InfoType.GamePass)
                end)

                if gamepassInformation then
                    gamepassesInformation[gamepassId] = {
                        gamepassId = gamepassId,
                        title = gamepassInformation.Name,
                        description = gamepassInformation.Description,
                        image = gamepassInformation.IconImageAssetId,
                        price = gamepassInformation.PriceInRobux,
                    }

                    UpdateGamepassBillboard(gamepassesInformation[gamepassId])
                end
            end

            task.wait(8)
        end
    end
end)()


return GamePassModule