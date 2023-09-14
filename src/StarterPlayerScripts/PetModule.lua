local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(script.Parent:WaitForChild("Utility"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))
local Maid = require(ReplicatedStorage:WaitForChild("Maid"))
local GamePassModule = require(script.Parent:WaitForChild("GamePassModule"))

local OpenEggRF : RemoteFunction = ReplicatedStorage:WaitForChild("OpenEgg")
local EquipPetRF : RemoteFunction = ReplicatedStorage:WaitForChild("EquipPet")
local EquipBestPetsRF : RemoteFunction = ReplicatedStorage:WaitForChild("EquipBestPets")
local DeletePetRF : RemoteFunction = ReplicatedStorage:WaitForChild("DeletePet")

local displayPets : Folder = ReplicatedStorage:WaitForChild("DisplayPets")

local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local petsOpenButton : ImageButton = playerGui:WaitForChild("Menu"):WaitForChild("SideButtons"):WaitForChild("PetsButton")

local petTemplate : ImageButton = ReplicatedStorage:WaitForChild("PetTemplate")

local eggsScreenGui : ScreenGui = playerGui:WaitForChild("Eggs")
local petsScreenGui : ScreenGui = playerGui:WaitForChild("Pets")
local eggOpeningBackground : Frame = petsScreenGui:WaitForChild("EggOpeningBackground")
local oneEggContainer : Frame = eggOpeningBackground:WaitForChild("OneEgg")
local threeEggContainer : Frame = eggOpeningBackground:WaitForChild("ThreeEggs")
local sixEggContainer : Frame = eggOpeningBackground:WaitForChild("SixEggs")

local inventoryBackground : Frame = petsScreenGui:WaitForChild("InventoryBackground")
local inventoryCloseButton : ImageButton = inventoryBackground:WaitForChild("Close")
local inventoryPetsListContainer : ScrollingFrame = inventoryBackground:WaitForChild("PetsListContainer")
local equipBestButton : TextButton = inventoryBackground:WaitForChild("EquipBest")
local inventoryCraftAll : TextButton = inventoryBackground:WaitForChild("CraftAll")

local petDetails : Frame = inventoryBackground:WaitForChild("PetDetails")
local petDetailsName : TextLabel = petDetails:WaitForChild("PetName")
local petDetailsPetDisplay : ViewportFrame = petDetails:WaitForChild("PetDisplay")
local petDetailsBoost : TextLabel = petDetails:WaitForChild("Boost")
local petDetailsRarity : TextLabel = petDetails:WaitForChild("Rarity")
local petDetailsUpgrade : TextLabel = petDetails:WaitForChild("Upgrade")
local equipPetButton : TextButton = petDetails:WaitForChild("Equip")
local deletePetButton : TextButton = petDetails:WaitForChild("Delete")
local petDetailsSizeCraftRequirements : TextLabel = petDetails:WaitForChild("SizeCraftRequirements")
local petDetailsSizeCraftButton : TextButton = petDetails:WaitForChild("SizeCraft")
local petDetailsSizeCraftDisabled : TextLabel = petDetails:WaitForChild("SizeCraftDisabled")

local equippedPets : TextLabel = inventoryBackground:WaitForChild("InventoryLimits"):WaitForChild("MaxEquippedPets"):WaitForChild("EquippedPets")
local moreEquippedPetsButton : TextButton = inventoryBackground.InventoryLimits.MaxEquippedPets:WaitForChild("MoreEquippedPets")
local inventoryCapacity : TextLabel = inventoryBackground.InventoryLimits:WaitForChild("MaxInvetoryCapacity"):WaitForChild("InventoryCapacity")
local moreInventorySlotsButton : TextButton = inventoryBackground.InventoryLimits.MaxInvetoryCapacity:WaitForChild("MoreInvetorySlots")


export type PetModule = {
    ownedPets : {pet},
    currentlyEquippedPets : number,
    maxEquippedPets : number,
    maxInventoryCapacity : number,
    utility : Utility.Utility,
    selectedPet : number?,
    canOpenEgg : boolean,
    petsUIMaid : Maid.Maid,
    eggsMaid : Maid.Maid,
    closeEggSequenceInputConnection : RBXScriptSignal?,
    new : (utility : Utility.Utility) -> PetModule,
    PlayEggOpeningSequence : (self : PetModule, eggSequenceContainer : Frame, pets : {pet}) -> nil,
    CloseEggOpeningSequence : (self : PetModule, eggSequenceContainer : Frame) -> nil,
    CountNumberOfSamePets : (self : PetModule, identifier : string, size : number, upgrade : number) -> number,
    UpdateNumberOfEquippedPets : (self : PetModule) -> nil,
    UpdateUsedCapacity : (self : PetModule) -> nil,
    SelectPet : (self : PetModule, id : number) -> nil,
    UnselectPet : (self : PetModule) -> nil,
    AddPetToInventory : (self : PetModule, pet : pet) -> nil,
    AddPetsToInventory : (self : PetModule, pets : {pet}) -> nil,
    EquipPet : (self : PetModule) -> boolean,
    OpenGui : (self : PetModule) -> nil,
    CloseGui : (self : PetModule) -> nil,
}

export type pet = {
    id : number,
    identifier : string,
    name : string,
    rarity : number,
    size : number,
    upgrade : number,
    baseBoost : number,
    activeBoost : number,
    equipped : boolean,
    inventorySlot : ImageButton
}

type Rarities = {
    Common : number,
    Uncommon : number,
    Rare : number,
    Epic : number,
    Legendary : number,
    Mystical : number
}

type Upgrades = {
    None : number,
    Shiny : number,
    Rainbow : number,
    Magic : number
}

type Sizes = {
    Small : number,
    Big : number,
    Huge : number
}

type rarity = {
    name : string,
    color : Color3,
    border : Color3
}

type upgrade = {
    name : string,
    visible : boolean,
    color : Color3,
    border : Color3,
    gradient : boolean,
    gradientColor : ColorSequence,
    image : boolean,
    imageUrl : string
}


local Rarities : Rarities = {
    Common = 0,
    Uncommon = 1,
    Rare = 2,
    Epic = 3,
    Legendary = 4,
    Mystical = 5
}

local Upgrades : Upgrades = {
    None = 0,
    Shiny = 1,
    Rainbow = 2,
    Magic = 3
}

local Sizes : Sizes = {
    Small = 0,
    Big = 1,
    Huge = 2
}


local rarities : {[Rarities] : rarity} = {
    [Rarities.Common] = {
        name = "Common",
        color = Color3.fromRGB(198, 212, 223),
        border = Color3.fromRGB(75, 82, 85)
    },
    [Rarities.Uncommon] = {
        name = "Uncommon",
        color = Color3.fromRGB(90, 164, 255),
        border = Color3.fromRGB(41, 75, 117)
    },
    [Rarities.Rare] = {
        name = "Rare",
        color = Color3.fromRGB(116, 231, 108),
        border = Color3.fromRGB(59, 117, 55)
    },
    [Rarities.Epic] = {
        name = "Epic",
        color = Color3.fromRGB(224, 112, 255),
        border = Color3.fromRGB(97, 49, 112)
    },
    [Rarities.Legendary] = {
        name = "Legendary",
        color = Color3.fromRGB(255, 159, 25),
        border = Color3.fromRGB(120, 73, 12)
    },
    [Rarities.Mystical] = {
        name = "Mystical",
        color = Color3.fromRGB(80, 8, 125),
        border = Color3.new(0, 0, 0)
    }
}

local upgrades : {[Upgrades] : upgrade} = {
    [Upgrades.None] = {
        name = "",
        visible = false,
        color = Color3.new(1, 1, 1),
        border = Color3.new(0, 0, 0),
        gradient = false,
        gradientColor = ColorSequence.new(Color3.new(1, 1, 1)),
        image = false,
        imageUrl = ""
    },
    [Upgrades.Shiny] = {
        name = "Shiny",
        visible = true,
        color = Color3.fromRGB(255, 220, 80),
        border = Color3.fromRGB(97, 84, 30),
        gradient = true,
        gradientColor = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 80)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 248, 192)),
            ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 248, 192)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 80)),
        },
        image = false,
        imageUrl = ""
    },
    [Upgrades.Rainbow] = {
        name = "Rainbow",
        visible = true,
        color = Color3.new(1, 1, 1),
        border = Color3.fromRGB(74, 74, 74),
        gradient = true,
        gradientColor = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 92, 92)),
            ColorSequenceKeypoint.new(0.2, Color3.fromRGB(252, 255, 99)),
            ColorSequenceKeypoint.new(0.4, Color3.fromRGB(112, 255, 90)),
            ColorSequenceKeypoint.new(0.6, Color3.fromRGB(106, 243, 255)),
            ColorSequenceKeypoint.new(0.8, Color3.fromRGB(94, 110, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(244, 96, 255)),
        },
        image = false,
        imageUrl = ""
    },
    [Upgrades.Magic] = {
        name = "Magic",
        visible = true,
        color = Color3.new(1, 1, 1),
        border = Color3.fromRGB(12, 27, 57),
        gradient = false,
        gradientColor = ColorSequence.new(Color3.new(1, 1, 1)),
        image = true,
        imageUrl = "http://www.roblox.com/asset/?id=14740906060"
    },
}

local sizes : {[Sizes] : string} = {
    [Sizes.Small] = "",
    [Sizes.Big] = "Big",
    [Sizes.Huge] = "Huge",
}


local PetModule : PetModule = {}
PetModule.__index = PetModule


function PetModule.new(utility : Utility.Utility)
    local petModule : PetModule = {}

    petModule.ownedPets = {}

    petModule.currentlyEquippedPets = 0
    petModule.maxEquippedPets = 3
    petModule.maxInventoryCapacity = 50

    petModule.utility = utility

    petModule.selectedPet = nil

    petModule.canOpenEgg = true
    petModule.closeEggSequenceInputConnection = nil

    petModule.petsUIMaid = Maid.new()
    petModule.eggsMaid = Maid.new()

    -- store all UIStroke in a table to change them easily later
    local eggsGuiUIStroke : {UIStroke} = {}
    for _,v : Instance in ipairs(eggsScreenGui:GetDescendants()) do
        if v:IsA("UIStroke") then
            table.insert(eggsGuiUIStroke, v)
        end
    end

    -- store all UIStroke in a table to change them easily later
    local petsGuiUIStroke : {UIStroke} = {}
    for _,v : Instance in ipairs(petsScreenGui:GetDescendants()) do
        if v:IsA("UIStroke") then
            table.insert(petsGuiUIStroke, v)
        end
    end

    utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
        local NUMBER_OF_PETS_PER_ROW : number = 6

        -- resize the pets list frames (based on the size of the scrolling frame) so that they can space properly
        inventoryPetsListContainer.UIGridLayout.CellSize = UDim2.new(
            0,
            inventoryPetsListContainer.AbsoluteSize.X / (NUMBER_OF_PETS_PER_ROW + 2),
            0,
            inventoryPetsListContainer.AbsoluteSize.X / (NUMBER_OF_PETS_PER_ROW + 2)
        )

        inventoryPetsListContainer.UIGridLayout.CellPadding = UDim2.new(
            0,
            (inventoryPetsListContainer.UIGridLayout.CellSize.X.Offset - (inventoryPetsListContainer.AbsolutePosition.X - inventoryBackground.AbsolutePosition.X)) / NUMBER_OF_PETS_PER_ROW * 2, -- frames can overlap the scroll bar, so we want to leave a gap on the right (which must be the same as the one on the left, hence the substraction of positions)
            0,
            (inventoryPetsListContainer.UIGridLayout.CellSize.X.Offset - (inventoryPetsListContainer.AbsolutePosition.X - inventoryBackground.AbsolutePosition.X)) / NUMBER_OF_PETS_PER_ROW * 2
        )

        local thickness : number = utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 2, 5)
        for _,uiStroke : UIStroke in pairs(eggsGuiUIStroke) do
            uiStroke.Thickness = thickness
        end

        for _,uiStroke : UIStroke in pairs(petsGuiUIStroke) do
            uiStroke.Thickness = thickness
        end
    end)

    table.insert(utility.guisToClose, inventoryBackground)

    -- open the gui when clicking on the pets button
    petsOpenButton.MouseButton1Down:Connect(function()
        petModule:OpenGui()
    end)

    -- if the player is in the eggs area, the eggs gui can be shown + add the click connections...
    for _,part : Part in ipairs(workspace:WaitForChild("EggsAreaDetectionParts"):GetChildren()) do
        part.Touched:Connect(function(hit : BasePart)
            if hit.Parent and hit.Name == "HumanoidRootPart" then

                -- for each button of each egg
                for _,eggGui : BillboardGui in ipairs(eggsScreenGui:GetChildren()) do
                    eggGui.Enabled = true

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
                            petModule.eggsMaid:GiveTask(
                                openEggButton.MouseEnter:Connect(function()
                                    mouseEnterTween:Play()
                                end)
                            )

                            -- scale the button down on mouse leave
                            petModule.eggsMaid:GiveTask(
                                openEggButton.MouseLeave:Connect(function()
                                    mouseLeaveTween:Play()
                                end)
                            )


                            -- open an egg when the player clicks the button
                            petModule.eggsMaid:GiveTask(
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

                                        petModule:AddPetsToInventory(openedPets)
                                    end
                                end)
                            )
                        end
                    end
                end
            end
        end)


        -- when the player leaves the eggs area, disable the pets guis
        part.TouchEnded:Connect(function(hit : BasePart)
            if hit.Parent and hit.Name == "HumanoidRootPart" then
                local isInZone : boolean = false

                -- since touch ended fires somewhat randomly (when the player jumps for example), we want to check if the player is really not in the zone anymore
                for _,touchingPart : BasePart in ipairs(hit:GetTouchingParts()) do
                    if touchingPart == part then
                        isInZone = true
                        break
                    end
                end

                if not isInZone then
                    -- hide all the pets guis
                    for _,eggGui : BillboardGui in ipairs(eggsScreenGui:GetChildren()) do
                        eggGui.Enabled = false
                    end

                    petModule.eggsMaid:DoCleaning()
                end
            end
        end)
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


--[[
    Counts and returns the number of pets matching the given parameters

    @param identifier : string, the identifier of the pet
    @param size : number, the size of the pet
    @param upgrade : number, the upgrade applied to the pet
]]--
function PetModule:CountNumberOfSamePets(identifier : string, size : number, upgrade : number) : number
    local numberOfPets : number = 0

    for _,pet : pet in pairs(self.ownedPets) do
        if pet.identifier == identifier and pet.size == size and pet.upgrade == upgrade then
            numberOfPets += 1
        end
    end

    return numberOfPets
end


--[[
    Updates the number of equipped pets
]]--
function PetModule:UpdateNumberOfEquippedPets()
    equippedPets.Text = tostring(self.currentlyEquippedPets) .. "/" .. tostring(self.maxEquippedPets)
end


--[[
    Updates the inventory capacity
]]--
function PetModule:UpdateUsedCapacity()
    inventoryCapacity.Text = tostring(#self.ownedPets) .. "/" .. tostring(self.maxInventoryCapacity)
end


--[[
    Selects a pet matching the given parameters and display its details

    @param id : number, the id of the pet to select
]]--
function PetModule:SelectPet(id : number)
    for _,pet : pet in pairs(self.ownedPets) do
        if pet.id == id then

            local rarity : rarity = rarities[pet.rarity]
            local petSize : string = sizes[pet.size]
            local petUpgrade : upgrade = upgrades[pet.upgrade]

            petDetailsName.Text = petUpgrade.name .. " " .. petSize .. " " .. pet.name

            -- if there was already a pet displayed, destroy the model from the viewport frame
            if displayPets:FindFirstAncestorWhichIsA("Model") then
                displayPets:FindFirstAncestorWhichIsA("Model"):Destroy()
            end

            -- clone the model of the pet to the viewport frame
            local displayPet : Model = displayPets:FindFirstChild(pet.identifier)
            if displayPet then
                displayPet:Clone().Parent = petDetailsPetDisplay
            end

            petDetailsBoost.Text = "x" .. tostring(pet.activeBoost) .. " followers"

            petDetailsRarity.Text = rarity.name
            petDetailsRarity.BackgroundColor3 = rarity.color
            petDetailsRarity.BorderUIStroke.Color = rarity.border
            petDetailsRarity.ContextualUIStroke.Color = rarity.border

            -- display the upgrade if the pet has one
            if petUpgrade.visible then
                petDetailsUpgrade.Visible = true

                petDetailsUpgrade.UpgradeName.Text = petUpgrade.name:upper()
                petDetailsUpgrade.BackgroundColor3 = petUpgrade.color
                petDetailsUpgrade.BorderUIStroke.Color = petUpgrade.border
                petDetailsUpgrade.UpgradeName.ContextualUIStroke.Color = petUpgrade.border

                -- display the gradient if the upgrade should have a gradient
                if petUpgrade.gradient then
                    petDetailsUpgrade.UIGradient.Enabled = true
                    petDetailsUpgrade.UIGradient.Color = petUpgrade.gradientColor
                else
                    petDetailsUpgrade.UIGradient.Enabled = false
                end

                -- display the image if the upgrade should have an image
                if petUpgrade.image then
                    petDetailsUpgrade.ImageLabel.Visible = true
                    petDetailsUpgrade.ImageLabel.Image = petUpgrade.imageUrl
                else
                    petDetailsUpgrade.ImageLabel.Visible = false
                end
            else
                petDetailsUpgrade.Visible = false
            end

            if pet.equipped then
                equipPetButton.Text = "UNEQUIP"
                equipPetButton.BackgroundColor3 = Color3.fromRGB(250, 22, 22)
                equipPetButton.BorderUIStroke.Color = Color3.fromRGB(110, 8, 8)
                equipPetButton.ContextualUIStroke.Color = Color3.fromRGB(110, 8, 8)
            else
                equipPetButton.Text = "EQUIP"
                equipPetButton.BackgroundColor3 = Color3.fromRGB(109, 241, 99)
                equipPetButton.BorderUIStroke.Color = Color3.fromRGB(45, 97, 40)
                equipPetButton.ContextualUIStroke.Color = Color3.fromRGB(45, 97, 40)
            end

            local numberOfSamePets : number = self:CountNumberOfSamePets(pet.identifier, pet.size, pet.upgrade)

            -- enable or disable the button based on if the player has enough pet to craft a better one
            if numberOfSamePets >= 3 then
                petDetailsSizeCraftDisabled.Visible = false
                petDetailsSizeCraftButton.Visible = true
            else
                petDetailsSizeCraftButton.Visible = false
                petDetailsSizeCraftDisabled.Visible = true
            end

            -- display the right text based on the current size of the pet
            if pet.size == Sizes.Small then
                petDetailsSizeCraftRequirements.Visible = true
                petDetailsSizeCraftRequirements.Text = "Craft into big: " .. tostring(numberOfSamePets) .. "/3"
            elseif pet.size == Sizes.Big then
                petDetailsSizeCraftRequirements.Visible = true
                petDetailsSizeCraftRequirements.Text = "Craft into huge: " .. tostring(numberOfSamePets) .. "/3"
            else
                petDetailsSizeCraftRequirements.Visible = false
                petDetailsSizeCraftButton.Visible = false
                petDetailsSizeCraftDisabled.Visible = false
            end
        end
    end

    -- display the details frame
    if not petDetails.Visible then
        petDetails.Visible = true

        -- tween the pets list container size down to give space to the details tab
        inventoryPetsListContainer:TweenSize(
            UDim2.new(0.5, 0, 0.85, 0),
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Linear,
            0.2,
            true
        )

        -- tween details tab size up to display it
        petDetails:TweenSize(
            UDim2.new(0.42, 0, 0.85, 0),
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Linear,
            0.2,
            true
        )
    end
end


--[[
    Hides the pet details tab
]]--
function PetModule:UnselectPet()
    -- tween the pets list container size up to remove space for the details tab
    inventoryPetsListContainer:TweenSize(
        UDim2.new(0.94, 0, 0.85, 0),
        Enum.EasingDirection.InOut,
        Enum.EasingStyle.Linear,
        0.2,
        true
    )

    -- tween details tab size down to hide it
    petDetails:TweenSize(
        UDim2.new(0, 0, 0.85, 0),
        Enum.EasingDirection.InOut,
        Enum.EasingStyle.Linear,
        0.2,
        true,
        function()
            petDetails.Visible = false
        end
    )

    petDetails.Visible = false
end


--[[
    Adds the given pet to the inventory UI

    @param pet : pet, the pet to add to the inventory
]]--
function PetModule:AddPetToInventory(pet : pet)
    local petClone : ImageButton = petTemplate:Clone()

    pet.inventorySlot = petClone

    petClone.PetName.Text = pet.name

    local rarity = rarities[pet.rarity]
    petClone.BackgroundColor3 = rarity.color
    petClone.UIStroke.Color = rarity.border

    local displayPet : Model = displayPets:FindFirstChild(pet.identifier)
    if displayPet then
        displayPet:Clone().Parent = petClone.PetDisplay
    end

    petClone.MouseButton1Down:Connect(function()

        -- if the player clicked the same pet twice, hide the details tab
        if petDetails.Visible and pet.id == self.selectedPet then
            self:UnselectPet()
            return
        end

        self.selectedPet = pet.id
        self:SelectPet(pet.id)
    end)

    -- if the is already equipped, move it to the front of the list and change its border color to green
    if pet.equipped then
        petClone.LayoutOrder = 1
        petClone.UIStroke.Color = Color3.fromRGB(37, 175, 55)
    end

    petClone.Parent = inventoryPetsListContainer
end


--[[
    Adds the given pets to the inventory UI

    @param pets : {pet} the pets to add to the inventory
]]--
function PetModule:AddPetsToInventory(pets : {pet})
    for _,pet : pet in pairs(pets) do
        self:AddPetToInventory(pet)
    end

    self:UpdateUsedCapacity()
end


--[[
    Equips the given pet

    @param pet : pet, the pet to equip
    @return boolean, true if the pet could be equipped, false otherwise
]]--
function PetModule:EquipPet()
    local id : number = self.selectedPet
    local success : boolean, equipped : boolean = EquipPetRF:InvokeServer(id)

    if success then
        if equipped then
            for _,pet : pet in pairs(self.ownedPets) do
                if pet.id == id then

                    -- mark the pet as equipped
                    pet.equipped = true

                    self.currentlyEquippedPets += 1

                    -- move the pet to the start of the list
                    pet.inventorySlot.LayoutOrder = 1

                    -- change the border color of the pet frame to green
                    pet.inventorySlot.UIStroke.Color = Color3.fromRGB(37, 175, 55)
                end
            end

        else
            for _,pet : pet in pairs(self.ownedPets) do
                if pet.id == id then

                    -- mark the pet as unequipped
                    pet.equipped = false

                    self.currentlyEquippedPets -= 1

                    -- remove the pet from the start of the list
                    pet.inventorySlot.LayoutOrder = 10

                    -- reset the border color of the pet frame
                    local rarity : rarity = rarities[pet.rarity]
                    pet.inventorySlot.UIStroke.Color = rarity.border
                end
            end
        end
    end

    self:UpdateNumberOfEquippedPets()

    -- update the pet details tab (equip/unequip button mainly) (set selectedPet to nil otherwise it would close the details tab since it would be the same pet as the one that was last selected)
    self.selectedPet = nil
    self:SelectPet(id)
    self.selectedPet = id
end


--[[
	Opens the pets gui
]]--
function PetModule:OpenGui()
    -- open the gui
    if self.utility.OpenGui(inventoryBackground) then

        -- equip the clicked pet
        self.petsUIMaid:GiveTask(
            equipPetButton.MouseButton1Down:Connect(function()
                if self.selectedPet then
                    self:EquipPet()
                end
            end)
        )

        -- equip the best pets
        self.petsUIMaid:GiveTask(
            equipBestButton.MouseButton1Down:Connect(function()
                local equippedPetsIds : {number} = EquipBestPetsRF:InvokeServer()

                -- unequip all pets
                for _,pet : pet in pairs(self.ownedPets) do
                    if pet.equipped then
                        pet.equipped = false
                        pet.inventorySlot.LayoutOrder = 10

                        -- reset the border color of the pet frame
                        local rarity : rarity = rarities[pet.rarity]
                        pet.inventorySlot.UIStroke.Color = rarity.border

                        self.currentlyEquippedPets -= 1
                    end
                end

                -- equip all pets returned from the server
                for _,petId : number in pairs(equippedPetsIds) do

                    for _,pet : pet in pairs(self.ownedPets) do
                        if pet.id == petId then
                            -- mark the pet as equipped
                            pet.equipped = true

                            self.currentlyEquippedPets += 1

                            -- move the pet to the start of the list
                            pet.inventorySlot.LayoutOrder = 1

                            -- change the border color of the pet frame to green
                            pet.inventorySlot.UIStroke.Color = Color3.fromRGB(37, 175, 55)
                        end
                    end
                end

                self:UpdateNumberOfEquippedPets()

                -- hide the pet details tab since we don't know which pet to display
                self:UnselectPet()
            end)
        )

        -- delete the selected pet
        self.petsUIMaid:GiveTask(
            deletePetButton.MouseButton1Down:Connect(function()
                local success : boolean = DeletePetRF:InvokeServer(self.selectedPet)

                if success then
                    -- remove the pet from the table
                    print(#self.ownedPets)
                    for i : number, pet : pet in pairs(self.ownedPets) do
                        if pet.id == self.selectedPet then
                            if pet.equipped then
                                self.currentlyEquippedPets -= 1
                            end

                            pet.inventorySlot:Destroy()

                            table.remove(self.ownedPets, i)

                            break
                        end
                    end
                    print(#self.ownedPets)

                    self:UpdateNumberOfEquippedPets()
                    self:UpdateUsedCapacity()

                    self.selectedPet = nil
                    self:UnselectPet()
                end
            end)
        )

        -- set the close gui connection (only do it if the gui was not already open, otherwise multiple connection exist and it is called multiple times)
        self.utility.SetCloseGuiConnection(
            inventoryCloseButton.MouseButton1Down:Connect(function()
                self:CloseGui()
            end)
        )
    end
end


--[[
	Closes the pets gui
]]--
function PetModule:CloseGui()
    self.utility.CloseGui(inventoryBackground)

    self.petsUIMaid:DoCleaning()
end


return PetModule