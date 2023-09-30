
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage:WaitForChild("Promise"))

local InformationNotificationRE : RemoteEvent = ReplicatedStorage:WaitForChild("InformationNotification")
local ErrorNotificationRE : RemoteEvent = ReplicatedStorage:WaitForChild("ErrorNotification")

local lplr = Players.LocalPlayer
local playerGui : PlayerGui = lplr.PlayerGui
local currentCamera : Camera = workspace.CurrentCamera

local blurEffect : BlurEffect = game:GetService("Lighting"):WaitForChild("Blur")
local blurWhiteBackground : ScreenGui = playerGui:WaitForChild("BackgroundBlur")

local notification : TextLabel = playerGui:WaitForChild("Menu"):WaitForChild("Notification")
local notificationType : TextLabel = notification:WaitForChild("Type")
local notificationClose : TextButton = notification:WaitForChild("Close")
local notificationUIPadding : UIPadding = notification:WaitForChild("UIPadding")

local dingSound : Sound = game:GetService("SoundService"):WaitForChild("Ding")

local uiToResize : {(viewportSize : Vector2) -> nil} = {}
local debounce : boolean = true
local openGuiDebounce : boolean = true


local NUMBER_ABBREVIATIONS : {[string] : number} = {["k"] = 4,["M"] = 7,["B"] = 10,["T"] = 13,["Qa"] = 16,["Qi"] = 19}


export type Utility = {
    guisToClose : {GuiObject},
    closeGuiConnection : RBXScriptConnection?,
    new : () -> nil,
    BlurBackground : (enabled : boolean) -> nil,
    ResizeUIOnWindowResize : ((viewportSize : Vector2) -> nil) -> nil,
    GetNumberInRangeProportionally : (a : number, X : number, b : number, minRange : number, maxRange : number) -> number,
    GetNumberInRangeProportionallyDefaultWidth : (X : number, minRange : number, maxRange : number) -> number,
    GetNumberInRangeProportionallyDefaultHeight : (X : number, minRange : number, maxRange : number) -> number,
    DisplayInformation : (text : string, duration : number) -> nil,
    DisplayError : (text : string, duration : number) -> nil,
    PlayDingSound : () -> nil,
    OpenGui : (ui : GuiObject, duration : number?) -> boolean,
    SetCloseGuiConnection : (closeConnection : RBXScriptConnection) -> nil,
    CloseGui : (ui : GuiObject, duration : number?) -> nil,
    CloseAllGuis : () -> boolean,
    AbbreviateNumber : (number : number) -> string
}


local Utility : Utility = {}

Utility.guisToClose = {}

function Utility.new()
    Utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
        notification.Size = UDim2.new(Utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 0.45, 0.2), 0, 0.1, 0)
        notification.Position = UDim2.new(1, notification.AbsoluteSize.X + 10, 0, 20)
        
        local iconSize : number = Utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 20, 40)
        local iconUDim : UDim = UDim.new(0, iconSize)
        notificationType.Size = UDim2.new(iconUDim, iconUDim)
        notificationClose.Size = UDim2.new(iconUDim, iconUDim)

        notificationUIPadding.PaddingLeft = UDim.new(0, 20 + iconSize)
        notificationUIPadding.PaddingRight = UDim.new(0, 35 + iconSize)
        notificationType.Position = UDim2.new(0, -notificationUIPadding.PaddingLeft.Offset + 10, 0.5, 0)
        notificationClose.Position = UDim2.new(1, notificationUIPadding.PaddingRight.Offset - 15, 0.5, 0)

        notification.TextSize = iconSize * 0.625
    end)

    InformationNotificationRE.OnClientEvent:Connect(function(text :string, duration : number)
        Utility.DisplayInformation(text, duration)
    end)

    ErrorNotificationRE.OnClientEvent:Connect(function(text :string, duration : number)
        Utility.DisplayError(text, duration)
    end)
end


--[[
	Blur the background and displays a semi-transparent white frame in the background (it helps have
	a better focus on the displayed gui)
	
	@param enabled : boolean, true if the ui should be displayed, false otherwise
]]--
function Utility.BlurBackground(enabled : boolean)
	blurEffect.Enabled = enabled
	blurWhiteBackground.Enabled = enabled
end


--[[
    Add a function to the uiToResize table so it can be updated when the window is resized

    @param func : function, the function to run when the window is resized
]]--
function Utility.ResizeUIOnWindowResize(func : (viewportSize : Vector2) -> nil)
    func(currentCamera.ViewportSize)

    table.insert(uiToResize, func)
end


--[[
    Get a number between minRange and maxRange based on a and b proportionally.
    Example : 
        a = 1920, X = ?, b = 480, minRange = 0.5, maxRange = 0.8.
        Given 1920 -> 0.5 and 480 -> 0.8, what would the result be if X = 1200 ?
        1200 is the average of 1920 and 480, so proportionally our result would be 0.65 (the average of 0.5 and 0.8)
        But then it becomes harder to find the result when X = 783 for example.
    This is usually useful when calculating gui sizes based on screen size.
    For example if we want our gui to have an Size.X.Scale of 0.5 when the screen size is 1920 and 0.8 when the screen size 480. This will
    then be helpful to calculate any value in between by passing the parameters as follow : (0.5, 0.8, X, 480, 1920)

    @return number, the result
]]--
function Utility.GetNumberInRangeProportionally(a : number, X : number, b : number, minRange : number, maxRange : number) : number
    -- if X is lower or higher than minRange and maxRange, then we don't need to calculate and only return the right value
    if X <= a then return minRange end
    if X >= b then return maxRange end

    return (((X - a) / (b - a)) * (maxRange - minRange) + minRange)
end


--[[
    @see Utility.GetNumberInRangeProportionally
    Calculate the X between minRange and maxRange proportionally using 480 and 1920 as a and b

    @return number, the result
    ]]--
function Utility.GetNumberInRangeProportionallyDefaultWidth(X : number, minRange : number, maxRange : number) : number
    return Utility.GetNumberInRangeProportionally(480, X, 1920, minRange, maxRange)
end


--[[
    @see Utility.GetNumberInRangeProportionally
    Calculate the X between minRange and maxRange proportionally using 480 and 1920 as a and b
    
    @return number, the result
]]--
function Utility.GetNumberInRangeProportionallyDefaultHeight(X : number, minRange : number, maxRange : number) : number
    return Utility.GetNumberInRangeProportionally(320, X, 1080, minRange, maxRange)
end


--[[
    Run all the functions in the uiToResize table when the window is resized (mainly used to resize the ui on scren size change)
]]--
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if debounce then
        debounce = false
        task.wait(1)

        local viewportSize : Vector2 = currentCamera.ViewportSize

        for _,func : (viewportSize : Vector2) -> nil in pairs(uiToResize) do
            func(viewportSize)
        end

        debounce = true
    end
end)


--[[
    Display the given text on the right upper hand of the screen for the given duration 

    @param text : string, the text to display
    @param duration : number?, the duration in seconds for how long the text should be displayed or default (8)
]]--
local function DisplayNotification(text : string, duration : number)

    local textSize : Vector2 = TextService:GetTextSize(text, notification.TextSize, Enum.Font.SourceSansBold, Vector2.new(notification.AbsoluteSize.X, 2000))

    notification.Size = UDim2.new(notification.Size.X, UDim.new(0, math.max(textSize.Y + 20, notificationClose.AbsoluteSize.Y + 40)))
    notification.Text = text

    if not notification.Visible then
        
        notification.Visible = true
        notification:TweenPosition(
            UDim2.new(1, 10, 0, 20),
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Quad,
            0.3
        )

        return

        Promise.new(function(resolve)
            local notificationCloseConnection : RBXScriptConnection
            notificationCloseConnection = notificationClose.MouseButton1Down:Connect(function()
                notificationCloseConnection:Disconnect()
                resolve()
            end)
            
            task.wait(duration or 8)

            resolve()
        end)
        :andThen(function()
            notification:TweenPosition(
            UDim2.new(1, notification.AbsoluteSize.X + 10, 0, 20),
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Quad,
            0.3,
            true,
            function()
                notification.Visible = false
            end
        )
        end)
    end
end


function Utility.DisplayInformation(text : string, duration : number)
    notification.BackgroundColor3 = Color3.fromRGB(107, 158, 240)
    notification.BorderUIStroke.Color = Color3.fromRGB(56, 84, 125)
    notification.ContextualUIStroke.Color = Color3.fromRGB(56, 84, 125)

    notificationType.BackgroundColor3 = Color3.fromRGB(56, 84, 125)
    notificationType.Text = "!"

    notificationClose.TextColor3 = Color3.fromRGB(56, 84, 125)
    notificationClose.UIStroke.Color = Color3.fromRGB(56, 84, 125)

    DisplayNotification(text, duration)
end


function Utility.DisplayError(text : string, duration : number)
    notification.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    notification.BorderUIStroke.Color = Color3.fromRGB(126, 0, 0)
    notification.ContextualUIStroke.Color = Color3.fromRGB(126, 0, 0)

    notificationType.BackgroundColor3 = Color3.fromRGB(126, 0, 0)
    notificationType.Text = "X"

    notificationClose.TextColor3 = Color3.fromRGB(126, 0, 0)
    notificationClose.UIStroke.Color = Color3.fromRGB(126, 0, 0)

    DisplayNotification(text, duration)
end


function Utility.PlayDingSound()
    dingSound:Play()
end


--[[
    Tweens a gui to open it (from 0,0 to X,Y)

    @param ui : GuiObject, the ui to tween
    @param duration : number?, the duration of the tween or nil (0.2)
    @return boolean, true if the gui has been opened, false if it was already open
]]
function Utility.OpenGui(ui : GuiObject, duration : number?) : boolean
    if not ui.Visible then
        if openGuiDebounce then
            openGuiDebounce = false

            -- close all guis before opening one
            -- if one of them was opened, we wait for it to close before opening another one
            if Utility.CloseAllGuis() then
                task.wait(0.2)
            end
            
            -- the ui doesn't have a size of 0 because it is kept at a normal size (this allows the ui to be able to be resized even when it's hidden (if the player resizes it's game window))
            local uiOriginalSize : UDim2 = ui.Size
            ui.Size = UDim2.new(0,0,0,0)
            
            Utility.BlurBackground(true)

            ui.Visible = true
            
            ui:TweenSize(
                uiOriginalSize,
                Enum.EasingDirection.InOut,
                Enum.EasingStyle.Linear,
                duration or 0.2,
                false,
                function()
                    openGuiDebounce = true
                end
            )

            return true
        end
    end

    return false
end


--[[
    Sets the gui connection to disconnect when closing the gui

    @param closeConnection : RBXScriptConnection, the connection
]]
function Utility.SetCloseGuiConnection(closeConnection : RBXScriptConnection)
    if not Utility.closeGuiConnection then
        Utility.closeGuiConnection = closeConnection
    end
end


--[[
    Tweens a gui to close it (from X,Y to 0,0)

    @param ui : GuiObject, the ui to tween
    @param duration : number?, the duration of the tween or nil (default: 0.2)
]]
function Utility.CloseGui(ui : GuiObject, duration : number?)
    
    if ui.Visible then
        local upgradesOriginalSize : UDim2 = ui.Size
        
        Utility.BlurBackground(false)

        ui:TweenSize(
            UDim2.new(0,0,0,0),
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Linear,
            duration or 0.2,
            false,
            function()
                ui.Visible = false
                ui.Size = upgradesOriginalSize
                
                -- disconnect the close gui connection
                if Utility.closeGuiConnection then
                    Utility.closeGuiConnection:Disconnect()
                    Utility.closeGuiConnection = nil
                end
            end
        )
    end
end


--[[
    Tweens all guis from the Utility.guisToClose table to close them (from X,Y to 0,0)
]]
function Utility.CloseAllGuis() : boolean
    local wasOneGuiOpened : boolean = false

    for _,ui : GuiObject in pairs(Utility.guisToClose) do
        if ui.Visible then
            wasOneGuiOpened = true
            Utility.CloseGui(ui)
        end
    end

    return wasOneGuiOpened
end


--[[
    Abbreviates the given number (ex: 1000 -> 1k, 1500000 -> 1.5M...)

    @see https://devforum.roblox.com/t/how-to-make-1-000-000-become-1m-in-text/1969945/3
    @param number : number, the number to abbreviate
    @return string, the abbreviated number
]]--
function Utility.AbbreviateNumber(number : number) : string
    local text : string = tostring(string.format("%.f",math.floor(number)))
        
    local chosenAbbreviation : string
        for abbreviation : string, digit : number in pairs(NUMBER_ABBREVIATIONS) do
            if (#text >= digit and #text < (digit + 3)) then
                chosenAbbreviation = abbreviation
                break
        end
    end
    
    if (chosenAbbreviation and chosenAbbreviation ~= 0) then
        local digits : number = NUMBER_ABBREVIATIONS[chosenAbbreviation]
        
        local rounded : number = math.floor(number / 10 ^  (digits - 2)) * 10 ^  (digits - 2)
        return string.format("%.1f", rounded / 10 ^ (digits - 1)) .. chosenAbbreviation
    else
        return tostring(number)
    end
end


return Utility