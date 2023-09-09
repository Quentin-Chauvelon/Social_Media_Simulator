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
    identifier : string,
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
    Legendary = 4,
    Mystical = 5
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
        identifier = "TearsOfJoy",
        name = "Tears of joy",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.05,
        activeBoost = 1.05,
        equipped = false
    },
    [1] = {
        identifier = "Grinning",
        name = "Grinning",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.1,
        activeBoost = 1.1,
        equipped = false
    },
    [2] = {
        identifier = "Flushed",
        name = "Flushed",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.1,
        activeBoost = 1.1,
        equipped = false
    },
    [3] = {
        identifier = "ROFL",
        name = "ROFL",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.2,
        activeBoost = 1.2,
        equipped = false
    },
    [4] = {
        identifier = "Crying",
        name = "Crying",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.25,
        activeBoost = 1.25,
        equipped = false
    },
    [5] = {
        identifier = "Smiling",
        name = "Smiling",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.5,
        activeBoost = 1.5,
        equipped = false
    },
    [6] = {
        identifier = "Winking",
        name = "Winking",
        rarity = rarities.Uncommon,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.65,
        activeBoost = 1.65,
        equipped = false
    },
    [7] = {
        identifier = "SmilingEyes",
        name = "Smiling eyes",
        rarity = rarities.Uncommon,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.8,
        activeBoost = 1.8,
        equipped = false
    },
    [8] = {
        identifier = "Sweat",
        name = "Sweat",
        rarity = rarities.Uncommon,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 2,
        activeBoost = 2,
        equipped = false
    },
    [9] = {
        identifier = "Nerd",
        name = "Nerd",
        rarity = rarities.Uncommon,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 2.1,
        activeBoost = 2.1,
        equipped = false
    },
    [10] = {
        identifier = "RollingEyes",
        name = "Rolling eyes",
        rarity = rarities.Rare,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 2.7,
        activeBoost = 2.7,
        equipped = false
    },
    [11] = {
        identifier = "HeartEyes",
        name = "Heart eyes",
        rarity = rarities.Rare,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 2.95,
        activeBoost = 2.95,
        equipped = false
    },
    [12] = {
        identifier = "Hugging",
        name = "Hugging",
        rarity = rarities.Rare,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 3.05,
        activeBoost = 3.05,
        equipped = false
    },
    [13] = {
        identifier = "Pensive",
        name = "Pensive",
        rarity = rarities.Rare,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 3.2,
        activeBoost = 3.2,
        equipped = false
    },
    [14] = {
        identifier = "Thinking",
        name = "Thinking",
        rarity = rarities.Rare,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 3.6,
        activeBoost = 3.6,
        equipped = false
    },
    [15] = {
        identifier = "Hearts",
        name = "Hearts",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 3.5,
        activeBoost = 3.5,
        equipped = false
    },
    [16] = {
        identifier = "Squinting",
        name = "Squinting",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 3.75,
        activeBoost = 3.75,
        equipped = false
    },
    [17] = {
        identifier = "Fear",
        name = "Fear",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 4,
        activeBoost = 4,
        equipped = false
    },
    [18] = {
        identifier = "ThumbsUp",
        name = "Thumbs up",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 4.5,
        activeBoost = 4.5,
        equipped = false
    },
    [19] = {
        identifier = "Swearing",
        name = "Swearing",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 5,
        activeBoost = 5,
        equipped = false
    },
    [20] = {
        identifier = "UpsideDown",
        name = "Upside down",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 5.2,
        activeBoost = 5.2,
        equipped = false
    },
    [21] = {
        identifier = "FoldedHands",
        name = "Folded hands",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 6,
        activeBoost = 6,
        equipped = false
    },
    [22] = {
        identifier = "OK",
        name = "OK",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 7,
        activeBoost = 7,
        equipped = false
    },
    [23] = {
        identifier = "PurpleHeart",
        name = "Purple heart",
        rarity = rarities.Legendary,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 9.5,
        activeBoost = 9.5,
        equipped = false
    },
    [24] = {
        identifier = "Clapping",
        name = "Clapping",
        rarity = rarities.Legendary,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 11.2,
        activeBoost = 11.2,
        equipped = false
    },
    [25] = {
        identifier = "Sleeping",
        name = "Sleeping",
        rarity = rarities.Legendary,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 15.3,
        activeBoost = 15.3,
        equipped = false
    },
    [26] = {
        identifier = "Sunglasses",
        name = "Sunglasses",
        rarity = rarities.Legendary,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 20.8,
        activeBoost = 20.8,
        equipped = false
    },
    [27] = {
        identifier = "Party",
        name = "Party",
        rarity = rarities.Legendary,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 35.5,
        activeBoost = 35.5,
        equipped = false
    },
    [28] = {
        identifier = "Angel",
        name = "Angel",
        rarity = rarities.Legendary,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 40.1,
        activeBoost = 40.1,
        equipped = false
    },
    [29] = {
        identifier = "Poo",
        name = "Poo",
        rarity = rarities.Legendary,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 50.5,
        activeBoost = 50.5,
        equipped = false
    },
    [100] = {
        identifier = "RedHeart",
        name = "Heart",
        rarity = rarities.Mystical,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 75,
        activeBoost = 75,
        equipped = false
    },
    [101] = {
        identifier = "Hundred",
        name = "Hundred",
        rarity = rarities.Mystical,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 100,
        activeBoost = 100,
        equipped = false
    },
    [102] = {
        identifier = "Fire",
        name = "Fire",
        rarity = rarities.Mystical,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 150,
        activeBoost = 150,
        equipped = false
    },
    [103] = {
        identifier = "PartyPopper",
        name = "Party popper",
        rarity = rarities.Mystical,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 250,
        activeBoost = 250,
        equipped = false
    },
    [104] = {
        identifier = "Devil",
        name = "Devil",
        rarity = rarities.Mystical,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 300,
        activeBoost = 300,
        equipped = false
    },
    [105] = {
        identifier = "Money",
        name = "Money",
        rarity = rarities.Mystical,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 500,
        activeBoost = 500,
        equipped = false
    },
}


local PetModule : PetModule = {}
PetModule.__index = PetModule


function PetModule.new(plr : Player)
    local petModule : PetModule = {}

    -- DataStore2("pets", plr):Set(nil)
    petModule.ownedPets = DataStore2("pets", plr):Get({})
    print(petModule.ownedPets)

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