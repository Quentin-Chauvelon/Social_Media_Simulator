local Rewards = {}

local rewards : {[number] : {[number] : {[string] : string | number}}} = {
    [120] = {
        [35] = {reward = "followers", value = 100},
        [25] = {reward = "coins", value = 10},
        [20] = {reward = "followers", value = 200},
        [10] = {reward = "coins", value = 20},
        [6] = {reward = "coins", value = 50},
        [4] = {reward = "followers", value = 500}
    }
}

-- reward ideas : followers, coins, temporary boosters (different times), temporary upgrades...


--[[
    Returns a random reward based on the tier of reward the player can collect

    @param rewardToCollect : number, the tier of the reward (120, 300, 600...)
    @return {[string] : number} | nil, the table containing the information about the reward
]]--
function Rewards.GetReward(rewardToCollect : number) : {[string] : string | number}
    if rewards[rewardToCollect] then
        local weight : number = 0
        local randomNumber : number = math.random(1,100)

        for chance, reward in pairs(rewards[rewardToCollect]) do
            weight += chance

            if weight >= randomNumber then
                return reward
            end
        end
    end

    return {reward = "followers", value = 100} -- default reward
end


return Rewards