local Players = game:GetService("Players")
local MarketplaceService : MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Maid = require(ReplicatedStorage:WaitForChild("Maid"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))
local Utility = require(script.Parent:WaitForChild("Utility"))
local GamePassModule = require(script.Parent:WaitForChild("GamePassModule"))

local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local shopOpenButton : ImageButton = playerGui:WaitForChild("Menu"):WaitForChild("SideButtons"):WaitForChild("ShopButton")
local shopScreenGui : ScreenGui = playerGui:WaitForChild("Shop")
local shopBackground : Frame = shopScreenGui:WaitForChild("Background")
local shopContent : ScrollingFrame = shopBackground:WaitForChild("Content")
local shopNavigationBarContainer : Frame = shopBackground:WaitForChild("NavigationBarContainer")
local shopCloseButton : ImageButton = shopBackground:WaitForChild("Close")

local titleScrollingPositions : {[string] : number} = {
    LimitedTimeOffers = 0,
    GamePasses = 0,
    Followers = 0,
    Coins = 0,
    Potions = 0,
}


local gamePassesFrames : {[GamePassModule.GamePasses] : {Frame}} = {
    [GamePassModule.gamePasses.VIP] = {shopContent.GamePasses1.VIPGamePass},
    [GamePassModule.gamePasses.AutoClicker] = {shopContent.GamePasses1.AutoClickerGamePass, shopContent.GamePassesLimitedOffersContainer.AutoClickerLimitedTimeOfferContainer},
    [GamePassModule.gamePasses.FollowersMultiplier] = {shopContent.GamePasses2.DoubleFollowersGamePass},
    [GamePassModule.gamePasses.CoinsMultiplier] = {shopContent.GamePasses2.DoubleCoinsGamePass},
    [GamePassModule.gamePasses.SpaceCase] = {shopContent.GamePasses3.SpaceCaseGamePass, shopContent.GamePassesLimitedOffersContainer.SpaceCaseLimitedTimeOfferContainer},
    [GamePassModule.gamePasses.PlusHundredAndFiftyInventoryCapacity] = {shopContent.GamePasses3.PlusHundredFiftyPetStorage},
    [GamePassModule.gamePasses.BasicLuck] = {shopContent.GamePasses4.BasicLuckGamePass},
    [GamePassModule.gamePasses.GoldenLuck] = {shopContent.GamePasses4.GoldenLuckGamePass},
    [GamePassModule.gamePasses.OpenThreeEggs] = {shopContent.GamePasses5.TimesThreeOpenEggs},
    [GamePassModule.gamePasses.OpenSixEggs] = {shopContent.GamePasses5.TimesSixOpenEggs},
    [GamePassModule.gamePasses.EquipFourMorePets] = {shopContent.GamePasses6.Plus4PetsEquippedGamePass}
}


export type ShopModule = {
    shopUIMaid : Maid.Maid,
    timeLeftPromise : Promise.Promise,
    utility : Utility.Utility,
    new : (utility : Utility.Utility) -> ShopModule,
    OpenGui : (self : ShopModule) -> nil,
    ScrollToSection : (self : ShopModule, section : string) -> nil,
    CloseGui : (self : ShopModule) -> nil,
    UpdateGamePassOwnership : (self : ShopModule, gamepassId : number) -> nil
}


type LimitedTimeOffers = {
    tenXFollowersAndCoinsPotion100Hours1 : number,
    tenXFollowersAndCoinsPotion100Hours2 : number,
    spaceCase : number,
    autoClicker : number
}

type LimitedTimeOffer = {
    endDate : number,
    dateTextLabel : TextLabel
}


-- end dates for the limited time offers
local limitedTimeOffers : {[LimitedTimeOffers] : LimitedTimeOffer} = {
    tenXFollowersAndCoinsPotion100Hours1 = {
        endDate = os.time({year = 2023, month = 11, day = 31, hour = 23, min = 59, sec = 59}),
        dateTextLabel = shopContent.PotionLimitedTimeOfferContainer.TimeLeft
    },
    tenXFollowersAndCoinsPotion100Hours2 = {
        endDate = os.time({year = 2023, month = 11, day = 31, hour = 23, min = 59, sec = 59}),
        dateTextLabel = shopContent.Potions3.TimeLeft
    },
    spaceCase = {
        endDate = os.time({year = 2023, month = 11, day = 23, hour = 23, min = 59, sec = 59}),
        dateTextLabel = shopContent.GamePassesLimitedOffersContainer.SpaceCaseLimitedTimeOfferContainer.TimeLeft
    },
    autoClicker = {
        endDate = os.time({year = 2023, month = 11, day = 23, hour = 23, min = 59, sec = 59}),
        dateTextLabel = shopContent.GamePassesLimitedOffersContainer.AutoClickerLimitedTimeOfferContainer.TimeLeft
    }
}


local ShopModule : ShopModule = {}
ShopModule.__index = ShopModule


function ShopModule.new(utility : Utility.Utility)
    local shopModule : ShopModule = {}
    setmetatable(shopModule, ShopModule)

    shopModule.shopUIMaid = Maid.new()

    shopModule.utility = utility

    -- store all UIStroke in a table to change them easily later
    local shopGuiUIStroke : {UIStroke} = {}
    for _,v : Instance in ipairs(shopBackground:GetDescendants()) do
        if v:IsA("UIStroke") then
            table.insert(shopGuiUIStroke, v)
        end
    end

    utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
        local thickness : number = utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 2, 5)
        for _,uiStroke : UIStroke in pairs(shopGuiUIStroke) do
            uiStroke.Thickness = thickness
        end

        -- save the position of each title for the navbar
        local originalCanvasPosition : Vector2 = shopContent.CanvasPosition
        shopContent.CanvasPosition = Vector2.new(0,0)

        titleScrollingPositions.GamePasses = shopContent.GamePassesTitle.AbsolutePosition.Y - (shopContent.GamePassesTitle.AbsoluteSize.Y * 3)
        titleScrollingPositions.Followers = shopContent.FollowersTitle.AbsolutePosition.Y - (shopContent.FollowersTitle.AbsoluteSize.Y * 3)
        titleScrollingPositions.Coins = shopContent.CoinsTitle.AbsolutePosition.Y - (shopContent.CoinsTitle.AbsoluteSize.Y * 3)
        titleScrollingPositions.Potions = shopContent.PotionsTitle.AbsolutePosition.Y - (shopContent.PotionsTitle.AbsoluteSize.Y * 3)

        shopContent.CanvasPosition = originalCanvasPosition
    end)

    table.insert(utility.guisToClose, shopBackground)

    -- open the gui when clicking on the case button
    shopOpenButton.MouseButton1Down:Connect(function()
        shopModule:OpenGui()
    end)


    -- checking ownership of the gamepasses
    for gamepassId : number,_ in pairs(gamePassesFrames) do
        if GamePassModule.PlayerOwnsGamePass(gamepassId) then
            shopModule:UpdateGamePassOwnership(gamepassId)
        end
    end
    -- if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.VIP) then
    --     shopContent.GamePasses1.VIPGamePass.Buy.Visible = false
    --     shopContent.GamePasses1.VIPGamePass.Owned.Visible = true
    -- end

    -- if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.AutoClicker) then
    --     shopContent.GamePasses1.VIPGamePass.Buy.Visible = false
    --     shopContent.GamePasses1.VIPGamePass.Owned.Visible = true
    --     shopContent.GamePassesLimitedOffersContainer.AutoClickerLimitedTimeOfferContainer.Buy.Visible = false
    --     shopContent.GamePassesLimitedOffersContainer.AutoClickerLimitedTimeOfferContainer.Owned.Visible = true
    -- end

    -- if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.FollowersMultiplier) then
    --     shopContent.GamePasses2.DoubleFollowersGamePass.Buy.Visible = false
    --     shopContent.GamePasses2.DoubleFollowersGamePass.Owned.Visible = true
    -- end

    -- if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.CoinsMultiplier) then
    --     shopContent.GamePasses2.DoubleCoinsGamePass.Buy.Visible = false
    --     shopContent.GamePasses2.DoubleCoinsGamePass.Owned.Visible = true
    -- end

    -- if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.SpaceCase) then
    --     shopContent.GamePasses3.SpaceCaseGamePass.Buy.Visible = false
    --     shopContent.GamePasses3.SpaceCaseGamePass.Owned.Visible = true
    --     shopContent.GamePassesLimitedOffersContainer.SpaceCaseLimitedTimeOfferContainer.Buy.Visible = false
    --     shopContent.GamePassesLimitedOffersContainer.SpaceCaseLimitedTimeOfferContainer.Owned.Visible = true
    -- end

    -- if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.PlusHundredAndFiftyInventoryCapacity) then
    --     shopContent.GamePasses3.PlusHundredFiftyPetStorage.Buy.Visible = false
    --     shopContent.GamePasses3.PlusHundredFiftyPetStorage.Owned.Visible = true
    -- end

    -- if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.BasicLuck) then
    --     shopContent.GamePasses4.BasicLuckGamePass.Buy.Visible = false
    --     shopContent.GamePasses4.BasicLuckGamePass.Owned.Visible = true
    -- end

    -- if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.GoldenLuck) then
    --     shopContent.GamePasses4.GoldenLuckGamePass.Buy.Visible = false
    --     shopContent.GamePasses4.GoldenLuckGamePass.Owned.Visible = true
    -- end

    -- if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.OpenThreeEggs) then
    --     shopContent.GamePasses5.TimesThreeOpenEggs.Buy.Visible = false
    --     shopContent.GamePasses5.TimesThreeOpenEggs.Owned.Visible = true
    -- end

    -- if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.OpenSixEggs) then
    --     shopContent.GamePasses5.TimesSixOpenEggs.Buy.Visible = false
    --     shopContent.GamePasses5.TimesSixOpenEggs.Owned.Visible = true
    -- end

    -- if GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.EquipFourMorePets) then
    --     shopContent.GamePasses6.Plus4PetsEquippedGamePass.Buy.Visible = false
    --     shopContent.GamePasses6.Plus4PetsEquippedGamePass.Owned.Visible = true
    -- end

    return shopModule
end


--[[
    Opens the gui
]]--
function ShopModule:OpenGui()
    -- open the gui
    if self.utility.OpenGui(shopBackground) then

        -- NAVBAR

        self.shopUIMaid:GiveTask(
            shopNavigationBarContainer.LimitedTimeOffers.MouseButton1Down:Connect(function()
                self:ScrollToSection("LimitedTimeOffers")
            end)
        )

        self.shopUIMaid:GiveTask(
            shopNavigationBarContainer.GamePasses.MouseButton1Down:Connect(function()
                self:ScrollToSection("GamePasses")
            end)
        )

        self.shopUIMaid:GiveTask(
            shopNavigationBarContainer.Followers.MouseButton1Down:Connect(function()
                self:ScrollToSection("Followers")
            end)
        )

        self.shopUIMaid:GiveTask(
            shopNavigationBarContainer.Coins.MouseButton1Down:Connect(function()
                self:ScrollToSection("Coins")
            end)
        )

        self.shopUIMaid:GiveTask(
            shopNavigationBarContainer.Potions.MouseButton1Down:Connect(function()
                self:ScrollToSection("Potions")
            end)
        )


        -- LIMITED TIME OFFERS

        self.shopUIMaid:GiveTask(
            shopContent.PotionLimitedTimeOfferContainer.Buy.MouseButton1Down:Connect(function()
                MarketplaceService:PromptProductPurchase(lplr, 1650536241)
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.GamePassesLimitedOffersContainer.SpaceCaseLimitedTimeOfferContainer.Buy.MouseButton1Down:Connect(function()
                -- if the player doesn't already own the game pass
                if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.VIP) then
                    -- prompt the purhcase to buy the case
                    GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.VIP)
                end
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.GamePassesLimitedOffersContainer.AutoClickerLimitedTimeOfferContainer.Buy.MouseButton1Down:Connect(function()
                -- if the player doesn't already own the game pass
                if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.AutoClicker) then
                    -- prompt the purhcase to buy the case
                    GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.AutoClicker)
                end
            end)
        )


        -- GAMEPASSES

        self.shopUIMaid:GiveTask(
            shopContent.GamePasses1.VIPGamePass.Buy.MouseButton1Down:Connect(function()
                -- if the player doesn't already own the game pass
                if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.VIP) then
                    -- prompt the purhcase to buy the case
                    GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.VIP)
                end
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.GamePasses1.AutoClickerGamePass.Buy.MouseButton1Down:Connect(function()
                -- if the player doesn't already own the game pass
                if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.AutoClicker) then
                    -- prompt the purhcase to buy the case
                    GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.AutoClicker)
                end
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.GamePasses2.DoubleFollowersGamePass.Buy.MouseButton1Down:Connect(function()
                -- if the player doesn't already own the game pass
                if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.FollowersMultiplier) then
                    -- prompt the purhcase to buy the case
                    GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.FollowersMultiplier)
                end
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.GamePasses2.DoubleCoinsGamePass.Buy.MouseButton1Down:Connect(function()
                -- if the player doesn't already own the game pass
                if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.CoinsMultiplier) then
                    -- prompt the purhcase to buy the case
                    GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.CoinsMultiplier)
                end
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.GamePasses3.SpaceCaseGamePass.Buy.MouseButton1Down:Connect(function()
                -- if the player doesn't already own the game pass
                if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.SpaceCase) then
                    -- prompt the purhcase to buy the case
                    GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.SpaceCase)
                end
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.GamePasses3.PlusHundredFiftyPetStorage.Buy.MouseButton1Down:Connect(function()
                -- if the player doesn't already own the game pass
                if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.PlusHundredAndFiftyInventoryCapacity) then
                    -- prompt the purhcase to buy the case
                    GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.PlusHundredAndFiftyInventoryCapacity)
                end
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.GamePasses4.BasicLuckGamePass.Buy.MouseButton1Down:Connect(function()
                -- if the player doesn't already own the game pass
                if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.BasicLuck) then
                    -- prompt the purhcase to buy the case
                    GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.BasicLuck)
                end
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.GamePasses4.GoldenLuckGamePass.Buy.MouseButton1Down:Connect(function()
                -- if the player doesn't already own the game pass
                if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.GoldenLuck) then
                    -- prompt the purhcase to buy the case
                    GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.GoldenLuck)
                end
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.GamePasses5.TimesThreeOpenEggs.Buy.MouseButton1Down:Connect(function()
                -- if the player doesn't already own the game pass
                if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.OpenThreeEggs) then
                    -- prompt the purhcase to buy the case
                    GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.OpenThreeEggs)
                end
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.GamePasses5.TimesSixOpenEggs.Buy.MouseButton1Down:Connect(function()
                -- if the player doesn't already own the game pass
                if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.OpenSixEggs) then
                    -- prompt the purhcase to buy the case
                    GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.OpenSixEggs)
                end
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.GamePasses6.Plus4PetsEquippedGamePass.Buy.MouseButton1Down:Connect(function()
                -- if the player doesn't already own the game pass
                if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.EquipFourMorePets) then
                    -- prompt the purhcase to buy the case
                    GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.EquipFourMorePets)
                end
            end)
        )


        -- FOLLOWERS

        self.shopUIMaid:GiveTask(
            shopContent.Followers1.PlusTwentykFollowers.Buy.MouseButton1Down:Connect(function()
                MarketplaceService:PromptProductPurchase(lplr, 1650538357)
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.Followers1.PlusHundredkFollowers.Buy.MouseButton1Down:Connect(function()
                MarketplaceService:PromptProductPurchase(lplr, 1650538552)
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.Followers2.PlusTwoHundredFiftykFollowers.Buy.MouseButton1Down:Connect(function()
                MarketplaceService:PromptProductPurchase(lplr, 1650538745)
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.Followers2.PlusOneMFollowers.Buy.MouseButton1Down:Connect(function()
                MarketplaceService:PromptProductPurchase(lplr, 1650539381)
            end)
        )


        -- COINS

        self.shopUIMaid:GiveTask(
            shopContent.Coins1.PlusOnekCoins.Buy.MouseButton1Down:Connect(function()
                MarketplaceService:PromptProductPurchase(lplr, 1650536557)
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.Coins1.PlusTenkCoins.Buy.MouseButton1Down:Connect(function()
                MarketplaceService:PromptProductPurchase(lplr, 1650536791)
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.Coins2.PlusFiftykCoins.Buy.MouseButton1Down:Connect(function()
                MarketplaceService:PromptProductPurchase(lplr, 1650537008)
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.Coins2.PlusTwoHundredkCoins.Buy.MouseButton1Down:Connect(function()
                MarketplaceService:PromptProductPurchase(lplr, 1650538021)
            end)
        )


        -- POTIONS

        self.shopUIMaid:GiveTask(
            shopContent.Potions1.TwoXFollowersPotionThirtyMin.Buy.MouseButton1Down:Connect(function()
                MarketplaceService:PromptProductPurchase(lplr, 1650535700)
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.Potions1.FiveXFollowersPotionThirtyMin.Buy.MouseButton1Down:Connect(function()
                MarketplaceService:PromptProductPurchase(lplr, 1650535260)
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.Potions2.TwoXCoinsPotionThirtyMin.Buy.MouseButton1Down:Connect(function()
                MarketplaceService:PromptProductPurchase(lplr, 1650535902)
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.Potions2.FiveXCoinsPotionThirtyMin.Buy.MouseButton1Down:Connect(function()
                MarketplaceService:PromptProductPurchase(lplr, 1650535469)
            end)
        )

        self.shopUIMaid:GiveTask(
            shopContent.Potions3.Buy.MouseButton1Down:Connect(function()
                MarketplaceService:PromptProductPurchase(lplr, 1650536241)
            end)
        )


        if not self.timeLeftPromise then
            self.timeLeftPromise = Promise.new(function(resolve)
                while shopBackground.Visible do

                    -- update the time left text for all the limited time offers
                    for _,limitedTimeOffer : LimitedTimeOffer in pairs(limitedTimeOffers) do
                        local timeLeft : number = os.difftime(limitedTimeOffer.endDate, os.time())
                        limitedTimeOffer.dateTextLabel.Text = string.format("%0.2id %0.2ih %0.2im %0.2is", timeLeft / 86400, (timeLeft / 3600) % 24, (timeLeft / 60) % 60, timeLeft % 60)
                    end
                    
                    task.wait(1)
                end

                resolve()
            end)
            :finally(function()
                self.timeLeftPromise = nil
            end)
        end


        -- set the close gui connection (only do it if the gui was not already open, otherwise multiple connection exist and it is called multiple times)
        self.utility.SetCloseGuiConnection(shopCloseButton, function()
            self:CloseGui()
        end)
    end
end


--[[
    Scrolls the shop gui to the given section

    @param section : string, the section to scroll to
]]--
function ShopModule:ScrollToSection(section : string)
    TweenService:Create(
        shopContent,
        TweenInfo.new(
            0.3
        ),
        {CanvasPosition = Vector2.new(0, titleScrollingPositions[section])}
    ):Play()
end


--[[
    Closes the gui
]]--
function ShopModule:CloseGui()
    self.shopUIMaid:DoCleaning()

    self.utility.CloseGui(shopBackground)
end


--[[
    Updates the ownership of the gamepass matching the given id (hide the buy button and show the owned text label)

    @param gamepassId : number, the id of the gamepass to update
]]--
function ShopModule:UpdateGamePassOwnership(gamepassId : number)
    if gamePassesFrames[gamepassId] then
        for _,gamePassFrames : {Frame} in pairs(gamePassesFrames[gamepassId]) do
            gamePassFrames.Buy.Visible = false
            gamePassFrames.Owned.Visible = true
        end
    end
end


return ShopModule