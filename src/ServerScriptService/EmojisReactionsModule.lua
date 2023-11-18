local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ServerScriptService:WaitForChild("Types"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))

local UnlockEmojiReactionRE : RemoteEvent = ReplicatedStorage:WaitForChild("UnlockEmojiReaction")

local displayPets : Folder = ReplicatedStorage:WaitForChild("DisplayPets")


export type EmojisReactionsModule = {
    emojiReactionBillboardGui : BillboardGui,
    inCooldown : boolean,
    lastEmojiTime : number,
    unlockedEmojis : {string},
    cooldownPromise : Promise.Promise,
    plr : Player,
    new : (p : Types.PlayerModule) -> EmojisReactionsModule,
    DisplayEmoji : (self : EmojisReactionsModule, emojiName : string) -> nil,
    UnlockEmoji : (self : EmojisReactionsModule, emojiName : string) -> nil,
}

local COOLDOWN_DURATION : number = 8


local EmojisReactionsModule : EmojisReactionsModule = {}
EmojisReactionsModule.__index = EmojisReactionsModule


function EmojisReactionsModule.new(p : Types.PlayerModule)
    local emojisReactionsModule = setmetatable({}, EmojisReactionsModule)

    emojisReactionsModule.emojiReactionBillboardGui = p.player.PlayerGui:WaitForChild("EmojiReactionBillboardGui")
    emojisReactionsModule.inCooldown = false
    emojisReactionsModule.lastEmojiTime = os.time()

    emojisReactionsModule.unlockedEmojis = {
        TearsOfJoy = false,
        Grinning = false,
        Flushed = false,
        ROFL = false,
        Crying = false,
        Smiling = false,
        Winking = false,
        SmilingEyes = false,
        Sweat = false,
        Nerd = false,
        RollingEyes = false,
        HeartEyes = false,
        Hugging = false,
        Pensive = false,
        Thinking = false,
        Hearts = false,
        Squinting = false,
        Fear = false,
        ThumbsUp = false,
        Swearing = false,
        UpsideDown = false,
        FoldedHands = false,
        OK = false,
        PurpleHeart = false,
        Clapping = false,
        Sleeping = false,
        Sunglasses = false,
        Party = false,
        Angel = false,
        Poo = false,
        Hundred = false,
        Fire = false,
        PartyPopper = false,
        RedHeart = false,
        Devil = false,
        Money = false
    }

    for _,ownedPet in pairs(p.petModule.ownedPets) do
        emojisReactionsModule.unlockedEmojis[ownedPet.identifier] = true
    end

    emojisReactionsModule.cooldownPromise = nil

    emojisReactionsModule.plr = p.player

    return emojisReactionsModule
end


--[[
    Displays the emoji over the player's head
]]--
function EmojisReactionsModule:DisplayEmoji(emojiName : string)
    -- if the cooldown is not over, don't display the emoji
    if self.inCooldown then
        -- sometimes self.inCooldown is true even if the cooldownPromise is resolved
        if self.lastEmojiTime + COOLDOWN_DURATION + 1 < os.time() then
            return
        end
    end

    -- if the emoji is not unlocked, don't display the emoji
    if not self.unlockedEmojis[emojiName] then return end

    self.inCooldown = true
    self.lastEmojiTime = os.time()

    -- disable the VIP tag while the emoji is displayed ff the player is VIP
    local head : Part? = self.plr.Character and self.plr.Character:FindFirstChild("Head")
    if head then
        if head:FindFirstChild("VIPTag") then
            head.VIPTag.Enabled = false
        end
    end

    -- clone the pet and display it
    local petClone : Model? = displayPets:FindFirstChild(emojiName):Clone()
    if not petClone then
        self.inCooldown = false
        return
    end

    petClone.Parent = self.emojiReactionBillboardGui.Background.Emoji
    self.emojiReactionBillboardGui.Enabled = true

    -- wait for the cooldown to be over
    self.cooldownPromise = Promise.new(function(resolve)
        task.wait(COOLDOWN_DURATION)
        resolve()
    end)
    :finally(function()
        self.inCooldown = false

        self.emojiReactionBillboardGui.Enabled = false
        petClone:Destroy()

        if head then
            if head:FindFirstChild("VIPTag") then
                head.VIPTag.Enabled = true
            end
        end
    end)
end


--[[
    Unlocks the specified emojis for the player.

    @param emojisNames : {string}, A table containing the names of the emojis to unlock.
]]--
function EmojisReactionsModule:UnlockEmojis(emojisNames : {string})
    for _,emojiName in pairs(emojisNames) do
        self.unlockedEmojis[emojiName] = true
    end

    UnlockEmojiReactionRE:FireClient(self.plr, emojisNames)
end


return EmojisReactionsModule