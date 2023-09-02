local Rewards = {}

local ServerScriptService = game:GetService("ServerScriptService")
local Types = require(ServerScriptService:WaitForChild("Types"))

export type Reward = {
    reward : string,
    value : number | string | Types.potion
}

--[[
    Returns a random reward based on the tier of reward the player can collect

    @param rewardToCollect : number, the tier of the reward (120, 300, 600...)
    @return Reward, the table containing the information about the reward
]]--
function Rewards.GetReward(rewardToCollect : number) : Reward
    if rewardToCollect == 60 then
        return {reward = "followers", value = 1_000}
    elseif rewardToCollect == 120 then
        return {reward = "coins", value = 10}
    elseif rewardToCollect == 300 then
        return {reward = "followers", value = 10_000}
    elseif rewardToCollect == 600 then
        return {reward = "potion", value = {type = 0, value = 2, duration = 10}}
    elseif rewardToCollect == 900 then
        return {reward = "coins", value = 100}
    elseif rewardToCollect == 1_200 then
        return {reward = "pet", value = ""}
    elseif rewardToCollect == 1_800 then
        return {reward = "followers", value = 75_000}
    elseif rewardToCollect == 2_700 then
        return {reward = "coins", value = 475}
    elseif rewardToCollect == 3_600 then
        return {reward = "potion", value = {type = 1, value = 3, duration = 20}}
    elseif rewardToCollect == 5_400 then
        return {reward = "followers", value = 300_000}
    elseif rewardToCollect == 7_200 then
        return {reward = "coins", value = 2_000}
    elseif rewardToCollect == 10_800 then
        return {reward = "potion", value = {type = 3, value = 5, duration = 30}}
    else
        return {reward = "followers", value = 1_000} -- default reward
    end
end


return Rewards