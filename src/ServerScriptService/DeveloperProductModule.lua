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
    MagicUpgrade : number
}

export type DeveloperProductModule = {
    BoughtDeveloperProduct : (receiptInfo : table, p : Types.PlayerModule) -> nil
}


local DeveloperProductModule : DeveloperProductModule = {}
DeveloperProductModule.__index = DeveloperProductModule

DeveloperProductModule.developerProducts = {
    Rebirth = 1590728129,
    LimitedEditionPetHundred = 1644616511,
    LimitedEditionPetFire = 1644617696,
    LimitedEditionPetPartyPopper = 1644617959,
    LimitedEditionPetRedHeart = 1644618109,
    LimitedEditionPetDevil = 1644618260,
    LimitedEditionPetMoney = 1644618414,
    MagicUpgrade = 1645098556
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

            PetsRE:FireClient(player, p.petModule.ownedPets, true)
        end
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end


return DeveloperProductModule