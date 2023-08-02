local ServerScriptService = game:GetService("ServerScriptService")

local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))

DataStore2.Combine("SMS", "rebirth")

local followersNeededToRebirth : {number} = {
    100,
    225,
    375,
    550,
    900,
    1500,
    2100,
    3000,
    4250,
    5600,
    7300,
    9700,
    12500,
    16000,
    21000,
    28000,
    34000,
    41000,
    49000,
    63500,
    75500,
    87000,
    100000,
    116500,
    133500,
    152000,
    172500,
    194500,
    218800,
    265500,
    296000,
    330000,
    364000,
    403000,
    444000,
    487000,
    534500,
    584500,
    637000,
    747000,
    811000,
    879000,
    951000,
    1027000,
    1107000,
    1191500,
    1280000,
    1373500,
    1471500,
    1687000,
    1802000,
    1923000,
    2049500,
    2181500,
    2319500,
    2463500,
    2613500,
    2770000,
    293300,
    3310000,
    3497000,
    3692500,
    3895000,
    4106000,
    4324000,
    4550000,
    4785000,
    5028000,
    5280000,
    5886000,
    6172000,
    6467000,
    6772500,
    7087500,
    7413000,
    7748000,
    8095500,
    8451000,
    8819000,
    9738500,
    10151500,
    10576500,
    11013000,
    11464000,
    11926500,
    12402000,
    12890000,
    13392000,
    13908000,
    15239500,
    15813000,
    16401000,
    17005000,
    17624000,
    18258500,
    18909000,
    19575500,
    20258000,
    20957500,
    22814000
}


export type RebirthModule = {
    rebirthLevel : number,
    followersMultiplier : number,
    followersNeededToRebirth : number,
    new : (plr : Player) -> RebirthModule,
    TryRebirth : (self : RebirthModule, followers : number, plr : Player) -> boolean,
    Rebirth : (self : RebirthModule, plr : Player) -> boolean,
    UpdateFollowersNeededToRebirth : (self : RebirthModule) -> number
}


local RebirthModule : RebirthModule = {}
RebirthModule.__index = RebirthModule


function RebirthModule.new(plr : Player) : RebirthModule
    local rebirthModule : RebirthModule = {}

    rebirthModule.rebirthLevel = DataStore2("rebirth", plr):Get(0)
    rebirthModule.followersMultiplier = rebirthModule.rebirthLevel / 10

    return setmetatable(rebirthModule, RebirthModule)
end


function RebirthModule:TryRebirth(followers : number, plr : Player) : boolean
    if followers >= self.followersNeededToRebirth then
        return self:Rebirth(plr)
    end

    return false
end


function RebirthModule:Rebirth(plr : Player) : boolean
    self.rebirthLevel += 1

    -- save the new rebirth level for the player
    DataStore2("rebirth", plr):Increment(1)

    plr.Stats.Rebirth.Value += 1

    -- update the rebirth followers multiplier
    self.followersMultiplier = self.rebirthLevel / 10

    -- update the number of followers needed to rebirth the next time
    self:UpdateFollowersNeededToRebirth()

    return true
end


function RebirthModule:UpdateFollowersNeededToRebirth()
    local nextRebirthLevel : number = self.rebirthLevel + 1

    if followersNeededToRebirth[nextRebirthLevel] then
        self.followersNeededToRebirth = followersNeededToRebirth[nextRebirthLevel]
    else
        self.followersNeededToRebirth = 1000 * math.round((2.35085 * (math.pow(nextRebirthLevel, 3.34297)) + 359.514) * (1 + math.floor(nextRebirthLevel / 10) / 10) / 1000)
    end
end


return RebirthModule