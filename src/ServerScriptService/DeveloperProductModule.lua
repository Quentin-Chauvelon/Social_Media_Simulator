local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = ServerScriptService:WaitForChild("Types")

local RebirthRE : RemoteEvent = ReplicatedStorage:WaitForChild("Rebirth")
local PetsRE : RemoteEvent = ReplicatedStorage:WaitForChild("Pets")


type receiptInfo = {
    PurchaseId : number,
    PlayerId : number,
    ProductId : number,
    PlaceIdWherePurchased : number,
    CurrencySpent : number,
    CurrencyType : number
}

type DeveloperProducts = {
    Rebirth : number,
    LimitedEditionPetHundred : number,
    LimitedEditionPetFire : number,
    LimitedEditionPetPartyPopper : number,
    LimitedEditionPetRedHeart : number,
    LimitedEditionPetDevil : number,
    LimitedEditionPetMoney : number,
    MagicUpgrade : number,
    TwentyKFollowers : number,
    HundredKFollowers : number,
    TwoHundredFiftyKFollowers : number,
    OneMFollowers : number,
    OneKCoins : number,
    TenKCoins : number,
    FiftyKCoins : number,
    TwoHundredKCoins : number,
    TwoXFollowersPotion30Min : number,
    FiveXFollowersPotion30Min : number,
    TwoXCoinsPotion30Min : number,
    FiveXCoinsPotion30Min : number,
    TenXFollowersAndCoinsPotion100Hours : number
}

export type DeveloperProductModule = {
    BoughtDeveloperProduct : (receiptInfo : table, p : Types.PlayerModule) -> nil
}


local DeveloperProductModule : DeveloperProductModule = {}
DeveloperProductModule.__index = DeveloperProductModule

DeveloperProductModule.developerProducts = {
    Rebirth = 1650523473,
    LimitedEditionPetHundred = 1650534346,
    LimitedEditionPetFire = 1650534615,
    LimitedEditionPetPartyPopper = 1650533751,
    LimitedEditionPetRedHeart = 1650533521,
    LimitedEditionPetDevil = 1650534926,
    LimitedEditionPetMoney = 1650533975,
    MagicUpgrade = 1650533238,
    TwentyKFollowers = 1650538357,
    HundredKFollowers = 1650538552,
    TwoHundredFiftyKFollowers = 1650538745,
    OneMFollowers = 1650539381,
    OneKCoins = 1650536557,
    TenKCoins = 1650536791,
    FiftyKCoins = 1650537008,
    TwoHundredKCoins = 1650538021,
    TwoXFollowersPotion30Min = 1650535700,
    FiveXFollowersPotion30Min = 1650535260,
    TwoXCoinsPotion30Min = 1650535902,
    FiveXCoinsPotion30Min = 1650535469,
    TenXFollowersAndCoinsPotion100Hours = 1650536241
}


--[[
    Adds the limited edition pet matching the given id to the player's inventory

    @param p : PlayerModule, the player object representing the player
    @param id : number, the id of the pet (position in the table)
    @return boolean, true if the pet could be added to the inventory, false otherwise
]]--
local function BoughtLimitedEditionPet(p : Types.PlayerModule, id : number) : boolean
    local pet : {} = p.petModule:GetPetFromPetId(id)
    if not pet then
        return false
    end

    -- set the unique id for the pet
    pet.id = p.petModule.nextId
    p.petModule.nextId += 1

    p.petModule:AddPetToInventory(pet)

    -- add the pet to the inventory
    PetsRE:FireClient(p.player, {pet}, false)
    
    return true
end


--[[
	Called when a player successfully purchases a developer product
]]--
function DeveloperProductModule.BoughtDeveloperProduct(receiptInfo : receiptInfo, p : Types.PlayerModule)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if player then

        if receiptInfo.ProductId == DeveloperProductModule.developerProducts.Rebirth then
            if p.rebirthModule:Rebirth(player) then
                RebirthRE:FireClient(player)

                p:SetFollowersAmount(0)

                return Enum.ProductPurchaseDecision.PurchaseGranted
            end

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.LimitedEditionPetHundred then
            if BoughtLimitedEditionPet(p, 100) then
                return Enum.ProductPurchaseDecision.PurchaseGranted
            end

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.LimitedEditionPetFire then
            if BoughtLimitedEditionPet(p, 101) then
                return Enum.ProductPurchaseDecision.PurchaseGranted
            end

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.LimitedEditionPetPartyPopper then
            if BoughtLimitedEditionPet(p, 102) then
                return Enum.ProductPurchaseDecision.PurchaseGranted
            end

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.LimitedEditionPetRedHeart then
            if BoughtLimitedEditionPet(p, 103) then
                return Enum.ProductPurchaseDecision.PurchaseGranted
            end

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.LimitedEditionPetDevil then
            if BoughtLimitedEditionPet(p, 104) then
                return Enum.ProductPurchaseDecision.PurchaseGranted
            end

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.LimitedEditionPetMoney then
            if BoughtLimitedEditionPet(p, 105) then
                return Enum.ProductPurchaseDecision.PurchaseGranted
            end

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.MagicUpgrade then
            p.petModule:MagicUpgradePet()

            p:UpdateFollowersMultiplier()

            PetsRE:FireClient(player, p.petModule.ownedPets, true)

            return Enum.ProductPurchaseDecision.PurchaseGranted

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.TwentyKFollowers then
            p:SetFollowersAmount(p.followers + 20_000)
            return Enum.ProductPurchaseDecision.PurchaseGranted

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.HundredKFollowers then
            p:SetFollowersAmount(p.followers + 100_000)
            return Enum.ProductPurchaseDecision.PurchaseGranted

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.TwoHundredFiftyKFollowers then
            p:SetFollowersAmount(p.followers + 250_000)
            return Enum.ProductPurchaseDecision.PurchaseGranted

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.OneMFollowers then
            p:SetFollowersAmount(p.followers + 1_000_000)
            return Enum.ProductPurchaseDecision.PurchaseGranted

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.OneKCoins then
            p:SetCoinsAmount(p.coins + 1_000)
            return Enum.ProductPurchaseDecision.PurchaseGranted

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.TenKCoins then
            p:SetCoinsAmount(p.coins + 10_000)
            return Enum.ProductPurchaseDecision.PurchaseGranted

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.FiftyKCoins then
            p:SetCoinsAmount(p.coins + 50_000)
            return Enum.ProductPurchaseDecision.PurchaseGranted

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.TwoHundredKCoins then
            p:SetCoinsAmount(p.coins + 200_000)
            return Enum.ProductPurchaseDecision.PurchaseGranted

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.TwoXFollowersPotion30Min then
            p.potionModule:CreateAndUsePotion(p.potionModule.potionTypes.Followers, 2, 30, p)
            return Enum.ProductPurchaseDecision.PurchaseGranted

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.FiveXFollowersPotion30Min then
            p.potionModule:CreateAndUsePotion(p.potionModule.potionTypes.Followers, 5, 30, p)
            return Enum.ProductPurchaseDecision.PurchaseGranted

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.TwoXCoinsPotion30Min then
            p.potionModule:CreateAndUsePotion(p.potionModule.potionTypes.Coins, 2, 30, p)
            return Enum.ProductPurchaseDecision.PurchaseGranted

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.FiveXCoinsPotion30Min then
            p.potionModule:CreateAndUsePotion(p.potionModule.potionTypes.Coins, 5, 30, p)
            return Enum.ProductPurchaseDecision.PurchaseGranted

        elseif receiptInfo.ProductId == DeveloperProductModule.developerProducts.TenXFollowersAndCoinsPotion100Hours then
            p.potionModule:CreateAndUsePotion(p.potionModule.potionTypes.Coins, 10, 60000, p)
            p.potionModule:CreateAndUsePotion(p.potionModule.potionTypes.Followers, 10, 60000, p)
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end


return DeveloperProductModule