local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(script.Parent:WaitForChild("Utility"))

local OpenEggRF : RemoteFunction = ReplicatedStorage:WaitForChild("OpenEgg")

local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local eggsScreenGui : ScreenGui = playerGui:WaitForChild("Eggs")

local petsScreenGui : ScreenGui = playerGui:WaitForChild("Pets")
local eggOpeningBackground : Frame = petsScreenGui:WaitForChild("EggOpeningBackground")
local eggImage : ImageLabel = eggOpeningBackground:WaitForChild("Egg")
local eggViewportFrame : ViewportFrame = eggOpeningBackground:WaitForChild("ViewportFrame")
local petInformation : CanvasGroup = eggOpeningBackground:WaitForChild("PetInformation")
local eggPetName : TextLabel = petInformation:WaitForChild("PetName")
local eggpetRarity : TextLabel = petInformation:WaitForChild("Rarity")

local displayPets : Folder = ReplicatedStorage:WaitForChild("DisplayPets")


-- tweens
local scaleEggUp : Tween = TweenService:Create(
    eggImage,
    TweenInfo.new(
        0.2
    ),
    {Size = UDim2.new(0.7, 0, 0.7, 0)}
)

local rotateEggLeft : Tween = TweenService:Create(
    eggImage,
    TweenInfo.new(
        0.15,
        Enum.EasingStyle.Linear
    ),
    {Rotation = -70}
)


local resetEggOrientation : Tween = TweenService:Create(
    eggImage,
    TweenInfo.new(
        0.15,
        Enum.EasingStyle.Linear
    ),
    {Rotation = 0}
)


local shakeEgg : Tween = TweenService:Create(
    eggImage,
    TweenInfo.new(
        0.15,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.InOut,
        3,
        true
    ),
    {Rotation = 70}
)

local explodeEgg : Tween = TweenService:Create(
    eggImage,
    TweenInfo.new(
        0.2,
        Enum.EasingStyle.Quad
    ),
    {
        Size = UDim2.new(3,0,3,0),
        ImageTransparency = 1
    }
)


export type PetModule = {
    ownedPets : {pet},
    canOpenEgg : boolean,
    new : (utility : Utility.Utility) -> PetModule,
    PlayEggOpeningSequence : (self : PetModule, pets : {pet}) -> nil,
    CloseEggOpeningSequence : (self : PetModule) -> nil
}

export type pet = {
    name : string,
    rarity : number,
    size : number,
    upgrade : number,
    baseBoost : number,
    activeBoost : number,
    equipped : boolean
}

type rarity = {
    name : string,
    color : Color3
}


local rarities : {[number] : rarity} = {
    [0] = {
        name = "Common",
        color = Color3.fromRGB(122, 171, 235)
    }
}


local PetModule : PetModule = {}
PetModule.__index = PetModule


function PetModule.new(utility : Utility.Utility)
    local petModule : PetModule = {}

    petModule.ownedPets = {}

    -- store all UIStroke in a table to change them easily later
    local eggsGuiUIStroke : {UIStroke} = {}
    for _,v : Instance in ipairs(eggsScreenGui:GetDescendants()) do
        if v:IsA("UIStroke") then
            table.insert(eggsGuiUIStroke, v)
        end
    end

    utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
        local thickness : number = utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 2, 5)
        for _,uiStroke : UIStroke in pairs(eggsGuiUIStroke) do
            uiStroke.Thickness = thickness
        end
    end)

    -- for each button of each egg, fire the server to open the egg
    for _,eggGui : ScreenGui in ipairs(eggsScreenGui:GetChildren()) do
        for _,openEggButton : GuiObject in ipairs(eggGui.Background.OpenEggContainer:GetChildren()) do
            if openEggButton:IsA("ImageButton") then

                -- tweens to scale the button up and down on mouse enter and mouse leave
                local mouseEnterTween : Tween = TweenService:Create(
                    openEggButton.UIScale,
                    TweenInfo.new(
                        0.15,
                        Enum.EasingStyle.Quad,
                        Enum.EasingDirection.InOut
                    ),
                    {Scale = 1.1}
                )

                local mouseLeaveTween : Tween = TweenService:Create(
                    openEggButton.UIScale,
                    TweenInfo.new(
                        0.15,
                        Enum.EasingStyle.Quad,
                        Enum.EasingDirection.InOut
                    ),
                    {Scale = 1}
                )

                -- scale the button up on mouse enter
                openEggButton.MouseEnter:Connect(function()
                    mouseEnterTween:Play()
                end)
                
                -- scale the button down on mouse leave
                openEggButton.MouseLeave:Connect(function()
                    mouseLeaveTween:Play()
                end)
                

                -- open an egg when the player clicks the button
                openEggButton.MouseButton1Down:Connect(function()
                    local openedPets : {pet} = OpenEggRF:InvokeServer(openEggButton.Parent.EggId.Value, openEggButton.NumberOfEggs.Value)
                    
                    for _,pet : pet in pairs(openedPets) do
                        table.insert(petModule.openedPets, pet)
                    end

                    petModule:PlayEggOpeningSequence(openedPets)
                end)
            end
        end
    end

    return setmetatable(petModule, PetModule)
end


--[[
    Plays the egg opening sequence

    @param pets : {pet}, the pets to show in the sequence
]]--
function PetModule:PlayEggOpeningSequence(pets : {pet})
    self.canOpenEgg = false

    local petName = pets[1].name
    local petClone : Model
    if displayPets:FindFirstChild(petName) then
        petClone = displayPets[petName]:Clone()
        petClone.Parent = eggViewportFrame.WorldModel
    end

    eggOpeningBackground.Visible = true
    
    eggImage.Visible = true
    scaleEggUp:Play()
    scaleEggUp.Completed:Wait()

    rotateEggLeft:Play()
    rotateEggLeft.Completed:Wait()

    shakeEgg:Play()
    shakeEgg.Completed:Wait()

    resetEggOrientation:Play()
    resetEggOrientation.Completed:Wait()

    explodeEgg:Play()
    explodeEgg.Completed:Wait()

    eggImage.Visible = false

    eggViewportFrame.Visible = true

    eggPetName.Text = petName

    local rarity : rarity = rarities[pets[1].rarity]
    eggpetRarity.Text = rarity.name
    eggpetRarity.TextColor3 = rarity.color

    TweenService:Create(
        petClone.PrimaryPart,
        TweenInfo.new(
            0.5
        ),
        {CFrame = CFrame.fromOrientation(0,0,0)}
    ):Play()

    task.wait(1)

    petInformation.Visible = true

    -- close and reset the egg opening sequence on screen click/touch
    local inputConnection : RBXScriptSignal
    inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent then
            
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                inputConnection:Disconnect()

                -- close and reset the egg opening sequence
                self:CloseEggOpeningSequence()
            end
        end
    end)

    TweenService:Create(
        petInformation,
        TweenInfo.new(
            1,
            Enum.EasingStyle.Linear
        ),
        {GroupTransparency = 0}
    ):Play()
end


--[[
    Closes and resets the egg opening sequence
]]--
function PetModule:CloseEggOpeningSequence()
    eggOpeningBackground.Visible = false

    eggImage.Visible = false
    eggImage.Size = UDim2.new(0,0,0,0)
    eggImage.ImageTransparency = 0

    eggViewportFrame.Visible = false
    local petClone : Model = eggViewportFrame.WorldModel:FindFirstChildOfClass("Model")
    if petClone then
        petClone:Destroy()
    end

    petInformation.Visible = false
    petInformation.GroupTransparency = 1

    self.canOpenEgg = true
end


return PetModule