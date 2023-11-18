local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(script.Parent:WaitForChild("Utility"))
local Maid = require(ReplicatedStorage:WaitForChild("Maid"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))

local EmojiReactionRE : RemoteEvent = ReplicatedStorage:WaitForChild("EmojiReaction")

local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local emojisReactionsOpenButton : ImageButton = playerGui:WaitForChild("Menu"):WaitForChild("SideButtons"):WaitForChild("EmojisReactionsButton")
local emojisReactionsOpenButtonCover : Frame = playerGui.Menu.SideButtons.EmojisReactionsButton:WaitForChild("Cover")
local emojisReactionsOpenButtonCoverUIGradient : UIGradient = emojisReactionsOpenButtonCover:WaitForChild("UIGradient")

local emojisReactionsGui : ScreenGui = playerGui:WaitForChild("EmojisReactions")
local emojisReactionsBackground : Frame = emojisReactionsGui:WaitForChild("Background")
local emojisReactionsCloseButton : TextButton = emojisReactionsBackground:WaitForChild("Close")
local recentsContainer : Frame = emojisReactionsBackground:WaitForChild("RecentsContainer")
local recentsContainerUIListLayout : UIListLayout = recentsContainer:WaitForChild("UIListLayout")
local emojisContainer : ScrollingFrame = emojisReactionsBackground:WaitForChild("EmojisContainer")
local emojisContainerUIGridLayout : UIGridLayout = emojisContainer:WaitForChild("UIGridLayout")

local COOLDOWN_DURATION : number = 8 * 60


export type EmojisReactionsModule = {
    inCooldown : boolean,
    lastUsedEmojiName : string,
    cooldownPromise : Promise.Promise,
    emojisReactionsMaid : Maid.Maid,
    utility : Utility.Utility,
    new : (utility : Utility.Utility) -> EmojisReactionsModule,
    UnlockEmojis : (self : EmojisReactionsModule, emojis : {string}) -> nil,
    ClickedEmoji : (self : EmojisReactionsModule, emojiName : string) -> nil,
    IsEmojiInRecents : (self : EmojisReactionsModule, emojiName : string) -> boolean,
    AddToRecents : (self : EmojisReactionsModule, emojiName : string) -> nil,
    AreRecentsFull : (self : EmojisReactionsModule) -> boolean,
    DestroyOverflowingEmojis : (self : EmojisReactionsModule) -> nil,
    StartCooldown : (self : EmojisReactionsModule) -> nil,
    OpenGui : (self : EmojisReactionsModule) -> nil,
    CloseGui : (self : EmojisReactionsModule) -> nil,
}


local EmojisReactionsModule : EmojisReactionsModule = {}
EmojisReactionsModule.__index = EmojisReactionsModule


function EmojisReactionsModule.new(utility : Utility.Utility)
    local emojisReactionsModule = setmetatable({}, EmojisReactionsModule)

    emojisReactionsModule.inCooldown = false
    emojisReactionsModule.lastUsedEmojiName = ""

    emojisReactionsModule.cooldownPromise = nil
    emojisReactionsModule.emojisReactionsMaid = Maid.new()

    emojisReactionsModule.utility = utility

    -- store all UIStroke in a table to change them easily later
    local emojisReactionsGuiUIStroke : {UIStroke} = {}
    for _,v : Instance in ipairs(emojisReactionsBackground:GetDescendants()) do
        if v:IsA("UIStroke") then
            table.insert(emojisReactionsGuiUIStroke, v)
        end
    end

    utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
        local emojiReactionSizeY : number = recentsContainer.AbsoluteSize.Y
        emojisContainerUIGridLayout.CellSize = UDim2.new(0, emojiReactionSizeY, 0, emojiReactionSizeY)

        -- auto resize padding to make the emojis take the whole width of the container
        local emojisPerRow : number = 0
        while (emojisPerRow + 3) * emojiReactionSizeY < emojisContainer.AbsoluteSize.X do
            emojisPerRow += 1
        end
        emojisContainerUIGridLayout.CellPadding = UDim2.new(0, (emojisContainer.AbsoluteSize.X - (emojisPerRow * emojiReactionSizeY)) / (emojisPerRow - 1) - 10, 0.15, 0)

        local thickness : number = utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 2, 5)
        for _,uiStroke : UIStroke in pairs(emojisReactionsGuiUIStroke) do
            uiStroke.Thickness = thickness
        end

        if emojisReactionsModule:AreRecentsFull() then
            emojisReactionsModule:DestroyOverflowingEmojis()
        end
    end)

    table.insert(utility.guisToClose, emojisReactionsBackground)

    emojisReactionsOpenButton.MouseButton1Down:Connect(function()
        if not emojisReactionsModule.inCooldown then
            emojisReactionsModule:OpenGui()
        end
    end)

    return emojisReactionsModule
end


--[[
    Unlocks the specified emojis.

    @param emojis : {string}, A table containing the names of the emojis to unlock.
]]--
function EmojisReactionsModule:UnlockEmojis(emojis : {string})
    for _,emoji in pairs(emojis) do
        if emojisContainer:FindFirstChild(emoji) then
            local emojiFrame : ImageButton = emojisContainer[emoji]
            emojiFrame.AutoButtonColor = true
            emojiFrame.Locked.Value = false
            emojiFrame.LockedCover.Visible = false
            emojiFrame.LayoutOrder = 1 + emojiFrame.Rarity.Value
        end
    end
end


--[[
    This function is called when an emoji is clicked.
    It fires a remote event to react with the specified emoji,
    adds the emoji to the recent list and starts the cooldown

    @param emojiName : string, The name of the clicked emoji.
]]--
function EmojisReactionsModule:ClickedEmoji(emojiName : string)
    EmojiReactionRE:FireServer(emojiName)

    self:CloseGui()

    if self.lastUsedEmojiName ~= emojiName then
        self:AddToRecents(emojiName)
    end

    self:StartCooldown()

    self.lastUsedEmojiName = emojiName
end


--[[
    Checks if the specified emoji is present in the recents container.

    @param emojiName : string, The name of the emoji to check.
    @return boolean, Returns true if the emoji is found in the recents container, false otherwise.
]]--
function EmojisReactionsModule:IsEmojiInRecents(emojiName : string) : boolean
    for _,emoji : GuiObject in ipairs(recentsContainer:GetChildren()) do
        if emoji.Name == emojiName then
            return true
        end
    end

    return false
end


--[[
    Adds the specified emoji to the recents container.
    If the emoji is already in the recents, it moves it to the first position.
    If the recents container is full, it removes the oldest emoji before adding the new one.

    @param emojiName : string, The name of the emoji to add to the recents.
]]--
--[[

]]--
function EmojisReactionsModule:AddToRecents(emojiName : string)
    if self:IsEmojiInRecents(emojiName) then
        for _,emoji : GuiObject in ipairs(recentsContainer:GetChildren()) do
            if emoji:IsA("ImageButton") then
                if emoji.Name == emojiName then
                    emoji.LayoutOrder = 1
                else
                    emoji.LayoutOrder += 1
                end
            end
        end

    else
        -- increase the layout orders of all emojis to make space for the new one + find the oldest emoji used to remove it if the recents are full
        for _,emoji : GuiObject in ipairs(recentsContainer:GetChildren()) do
            if emoji:IsA("ImageButton") then
                emoji.LayoutOrder += 1
            end
        end

        -- create the new emoji
        if emojisContainer:FindFirstChild(emojiName) then
            local emojiClone : ImageButton = emojisContainer[emojiName]:Clone()
            emojiClone.Size = UDim2.new(1,0,1,0)
            emojiClone.LayoutOrder = 1
            emojiClone.Parent = recentsContainer
        end

        if self:AreRecentsFull() then
            self:DestroyOverflowingEmojis()
        end
    end
end


--[[
    Checks if the recents container is full.
    The recents container is considered full if its content width exceeds the width of the container itself.

    @return boolean, true if the recents container is full, false otherwise.
]]--
function EmojisReactionsModule:AreRecentsFull() : boolean
    -- minus 1 because there is a UIListLayout that shouldn't be counted
    return recentsContainerUIListLayout.AbsoluteContentSize.X > recentsContainer.AbsoluteSize.X
end


--[[
    Destroys overflowing emojis in the recentsContainer.
]]--
function EmojisReactionsModule:DestroyOverflowingEmojis()
    for _,emoji : GuiObject in ipairs(recentsContainer:GetChildren()) do
        if emoji:IsA("ImageButton") then
            if (emoji.AbsolutePosition.X - recentsContainer.AbsolutePosition.X) + emoji.AbsoluteSize.X > recentsContainer.AbsoluteSize.X then
                emoji:Destroy()
            end
        end
    end
end


--[[
    This function starts the cooldown for the emojis reactions module.
]]--
function EmojisReactionsModule:StartCooldown()
    self.cooldownPromise = Promise.new(function(resolve)
        self.inCooldown = true

        emojisReactionsOpenButtonCover.Visible = true

        for i=COOLDOWN_DURATION - 1, 1, -1 do
            emojisReactionsOpenButtonCoverUIGradient.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0.2),
                NumberSequenceKeypoint.new((i - 1) / COOLDOWN_DURATION, 0.2),
                NumberSequenceKeypoint.new(i / COOLDOWN_DURATION, 1),
                NumberSequenceKeypoint.new(1, 1),
            }

            RunService.Heartbeat:Wait()
        end

        resolve()
    end)
    :andThen(function()
        self.cooldownPromise = nil

        emojisReactionsOpenButtonCover.Visible = false
        self.inCooldown = false
    end)
end


--[[
    Opens the emojis reactions gui
]]--
function EmojisReactionsModule:OpenGui()
    -- open the gui
    if self.utility.OpenGui(emojisReactionsBackground) then

        for _,emojiReactionButton : GuiObject in ipairs(recentsContainer:GetChildren()) do
            if emojiReactionButton:IsA("ImageButton") then

                self.emojisReactionsMaid:GiveTask(
                    emojiReactionButton.MouseButton1Down:Connect(function()
                        self:ClickedEmoji(emojiReactionButton.Name)
                    end)
                )
            end
        end

        for _,emojiReactionButton : GuiObject in ipairs(emojisContainer:GetChildren()) do
            if emojiReactionButton:IsA("ImageButton") and not emojiReactionButton.Locked.Value then

                self.emojisReactionsMaid:GiveTask(
                    emojiReactionButton.MouseButton1Down:Connect(function()
                        self:ClickedEmoji(emojiReactionButton.Name)
                    end)
                )
            end
        end

        -- set the close gui connection (only do it if the gui was not already open, otherwise multiple connection exist and it is called multiple times)
        self.utility.SetCloseGuiConnection(emojisReactionsCloseButton, function()
            self:CloseGui()
        end)
    end
end


--[[
    Closes the emojis reactions gui
]]--
function EmojisReactionsModule:CloseGui()
    self.emojisReactionsMaid:DoCleaning()

    self.utility.CloseGui(emojisReactionsBackground)
end


return EmojisReactionsModule