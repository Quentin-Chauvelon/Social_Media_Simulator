
type Eggs = {
    BasicEgg : number,
    CryingEgg : number,
    LoveEgg : number,
    SleepyEgg : number,
    AngelEgg : number
    -- RobuxEgg : number
}

type egg = {
    id : number,
    name : string,
    price : number,
    enabled : boolean,
    pets : {[number] : number}
}

type pet = {
    id : number,
    probability : number
}


local Eggs : Eggs = {
    BasicEgg = 0,
    CryingEgg = 1,
    LoveEgg = 2,
    SleepyEgg = 3,
    AngelEgg = 4,
    -- RobuxEgg = 5
}


local eggs : {[Eggs] : egg} = {
    [Eggs.BasicEgg] = {
        id = 0,
        name = "Basic Egg",
        price = 1,
        enabled = true,
        pets = {
            [0] = 0.35,
            [1] = 0.242,
            [2] = 0.181,
            [6] = 0.126,
            [10] = 0.078,
            [15] = 0.023
        }
    },
    [Eggs.CryingEgg] = {
        id = 1,
        name = "Crying Egg",
        price = 4,
        enabled = true,
        pets = {
            [3] = 0.375,
            [4] = 0.323,
            [7] = 0.226,
            [11] = 0.042,
            [12] = 0.028,
            [16] = 0.006
        }
    },
    [Eggs.LoveEgg] = {
        id = 2,
        name = "Love Egg",
        price = 20,
        enabled = true,
        pets = {
            [5] = 0.426,
            [8] = 0.263,
            [9] = 0.222,
            [13] = 0.058,
            [17] = 0.026,
            [23] = 0.005
        }
    },
    [Eggs.SleepyEgg] = {
        id = 3,
        name = "Sleepy Egg",
        price = 125,
        enabled = true,
        pets = {
            [14] = 0.423,
            [18] = 0.283,
            [19] = 0.167,
            [20] = 0.113,
            [24] = 0.011,
            [25] = 0.003
        }
    },
    [Eggs.AngelEgg] = {
        id = 4,
        name = "Angel Egg",
        price = 1100,
        enabled = true,
        pets = {
            [21] = 0.481,
            [22] = 0.438,
            [26] = 0.039,
            [27] = 0.026,
            [28] = 0.012,
            [29] = 0.004
        }
    }
    -- [Eggs.RobuxEgg] = {
    --     id = 5,
    --     name = "Robux Egg",
    --     price = 0,
    --     enabled = false,
    --     pets = {
    --         [30] = 0.32,
    --         [31] = 0.26,
    --         [32] = 0.2,
    --         [33] = 0.12,
    --         [34] = 0.08,
    --         [35] = 0.02
    --     }
    -- }
}


-- local eggPets = {
--     [Eggs.BasicEgg] = {
--         [1] = 0.35,
--         [2] = 0.242,
--         [3] = 0.181,
--         [4] = 0.126,
--         [5] = 0.078,
--         [6] = 0.023
--     }
-- }


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
    if eggs[eggId] then
        local petOdds : {[number] : number} = eggs[eggId].pets
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