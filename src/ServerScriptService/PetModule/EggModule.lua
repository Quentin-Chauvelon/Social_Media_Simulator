
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
            [0] = {
                [0] = 0.35,
                [1] = 0.242,
                [2] = 0.181,
                [6] = 0.126,
                [10] = 0.078,
                [15] = 0.023
            },
            [1] = {
                [0] = 0.315,
                [1] = 0.217,
                [2] = 0.163,
                [6] = 0.136,
                [10] = 0.105,
                [15] = 0.062
            },
            [2] = {
                [0] = 0.312,
                [1] = 0.216,
                [2] = 0.161,
                [6] = 0.123,
                [10] = 0.083,
                [15] = 0.102
            }
        }
    },
    [Eggs.CryingEgg] = {
        id = 1,
        name = "Crying Egg",
        price = 4,
        enabled = true,
        pets = {
            [0] = {
                [3] = 0.375,
                [4] = 0.323,
                [7] = 0.226,
                [11] = 0.042,
                [12] = 0.028,
                [16] = 0.006
            },
            [1] = {
                [3] = 0.343,
                [4] = 0.295,
                [7] = 0.248,
                [11] = 0.057,
                [12] = 0.038,
                [16] = 0.016
            },
            [2] = {
                [3] = 0.353,
                [4] = 0.304,
                [7] = 0.234,
                [11] = 0.047,
                [12] = 0.031,
                [16] = 0.028
            }
        }
    },
    [Eggs.LoveEgg] = {
        id = 2,
        name = "Love Egg",
        price = 20,
        enabled = true,
        pets = {
            [0] = {
                [5] = 0.426,
                [8] = 0.263,
                [9] = 0.222,
                [13] = 0.058,
                [17] = 0.026,
                [23] = 0.005
            },
            [1] = {
                [5] = 0.353,
                [8] = 0.261,
                [9] = 0.221,
                [13] = 0.072,
                [17] = 0.065,
                [23] = 0.029
            },
            [2] = {
                [5] = 0.332,
                [8] = 0.225,
                [9] = 0.190,
                [13] = 0.054,
                [17] = 0.101,
                [23] = 0.097
            }
        }
    },
    [Eggs.SleepyEgg] = {
        id = 3,
        name = "Sleepy Egg",
        price = 125,
        enabled = true,
        pets = {
            [0] = {
                [14] = 0.423,
                [18] = 0.283,
                [19] = 0.167,
                [20] = 0.113,
                [24] = 0.011,
                [25] = 0.003
            },
            [1] = {
                [14] = 0.262,
                [18] = 0.351,
                [19] = 0.207,
                [20] = 0.140,
                [24] = 0.032,
                [25] = 0.009
            },
            [2] = {
                [14] = 0.138,
                [18] = 0.385,
                [19] = 0.227,
                [20] = 0.154,
                [24] = 0.075,
                [25] = 0.020
            }
        }
    },
    [Eggs.AngelEgg] = {
        id = 4,
        name = "Angel Egg",
        price = 1100,
        enabled = true,
        pets = {
            [0] = {
                [21] = 0.481,
                [22] = 0.438,
                [26] = 0.039,
                [27] = 0.026,
                [28] = 0.012,
                [29] = 0.004
            },
            [1] = {
                [21] = 0.434,
                [22] = 0.395,
                [26] = 0.082,
                [27] = 0.055,
                [28] = 0.025,
                [29] = 0.008
            },
            [2] = {
                [21] = 0.363,
                [22] = 0.331,
                [26] = 0.147,
                [27] = 0.098,
                [28] = 0.045,
                [29] = 0.015
            }
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


export type EggModule = {
    new : () -> EggModule,
    GetEggPrice : (eggId : number) -> number,
    GetRandomPetForEgg : (eggId : number, luck : number) -> number?,
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
    @param luck : number, the id of the player's luck (0 = none, 1 = basic luck, 2 = golden luck)
    @return pet, the id of the randomly selected pet
]]--
function EggModule.GetRandomPetForEgg(eggId : number, luck : number) : number?
    if eggs[eggId] then
        local petOdds : {[number] : number} = eggs[eggId].pets[luck]
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