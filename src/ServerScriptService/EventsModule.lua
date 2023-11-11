local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage:WaitForChild("Promise"))

local UpdateFollowersBE : BindableEvent = ServerStorage:WaitForChild("UpdateFollowers")
local UpdateCoinsBE : BindableEvent = ServerStorage:WaitForChild("UpdateCoins")

local TimeLeftBeforeEventStartRE : RemoteEvent = ReplicatedStorage:WaitForChild("TimeLeftBeforeEventStart")
local EventCountdownRE : RemoteEvent = ReplicatedStorage:WaitForChild("EventCountdown")
local UpdateNextEventRE : RemoteEvent = ReplicatedStorage:WaitForChild("UpdateNextEvent")
local StartEventRE : RemoteEvent = ReplicatedStorage:WaitForChild("StartEvent")
local CollectedEventCoinRE : RemoteEvent = ReplicatedStorage:WaitForChild("CollectedEventCoin")

local followersRainEventCoin : Part = ReplicatedStorage:WaitForChild("FollowersRainEventCoin")
local coinsRainEventCoin : Part = ReplicatedStorage:WaitForChild("CoinsRainEventCoin")

local rainEventCoins : Folder = workspace:WaitForChild("RainEventCoins")

local TOTAL_NUMBER_OF_COINS_TO_SPAWN : number = 300
local NUMBER_OF_COINS_TO_SPAWN_PER_SECOND : number = 10


local EventsModule : EventsModule = {}
EventsModule.__index = EventsModule

EventsModule.eventInProgress = false
EventsModule.nextEvent = nil
EventsModule.rewards = {}
EventsModule.eventsLoopPromise = nil


type Event = {
    id : number,
    name : string,
    duration : number,
    startEvent : () -> nil,
    backgroundColor : Color3,
    borderColor : Color3,
    progressBarColor : Color3,
    eventIcon : string
}

local events : {Event} = {}

export type EventsModule = {
    eventInProgress : boolean,
    nextEvent : Event,
    timeBeforeNextEvent : number,
    rewards : {[string] : number},
    eventsLoopPromise : Promise.Promise,
    new : () -> EventsModule,
    StartEventsLoop : () -> nil,
    GetNextEvent : () -> Event,
    SpawnCoin : (coin : Part) -> nil,
    CollectedCoin : (plr : Player) -> nil,
    StartRainEvent : (coin : Part) -> nil,
    StartFollowersRain : () -> nil,
    StartCoinsRain : () -> nil
}


--[[
    Starts the events loop, which continuously runs and updates clients on the status of upcoming events.
    The loop waits for specific intervals of time before updating clients with information such as the next event, time left before event start, and event countdown.
    Once an event starts, the loop waits until the event is over before continuing to the next event.
]]--
function EventsModule.StartEventsLoop()
    EventsModule.eventsLoopPromise = Promise.new(function()
        while true do
            EventsModule.nextEvent = EventsModule:GetNextEvent()

            task.wait(2)
            UpdateNextEventRE:FireAllClients(EventsModule.nextEvent)

            task.wait(15)
            TimeLeftBeforeEventStartRE:FireAllClients(10)

            task.wait(5 * 60)
            TimeLeftBeforeEventStartRE:FireAllClients(5)

            task.wait(3 * 60)
            TimeLeftBeforeEventStartRE:FireAllClients(2)

            task.wait(60)
            EventCountdownRE:FireAllClients("%s event will start in %d seconds", 60)

            task.wait(60)
            StartEventRE:FireAllClients()

            task.wait(2)
            EventsModule.eventInProgress = true
            EventsModule.nextEvent.startEvent()

            repeat
                task.wait(1)
            until not EventsModule.eventInProgress
        end
    end)
end


--[[
    Gets a random event from the list of available events and sets it as the next event to be played.

    @return Event, The next event to be played.
]]--
function EventsModule.GetNextEvent() : Event
    EventsModule.timeBeforeNextEvent = os.time() + 615

    return events[math.random(1, #events)]
end


--[[
    Spawns a coin at a random position within the map and detects when a player collects it.

    @param coin : Part, The Part to be cloned and used as the coin.
]]--
function EventsModule.SpawnCoin(coin : Part)
    local coinClone : Part = coin:Clone()

    local r : number = 175 * math.sqrt(math.random())
    local theta : number = math.random() * 2 * math.pi
    coinClone.Position = Vector3.new(
        4 + r * math.cos(theta), -- 4 is the x coordinate of the center of the map and 175 is the radius of the map
        coinClone.Position.Y,
        203 + r * math.sin(theta) -- 203 is the y coordinate of the center of the map and 175 is the radius of the map
    )

    coinClone.Parent = rainEventCoins

    coinClone.Touched:Connect(function(hit : BasePart)
        if hit.Parent and hit.Name == "HumanoidRootPart" then

            local plr : Player = Players:GetPlayerFromCharacter(hit.Parent)
            if plr then
                EventsModule.CollectedCoin(plr)
                coinClone:Destroy()
            end
        end
    end)
end


--[[
    Calculates the number of followers the player will gain from collecting a coin and updates their reward.
    And fires the client event to update the UI.

    @param plr : Player, The player who collected the coin.
]]--
function EventsModule.CollectedCoin(plr)
    local numberValueName : string = EventsModule.nextEvent.id == 1 and "AverageFollowersPerSecond" or "AverageCoinsPerSecond"

    -- Calculate the number of followers the player will gain from collecting the coin
    -- Take the average number of followers the player gains per second and multiply it by 600 (the number of seconds in 10 minutes) times 2 (to get higher numbers)
    -- Then multiply that by a random number between 0 and 2 to get a random number of followers gained (which averages at 1 but gives a little bit of variance)
    local gain : number = math.round((2 * (plr:FindFirstChild(numberValueName) and plr[numberValueName].Value or 1) * 600) / TOTAL_NUMBER_OF_COINS_TO_SPAWN * math.random() * 2)

    if gain < 1 then
        gain = 1
    end

    -- If the player has not collected any coins yet, initialize their reward to 0
    if not EventsModule.rewards[plr.Name] then
        EventsModule.rewards[plr.Name] = 0
    end

    EventsModule.rewards[plr.Name] += gain

    CollectedEventCoinRE:FireClient(plr, gain)
end


--[[
    Spawns multiple coins every seconds for a certain amount of time.
    At the end of the event, the coins are destroyed and the event is marked as over.
]]--
function EventsModule.StartRainEvent(coin : Part)
    for _=1, math.floor(TOTAL_NUMBER_OF_COINS_TO_SPAWN / NUMBER_OF_COINS_TO_SPAWN_PER_SECOND) do
        for _=1,NUMBER_OF_COINS_TO_SPAWN_PER_SECOND do
            EventsModule.SpawnCoin(coin)
        end

        task.wait(1)
    end

    task.wait(EventsModule.nextEvent.duration - math.floor(TOTAL_NUMBER_OF_COINS_TO_SPAWN / NUMBER_OF_COINS_TO_SPAWN_PER_SECOND))
    rainEventCoins:ClearAllChildren()
    EventsModule.eventInProgress = false
end


--[[
    Starts the followers rain event
    After the event, the rewards are given to each player.
]]--
function EventsModule.StartFollowersRain()
    EventsModule.StartRainEvent(followersRainEventCoin)

    for playerName : string, reward : number in pairs(EventsModule.rewards) do
        UpdateFollowersBE:Fire(playerName, reward)
    end
end


--[[
    Starts the coins rain event
    After the event, the rewards are given to each player.
]]--
function EventsModule.StartCoinsRain()
    EventsModule.StartRainEvent(coinsRainEventCoin)

    for playerName : string, reward : number in pairs(EventsModule.rewards) do
        UpdateCoinsBE:Fire(playerName, reward)
    end
end


events = {
    {
        id = 1,
        name = "Followers rain",
        duration = 60,
        startEvent = EventsModule.StartFollowersRain,
        backgroundColor = Color3.fromRGB(221, 142, 255),
        borderColor = Color3.fromRGB(80, 52, 93),
        progressBarColor = Color3.fromRGB(113, 74, 132),
        eventIcon = "http://www.roblox.com/asset/?id=14109181705"
    },
    {
        id = 2,
        name = "Coins rain",
        duration = 60,
        startEvent = EventsModule.StartCoinsRain,
        backgroundColor = Color3.fromRGB(255, 212, 52),
        borderColor = Color3.fromRGB(95, 79, 19),
        progressBarColor = Color3.fromRGB(161, 133, 31),
        eventIcon = "http://www.roblox.com/asset/?id=14109221821"
    }
}


return EventsModule