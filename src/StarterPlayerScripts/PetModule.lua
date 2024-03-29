local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local SoundService = game:GetService("SoundService")
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
local DeleteUnequippedPetsRF : RemoteFunction = ReplicatedStorage:WaitForChild("DeleteUnequippedPets")
local CraftPetRF : RemoteFunction = ReplicatedStorage:WaitForChild("CraftPet")
local UpgradePetRF : RemoteFunction = ReplicatedStorage:WaitForChild("UpgradePet")
local PetsRE : RemoteEvent = ReplicatedStorage:WaitForChild("Pets")

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
local inventoryTitle : TextLabel = inventoryBackground:WaitForChild("Title")
local inventoryCloseButton : ImageButton = inventoryBackground:WaitForChild("InventoryClose")
local inventoryPetsListContainer : ScrollingFrame = inventoryBackground:WaitForChild("PetsListContainer")
local equipBestButton : TextButton = inventoryBackground:WaitForChild("EquipBest")
local deleteUnequippedPetsButton : TextButton = inventoryBackground:WaitForChild("DeleteUnequippedPets")
local deleteUnequippedPetsconfirmationContainer : Frame = deleteUnequippedPetsButton:WaitForChild("ConfirmationContainer")
local deleteUnequippedPetsCancelButton : TextButton = deleteUnequippedPetsconfirmationContainer:WaitForChild("DeleteUnequippedCancel")
local deleteUnequippedPetsConfirmButton : TextButton = deleteUnequippedPetsconfirmationContainer:WaitForChild("DeleteUnequippedConfirm")

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

local inventoryLimitsContainer : Frame = inventoryBackground:WaitForChild("InventoryLimits")
local equippedPets : TextLabel = inventoryLimitsContainer:WaitForChild("MaxEquippedPets"):WaitForChild("EquippedPets")
local moreEquippedPetsButton : TextButton = inventoryLimitsContainer.MaxEquippedPets:WaitForChild("MoreEquippedPets")
local inventoryCapacity : TextLabel = inventoryLimitsContainer:WaitForChild("MaxInvetoryCapacity"):WaitForChild("InventoryCapacity")
local moreInventorySlotsButton : TextButton = inventoryLimitsContainer.MaxInvetoryCapacity:WaitForChild("MoreInvetorySlots")

local upgradesMachineDetails : Frame = inventoryBackground:WaitForChild("UpgradesMachineDetails")
local upgradesMachineCloseButton : TextButton = inventoryBackground:WaitForChild("UpgradesMachineClose")
local upgradesMachineDetailsUpgradeType : TextLabel = upgradesMachineDetails:WaitForChild("UpgradeType")
local upgradesMachinesDetailsBoost : TextLabel = upgradesMachineDetails:WaitForChild("Boost")
local upgradesMachinesSlots : Frame = upgradesMachineDetails:WaitForChild("Slots")
local upgradesMachinesMagicSlot : Frame = upgradesMachineDetails:WaitForChild("MagicSlot")
local upgradesMachinesUpgradeButton : TextButton = upgradesMachineDetails:WaitForChild("Upgrade")
local upgradesMachinesMagicUpgradeButton : TextButton = upgradesMachineDetails:WaitForChild("MagicUpgrade")
local upgradesMachinesGuaranteedSuccess : TextLabel = upgradesMachineDetails:WaitForChild("GuaranteedSuccess")
local upgradesMachinesChance : TextLabel = upgradesMachineDetails:WaitForChild("Chance")
local upgradesMachinesUpgradeResult : TextLabel = upgradesMachineDetails:WaitForChild("UpgradeResult")
local petNameToolTip : TextLabel = inventoryBackground:WaitForChild("PetNameTooltip")

local successSound : Sound = SoundService:WaitForChild("Success")
local failureSound : Sound = SoundService:WaitForChild("Failure")


export type PetModule = {
    ownedPets : {pet},
    currentlyEquippedPets : number,
    maxEquippedPets : number,
    maxInventoryCapacity : number,
    utility : Utility.Utility,
    selectedPet : number?,
    canOpenEgg : boolean,
    selectedUpgradeType : number,
    upgradeSuccessChance : number,
    maxNumberOfPetsInMachine : number,
    petsInMachine : {pet},
    revealSound : Sound,
    petsUIMaid : Maid.Maid,
    eggsMaid : Maid.Maid,
    closeEggSequenceInputConnection : RBXScriptSignal?,
    upgradesMachineCloseButtonConnection : RBXScriptConnection,
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
    RecreatePetsInventory : (self : PetModule) -> nil,
    EquipPet : (self : PetModule) -> boolean,
    UpdateEggsOdds : (self : PetModule, luck : number) -> nil,
    CalculateActiveBoost : (self : PetModule, pet : pet) -> number,
    OpenGui : (self : PetModule) -> nil,
    CloseGui : (self : PetModule) -> nil,
    SetUpgradesMachineType : (self : PetModule, upgrade : number) -> nil,
    AddPetToMachine : (self : PetModule, pet : pet) -> nil,
    RemovePetFromMachine : (self : PetModule) -> nil,
    FilterPetsList : (self : PetModule, petFilterModel : pet) -> nil,
    UnfilterPetsList : (self : PetModule) -> nil,
    UpdateUpgradeSuccessChance : (self : PetModule) -> nil,
    OpenUpgradesMachineGui : (self : PetModule) -> nil,
    CloseUpgradesMachineGui : (self : PetModule) -> nil
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
        color = Color3.fromRGB(87, 188, 255),
        border = Color3.fromRGB(37, 81, 108)
    },
    [Rarities.Rare] = {
        name = "Rare",
        color = Color3.fromRGB(117, 250, 105),
        border = Color3.fromRGB(49, 104, 44)
    },
    [Rarities.Epic] = {
        name = "Epic",
        color = Color3.fromRGB(242, 102, 255),
        border = Color3.fromRGB(104, 44, 111)
    },
    [Rarities.Legendary] = {
        name = "Legendary",
        color = Color3.fromRGB(255, 159, 25),
        border = Color3.fromRGB(120, 73, 12)
    },
    [Rarities.Mystical] = {
        name = "Mystical",
        color = Color3.fromRGB(81, 0, 161),
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


local eggsOdds : {[number] : {[number] : {number}}} = {
    [0] = {
        [0] = {
            35,
            24.2,
            18.1,
            12.6,
            7.8,
            2.3
        },
        [1] = {
            31.5,
            21.7,
            16.3,
            13.6,
            10.5,
            6.2
        },
        [2] = {
            31.2,
            21.6,
            16.1,
            12.3,
            8.3,
            10.2
        }
    },
    [1] = {
        [0] = {
            37.5,
            32.3,
            22.6,
            4.2,
            2.8,
            0.6
        },
        [1] = {
            34.3,
            29.5,
            24.8,
            5.7,
            3.8,
            1.6
        },
        [2] = {
            35.3,
            30.4,
            23.4,
            4.7,
            3.1,
            2.8
        }
    },
    [2] = {
        [0] = {
            42.6,
            26.3,
            22.2,
            5.8,
            2.6,
            0.5
        },
        [1] = {
            35.3,
            26.1,
            22.1,
            7.2,
            6.5,
            2.9
        },
        [2] = {
            33.2,
            22.5,
            19,
            5.4,
            10.1,
            9.7
        }
    },
    [3] = {
        [0] = {
            42.3,
            28.3,
            16.7,
            11.3,
            1.1,
            0.3
        },
        [1] = {
            26.2,
            35.1,
            20.7,
            14,
            3.2,
            0.9
        },
        [2] = {
            13.8,
            38.5,
            22.7,
            15.4,
            7.5,
            2
        }
    },
    [4] = {
        [0] = {
            48.1,
            43.8,
            3.9,
            2.6,
            1.2,
            0.4
        },
        [1] = {
            43.4,
            39.5,
            8.2,
            5.5,
            2.5,
            0.8
        },
        [2] = {
            36.3,
            33.1,
            14.7,
            9.8,
            4.5,
            1.5
        }
    }
}


local PetModule : PetModule = {}
PetModule.__index = PetModule


function PetModule.new(utility : Utility.Utility)
    local petModule : PetModule = {}
    setmetatable(petModule, PetModule)

    petModule.ownedPets = {}

    petModule.currentlyEquippedPets = 0
    petModule.maxEquippedPets = 3
    petModule.maxInventoryCapacity = 50

    petModule.utility = utility

    petModule.selectedPet = nil

    petModule.canOpenEgg = true

    petModule.maxNumberOfPetsInMachine = 0
    petModule.petsInMachine = {}

    petModule.selectedUpgradeType = 0
    petModule.upgradeSuccessChance = 0
    petModule.closeEggSequenceInputConnection = nil
    petModule.upgradesMachineCloseButtonConnection = nil

    petModule.revealSound = game:GetService("SoundService"):WaitForChild("Reveal")

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
        -- the number of pets per row depends of the size of the list (if the details tab is open and list is half it's normal size, then number of pets per row should 3)
        local NUMBER_OF_PETS_PER_ROW : number = math.round(6 * inventoryPetsListContainer.Size.X.Scale)

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
        if upgradesMachineDetails.Visible then
            petModule:CloseUpgradesMachineGui()
            task.wait(0.5)
        end

        petModule:OpenGui()
    end)

    -- if the player is in the eggs area, the eggs gui can be shown + add the click connections...
    for _,part : Part in ipairs(workspace:WaitForChild("EggsAreaDetectionParts"):GetChildren()) do
        part.Touched:Connect(function(hit : BasePart)
            if hit.Parent and hit.Name == "HumanoidRootPart" then
                if Players:GetPlayerFromCharacter(hit.Parent) == lplr then

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


                        -- prompt the luck game passes purchase on luck buttons click
                        for _,luckButton : GuiObject in ipairs(eggGui.Background.LuckContainer:GetChildren()) do
                            if luckButton:IsA("ImageButton") then

                                -- tweens to scale the button up and down on mouse enter and mouse leave
                                local mouseEnterTween : Tween = TweenService:Create(
                                    luckButton.UIScale,
                                    TweenInfo.new(
                                        0.15,
                                        Enum.EasingStyle.Quad,
                                        Enum.EasingDirection.InOut
                                    ),
                                    {Scale = 1.1}
                                )

                                local mouseLeaveTween : Tween = TweenService:Create(
                                    luckButton.UIScale,
                                    TweenInfo.new(
                                        0.15,
                                        Enum.EasingStyle.Quad,
                                        Enum.EasingDirection.InOut
                                    ),
                                    {Scale = 1}
                                )

                                
                                -- scale the button up on mouse enter
                                petModule.eggsMaid:GiveTask(
                                    luckButton.MouseEnter:Connect(function()
                                        mouseEnterTween:Play()
                                    end)
                                )

                                -- scale the button down on mouse leave
                                petModule.eggsMaid:GiveTask(
                                    luckButton.MouseLeave:Connect(function()
                                        mouseLeaveTween:Play()
                                    end)
                                )


                                if luckButton.Name == "BasicLuck" then
                                    petModule.eggsMaid:GiveTask(
                                        luckButton.MouseButton1Down:Connect(function()
                                            GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.BasicLuck)
                                        end)
                                    )

                                elseif luckButton.Name == "GoldenLuck" then
                                    petModule.eggsMaid:GiveTask(
                                        luckButton.MouseButton1Down:Connect(function()
                                            GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.GoldenLuck)
                                        end)
                                    )
                                end
                            end
                        end
                    end
                end
            end
        end)


        -- when the player leaves the eggs area, disable the pets guis
        part.TouchEnded:Connect(function(hit : BasePart)
            if hit.Parent and hit.Name == "HumanoidRootPart" then
                if Players:GetPlayerFromCharacter(hit.Parent) == lplr then
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
            end
        end)
    end

    
    -- upgrades machine
    for _,upgradeMachine : Folder in ipairs(workspace:WaitForChild("PetsUpgradesMachine"):GetChildren()) do
        upgradeMachine.TouchDetector.Touched:Connect(function(hit : BasePart)
            if hit.Parent and hit.Name == "HumanoidRootPart" then
                if Players:GetPlayerFromCharacter(hit.Parent) == lplr then
                    petModule:SetUpgradesMachineType(upgradeMachine.UpgradeType.Value)

                    petModule:OpenUpgradesMachineGui()
                end
            end
        end)

        upgradeMachine.TouchDetector.TouchEnded:Connect(function(hit : BasePart)
            if hit.Parent and hit.Name == "HumanoidRootPart" then
                if Players:GetPlayerFromCharacter(hit.Parent) == lplr then
                    local isInZone : boolean = false

                    -- since touch ended fires somewhat randomly (when the player jumps for example), we want to check if the player is really not in the zone anymore
                    for _,touchingPart : BasePart in ipairs(hit:GetTouchingParts()) do
                        if touchingPart == upgradeMachine.TouchDetector then
                            isInZone = true
                            break
                        end
                    end

                    if not isInZone then
                        petModule:CloseUpgradesMachineGui()
                    end
                end
            end
        end)
    end

    return petModule
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
                petClone:ScaleTo(1.4)
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

                if i == 1 then
                    self.revealSound:Play()
                end

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
            if petDetailsPetDisplay:FindFirstChildWhichIsA("Model") then
                petDetailsPetDisplay:FindFirstChildWhichIsA("Model"):Destroy()
            end

            -- clone the model of the pet to the viewport frame
            local displayPet : Model = displayPets:FindFirstChild(pet.identifier)
            if displayPet then
                displayPet:Clone().Parent = petDetailsPetDisplay
            end

            -- petDetailsBoost.Text = string.format("x%f followers", math.round(pet.activeBoost * 1000) / 1000)
            petDetailsBoost.Text = "x" .. (math.round(pet.activeBoost * 1000) / 1000) .. " followers"

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

    -- show the pet name tooltip if the player is using the machine
    petClone.MouseEnter:Connect(function()
        local petSize : string = sizes[pet.size]
        local petUpgrade : upgrade = upgrades[pet.upgrade]
        
        petNameToolTip.Text = petUpgrade.name .. " " .. petSize .. " " .. pet.name

        petNameToolTip.Position = UDim2.new(
            0,
            petClone.AbsolutePosition.X - inventoryBackground.AbsolutePosition.X - (petNameToolTip.AbsoluteSize.X / 2) + (petClone.AbsoluteSize.X / 2),
            0,
            petClone.AbsolutePosition.Y - inventoryBackground.AbsolutePosition.Y - (petNameToolTip.AbsoluteSize.Y / 2)
        )

        petNameToolTip.Visible = true
    end)

    petClone.MouseLeave:Connect(function()
        petNameToolTip.Visible = false
    end)

    petClone.MouseButton1Down:Connect(function()

        -- if the upgrade machine ui is visible, add the pet to the machine to upgrade it
        if upgradesMachineDetails.Visible then
            self:AddPetToMachine(pet)
            return
        end

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
    Recreates the pet inventory (deletes all pets and adds them back (used when deleting unequipped pets or when upgrading))
]]--
function PetModule:RecreatePetsInventory()
    for _,petFrame : GuiObject in ipairs(inventoryPetsListContainer:GetChildren()) do
        if petFrame:IsA("ImageButton") then
            petFrame:Destroy()
        end
    end

    self.currentlyEquippedPets = 0

    -- count the number of pets the player has equipped
    for _,pet : pet in pairs(self.ownedPets) do
        if pet.equipped then
            self.currentlyEquippedPets += 1
        end
    end

    self:AddPetsToInventory(self.ownedPets)

    self:UpdateNumberOfEquippedPets()
    self:UpdateUsedCapacity()

    -- change all the colors to display the upgrade of the pet rather than the rarity if the upgrades machine ui is displayed
    if upgradesMachineDetails.Visible then
        for _,pet : pet in pairs(self.ownedPets) do
            if pet.upgrade == 1 then
                pet.inventorySlot.UIStroke.Color = Color3.fromRGB(255, 220, 80)
            elseif pet.upgrade == 2 then
                pet.inventorySlot.UIStroke.Color = Color3.new(1,1,1)
                pet.inventorySlot.UIStroke.UIGradient.Enabled = true
            elseif pet.upgrade == 3 then
                pet.inventorySlot.UIStroke.Color = Color3.fromRGB(127, 246, 255)
            end
        end
    end
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
    Updates all the odds text labels in the eggs gui to match the luck parameter (basic luck, golden luck or none

    @param luck : number, 0 = none, 1 = basic luck, 2 = golden luck
]]--
function PetModule:UpdateEggsOdds(luck : number)
    local textColor : Color3
    if luck == 2 then
        textColor = Color3.fromRGB(248, 225, 14)
    elseif luck == 1 then
        textColor = Color3.fromRGB(47, 197, 10)
    else
        textColor = Color3.new(1,1,1)
    end

    for _,eggGui : BillboardGui in ipairs(eggsScreenGui:GetChildren()) do

        -- update the odds on hover to allow players to preview the new percentage
        for _,petFrame : GuiObject in ipairs(eggGui.Background.PetsContainer:GetChildren()) do
            if petFrame:IsA("Frame") then
                petFrame.Odds.Text = tostring(eggsOdds[eggGui.Background.OpenEggContainer.EggId.Value][luck][petFrame.LayoutOrder]) .. "%"
                petFrame.Odds.TextColor3 = textColor
            end
        end
    end
end


--[[
    Calculates the active boost for the given pet (based on its base boost, size and upgrade)

    @param pet : pet, the pet to calculate the active boost for
    @return number, the calculated active boost
]]--
function PetModule:CalculateActiveBoost(pet : pet) : number
    local sizeBoost : number = 1
    local upgradeBoost : number = 1

    if pet.size == Sizes.Big then
        sizeBoost = 1.5
    elseif pet.size == Sizes.Huge then
        sizeBoost = 2
    end

    if pet.upgrade == Upgrades.Shiny then
        upgradeBoost = 1.5
    elseif pet.upgrade == Upgrades.Rainbow then
        upgradeBoost = 2.5
    elseif pet.upgrade == Upgrades.Magic then
        upgradeBoost = 6
    end

    return math.floor((pet.baseBoost * sizeBoost * upgradeBoost) * 100) / 100
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

                    self:UpdateNumberOfEquippedPets()
                    self:UpdateUsedCapacity()

                    self.selectedPet = nil
                    self:UnselectPet()
                end
            end)
        )


        -- buy more equipped pets
        self.petsUIMaid:GiveTask(
            moreEquippedPetsButton.MouseButton1Down:Connect(function()
                GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.EquipFourMorePets)
            end)
        )


        -- buy more inventory capacity
        self.petsUIMaid:GiveTask(
            moreInventorySlotsButton.MouseButton1Down:Connect(function()
                GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.PlusHundredAndFiftyInventoryCapacity)
            end)
        )


        -- delete all unequipped pets
        self.petsUIMaid:GiveTask(
            deleteUnequippedPetsButton.MouseButton1Down:Connect(function()
                for _,pet : pet in pairs(self.ownedPets) do
                    if not pet.equipped and pet.rarity ~= Rarities.Mystical then
                        pet.inventorySlot.UIStroke.Color = Color3.new(1,0,0)
                    end
                end

                deleteUnequippedPetsconfirmationContainer.Visible = true
            end)
        )


        -- cancel the pets unequipped deletion
        self.petsUIMaid:GiveTask(
            deleteUnequippedPetsCancelButton.MouseButton1Down:Connect(function()
                for _,pet : pet in pairs(self.ownedPets) do
                    if not pet.equipped then
                        -- reset the border color of the pet frame
                        local rarity : rarity = rarities[pet.rarity]

                        pet.inventorySlot.UIStroke.Color = rarity.border
                    end
                end

                deleteUnequippedPetsconfirmationContainer.Visible = false
            end)
        )


        -- confirm the pets unequipped deletion
        self.petsUIMaid:GiveTask(
            deleteUnequippedPetsConfirmButton.MouseButton1Down:Connect(function()
                self:UnselectPet()

                self.ownedPets = DeleteUnequippedPetsRF:InvokeServer()

                self:RecreatePetsInventory()

                deleteUnequippedPetsconfirmationContainer.Visible = false
            end)
        )


        -- craft the pet into a bigger one
        self.petsUIMaid:GiveTask(
            petDetailsSizeCraftButton.MouseButton1Down:Connect(function()
                local success : boolean = CraftPetRF:InvokeServer(self.selectedPet)

                if success then
                    local craftedPet : pet
                    for _,pet : pet in pairs(self.ownedPets) do
                        if pet.id == self.selectedPet then
                            craftedPet = pet
                        end
                    end

                    if craftedPet then
                        local petsToRemovePositions : {pet} = {}
                        for i : number, pet : pet in pairs(self.ownedPets) do
                            if pet.identifier == craftedPet.identifier and pet.size == craftedPet.size and pet.upgrade == craftedPet.upgrade and pet.id ~= craftedPet.id then
                                table.insert(petsToRemovePositions, i)

                                pet.inventorySlot:Destroy()

                                -- if we have found 2 matching pets, stop because we don't want to remove all matching pets
                                if #petsToRemovePositions == 2 then
                                    break
                                end
                            end
                        end

                        -- increase the pet size
                        if craftedPet.size < 2 then
                            craftedPet.size += 1
                        end

                        -- sort the table by descending order
                        table.sort(petsToRemovePositions, function(a, b)
                            return a > b
                        end)

                        table.remove(self.ownedPets, petsToRemovePositions[1])
                        table.remove(self.ownedPets, petsToRemovePositions[2])

                        craftedPet.activeBoost = self:CalculateActiveBoost(craftedPet)

                        self.selectedPet = nil
                        self:SelectPet(craftedPet.id)
                        self.selectedPet = craftedPet.id

                        self:UpdateUsedCapacity()
                    end
                end
            end)
        )


        -- set the close gui connection (only do it if the gui was not already open, otherwise multiple connection exist and it is called multiple times)
        self.utility.SetCloseGuiConnection(inventoryCloseButton, function()
            self:CloseGui()
        end)
    end
end


--[[
	Closes the pets gui
]]--
function PetModule:CloseGui()
    self.utility.CloseGui(inventoryBackground)

    self.petsUIMaid:DoCleaning()
end


--[[
    Sets the upgrade type for the machine (shiny, rainbow or magic)

    @param upgrade : number, the upgrade to set the machine to
]]--
function PetModule:SetUpgradesMachineType(upgrade : number)
    
    local upgradeType : upgrade = upgrades[upgrade]

    self.selectedUpgradeType = upgrade

    -- update the upgrade type ui (shiny, rainbow or magic)
    upgradesMachineDetailsUpgradeType.UpgradeName.Text = upgradeType.name:upper()
    upgradesMachineDetailsUpgradeType.BackgroundColor3 = upgradeType.color
    upgradesMachineDetailsUpgradeType.BorderUIStroke.Color = upgradeType.border
    upgradesMachineDetailsUpgradeType.UpgradeName.ContextualUIStroke.Color = upgradeType.border

    -- display the gradient if the upgrade should have a gradient
    if upgradeType.gradient then
        upgradesMachineDetailsUpgradeType.UIGradient.Enabled = true
        upgradesMachineDetailsUpgradeType.UIGradient.Color = upgradeType.gradientColor
    else
        upgradesMachineDetailsUpgradeType.UIGradient.Enabled = false
    end

    -- display the image if the upgrade should have an image
    if upgradeType.image then
        upgradesMachineDetailsUpgradeType.ImageLabel.Visible = true
        upgradesMachineDetailsUpgradeType.ImageLabel.Image = upgradeType.imageUrl
    else
        upgradesMachineDetailsUpgradeType.ImageLabel.Visible = false
    end

    -- update the boost
    if upgrade == Upgrades.Shiny then
        self.maxNumberOfPetsInMachine = 5
        upgradesMachinesDetailsBoost.Text = "+50% boost"
    elseif upgrade == Upgrades.Rainbow then
        self.maxNumberOfPetsInMachine = 5
        upgradesMachinesDetailsBoost.Text = "+150% boost"
    elseif upgrade == Upgrades.Magic then
        self.maxNumberOfPetsInMachine = 1
        upgradesMachinesDetailsBoost.Text = "+600% boost"
    end
end


--[[
    Opens the upgrades machine gui
]]--
function PetModule:OpenUpgradesMachineGui()
    if inventoryBackground.Visible then
        self:CloseUpgradesMachineGui()
        self:CloseGui()
        task.wait(0.5)
    end

    -- wait before opening the ui otherwise it would sometimes break (opening before closing and thus changing the originalSize of the ui in utility to 0,0,0,0)
    task.wait(0.2)

    if not upgradesMachineDetails.Visible then
        -- open the pets gui
        self:OpenGui()

        -- listen to clicks on slots to remove the pets from the machine
        for _,slot : ImageButton in ipairs(upgradesMachinesSlots:GetChildren()) do
            self.petsUIMaid:GiveTask(
                slot.MouseButton1Down:Connect(function()
                    self:RemovePetFromMachine()
                end)
            )
        end

        -- listen to click on the magic slot to remove the pet from the machine
        self.petsUIMaid:GiveTask(
            upgradesMachinesMagicSlot.Slot1.MouseButton1Down:Connect(function()
                self:RemovePetFromMachine()
            end)
        )


        -- magic upgrade button click
        self.petsUIMaid:GiveTask(
            upgradesMachinesMagicUpgradeButton.MouseButton1Down:Connect(function()
                if #self.petsInMachine > 0 and self.petsInMachine[1].upgrade < Upgrades.Magic then

                    -- fire the server before to save the pet we want to upgrade to magic (because after the purchase succeeds, we have no way of knowing which pet to upgrade)
                    PetsRE:FireServer(self.petsInMachine[1].id)

                    self:RemovePetFromMachine()

                    MarketplaceService:PromptProductPurchase(lplr, 1650533238)
                end
            end)
        )

        -- upgrade button click
        self.petsUIMaid:GiveTask(
            upgradesMachinesUpgradeButton.MouseButton1Down:Connect(function()
                if #self.petsInMachine > 0 then
                    local success : boolean, pets : {pet} = UpgradePetRF:InvokeServer(self.petsInMachine[1].id, self.selectedUpgradeType, #self.petsInMachine)

                    if success then
                        upgradesMachinesUpgradeResult.Text = "Success!"
                        upgradesMachinesUpgradeResult.TextColor3 = Color3.fromRGB(135, 255, 139)
                        upgradesMachinesUpgradeResult.UIStroke.Color = Color3.fromRGB(0, 115, 4)
                        upgradesMachinesUpgradeResult.Visible = true
                        successSound:Play()

                    else
                        upgradesMachinesUpgradeResult.Text = "Failed!"
                        upgradesMachinesUpgradeResult.TextColor3 = Color3.fromRGB(255, 146, 146)
                        upgradesMachinesUpgradeResult.UIStroke.Color = Color3.fromRGB(126, 0, 0)
                        upgradesMachinesUpgradeResult.Visible = true
                        failureSound:Play()
                    end

                    if #pets > 0 then
                        -- remove all the pets from the machine
                        while #self.petsInMachine > 0 do
                            self:RemovePetFromMachine()
                        end

                        self.ownedPets = pets

                        self:RecreatePetsInventory()
                    end
                end
            end)
        )

        equipBestButton.Visible = false
        deleteUnequippedPetsButton.Visible = false
        deleteUnequippedPetsCancelButton.Visible = false
        deleteUnequippedPetsConfirmButton.Visible = false
        inventoryLimitsContainer.Visible = false

        inventoryCloseButton.Visible = false
        upgradesMachineCloseButton.Visible = true

        if self.selectedUpgradeType == Upgrades.Shiny then
            inventoryTitle.Text = "Shiny Machine"
        elseif self.selectedUpgradeType == Upgrades.Rainbow then
            inventoryTitle.Text = "Rainbow Machine"
        elseif self.selectedUpgradeType == Upgrades.Magic then
            inventoryTitle.Text = "Magic"
        end

        if self.selectedUpgradeType == Upgrades.Magic then
            upgradesMachinesSlots.Visible = false
            upgradesMachinesMagicSlot.Visible = true
            upgradesMachinesUpgradeButton.Visible = false
            upgradesMachinesMagicUpgradeButton.Visible = true
            upgradesMachinesGuaranteedSuccess.Visible = true

        else
            upgradesMachinesGuaranteedSuccess.Visible = false
            upgradesMachinesMagicSlot.Visible = false
            upgradesMachinesSlots.Visible = true
            upgradesMachinesMagicUpgradeButton.Visible = false
            upgradesMachinesUpgradeButton.Visible = true
        end

        -- change all the colors to display the upgrade of the pet rather than the rarity
        for _,pet : pet in pairs(self.ownedPets) do
            if pet.upgrade == 1 then
                pet.inventorySlot.UIStroke.Color = Color3.fromRGB(255, 220, 80)
            elseif pet.upgrade == 2 then
                pet.inventorySlot.UIStroke.Color = Color3.new(1,1,1)
                pet.inventorySlot.UIStroke.UIGradient.Enabled = true
            elseif pet.upgrade == 3 then
                pet.inventorySlot.UIStroke.Color = Color3.fromRGB(127, 246, 255)
            end
        end

        petDetails.Visible = false
        petDetails.Size = UDim2.new(0, 0, 0.85, 0)
        inventoryPetsListContainer.Size = UDim2.new(0.5, 0, 0.85, 0)
        upgradesMachineDetails.Size = UDim2.new(0.42, 0, 0.85, 0)

        upgradesMachineDetails.Visible = true

        self.upgradesMachineCloseButtonConnection = upgradesMachineCloseButton.MouseButton1Down:Connect(function()
            self:CloseUpgradesMachineGui()
        end)
    end
end


--[[
    Closes the upgrades machine gui
]]--
function PetModule:CloseUpgradesMachineGui()
    if self.upgradesMachineCloseButtonConnection then
        self.upgradesMachineCloseButtonConnection:Disconnect()
    end

    if upgradesMachineDetails.Visible then
        -- remove all the pets from the machine
        while #self.petsInMachine > 0 do
            self:RemovePetFromMachine()
        end

        -- reset the border colors (based on the rarity)
        for _,pet : pet in pairs(self.ownedPets) do
            if pet.equipped then
                pet.inventorySlot.UIStroke.Color = Color3.fromRGB(37, 175, 55)
            else
                pet.inventorySlot.UIStroke.Color = rarities[pet.rarity].border
            end
            pet.inventorySlot.UIStroke.UIGradient.Enabled = false
        end

        equipBestButton.Visible = true
        deleteUnequippedPetsButton.Visible = true
        deleteUnequippedPetsCancelButton.Visible = true
        deleteUnequippedPetsConfirmButton.Visible = true
        inventoryLimitsContainer.Visible = true

        upgradesMachineCloseButton.Visible = false
        inventoryCloseButton.Visible = true

        inventoryTitle.Text = "Pets"
        
        inventoryPetsListContainer.Size = UDim2.new(0.94, 0, 0.85, 0)
        upgradesMachineDetails.Size = UDim2.new(0, 0, 0.85, 0)
        
        upgradesMachineDetails.Visible = false
        upgradesMachinesUpgradeResult.Visible = false

        self:CloseGui()
    end
end


--[[
    Adds the given pet to the machine and updates the chance of success

    @param pet : pet, the pet to add to the machine
]]--
function PetModule:AddPetToMachine(pet : pet)
    if #self.petsInMachine == 0 then
        self:FilterPetsList(pet)
    end

    -- move the scrolling frame to the top
    inventoryPetsListContainer.CanvasPosition = Vector2.new(0, 0)

    -- if the player has already filled the machine, return
    if #self.petsInMachine == self.maxNumberOfPetsInMachine then return end

    table.insert(self.petsInMachine, pet)

    pet.inventorySlot.Visible = false

    -- find the right slot to use based on the number of pets already in the machine and the upgrade type
    local slot : ImageButton
    if self.selectedUpgradeType == Upgrades.Magic then
        slot = upgradesMachinesMagicSlot:FindFirstChild("Slot" .. tostring(#self.petsInMachine))
    else
        slot = upgradesMachinesSlots:FindFirstChild("Slot" .. tostring(#self.petsInMachine))
    end

    -- add the pet to the slot's viewport frame
    if slot then
        if displayPets:FindFirstChild(pet.identifier) then
            local petClone : Model = displayPets[pet.identifier]:Clone()
            petClone.Parent = slot.PetDisplay
        end

        slot.BackgroundColor3 = pet.inventorySlot.BackgroundColor3
        slot.UIStroke.Color = pet.inventorySlot.UIStroke.Color
    end

    -- updates the chance of having a succes after the upgrade
    self:UpdateUpgradeSuccessChance()
end


--[[
    Removes a pet from the machine
]]--
function PetModule:RemovePetFromMachine()

    -- only remove pets if there is at least one in the machine
    if #self.petsInMachine == 0 then return end

    -- find the right slot to use based on the number of pets already in the machine and the upgrade type
    local slot : ImageButton
    if self.selectedUpgradeType == Upgrades.Magic then
        slot = upgradesMachinesMagicSlot:FindFirstChild("Slot" .. tostring(#self.petsInMachine))
    else
        slot = upgradesMachinesSlots:FindFirstChild("Slot" .. tostring(#self.petsInMachine))
    end

    -- make the pet visible in the list
    self.petsInMachine[#self.petsInMachine].inventorySlot.Visible = true

    -- remove the last entry of the petsInMachine table
    table.remove(self.petsInMachine, #self.petsInMachine)


    -- if there are no pets in the machine anymore, unfilter the pet list so that the player can add other pets to the machine
    if #self.petsInMachine == 0 then
        self:UnfilterPetsList()
    end

    -- destroy the pet in the viewport frame
    if slot.PetDisplay:FindFirstChildWhichIsA("Model") then
        slot.PetDisplay:FindFirstChildWhichIsA("Model"):Destroy()
    end

    slot.BackgroundColor3 = Color3.fromRGB(223, 223, 223)
    slot.UIStroke.Color = Color3.fromRGB(75, 75, 75)

    -- updates the chance of having a succes after the upgrade
    self:UpdateUpgradeSuccessChance()
end


--[[
    
]]--
function PetModule:FilterPetsList(petFilterModel : pet)
    for _,pet : pet in pairs(self.ownedPets) do
        if pet.identifier ~= petFilterModel.identifier or pet.size ~= petFilterModel.size or pet.upgrade ~= petFilterModel.upgrade then
            pet.inventorySlot.Visible = false
        end
    end
end


--[[
    
]]--
function PetModule:UnfilterPetsList()
    for _,pet : pet in pairs(self.ownedPets) do
        pet.inventorySlot.Visible = true
    end
end


--[[
    
]]--
function PetModule:UpdateUpgradeSuccessChance()
    if self.selectedUpgradeType == Upgrades.Shiny then
        self.upgradeSuccessChance = 0.2 * #self.petsInMachine
    elseif self.selectedUpgradeType == Upgrades.Rainbow then
        self.upgradeSuccessChance = 0.1 * #self.petsInMachine
    else
        self.upgradeSuccessChance = 1
    end

    -- update the chance text
    upgradesMachinesChance.Text = string.format("Chance: %d%%", self.upgradeSuccessChance * 100)

    -- update the chance text color
    if self.upgradeSuccessChance <= 0.25 then
        upgradesMachinesChance.UIStroke.Color = Color3.fromRGB(218, 72, 72)
    elseif self.upgradeSuccessChance <= 0.45 then
        upgradesMachinesChance.UIStroke.Color = Color3.fromRGB(214, 151, 24)
    elseif self.upgradeSuccessChance <= 0.7 then
        upgradesMachinesChance.UIStroke.Color = Color3.fromRGB(207, 196, 35)
    elseif self.upgradeSuccessChance <= 0.9 then
        upgradesMachinesChance.UIStroke.Color = Color3.fromRGB(111, 193, 114)
    else
        upgradesMachinesChance.UIStroke.Color = Color3.fromRGB(19, 172, 29)
    end
end


return PetModule