local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(script.Parent:WaitForChild("Utility"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))
local GamePassModule = require(script.Parent:WaitForChild("GamePassModule"))

local OpenEggRF : RemoteFunction = ReplicatedStorage:WaitForChild("OpenEgg")

local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local eggsScreenGui : ScreenGui = playerGui:WaitForChild("Eggs")

local petsScreenGui : ScreenGui = playerGui:WaitForChild("Pets")
local eggOpeningBackground : Frame = petsScreenGui:WaitForChild("EggOpeningBackground")
local oneEggContainer : Frame = eggOpeningBackground:WaitForChild("OneEgg")
local threeEggContainer : Frame = eggOpeningBackground:WaitForChild("ThreeEggs")
local sixEggContainer : Frame = eggOpeningBackground:WaitForChild("SixEggs")

local displayPets : Folder = ReplicatedStorage:WaitForChild("DisplayPets")


export type PetModule = {
    ownedPets : {pet},
    canOpenEgg : boolean,
    closeEggSequenceInputConnection : RBXScriptSignal?,
    new : (utility : Utility.Utility) -> PetModule,
    PlayEggOpeningSequence : (self : PetModule, eggSequenceContainer : Frame, pets : {pet}) -> nil,
    CloseEggOpeningSequence : (self : PetModule, eggSequenceContainer : Frame) -> nil
}

export type pet = {
    identifier : string,
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
        color = Color3.fromRGB(198, 212, 223)
    },
    [1] = {
        name = "Uncommon",
        color = Color3.fromRGB(90, 164, 255)
    },
    [2] = {
        name = "Rare",
        color = Color3.fromRGB(6, 231, 2)
    },
    [3] = {
        name = "Epic",
        color = Color3.fromRGB(210, 30, 255)
    },
    [4] = {
        name = "Legendary",
        color = Color3.fromRGB(255, 159, 25)
    },
    [5] = {
        name = "Mystical",
        color = Color3.fromRGB(80, 8, 125)
    }
}


local PetModule : PetModule = {}
PetModule.__index = PetModule


function PetModule.new(utility : Utility.Utility)
    local petModule : PetModule = {}

    petModule.ownedPets = {}

    petModule.canOpenEgg = true

    petModule.closeEggSequenceInputConnection = nil

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
                    
                    -- if the player doesn't own the 3x or 6x open eggs game passes, prompt them to pruchase it
                    if openEggButton.NumberOfEggs.Value == 3 then
                        -- if the player doesn't already own the game pass
                        if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.OpenThreeEggs) then
                            -- prompt the purhcase to buy it
                            GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.OpenThreeEggs)
                            return
                        end

                    elseif openEggButton.NumberOfEggs.Value == 6 then
                        -- if the player doesn't already own the game pass
                        if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.OpenSixEggs) then
                            -- prompt the purhcase to buy it
                            GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.OpenSixEggs)
                            return
                        end
                    end

                    if petModule.canOpenEgg then
                        petModule.canOpenEgg = false

                        -- fire the server to get random pets
                        local openedPets : {pet} = OpenEggRF:InvokeServer(openEggButton.Parent.EggId.Value, openEggButton.NumberOfEggs.Value)

                        -- add all the pets to the owned pets table
                        for _,pet : pet in pairs(openedPets) do
                            table.insert(petModule.ownedPets, pet)
                        end

                        -- play the right egg opening sequence based on the number of pets the player got
                        if #openedPets == 1 then
                            petModule:PlayEggOpeningSequence(oneEggContainer, openedPets)
                        elseif #openedPets == 3 then
                            petModule:PlayEggOpeningSequence(threeEggContainer, openedPets)
                        elseif #openedPets == 6 then
                            petModule:PlayEggOpeningSequence(sixEggContainer, openedPets)
                        else
                            -- if petModule:PlayEggOpeningSequence hasn't been called, set can open egg to true to release the debounce and allow the player to re-open eggs
                            petModule.canOpenEgg = true
                        end
                    end
                end)
            end
        end
    end

    return setmetatable(petModule, PetModule)
end


--[[
    Plays the egg opening sequence

    @param eggSequenceContainer : Frame, the frame containing all the eggs on which to play the opening sequence
    @param pets : {pet}, the pets to show in the sequence
]]--
function PetModule:PlayEggOpeningSequence(eggSequenceContainer : Frame, pets : {pet})

    self.canOpenEgg = false

    for i : number, eggContainer : GuiObject in ipairs(eggSequenceContainer:GetChildren()) do
        if eggContainer:IsA("Frame") then
            eggOpeningBackground.Visible = true
            eggSequenceContainer.Visible = true

            local pet : pet = pets[i]

            -- clone the pet to the viewport frame's world model to display it after the egg explodes
            local petClone : Model
            if displayPets:FindFirstChild(pet.identifier) then
                petClone = displayPets[pet.identifier]:Clone()
                petClone.Parent = eggContainer.ViewportFrame.WorldModel
            end

            local eggImage : ImageLabel = eggContainer.EggImage

            eggImage.Visible = true

            -- scale the egg up from 0 to its normal size
            local scaleEggUp : Tween = TweenService:Create(
                eggImage,
                TweenInfo.new(
                    0.2
                ),
                {Size = UDim2.new(0.7, 0, 0.7, 0)}
            )

            -- rotate the egg left 70°
            local rotateEggLeft : Tween = TweenService:Create(
                eggImage,
                TweenInfo.new(
                    0.15,
                    Enum.EasingStyle.Linear
                ),
                {Rotation = -70}
            )

            -- shake the egg multiple times from left to right
            local shakeEgg : Tween = TweenService:Create(
                eggImage,
                TweenInfo.new(
                    0.15,
                    Enum.EasingStyle.Linear,
                    Enum.EasingDirection.InOut,
                    4,
                    true
                ),
                {Rotation = 70}
            )

            -- reset the orientation of the egg back to 0°
            local resetEggOrientation : Tween = TweenService:Create(
                eggImage,
                TweenInfo.new(
                    0.15,
                    Enum.EasingStyle.Linear
                ),
                {Rotation = 0}
            )

            -- explode the egg to reveal the pet
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

            -- turn the pet around to face the camera
            local turnPetAround : Tween = TweenService:Create(
                petClone.PrimaryPart,
                TweenInfo.new(
                    0.5
                ),
                {CFrame = CFrame.fromOrientation(0,0,0)}
            )

            -- wrap the sequence in a promise, so that we can open multiple eggs at once (only useful for x3 and x6 open eggs game passes)
            Promise.new(function(resolve)
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

                -- reveal the pet
                eggContainer.ViewportFrame.Visible = true

                -- get the name and color of the rarity based on the id
                local rarity : rarity = rarities[pet.rarity]

                -- update the pet's information
                eggContainer.PetInformation.PetName.Text = pet.name
                eggContainer.PetInformation.Rarity.Text = rarity.name
                eggContainer.PetInformation.Rarity.TextColor3 = rarity.color

                turnPetAround:Play()
                turnPetAround.Completed:Wait()

                task.wait(0.5)

                eggContainer.PetInformation.Visible = true

                local canvasGroupTransparencyTween : Tween = TweenService:Create(
                    eggContainer.PetInformation,
                    TweenInfo.new(
                        1,
                        Enum.EasingStyle.Linear
                    ),
                    {GroupTransparency = 0}
                )

                canvasGroupTransparencyTween:Play()
                canvasGroupTransparencyTween.Completed:Wait()

                -- close and reset the egg opening sequence on screen click/touch
                if not self.closeEggSequenceInputConnection then
                    self.closeEggSequenceInputConnection = UserInputService.InputBegan:Connect(function(input)

                        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                            self.closeEggSequenceInputConnection:Disconnect()
                            self.closeEggSequenceInputConnection = nil

                            -- close and reset the egg opening sequence
                            self:CloseEggOpeningSequence(eggSequenceContainer)
                        end
                    end)
                end

                resolve()
            end)
        end
    end
end


--[[
    Closes and resets the egg opening sequence

    @param eggSequenceContainer : Frame, the frame containing all the eggs on which to play the opening sequence
]]--
function PetModule:CloseEggOpeningSequence(eggSequenceContainer : Frame)

    eggOpeningBackground.Visible = false
    eggSequenceContainer.Visible = false

    for _,eggContainer : GuiObject in ipairs(eggSequenceContainer:GetChildren()) do
        if eggContainer:IsA("Frame") then

            eggContainer.EggImage.Visible = false
            eggContainer.EggImage.Size = UDim2.new(0,0,0,0)
            eggContainer.EggImage.ImageTransparency = 0

            eggContainer.ViewportFrame.Visible = false
            local petClone : Model = eggContainer.ViewportFrame.WorldModel:FindFirstChildOfClass("Model")
            if petClone then
                petClone:Destroy()
            end

            eggContainer.PetInformation.Visible = false
            eggContainer.PetInformation.GroupTransparency = 1
        end
    end

    self.canOpenEgg = true
end


return PetModule