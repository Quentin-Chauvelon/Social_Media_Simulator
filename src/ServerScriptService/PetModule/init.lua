local ServerScriptService = game:GetService("ServerScriptService")

local EggModule = require(script:WaitForChild("EggModule"))
local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local Types = require(ServerScriptService:WaitForChild("Types"))

DataStore2.Combine("SMS", "pets")


export type PetModule = {
    ownedPets : {pet},
    maxEquippedPets : number,
    inventoryCapacity : number,
    plr : Player,
    new : (plr : Player) -> PetModule,
    IsPetInventoryFull : (self : PetModule) -> boolean,
    AddPetToInventory : (self : PetModule, pet : pet) -> nil,
    GetPetFromPetId : (self : PetModule, petId : number) -> pet?,
    OpenEgg : (self : PetModule, eggId : number) -> pet,
    OpenEggs : (self : PetModule, p : Types.PlayerModule, eggId : number, numberOfEggsToOpen : number) -> pet,
}

type pet = {
    name : string,
    rarity : number,
    size : number,
    upgrade : number,
    baseBoost : number,
    activeBoost : number,
    equipped : boolean
}


local rarities = {
    Common = 0,
    Uncommon = 1,
    Rare = 2,
    Epic = 3,
    Legendary = 4
}

local sizes = {
    Normal = 0,
    Big = 1,
    Huge = 2
}

local upgrades = {
    None = 0,
    Shiny = 1,
    Rainbow = 2,
    Magic = 3
}


local pets : {[number] : pet} = {
    [0] = {
        name = "Smiling",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.1,
        activeBoost = 1.1,
        equipped = false
    },
    [1] = {
        name = "Smiling",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.1,
        activeBoost = 1.1,
        equipped = false
    },
    [2] = {
        name = "Smiling",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.1,
        activeBoost = 1.1,
        equipped = false
    },
    [3] = {
        name = "Smiling",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.1,
        activeBoost = 1.1,
        equipped = false
    },
    [4] = {
        name = "Smiling",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.1,
        activeBoost = 1.1,
        equipped = false
    },
    [5] = {
        name = "Smiling",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.1,
        activeBoost = 1.1,
        equipped = false
    },
    [6] = {
        name = "Smiling",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.1,
        activeBoost = 1.1,
        equipped = false
    }
}


local PetModule : PetModule = {}
PetModule.__index = PetModule


function PetModule.new(plr : Player)
    local petModule : PetModule = {}

    petModule.ownedPets = DataStore2("pets", plr):Get({})

    petModule.maxEquippedPets = 3
    petModule.inventoryCapacity = 50

    petModule.plr = plr

    return setmetatable(petModule, PetModule)
end


--[[
    Returns true if the inventory is full, false otherwise
]]--
function PetModule:IsPetInventoryFull()
    return not (#self.ownedPets < self.inventoryCapacity)
end


--[[
    Adds the given pet id to the inventory

    @param petId : number, the id of the pet to add to the inventory
]]--
function PetModule:AddPetToInventory(pet : pet)
    table.insert(self.ownedPets, pet)

    DataStore2("pets", self.plr):Set(self.ownedPets)
end


--[[
    Returns the pet matching the given id

    @param petId : number, the id of the pet to return
    @return pet?, the table containing the information about the pets if it has been found, nil otherwise
]]--
function PetModule:GetPetFromPetId(petId : number) : pet?
    for id : number, pet : pet in pairs(pets) do
        if id == petId then
            return pet
        end
    end

    return nil
end


--[[
    Open one egg corresponding to the given eggId and return the randomly selected pet

    @param eggId : number, the id of the egg the player wants to open
    @return pet?, the information about the randomly selected pet if it could be selected, nil otherwise
]]--
function PetModule:OpenEgg(eggId : number) : pet?
    -- if the inventory is not full
    if not self:IsPetInventoryFull() then

        -- get a random pet for the given egg
        local petId : number? = EggModule.GetRandomPetForEgg(eggId)
        if petId then

            -- get the pet information table from the id
            local pet : pet = self:GetPetFromPetId(petId)
            if pet then

                self:AddPetToInventory(pet)
                return pet
            end
        end
    end

    return nil
end


--[[
    Open x times (numberOfEggsToOpen) the egg matching the given id and return a table containing all the pets the player got

    @param p : PlayerModule, the object reprensenting the player
    @param eggId : number, the id of the egg the player wants to open
    @param numberOfEggsToOpen : number, the number of eggs to open
    @return {pet}, a table containing information about all the pets the player got while opening the eggs
]]--
function PetModule:OpenEggs(p : Types.PlayerModule, eggId : number, numberOfEggsToOpen : number) : {pet}
    -- get the price of the egg with the given id
    local price : number? = EggModule.GetEggPrice(eggId)
    if price then

        if p:HasEnoughCoins(price * numberOfEggsToOpen) then
            
            local openedPets : {pet} = {}

            for _=1,numberOfEggsToOpen do
                
                local openedPet : pet? = self:OpenEgg(eggId)
                if openedPet then
                    table.insert(openedPets, openedPet)
                end
            end

            -- remove the price of the egg times the number of times the player got a pet
            p:UpdateCoinsAmount(-price * #openedPets)

            return openedPets
        end
    end

    return {}
end


return PetModule