
type egg = {
    id : number,
    name : string,
    price : number,
    enabled : boolean,
    pets : {pet}
}

type pet = {
    id : number,
    probability : number
}


-- local eggs = {
--     BasicEgg = 0
-- }


local eggs : {egg} = {
    [0] = {
        id = 0,
        name = "Basic Egg",
        price = 1,
        enabled = true,
        pets = {

        }
    },
    [1] = {
        id = 1,
        name = "Other Egg",
        price = 5,
        enabled = true,
        pets = {

        }
    }
}


local eggPets = {
    [0] = {
        [1] = 0.35,
        [2] = 0.242,
        [3] = 0.181,
        [4] = 0.126,
        [5] = 0.078,
        [6] = 0.023
    }
}


export type EggModule = {
    new : () -> EggModule,
    GetEggPrice : (eggId : number) -> number,
    GetRandomPetForEgg : (eggId : number) -> number?,
    HasEnoughCoinsToOpenEgg : (p : {}, eggId : number, numberOfEggsToOpen : number) -> number?
}


local EggModule : EggModule = {}
EggModule.__index = EggModule


function EggModule.new()
    
end


--[[
    Returns the price of the egg matching the given id

    @param eggId : number, the id of the egg
    @return number?, the price of the given egg or nil if not found
]]--
function EggModule.GetEggPrice(eggId : number) : number?
    if eggs[eggId] and eggs[eggId].enabled then
        return eggs[eggId].price
    end

    return nil
end


--[[
    Returns a random pet for the given egg

    @param eggId : number, the id of the egg
    @return pet, the id of the randomly selected pet
]]--
function EggModule.GetRandomPetForEgg(eggId : number) : number?
    local petOdds : {[number] : number} = eggPets[eggId]
    if petOdds then

        local sum : number = 0
        local randomNumber : number = math.random()
        
        for petId : number, probability : number in pairs(petOdds) do
            sum += probability
            if sum > randomNumber then
                return petId
            end
        end
    end

    return nil
end


--[[
    Checks and returns if the player has enough coins to open the specified number of eggs of the egg matching the given id

    @param p : PlayerModule, the object reprensenting the player
    @param eggId : number, the id of the egg to check
    @param numberOfEggsToOpen : number, the number of eggs the player is trying to open at once
    @return number?, the price to open all the eggs if the player has enough, nil otherwise
]]--
function EggModule.HasEnoughCoinsToOpenEgg(p : {}, eggId : number, numberOfEggsToOpen : number) : number?
    -- get the price of the egg with the given id
    local price : number? = EggModule.GetEggPrice(eggId)
    if price then

        if p:HasEnoughCoins(price * numberOfEggsToOpen) then
            return price * numberOfEggsToOpen
        end
    end

    return nil
end


return EggModule