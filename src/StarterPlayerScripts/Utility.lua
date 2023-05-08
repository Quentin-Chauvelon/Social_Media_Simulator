local Utility = {}

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
local notificationImage : ImageLabel = notification:WaitForChild("Image")
local notificationClose : TextButton = notification:WaitForChild("Close")
local notificationUIPadding : UIPadding = notification:WaitForChild("UIPadding")

local uiToResize = {}
local debounce = true


function Utility.new()
    Utility.ResizeUIOnWindowResize(function()
        notification.Size = UDim2.new(Utility.GetNumberInRangeProportionallyDefaultWidth(currentCamera.ViewportSize.X, 0.45, 0.2), 0, 0.1, 0)
        notification.Position = UDim2.new(1, notification.AbsoluteSize.X + 10, 0, 20)
        
        local iconSize : number = Utility.GetNumberInRangeProportionallyDefaultWidth(currentCamera.ViewportSize.X, 20, 40)
        local iconUDim : UDim = UDim.new(0, iconSize)
        notificationImage.Size = UDim2.new(iconUDim, iconUDim)
        notificationClose.Size = UDim2.new(iconUDim, iconUDim)

        notificationUIPadding.PaddingLeft = UDim.new(0, 20 + iconSize)
        notificationUIPadding.PaddingRight = UDim.new(0, 35 + iconSize)
        notificationImage.Position = UDim2.new(0, -notificationUIPadding.PaddingLeft.Offset + 10, 0.5, 0)
        notificationClose.Position = UDim2.new(1, notificationUIPadding.PaddingRight.Offset - 15, 0.5, 0)

        notification.TextSize = iconSize * 0.625
    end)

    InformationNotificationRE.OnClientEvent:Connect(function(text :string, duration : number)
        Utility:DisplayInformation(text, duration)
    end)

    ErrorNotificationRE.OnClientEvent:Connect(function(text :string, duration : number)
        Utility:DisplayError(text, duration)
    end)
end


--[[
	Blur the background and displays a semi-transparent white frame in the background (it helps have
	a better focus on the displayed gui)
	
	@param visible : boolean, true if the ui should be displayed, false otherwise
]]--
function Utility.BlurBackground(enabled : boolean)
	blurEffect.Enabled = enabled
	blurWhiteBackground.Enabled = enabled
end


--[[
    Add a function to the uiToResize table so it can be updated when the window is resized

    @param func : function, the function to run when the window is resized
]]--
function Utility.ResizeUIOnWindowResize(func)
    func()

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

        for _,func in pairs(uiToResize) do
            func()
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

    notification.Size = UDim2.new(notification.Size.X, UDim.new(0, math.max(textSize.Y + 20, notificationClose.AbsoluteSize.Y + 20)))
    notification.Text = text

    if not notification.Visible then
        
        notification.Visible = true
        notification:TweenPosition(
            UDim2.new(1, 10, 0, 20),
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Quad,
            0.3
        )

        Promise.new(function(resolve)
            local notificationCloseConnection : RBXScriptSignal
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


function Utility:DisplayInformation(text : string, duration : number)
    notification.BackgroundColor3 = Color3.fromRGB(175, 213, 240)
    notificationImage.ImageColor3 = Color3.fromRGB(97, 154, 240)
    notificationClose.BackgroundColor3 = Color3.fromRGB(97, 154, 240)

    DisplayNotification(text, duration)
end


function Utility:DisplayError(text : string, duration : number)
    notification.BackgroundColor3 = Color3.fromRGB(255, 79, 79)
    notificationImage.ImageColor3 = Color3.new(1,1,1)
    notificationClose.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

    DisplayNotification(text, duration)
end


return Utility