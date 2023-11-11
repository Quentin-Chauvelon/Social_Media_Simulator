local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage:WaitForChild("Promise"))
local Utility = require(script.Parent:WaitForChild("Utility"))


local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local petsScreenGui : ScreenGui = playerGui:WaitForChild("Pets")
local limitedEditionPetsBackground : Frame = petsScreenGui:WaitForChild("LimitedEditionPetsBackground")
local closeButton : TextButton = limitedEditionPetsBackground:WaitForChild("Close")
local limitedEditionTimeLeft : TextLabel = limitedEditionPetsBackground:WaitForChild("TimeLeft")
local offersContainer : ScrollingFrame = limitedEditionPetsBackground:WaitForChild("OffersContainer")


local touchDetector : Part = workspace:WaitForChild("LimitedEditionPets"):WaitForChild("TouchDetector")
local limitedEditionPetsBillboardGuiTitle : TextLabel = workspace.LimitedEditionPets.TouchDetector:WaitForChild("BillboardGui"):WaitForChild("TextLabel")

local OFFER_END_TIME = os.time({year = 2023, month = 11, day = 25, hour = 23, min = 59, sec = 59})


export type LimitedEditionPetsModule = {
    buyPetButtonConnection : {RBXScriptSignal},
    timeLeftPromise : Promise.Promise,
    utility : Utility.Utility,
    new : (utility : Utility.Utility) -> LimitedEditionPetsModule,
    StartTimer : (self : LimitedEditionPetsModule) -> nil,
    OpenGui : (self : LimitedEditionPetsModule) -> nil,
    CloseGui : (self : LimitedEditionPetsModule) -> nil,
}


local LimitedEditionPetsModule : LimitedEditionPetsModule = {}
LimitedEditionPetsModule.__index = LimitedEditionPetsModule


function LimitedEditionPetsModule.new(utility : Utility.Utility)
    local limitedEditionPetsModule : LimitedEditionPetsModule = {}
    setmetatable(limitedEditionPetsModule, LimitedEditionPetsModule)

    limitedEditionPetsModule.buyPetButtonConnection = {}

    limitedEditionPetsModule.utility = utility


    -- open the gui on part touched
    touchDetector.Touched:Connect(function(hit : BasePart)
        if hit.Parent and hit.Name == "HumanoidRootPart" then
            if Players:GetPlayerFromCharacter(hit.Parent) == lplr then
                limitedEditionPetsModule:OpenGui()
            end
        end
    end)


    -- close the gui on part touch ended
    touchDetector.TouchEnded:Connect(function(hit : BasePart)
        if hit.Parent and hit.Name == "HumanoidRootPart" then
            if Players:GetPlayerFromCharacter(hit.Parent) == lplr then
                limitedEditionPetsModule:CloseGui()
            end
        end
    end)


    -- store all UIStroke in a table to change them easily later
    local limitedEditionPetsUIStroke : {UIStroke} = {}
    for _,v : Instance in ipairs(limitedEditionPetsBackground:GetDescendants()) do
        if v:IsA("UIStroke") then
            table.insert(limitedEditionPetsUIStroke, v)
        end
    end

    utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
        local thickness : number = utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 2, 5)
        for _,uiStroke : UIStroke in pairs(limitedEditionPetsUIStroke) do
            uiStroke.Thickness = thickness
        end
    end)

    -- rainbow color cycle effect on the group chest billboard gui title
    coroutine.wrap(function()
        while true do
            for i=0,1,0.01 do
                limitedEditionPetsBillboardGuiTitle.TextColor3 = Color3.fromHSV(i,0.67,1)

                for _=1,10 do
                    RunService.Heartbeat:Wait()
                end
            end
        end
    end)()

    return limitedEditionPetsBackground
end


--[[
    Opens the gui
]]--
function LimitedEditionPetsModule:OpenGui()
    if not limitedEditionPetsBackground.Visible then

        -- the ui doesn't have a size of 0 because it is kept at a normal size (this allows the ui to be able to be resized even when it's hidden (if the player resizes it's game window))
        local upgradesOriginalSize : UDim2 = limitedEditionPetsBackground.Size
        limitedEditionPetsBackground.Size = UDim2.new(0,0,0,0)

        self.utility.BlurBackground(true)

        limitedEditionPetsBackground.Visible = true

        limitedEditionPetsBackground:TweenSize(
            upgradesOriginalSize,
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Linear,
            0.2
        )


        -- listen to the clicks on the buy button
        for _,offer : GuiObject in ipairs(offersContainer:GetChildren()) do
            if offer:IsA("ImageLabel") then

                -- if the player clicks the buy button, prompt the purchase to buy the pet
                table.insert(self.buyPetButtonConnection,
                    offer.CaseRobuxBuyButton.MouseButton1Down:Connect(function()
                        MarketplaceService:PromptProductPurchase(lplr, offer.ProductId.Value)
                    end)
                )
            end
        end

        -- start the time left timer
        self:StartTimer()

        local upgradesCloseConnection : RBXScriptConnection
        upgradesCloseConnection = closeButton.MouseButton1Down:Connect(function()
            upgradesCloseConnection:Disconnect()
            self:CloseGui()
        end)
    end
end


--[[
    Closes the gui
]]--
function LimitedEditionPetsModule:CloseGui()
    for _,buyPetButtonConnection : RBXScriptConnection in pairs(self.buyPetButtonConnection) do
        buyPetButtonConnection:Disconnect()
    end
    table.clear(self.buyPetButtonConnection)

    self.utility.BlurBackground(false)

    if limitedEditionPetsBackground.Visible then
        local upgradesOriginalSize : UDim2 = limitedEditionPetsBackground.Size

        limitedEditionPetsBackground:TweenSize(
            UDim2.new(0,0,0,0),
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Linear,
            0.2,
            false,
            function()
                limitedEditionPetsBackground.Visible = false
                limitedEditionPetsBackground.Size = upgradesOriginalSize
            end
        )
    end
end


--[[
    Starts the timer that counts the time left before the offer ends
]]--
function LimitedEditionPetsModule:StartTimer()
    self.timeLeftPromise = Promise.new(function(resolve)

        while limitedEditionPetsBackground.Visible do
            local timeLeft : number = os.difftime(OFFER_END_TIME, os.time())
            limitedEditionTimeLeft.Text = string.format("%0.2id %0.2ih %0.2im %0.2is", timeLeft / 86400, (timeLeft / 3600) % 24, (timeLeft / 60) % 60, timeLeft % 60)

            task.wait(1)
        end

        resolve()
    end)
end


return LimitedEditionPetsModule