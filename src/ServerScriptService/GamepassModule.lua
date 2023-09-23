local ServerScriptService = game:WaitForChild("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BoughtGamePassRE : RemoteEvent = ReplicatedStorage:WaitForChild("BoughtGamePass")

local Types = ServerScriptService:WaitForChild("Types")

local vipTag : BillboardGui = ReplicatedStorage:WaitForChild("VIPTag")

export type GamepassModule = {
    gamePasses : GamePasses,
    ownedGamePasses : {[GamePasses] : ownedGamePass},
    player : Player,
    new : (plr : Player) -> GamepassModule,
    PlayerBoughtGamePass : (self : GamepassModule, gamePassId : number, p : Types.PlayerModule) -> nil,
    UserOwnsGamePass : (self : GamepassModule, gamePassId : number) -> (boolean, boolean),
    PlayerOwnsGamePass : (self : GamepassModule, gamePassId : number) -> boolean,
    LoadOwnedGamePasses : (self : GamepassModule) -> nil,
    GetCoinsMultiplier : (self : GamepassModule) -> number,
    GetFollowersMultiplier : (self : GamepassModule) -> number,
    OnLeave : (self : GamepassModule) -> nil
}

type GamePasses = {
    VIP : number,
    AutoClicker : number,
    CoinsMultiplier : number,
    FollowersMultiplier : number,
    SpaceCase : number,
    Open3Eggs : number,
    Open6Eggs : number,
    EquipFourMorePets : number,
    PlusHundredAndFiftyInventoryCapacity : number,
    BasicLuck : number,
    GoldenLuck : number
}

type ownedGamePass = {
    loaded : boolean,
    owned : boolean
}


local GamepassModule : GamepassModule = {}
GamepassModule.__index = GamepassModule


function GamepassModule.new(plr : Player)
    local gamepassModule : GamepassModule = {}

    gamepassModule.gamePasses = {
        VIP = 259863695,
        AutoClicker = 259863929,
        CoinsMultiplier = 259864413,
        FollowersMultiplier = 259864174,
        SpaceCase = 259864682,
        Open3Eggs = 259865245,
        Open6Eggs = 259865406,
        EquipFourMorePets = 259864854,
        PlusHundredAndFiftyInventoryCapacity = 259865048,
        BasicLuck = 259865697,
        GoldenLuck = 259865957
    }

    gamepassModule.ownedGamePasses = {}

    for _,gamePassId : number in pairs(gamepassModule.gamePasses) do
        gamepassModule.ownedGamePasses[gamePassId] = {loaded = false, owned = false}
    end

    gamepassModule.player = plr

    return setmetatable(gamepassModule, GamepassModule)
end


--[[
    Applies the effect of the game pass the player bought

    @param gamePassId : number, the id of the game pass the player bought
    @param p : PlayerModule, the player object representing the player
]]--
function GamepassModule:PlayerBoughtGamePass(gamePassId : number, p : Types.PlayerModule)
    local isGamePassPurchaseSuccesfull : boolean = true

    self.ownedGamePasses[gamePassId].loaded = true
    self.ownedGamePasses[gamePassId].owned = true

    if gamePassId == self.gamePasses.SpaceCase then
        p.caseModule:BuyCase("Space", p)

    elseif gamePassId == self.gamePasses.EquipFourMorePets then
        p.petModule.maxEquippedPets = 7

    elseif gamePassId == self.gamePasses.PlusHundredAndFiftyInventoryCapacity then
        p.petModule.inventoryCapacity = 200

    elseif gamePassId == self.gamePasses.BasicLuck then
        -- only update the pet luck if it's 0, otherwise we don't want to override a better pass
        if p.petModule.luck == 0 then
            p.petModule.luck = 1
        end

    elseif gamePassId == self.gamePasses.GoldenLuck then
        p.petModule.luck = 2

    elseif gamePassId == self.gamePasses.AutoClicker then
        p.postModule:StartAutoClicker(p)

    elseif gamePassId == self.gamePasses.VIP then
        local character : Model = p.player.Character
        if character then

            local humanoid : Humanoid = character:FindFirstChild("Humanoid")
            if humanoid then
                -- hide the player's default name display
                humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                
                -- clone the vip tag over the player's head
                local vipTagClone : BillboardGui = vipTag:Clone()
                vipTagClone.PlayerNameContainer.PlayerName.Text = p.player.DisplayName
                vipTagClone.Enabled = true
                vipTagClone.Parent = character.Head
            end
        end

        if p.player:FindFirstChild("VIP") then
            p.player.VIP.Value = true
        end
    end

    -- if the purchase of the game pass was succesful, fire the client to make changes locally if needed
    if isGamePassPurchaseSuccesfull then
        BoughtGamePassRE:FireClient(p.player, gamePassId)
    end
end


--[[
    Contacts the server to know if the player owns the game pass matching the given id

    @param gamePassId : number, the id of the game pass to check ownership from the player
    @return (boolean, boolean),
        The first value will be false if the call to the server errored and true otherwise.
        The second value will be true if the player owns the game pass and false otherwise
]]--
function GamepassModule:UserOwnsGamePass(gamePassId : number) : (boolean, boolean)
    local ownsPass : boolean = false

    local success,_ = pcall(function()
        ownsPass = MarketplaceService:UserOwnsGamePassAsync(self.player.UserId, gamePassId)
    end)

    return success, (success and ownsPass or false)
end


--[[
    Check if the player owns the game pass matching the given id

    @param gamePassId : number, the id of the game pass to check ownership from the player
    @return boolean, true if the player owns the game pass, false otherwise
]]--
function GamepassModule:PlayerOwnsGamePass(gamePassId : number) : boolean
    if self.ownedGamePasses[gamePassId].loaded == true then
        return self.ownedGamePasses[gamePassId].owned
    else
        local _, ownsGamePass : boolean = self:UserOwnsGamePass(gamePassId)
        return ownsGamePass
    end
end


--[[
    Loads the effects of the game passes the player owns on join

    @param p : PlayerModule, the player object representing the player
]]--
function GamepassModule:LoadOwnedGamePasses(p : Types.PlayerModule)
    for _,gamePassId : number in pairs(self.gamePasses) do

        local loaded : boolean, owned : boolean = self:UserOwnsGamePass(gamePassId)

        self.ownedGamePasses[gamePassId].loaded = loaded
        self.ownedGamePasses[gamePassId].owned = owned

        -- if the player owns the game pass
        if loaded and owned then

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
    return self:PlayerOwnsGamePass(self.gamePasses.CoinsMultiplier)
        and 2 + (self:PlayerOwnsGamePass(self.gamePasses.VIP) and 0.5 or 0)
        or 1  + (self:PlayerOwnsGamePass(self.gamePasses.VIP) and 0.5 or 0)
end


function GamepassModule:GetFollowersMultiplier()
    return self:PlayerOwnsGamePass(self.gamePasses.FollowersMultiplier)
        and 2 + (self:PlayerOwnsGamePass(self.gamePasses.VIP) and 0.5 or 0)
        or 1  + (self:PlayerOwnsGamePass(self.gamePasses.VIP) and 0.5 or 0)
end


function GamepassModule:OnLeave()
	setmetatable(self, nil)
	self = nil
end


return GamepassModule