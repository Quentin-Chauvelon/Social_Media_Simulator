local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = ServerScriptService:WaitForChild("Types")

local RebirthRE : RemoteEvent = ReplicatedStorage:WaitForChild("Rebirth")


export type DeveloperProductModule = {
    BoughtDeveloperProduct : (receiptInfo : table, p : Types.PlayerModule) -> nil
}

export type receiptInfo = {
    PurchaseId : number,
    PlayerId : number,
    ProductId : number,
    PlaceIdWherePurchased : number,
    CurrencySpent : number,
    CurrencyType : number
}


local DeveloperProductModule : DeveloperProductModule = {}
DeveloperProductModule.__index = DeveloperProductModule


function DeveloperProductModule.BoughtDeveloperProduct(receiptInfo : receiptInfo, p : Types.PlayerModule)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if player then

        -- Rebirth dev product
        if receiptInfo.ProductId == 1590728129 then
            if p.rebirthModule:Rebirth(player) then
                RebirthRE:FireClient(player)

                p:SetFollowersAmount(0)

                return Enum.ProductPurchaseDecision.PurchaseGranted
            end
        end
	end

	return Enum.ProductPurchaseDecision.NotProcessedYet
end


return DeveloperProductModule