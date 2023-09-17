local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EggModule = require(script:WaitForChild("EggModule"))
local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))
local Types = require(ServerScriptService:WaitForChild("Types"))

local InformationNotificationRE : RemoteEvent = ReplicatedStorage:WaitForChild("InformationNotification")

local displayPets : Folder = ReplicatedStorage:WaitForChild("DisplayPets")

DataStore2.Combine("SMS", "pets")


export type PetModule = {
    ownedPets : {pet},
    followersMultiplier : number,
    currentlyEquippedPets : number,
    maxEquippedPets : number,
    inventoryCapacity : number,
    nextId : number,
    luck : number,
    magicUpgradePetId : number,
    plr : Player,
    new : (plr : Player) -> PetModule,
    IsPetInventoryFull : (self : PetModule) -> boolean,
    AddPetToInventory : (self : PetModule, pet : pet) -> nil,
    CreatePetAttachments : (self : PetModule) -> nil,
    RotateAttachmentsTowardsPlayer : (self : PetModule, target : Vector3) -> nil,
    GetPetFromPetId : (self : PetModule, petId : number) -> pet?,
    OpenEgg : (self : PetModule, eggId : number) -> pet,
    OpenEggs : (self : PetModule, p : Types.PlayerModule, eggId : number, numberOfEggsToOpen : number) -> pet,
    CanEquipPet : (self : PetModule) -> boolean,
    EquipPet : (self : PetModule, id : number, updateFollowersMultiplier : boolean) -> (boolean, boolean),
    AddPetToCharacter : (self : PetModule, pet : pet) -> nil,
    RemovePetFromCharacter : (self : PetModule, pet : pet) -> nil,
    LoadEquippedPets : (self : PetModule) -> nil,
    EquipBest : (self : PetModule) -> {number},
    UnequipAllPets : (self : PetModule) -> nil,
    DeletePet : (self : PetModule, id : number) -> boolean,
    DeleteUnequippedPets : (self : PetModule) -> {pet},
    CraftPet : (self : PetModule, id : number) -> boolean,
    UpgradePet : (self : PetModule, id : number, upgradeType : number, numberOfPetsInMachine : number) -> (boolean, {pet}),
    MagicUpgradePet : (self : PetModule) -> nil,
    CalculateActiveBoost : (self : PetModule, pet : pet) -> number,
    UpdateFollowersMultiplier : (self : PetModule) -> nil
}

type pet = {
    id : number,
    identifier : string,
    name : string,
    rarity : number,
    size : number,
    upgrade : number,
    baseBoost : number,
    activeBoost : number,
    equipped : boolean
}


local rarities = {
    Common = 0,
    Uncommon = 1,
    Rare = 2,
    Epic = 3,
    Legendary = 4,
    Mystical = 5
}

local sizes = {
    Normal = 0,
    Big = 1,
    Huge = 2
}

local upgrades = {
    None = 0,
    Shiny = 1,
    Rainbow = 2,
    Magic = 3
}


local pets : {[number] : pet} = {
    [0] = {
        id = 0,
        identifier = "TearsOfJoy",
        name = "Tears of joy",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.05,
        activeBoost = 1.05,
        equipped = false
    },
    [1] = {
        id = 0,
        identifier = "Grinning",
        name = "Grinning",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.1,
        activeBoost = 1.1,
        equipped = false
    },
    [2] = {
        id = 0,
        identifier = "Flushed",
        name = "Flushed",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.1,
        activeBoost = 1.1,
        equipped = false
    },
    [3] = {
        id = 0,
        identifier = "ROFL",
        name = "ROFL",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.2,
        activeBoost = 1.2,
        equipped = false
    },
    [4] = {
        id = 0,
        identifier = "Crying",
        name = "Crying",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.25,
        activeBoost = 1.25,
        equipped = false
    },
    [5] = {
        id = 0,
        identifier = "Smiling",
        name = "Smiling",
        rarity = rarities.Common,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.5,
        activeBoost = 1.5,
        equipped = false
    },
    [6] = {
        id = 0,
        identifier = "Winking",
        name = "Winking",
        rarity = rarities.Uncommon,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.65,
        activeBoost = 1.65,
        equipped = false
    },
    [7] = {
        id = 0,
        identifier = "SmilingEyes",
        name = "Smiling eyes",
        rarity = rarities.Uncommon,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1.8,
        activeBoost = 1.8,
        equipped = false
    },
    [8] = {
        id = 0,
        identifier = "Sweat",
        name = "Sweat",
        rarity = rarities.Uncommon,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 2,
        activeBoost = 2,
        equipped = false
    },
    [9] = {
        id = 0,
        identifier = "Nerd",
        name = "Nerd",
        rarity = rarities.Uncommon,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 2.1,
        activeBoost = 2.1,
        equipped = false
    },
    [10] = {
        id = 0,
        identifier = "RollingEyes",
        name = "Rolling eyes",
        rarity = rarities.Rare,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 2.7,
        activeBoost = 2.7,
        equipped = false
    },
    [11] = {
        id = 0,
        identifier = "HeartEyes",
        name = "Heart eyes",
        rarity = rarities.Rare,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 2.95,
        activeBoost = 2.95,
        equipped = false
    },
    [12] = {
        id = 0,
        identifier = "Hugging",
        name = "Hugging",
        rarity = rarities.Rare,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 3.05,
        activeBoost = 3.05,
        equipped = false
    },
    [13] = {
        id = 0,
        identifier = "Pensive",
        name = "Pensive",
        rarity = rarities.Rare,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 3.2,
        activeBoost = 3.2,
        equipped = false
    },
    [14] = {
        id = 0,
        identifier = "Thinking",
        name = "Thinking",
        rarity = rarities.Rare,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 3.6,
        activeBoost = 3.6,
        equipped = false
    },
    [15] = {
        id = 0,
        identifier = "Hearts",
        name = "Hearts",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 3.5,
        activeBoost = 3.5,
        equipped = false
    },
    [16] = {
        id = 0,
        identifier = "Squinting",
        name = "Squinting",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 3.75,
        activeBoost = 3.75,
        equipped = false
    },
    [17] = {
        id = 0,
        identifier = "Fear",
        name = "Fear",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 4,
        activeBoost = 4,
        equipped = false
    },
    [18] = {
        id = 0,
        identifier = "ThumbsUp",
        name = "Thumbs up",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 4.5,
        activeBoost = 4.5,
        equipped = false
    },
    [19] = {
        id = 0,
        identifier = "Swearing",
        name = "Swearing",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 5,
        activeBoost = 5,
        equipped = false
    },
    [20] = {
        id = 0,
        identifier = "UpsideDown",
        name = "Upside down",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 5.2,
        activeBoost = 5.2,
        equipped = false
    },
    [21] = {
        id = 0,
        identifier = "FoldedHands",
        name = "Folded hands",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 6,
        activeBoost = 6,
        equipped = false
    },
    [22] = {
        id = 0,
        identifier = "OK",
        name = "OK",
        rarity = rarities.Epic,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 7,
        activeBoost = 7,
        equipped = false
    },
    [23] = {
        id = 0,
        identifier = "PurpleHeart",
        name = "Purple heart",
        rarity = rarities.Legendary,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 9.5,
        activeBoost = 9.5,
        equipped = false
    },
    [24] = {
        id = 0,
        identifier = "Clapping",
        name = "Clapping",
        rarity = rarities.Legendary,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 11.2,
        activeBoost = 11.2,
        equipped = false
    },
    [25] = {
        id = 0,
        identifier = "Sleeping",
        name = "Sleeping",
        rarity = rarities.Legendary,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 15.3,
        activeBoost = 15.3,
        equipped = false
    },
    [26] = {
        id = 0,
        identifier = "Sunglasses",
        name = "Sunglasses",
        rarity = rarities.Legendary,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 20.8,
        activeBoost = 20.8,
        equipped = false
    },
    [27] = {
        id = 0,
        identifier = "Party",
        name = "Party",
        rarity = rarities.Legendary,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 35.5,
        activeBoost = 35.5,
        equipped = false
    },
    [28] = {
        id = 0,
        identifier = "Angel",
        name = "Angel",
        rarity = rarities.Legendary,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 40.1,
        activeBoost = 40.1,
        equipped = false
    },
    [29] = {
        id = 0,
        identifier = "Poo",
        name = "Poo",
        rarity = rarities.Legendary,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 50.5,
        activeBoost = 50.5,
        equipped = false
    },
    [100] = {
        id = 0,
        identifier = "Hundred",
        name = "Hundred",
        rarity = rarities.Mystical,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 100,
        activeBoost = 100,
        equipped = false
    },
    [101] = {
        id = 0,
        identifier = "Fire",
        name = "Fire",
        rarity = rarities.Mystical,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 150,
        activeBoost = 150,
        equipped = false
    },
    [102] = {
        id = 0,
        identifier = "PartyPopper",
        name = "Party Popper",
        rarity = rarities.Mystical,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 250,
        activeBoost = 250,
        equipped = false
    },
    [103] = {
        id = 0,
        identifier = "RedHeart",
        name = "Red Heart",
        rarity = rarities.Mystical,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 400,
        activeBoost = 400,
        equipped = false
    },
    [104] = {
        id = 0,
        identifier = "Devil",
        name = "Devil",
        rarity = rarities.Mystical,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 650,
        activeBoost = 650,
        equipped = false
    },
    [105] = {
        id = 0,
        identifier = "Money",
        name = "Money",
        rarity = rarities.Mystical,
        size = sizes.Normal,
        upgrade = upgrades.None,
        baseBoost = 1000,
        activeBoost = 1000,
        equipped = false
    },
}


local function shallowCopy(original)
    local copy = {}
    for key, value in pairs(original) do
        copy[key] = value
    end
    return copy
end


local function CreatePetAttachment(position : Vector3, humanoidRootPart : Part, size : number)
    local petAttachment : Attachment
    petAttachment = Instance.new("Attachment")
    petAttachment.Name = "PetAttachment"

    local used : BoolValue = Instance.new("BoolValue")
    used.Name = "Used"
    used.Value = false
    used.Parent = petAttachment

    -- 2 for huge pets, 1 otherwise
    local petSize : NumberValue = Instance.new("NumberValue")
    petSize.Name = "Size"
    petSize.Value = size
    petSize.Parent = petAttachment

    local petId : NumberValue = Instance.new("NumberValue")
    petId.Name = "PetId"

    petId.Value = false
    petId.Parent = petAttachment

    petAttachment.Parent = humanoidRootPart
    petAttachment.CFrame = CFrame.new(position)
end


local PetModule : PetModule = {}
PetModule.__index = PetModule


function PetModule.new(plr : Player)
    local petModule : PetModule = {}

    -- DataStore2("pets", plr):Set(nil)
    petModule.ownedPets = DataStore2("pets", plr):Get({})

    petModule.followersMultiplier = 0

    -- found the max id from all the pets to create unique ids for the next ones
    petModule.nextId = 0
    local maxId : number = 0
    for _,pet : pet in pairs(petModule.ownedPets) do
        if pet.id > maxId then
            maxId = pet.id
        end
    end
    petModule.nextId = maxId + 1

    petModule.luck = 0

    -- used to know which pet to upgrade when the magic upgrade developer product purchase succeeds
    petModule.magicUpgradePetId = nil

    petModule.currentlyEquippedPets = 0
    petModule.maxEquippedPets = 3
    petModule.inventoryCapacity = 50

    petModule.plr = plr

    return setmetatable(petModule, PetModule)
end


--[[
    Returns true if the inventory is full, false otherwise
]]--
function PetModule:IsPetInventoryFull()
    return not (#self.ownedPets < self.inventoryCapacity)
end


--[[
    Adds the given pet id to the inventory

    @param petId : number, the id of the pet to add to the inventory
]]--
function PetModule:AddPetToInventory(pet : pet)
    table.insert(self.ownedPets, pet)

    DataStore2("pets", self.plr):Set(self.ownedPets)
end


--[[
    Create all the attachments on the player for the pets
]]--
function PetModule:CreatePetAttachments()
    if not self.plr.Character then
        self.plr.CharacterAdded:Wait()
    end
    self.plr.Character:WaitForChild("HumanoidRootPart")

    local humanoidRootPart : Part = self.plr.Character.HumanoidRootPart

    CreatePetAttachment(Vector3.new(-5, 0, 4), humanoidRootPart, sizes.Big)
    CreatePetAttachment(Vector3.new(0, 0, 5), humanoidRootPart, sizes.Big)
    CreatePetAttachment(Vector3.new(5, 0, 4), humanoidRootPart, sizes.Big)
    CreatePetAttachment(Vector3.new(-8, 0, 7), humanoidRootPart, sizes.Big)
    CreatePetAttachment(Vector3.new(-3, 0, 9), humanoidRootPart, sizes.Big)
    CreatePetAttachment(Vector3.new(3, 0, 9), humanoidRootPart, sizes.Big)
    CreatePetAttachment(Vector3.new(8, 0, 7), humanoidRootPart, sizes.Big)

    CreatePetAttachment(Vector3.new(-9, 0, 5), humanoidRootPart, sizes.Huge)
    CreatePetAttachment(Vector3.new(0, 0, 7), humanoidRootPart, sizes.Huge)
    CreatePetAttachment(Vector3.new(9, 0, 5), humanoidRootPart, sizes.Huge)
    CreatePetAttachment(Vector3.new(-14, 0, 13), humanoidRootPart, sizes.Huge)
    CreatePetAttachment(Vector3.new(-5, 0, 16), humanoidRootPart, sizes.Huge)
    CreatePetAttachment(Vector3.new(5, 0, 16), humanoidRootPart, sizes.Huge)
    CreatePetAttachment(Vector3.new(14, 0, 13), humanoidRootPart, sizes.Huge)
end


--[[
    Rotates all the pet attachments towards the player's character

    @param target : Vector3, the target position the attachment should look towards
]]--
function PetModule:RotateAttachmentsTowardsPlayer(target : Vector3)
    if not self.plr.Character then
        self.plr.CharacterAdded:Wait()
    end
    self.plr.Character:WaitForChild("HumanoidRootPart")

    local humanoidRootPart : Part = self.plr.Character.HumanoidRootPart

    for _,v in ipairs(humanoidRootPart:GetChildren()) do
        if v:IsA("Attachment") and v.Name == "PetAttachment" then
            v.WorldCFrame = CFrame.lookAt(v.WorldPosition, target)
        end
    end
end


--[[
    Returns the pet matching the given id

    @param petId : number, the id of the pet to return
    @return pet?, the table containing the information about the pets if it has been found, nil otherwise
]]--
function PetModule:GetPetFromPetId(petId : number) : pet?
    for id : number, pet : pet in pairs(pets) do
        if id == petId then
            return shallowCopy(pet)
        end
    end

    return nil
end


--[[
    Open one egg corresponding to the given eggId and return the randomly selected pet

    @param eggId : number, the id of the egg the player wants to open
    @return pet?, the information about the randomly selected pet if it could be selected, nil otherwise
]]--
function PetModule:OpenEgg(eggId : number) : pet?
    -- if the inventory is full, tell the client
    if self:IsPetInventoryFull() then
        InformationNotificationRE:FireClient(self.plr, "Your pet inventory is full!\nDelete pets or buy more inventory capacity.", 10)
        return nil
    end

    -- get a random pet for the given egg
    local petId : number? = EggModule.GetRandomPetForEgg(eggId, self.luck)
    if petId then

        -- get the pet information table from the id
        local pet : pet = self:GetPetFromPetId(petId)
        if pet then
            -- set the unique id for the pet
            pet.id = self.nextId
            self.nextId += 1

            self:AddPetToInventory(pet)
            return pet
        end
    end

    return nil
end


--[[
    Open x times (numberOfEggsToOpen) the egg matching the given id and return a table containing all the pets the player got

    @param p : PlayerModule, the object reprensenting the player
    @param eggId : number, the id of the egg the player wants to open
    @param numberOfEggsToOpen : number, the number of eggs to open
    @return {pet}, a table containing information about all the pets the player got while opening the eggs
]]--
function PetModule:OpenEggs(p : Types.PlayerModule, eggId : number, numberOfEggsToOpen : number) : {pet}
    -- get the price of the egg with the given id
    local price : number? = EggModule.GetEggPrice(eggId)
    if price then

        if p:HasEnoughCoins(price * numberOfEggsToOpen) then

            local openedPets : {pet} = {}

            for _=1,numberOfEggsToOpen do

                local openedPet : pet? = self:OpenEgg(eggId)
                if openedPet then
                    table.insert(openedPets, openedPet)
                end
            end

            -- remove the price of the egg times the number of times the player got a pet
            p:UpdateCoinsAmount(-price * #openedPets)

            return openedPets
        end
    end

    return {}
end


--[[
    Checks and returns if a pet can be equipped

    @return boolean, true if a pet can be equipped, false otherwise
]]--
function PetModule:CanEquipPet() : boolean
    return self.currentlyEquippedPets < self.maxEquippedPets
end


--[[
    Equips or unequips the pet matching the given id

    @param id : number, the id of the pet to equip
    @param updateFollowersMultiplier : boolean, true if the followers multiplier should be updated, false otherwise
    @return
        boolean : true if the player could equip a pet, false otherwise (success)
        boolean : true if the pet is equipped, false otherwise (equipped)
]]--
function PetModule:EquipPet(id : number, updateFollowersMultiplier : boolean) : (boolean, boolean)
    for _,pet : pet in pairs(self.ownedPets) do
        if pet.id == id then

            -- if the pet is not equipped and the player already the limit for equipped pet, we can't equip the pet
            if not pet.equipped and not self:CanEquipPet() then
                return false, false
            end

            pet.equipped = not pet.equipped

            if updateFollowersMultiplier then
                self:UpdateFollowersMultiplier()
            end

            DataStore2("pets", self.plr):Set(self.ownedPets)

            if pet.equipped then
                self.currentlyEquippedPets += 1
                self:AddPetToCharacter(pet)
            else
                self.currentlyEquippedPets -= 1
                self:RemovePetFromCharacter(pet)
            end

            return true, pet.equipped
        end
    end

    return false, false
end


--[[
    Adds the pet to the player's character

    @param pet : pet, the pet to add to the character
]]--
function PetModule:AddPetToCharacter(pet : pet)
    -- 2 if the pet is huge, 1 otherwise
    local petAttachmentSizeValue : number = pet.size == sizes.Huge and sizes.Huge or sizes.Big

    if self.plr.Character and self.plr.Character:FindFirstChild("HumanoidRootPart") then
        for _,v in ipairs(self.plr.Character.HumanoidRootPart:GetChildren()) do
            if v:IsA("Attachment") and v.Name == "PetAttachment" then

                -- if the attachment is not used and it's for the right size of pet
                if not v.Used.Value and v.Size.Value == petAttachmentSizeValue then
                    v.Used.Value = true
                    v.PetId.Value = pet.id

                    -- clone the pet's model
                    local petClone : Model
                    if displayPets:FindFirstChild(pet.identifier) then
                        petClone = displayPets[pet.identifier]:Clone()
                    end

                    -- if the pet couldn't be found, return
                    if not petClone then return end

                    if pet.size == sizes.Huge then
                        petClone:ScaleTo(2.5)
                    elseif pet.size == sizes.Big then
                        petClone:ScaleTo(1.5)
                    else
                        petClone:ScaleTo(1)
                    end

                    local petId : NumberValue = Instance.new("NumberValue")
                    petId.Name = "PetId"
                    petId.Value = pet.id
                    petId.Parent = petClone

                    local petAttachment : Attachment = Instance.new("Attachment")
                    petAttachment.CFrame = CFrame.fromEulerAnglesXYZ(0,math.rad(90), 0)
                    petAttachment.Parent = petClone.PrimaryPart

                    local alignPosition : AlignPosition = Instance.new("AlignPosition")
                    alignPosition.MaxForce = 100_000
                    alignPosition.Responsiveness = 25
                    alignPosition.Attachment0 = petAttachment
                    alignPosition.Attachment1 = v
                    alignPosition.Parent = petClone.PrimaryPart

                    local alignOrientation : AlignOrientation = Instance.new("AlignOrientation")
                    alignOrientation.MaxTorque = 50_000
                    alignOrientation.Responsiveness = 25
                    alignOrientation.Attachment0 = petAttachment
                    alignOrientation.Attachment1 = v
                    alignOrientation.Parent = petClone.PrimaryPart

                    if pet.upgrade == upgrades.Shiny then
                        local curveSize : number = 0.8
                        if pet.size == sizes.Big then
                            curveSize = 1
                        elseif pet.size == sizes.Huge then
                            curveSize = 1.5
                        end

                        local beamPart : Part = Instance.new("Part")
                        beamPart.Transparency = 1
                        beamPart.Name = "BeamPart"
                        beamPart.Size = petClone.PrimaryPart.Size
                        beamPart.CFrame = petClone.PrimaryPart.CFrame
                        beamPart.Rotation = Vector3.new(0,-90,180)
                        beamPart.CanCollide = false
                        beamPart.CanQuery = false
                        beamPart.CanTouch = false
                        beamPart.Anchored = false
                        beamPart.Massless = true
                        beamPart.Shape = Enum.PartType.Ball

                        local beamPartCenterAttachment : Attachment = Instance.new("Attachment")
                        beamPartCenterAttachment.Name = "Center"
                        beamPartCenterAttachment.Parent = beamPart

                        local beamPartAttachment0 : Attachment = Instance.new("Attachment")
                        beamPartAttachment0.Name = "Attachment"
                        beamPartAttachment0.CFrame = CFrame.new(Vector3.new(math.ceil(beamPart.Size.X) / 2, 0, 0)) -- round size to upper 0.5
                        beamPartAttachment0.Orientation = Vector3.new(0,0,90)
                        beamPartAttachment0.Parent = beamPart

                        local beamPartAttachment1 : Attachment = Instance.new("Attachment")
                        beamPartAttachment1.Name = "Attachment"
                        beamPartAttachment1.CFrame = CFrame.new(Vector3.new(0, math.ceil(beamPart.Size.Y) / 2, 0)) -- round size to upper 0.5
                        beamPartAttachment1.Orientation = Vector3.new(0,0,180)
                        beamPartAttachment1.Parent = beamPart

                        local beamPartAlignPosition : AlignPosition = Instance.new("AlignPosition")
                        beamPartAlignPosition.ReactionForceEnabled = true
                        beamPartAlignPosition.Attachment0 = petClone.PrimaryPart.Center
                        beamPartAlignPosition.Attachment1 = beamPartCenterAttachment
                        beamPartAlignPosition.MaxForce = 1_000_000
                        beamPartAlignPosition.Parent = beamPart

                        local beamPartAngularVelocity : AngularVelocity = Instance.new("AngularVelocity")
                        beamPartAngularVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
                        beamPartAngularVelocity.Attachment0 = beamPartCenterAttachment
                        beamPartAngularVelocity.AngularVelocity = Vector3.new(0,0,15)
                        beamPartAngularVelocity.MaxTorque = 1000
                        beamPartAngularVelocity.Parent = beamPart

                        local beam : Beam = Instance.new("Beam")
                        beam.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 241, 43)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 251, 125))
                        }
                        beam.Transparency = NumberSequence.new(0)
                        beam.Attachment0 = beamPartAttachment0
                        beam.Attachment1 = beamPartAttachment1
                        beam.CurveSize0 = curveSize
                        beam.CurveSize1 = curveSize
                        beam.Segments = 20
                        beam.Width0 = 0.1
                        beam.Width1 = 0.1
                        beam.Parent = beamPart

                        beamPart.Parent = petClone

                        local beamPart2 : Part = Instance.new("Part")
                        beamPart2.Transparency = 1
                        beamPart2.Name = "BeamPart"
                        beamPart2.Size = petClone.PrimaryPart.Size
                        beamPart2.CFrame = petClone.PrimaryPart.CFrame
                        beamPart2.Rotation = Vector3.new(0,180,0)
                        beamPart2.CanCollide = false
                        beamPart2.CanQuery = false
                        beamPart2.CanTouch = false
                        beamPart2.Anchored = false
                        beamPart2.Massless = true
                        beamPart2.Shape = Enum.PartType.Ball

                        local beamPart2CenterAttachment : Attachment = Instance.new("Attachment")
                        beamPart2CenterAttachment.Name = "Center"
                        beamPart2CenterAttachment.Parent = beamPart2

                        local beamPart2Attachment0 : Attachment = Instance.new("Attachment")
                        beamPart2Attachment0.Name = "Attachment"
                        beamPart2Attachment0.CFrame = CFrame.new(Vector3.new(math.ceil(beamPart2.Size.X) / 2, 0, 0)) -- round size to upper 0.5
                        beamPart2Attachment0.Orientation = Vector3.new(0,0,90)
                        beamPart2Attachment0.Parent = beamPart2

                        local beamPart2Attachment1 : Attachment = Instance.new("Attachment")
                        beamPart2Attachment1.Name = "Attachment"
                        beamPart2Attachment1.CFrame = CFrame.new(Vector3.new(0, math.ceil(beamPart2.Size.Y) / 2, 0)) -- round size to upper 0.5
                        beamPart2Attachment1.Orientation = Vector3.new(0,0,180)
                        beamPart2Attachment1.Parent = beamPart2

                        local beamPart2AlignPosition : AlignPosition = Instance.new("AlignPosition")
                        beamPart2AlignPosition.ReactionForceEnabled = true
                        beamPart2AlignPosition.Attachment0 = petClone.PrimaryPart.Center
                        beamPart2AlignPosition.Attachment1 = beamPart2CenterAttachment
                        beamPart2AlignPosition.MaxForce = 1_000_000
                        beamPart2AlignPosition.Parent = beamPart2

                        local beamPart2AngularVelocity : AngularVelocity = Instance.new("AngularVelocity")
                        beamPart2AngularVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
                        beamPart2AngularVelocity.Attachment0 = beamPart2Attachment0
                        beamPart2AngularVelocity.AngularVelocity = Vector3.new(0,0,15)
                        beamPart2AngularVelocity.MaxTorque = 1000
                        beamPart2AngularVelocity.Parent = beamPart2

                        local beam2 : Beam = Instance.new("Beam")
                        beam2.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 241, 43)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 251, 125))
                        }
                        beam2.Transparency = NumberSequence.new(0)
                        beam2.Attachment0 = beamPart2Attachment0
                        beam2.Attachment1 = beamPart2Attachment1
                        beam2.CurveSize0 = curveSize
                        beam2.CurveSize1 = curveSize
                        beam2.Segments = 10
                        beam2.Width0 = 0.1
                        beam2.Width1 = 0.1
                        beam2.Parent = beamPart2

                        beamPart2.Parent = petClone

                    elseif pet.upgrade == upgrades.Rainbow then
                        local particleEmitter1 : ParticleEmitter = Instance.new("ParticleEmitter")
                        particleEmitter1.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.new(1,0,0)),
                            ColorSequenceKeypoint.new(1, Color3.new(1,1,0))
                        }
                        particleEmitter1.Brightness = 10
                        particleEmitter1.Size = NumberSequence.new(0.4)
                        particleEmitter1.Squash = NumberSequence.new(1.5)
                        particleEmitter1.Lifetime = NumberRange.new(0.3)
                        particleEmitter1.Rate = 12
                        particleEmitter1.Speed = NumberRange.new(5)
                        particleEmitter1.Parent = petClone.PrimaryPart

                        local particleEmitter2 : ParticleEmitter = Instance.new("ParticleEmitter")
                        particleEmitter2.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.new(0,1,0)),
                            ColorSequenceKeypoint.new(1, Color3.new(0,1,1))
                        }
                        particleEmitter1.Brightness = 10
                        particleEmitter2.Size = NumberSequence.new(0.4)
                        particleEmitter2.Squash = NumberSequence.new(1.5)
                        particleEmitter2.Lifetime = NumberRange.new(0.3)
                        particleEmitter2.Rate = 12
                        particleEmitter2.Speed = NumberRange.new(5)
                        particleEmitter2.Parent = petClone.PrimaryPart

                        local particleEmitter3 : ParticleEmitter = Instance.new("ParticleEmitter")
                        particleEmitter3.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.new(0,0,1)),
                            ColorSequenceKeypoint.new(1, Color3.new(1,0,1))
                        }
                        particleEmitter1.Brightness = 10
                        particleEmitter3.Size = NumberSequence.new(0.4)
                        particleEmitter3.Squash = NumberSequence.new(1.5)
                        particleEmitter3.Lifetime = NumberRange.new(0.3)
                        particleEmitter3.Rate = 12
                        particleEmitter3.Speed = NumberRange.new(5)
                        particleEmitter3.Parent = petClone.PrimaryPart

                    elseif pet.upgrade == upgrades.Magic then
                        local curveSize : number = 0.8
                        if pet.size == sizes.Big then
                            curveSize = 1
                        elseif pet.size == sizes.Huge then
                            curveSize = 1.5
                        end

                        local beamPart : Part = Instance.new("Part")
                        beamPart.Transparency = 1
                        beamPart.Name = "BeamPart"
                        beamPart.Size = petClone.PrimaryPart.Size
                        beamPart.CFrame = petClone.PrimaryPart.CFrame
                        beamPart.Rotation = Vector3.new(0,-90,180)
                        beamPart.CanCollide = false
                        beamPart.CanQuery = false
                        beamPart.CanTouch = false
                        beamPart.Anchored = false
                        beamPart.Massless = true
                        beamPart.Shape = Enum.PartType.Ball

                        local beamPartCenterAttachment : Attachment = Instance.new("Attachment")
                        beamPartCenterAttachment.Name = "Center"
                        beamPartCenterAttachment.Parent = beamPart

                        local beamPartAttachment0 : Attachment = Instance.new("Attachment")
                        beamPartAttachment0.Name = "Attachment"
                        beamPartAttachment0.CFrame = CFrame.new(Vector3.new(math.ceil(beamPart.Size.X) / 2, 0, 0)) -- round size to upper 0.5
                        beamPartAttachment0.Orientation = Vector3.new(0,0,90)
                        beamPartAttachment0.Parent = beamPart

                        local beamPartAttachment1 : Attachment = Instance.new("Attachment")
                        beamPartAttachment1.Name = "Attachment"
                        beamPartAttachment1.CFrame = CFrame.new(Vector3.new(0, math.ceil(beamPart.Size.Y) / 2, 0)) -- round size to upper 0.5
                        beamPartAttachment1.Orientation = Vector3.new(0,0,180)
                        beamPartAttachment1.Parent = beamPart

                        local beamPartAlignPosition : AlignPosition = Instance.new("AlignPosition")
                        beamPartAlignPosition.ReactionForceEnabled = true
                        beamPartAlignPosition.Attachment0 = petClone.PrimaryPart.Center
                        beamPartAlignPosition.Attachment1 = beamPartCenterAttachment
                        beamPartAlignPosition.MaxForce = 1_000_000
                        beamPartAlignPosition.Parent = beamPart

                        local beamPartAngularVelocity : AngularVelocity = Instance.new("AngularVelocity")
                        beamPartAngularVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
                        beamPartAngularVelocity.Attachment0 = beamPartCenterAttachment
                        beamPartAngularVelocity.AngularVelocity = Vector3.new(0,0,15)
                        beamPartAngularVelocity.MaxTorque = 1000
                        beamPartAngularVelocity.Parent = beamPart

                        local beam : Beam = Instance.new("Beam")
                        beam.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 205, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(29, 44, 132))
                        }
                        beam.Transparency = NumberSequence.new(0)
                        beam.Attachment0 = beamPartAttachment0
                        beam.Attachment1 = beamPartAttachment1
                        beam.CurveSize0 = curveSize
                        beam.CurveSize1 = curveSize
                        beam.Segments = 20
                        beam.Width0 = 0.1
                        beam.Width1 = 0.1
                        beam.Parent = beamPart

                        beamPart.Parent = petClone

                        local beamPart2 : Part = Instance.new("Part")
                        beamPart2.Transparency = 1
                        beamPart2.Name = "BeamPart"
                        beamPart2.Size = petClone.PrimaryPart.Size
                        beamPart2.CFrame = petClone.PrimaryPart.CFrame
                        beamPart2.Rotation = Vector3.new(0,180,0)
                        beamPart2.CanCollide = false
                        beamPart2.CanQuery = false
                        beamPart2.CanTouch = false
                        beamPart2.Anchored = false
                        beamPart2.Massless = true
                        beamPart2.Shape = Enum.PartType.Ball

                        local beamPart2CenterAttachment : Attachment = Instance.new("Attachment")
                        beamPart2CenterAttachment.Name = "Center"
                        beamPart2CenterAttachment.Parent = beamPart2

                        local beamPart2Attachment0 : Attachment = Instance.new("Attachment")
                        beamPart2Attachment0.Name = "Attachment"
                        beamPart2Attachment0.CFrame = CFrame.new(Vector3.new(math.ceil(beamPart2.Size.X) / 2, 0, 0)) -- round size to upper 0.5
                        beamPart2Attachment0.Orientation = Vector3.new(0,0,90)
                        beamPart2Attachment0.Parent = beamPart2

                        local beamPart2Attachment1 : Attachment = Instance.new("Attachment")
                        beamPart2Attachment1.Name = "Attachment"
                        beamPart2Attachment1.CFrame = CFrame.new(Vector3.new(0, math.ceil(beamPart2.Size.Y) / 2, 0)) -- round size to upper 0.5
                        beamPart2Attachment1.Orientation = Vector3.new(0,0,180)
                        beamPart2Attachment1.Parent = beamPart2

                        local beamPart2AlignPosition : AlignPosition = Instance.new("AlignPosition")
                        beamPart2AlignPosition.ReactionForceEnabled = true
                        beamPart2AlignPosition.Attachment0 = petClone.PrimaryPart.Center
                        beamPart2AlignPosition.Attachment1 = beamPart2CenterAttachment
                        beamPart2AlignPosition.MaxForce = 1_000_000
                        beamPart2AlignPosition.Parent = beamPart2

                        local beamPart2AngularVelocity : AngularVelocity = Instance.new("AngularVelocity")
                        beamPart2AngularVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
                        beamPart2AngularVelocity.Attachment0 = beamPart2Attachment0
                        beamPart2AngularVelocity.AngularVelocity = Vector3.new(0,0,15)
                        beamPart2AngularVelocity.MaxTorque = 1000
                        beamPart2AngularVelocity.Parent = beamPart2

                        local beam2 : Beam = Instance.new("Beam")
                        beam2.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 205, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(29, 44, 132))
                        }
                        beam2.Transparency = NumberSequence.new(0)
                        beam2.Attachment0 = beamPart2Attachment0
                        beam2.Attachment1 = beamPart2Attachment1
                        beam2.CurveSize0 = curveSize
                        beam2.CurveSize1 = curveSize
                        beam2.Segments = 10
                        beam2.Width0 = 0.1
                        beam2.Width1 = 0.1
                        beam2.Parent = beamPart2

                        beamPart2.Parent = petClone

                        local particleEmitter : ParticleEmitter = Instance.new("ParticleEmitter")
                        particleEmitter.Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(67, 205, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(29, 44, 132))
                        }
                        particleEmitter.Brightness = 5
                        particleEmitter.Size = NumberSequence.new(0.4)
                        particleEmitter.Squash = NumberSequence.new(1.5)
                        particleEmitter.Lifetime = NumberRange.new(0.3)
                        particleEmitter.Rate = 40
                        particleEmitter.Speed = NumberRange.new(5)
                        particleEmitter.Parent = petClone.PrimaryPart
                    end

                    -- move the pet to the attachment it will be using
                    petClone:PivotTo(v.WorldCFrame)

                    -- parent the pet to the pets folder in the character or destroy it if the folder doesn't exist
                    if self.plr.Character and self.plr.Character:FindFirstChild("Pets") then
                        petClone.PrimaryPart.Anchored = false
                        petClone.Parent = self.plr.Character.Pets
                    else
                        -- if the folder is not created yet, we wait for it to be created (it's mainly the case when the player joins the game (since this function is called before the folder is created))
                        coroutine.wrap(function()
                            self.plr.Character:WaitForChild("Pets")

                            petClone.PrimaryPart.Anchored = false
                            petClone.Parent = self.plr.Character.Pets
                        end)()
                    end

                    return
                end
            end
        end
    end
end


--[[
    Removes the given from the player's character

    @param pet : pet, the pet to remove from the character
]]--
function PetModule:RemovePetFromCharacter(pet : pet)
    -- 2 if the pet is huge, 1 otherwise
    local petAttachmentSizeValue : number = pet.size == sizes.Huge and sizes.Huge or sizes.Big

    if self.plr.Character and self.plr.Character:FindFirstChild("HumanoidRootPart") then
        for _,v in ipairs(self.plr.Character.HumanoidRootPart:GetChildren()) do
            if v:IsA("Attachment") and v.Name == "PetAttachment" then

                -- if the attachment is not used and it's for the right size of pet
                if v.Used.Value and v.Size.Value == petAttachmentSizeValue and v.PetId.Value == pet.id then
                    v.Used.Value = false

                    -- remove the pet from the player's character
                    if self.plr.Character and self.plr.Character:FindFirstChild("Pets") then
                        for _,petModel : Model in ipairs(self.plr.Character.Pets:GetChildren()) do
                            if petModel.PetId.Value == pet.id then
                                petModel:Destroy()
                            end
                        end
                    end

                    return
                end

            end
        end
    end
end


--[[
    Loads the equipped pets and updates the followers multiplier
]]--
function PetModule:LoadEquippedPets()
    for _,pet : pet in pairs(self.ownedPets) do
        if pet.equipped then
            self.currentlyEquippedPets += 1
            self:AddPetToCharacter(pet)
        end
    end

    self:UpdateFollowersMultiplier()
end


--[[
    Equips the best pets the player owns

    @return {number}, a table containing the id of all the equiped pets
]]--
function PetModule:EquipBest() : {number}
    local equippedPets : {number} = {}

    self:UnequipAllPets()

    table.sort(self.ownedPets, function(pet1 : pet, pet2 : pet)
        return pet1.activeBoost > pet2.activeBoost
    end)

    for _,pet in pairs(self.ownedPets) do
        local success : boolean, equipped : boolean = self:EquipPet(pet.id, false)

        if success and equipped then
            table.insert(equippedPets, pet.id)
        end

        if not self:CanEquipPet() then
            break
        end
    end

    self:UpdateFollowersMultiplier()

    return equippedPets
end


--[[
    Unequips all the currently equipped pets
]]--
function PetModule:UnequipAllPets()
    for _,pet : pet in pairs(self.ownedPets) do
        if pet.equipped then
            pet.equipped = false

            self.currentlyEquippedPets -= 1

            self:RemovePetFromCharacter(pet)
        end
    end

    self:UpdateFollowersMultiplier()
end


--[[
    Deletes the pet matching the given id

    @param id : number, the id of the pet to delete
    @return boolean, true if the pet could be deleted, false otherwise
]]--
function PetModule:DeletePet(id : number) : boolean
    local deleted : boolean = false

    -- remove the pet from the table
    for i : number, pet : pet in pairs(self.ownedPets) do
        if pet.id == id then
            if pet.equipped then
                self.currentlyEquippedPets -= 1

                self:RemovePetFromCharacter(pet)
            end

            table.remove(self.ownedPets, i)
            deleted = true

            DataStore2("pets", self.plr):Set(self.ownedPets)

            break
        end
    end

    self:UpdateFollowersMultiplier()

    return deleted
end


--[[
    Deletes all the player's unequipped pets (except the mystical ones to prevent any accidental deletion)

    @return the table containing the pets left the player owns (new table of pets after deletion)
]]--
function PetModule:DeleteUnequippedPets() : {pet}
    local newOwnedPets : {pet} = {}

    for _,pet : pet in pairs(self.ownedPets) do
        if pet.equipped or pet.rarity == rarities.Mystical then
            table.insert(newOwnedPets, pet)
        end
    end

    self.ownedPets = newOwnedPets

    DataStore2("pets", self.plr):Set(self.ownedPets)

    return self.ownedPets
end


--[[
    Crafts the pet matching the given id into a bigger one

    @param id : number, the id of the pet to craft
    @return, true if the pet could be craft, false otherwise
]]--
function PetModule:CraftPet(id : number) : boolean

    -- find the pet to craft
    local petToCraft : pet
    for _,pet : pet in pairs(self.ownedPets) do
        if pet.id == id then
            petToCraft = pet
        end
    end

    -- if the pet couldn't be found, return
    if not petToCraft then return false end

    -- if the pet is already a huge one, return
    if petToCraft.size == 2 then return false end

    -- find 2 pets (other than petToCraft) that have the same identifier, size and upgrade and store their position in a table so that we can then remove them
    local petsToRemovePositions : {number} = {}
    for i : number, pet : pet in pairs(self.ownedPets) do
        if pet.identifier == petToCraft.identifier and pet.size == petToCraft.size and pet.upgrade == petToCraft.upgrade and pet.id ~= petToCraft.id then
            table.insert(petsToRemovePositions, i)

            -- unequip the pet if it's equipped
            if pet.equipped then
                self:EquipPet(pet.id, false)
            end

            -- if we have found 2 matching pets, stop because we don't want to remove all matching pets
            if #petsToRemovePositions == 2 then
                break
            end
        end
    end


    petToCraft.size += 1

    -- if we couldn't find 2 other matching pets, return
    if #petsToRemovePositions ~= 2 then return false end

    -- sort the table by descending order
    table.sort(petsToRemovePositions, function(a, b)
        return a > b
    end)

    table.remove(self.ownedPets, petsToRemovePositions[1])
    table.remove(self.ownedPets, petsToRemovePositions[2])


    -- if the pet to craft was equipped, update the pet size of the pet in the player's character
    if petToCraft.equipped then
        self:RemovePetFromCharacter(petToCraft)
        self:AddPetToCharacter(petToCraft)
    end

    petToCraft.activeBoost = self:CalculateActiveBoost(petToCraft)

    DataStore2("pets", self.plr):Set(self.ownedPets)

    self:UpdateFollowersMultiplier()

    return true
end


--[[
    Calculates the active boost for the given pet (based on its base boost, size and upgrade)

    @param pet : pet, the pet to calculate the active boost for
    @return number, the calculated active boost
]]--
function PetModule:CalculateActiveBoost(pet : pet) : number
    local sizeBoost : number = 1
    local upgradeBoost : number = 1

    if pet.size == sizes.Big then
        sizeBoost = 1.5
    elseif pet.size == sizes.Huge then
        sizeBoost = 2
    end

    if pet.upgrade == upgrades.Shiny then
        upgradeBoost = 1.5
    elseif pet.upgrade == upgrades.Rainbow then
        upgradeBoost = 2.5
    elseif pet.upgrade == upgrades.Magic then
        upgradeBoost = 7
    end

    return math.floor((pet.baseBoost * sizeBoost * upgradeBoost) * 100) / 100
end


--[[
    Updates the followers multiplier based on the equipped pets
]]--
function PetModule:UpdateFollowersMultiplier()
    local followersMultiplier : number = 0

    for _,pet : pet in pairs(self.ownedPets) do
        if pet.equipped then
            followersMultiplier += pet.activeBoost
        end
    end

    -- remove 1 because the multiplier is already at 1 by default
    self.followersMultiplier = math.max(followersMultiplier - 1, 0)
end


--[[
    Upgrades the given pet with the given upgrade type

    @param id : number, the id of the pet to upgrade
	@param upgradeType : number, the upgrade type the player wants to upgrade his pet to (shiny, rainbow)
	@param numberOfPetsInMachine : number, the number of pets the player put in the machine, used to know the odds of the upgrade succeeding
	@return
		boolean, true if the upgrade succeeded, false otherwise
		{pets}, a table containing the pets the player owns (new table of pets after upgrade)
]]--
function PetModule:UpgradePet(id : number, upgradeType : number, numberOfPetsInMachine : number) : (boolean, {pet})

    -- find the pet to upgrade
    local petToUpgrade : pet
    for _,pet : pet in pairs(self.ownedPets) do
        if pet.id == id then
            petToUpgrade = pet
        end
    end

    -- if the pet couldn't be found, return
    if not petToUpgrade then return false, self.ownedPets end

    -- decrease numberOfPetsInMachine because we don't want to delete the pet matching the given id
    numberOfPetsInMachine -= 1

    -- find numberOfPetsInMachine pets (other than petToUpgrade) that have the same identifier, size and upgrade and store their position in a table so that we can then remove them
    local petsToRemovePositions : {number} = {}
    for i : number, pet : pet in pairs(self.ownedPets) do
        if pet.identifier == petToUpgrade.identifier and pet.size == petToUpgrade.size and pet.upgrade == petToUpgrade.upgrade and pet.id ~= petToUpgrade.id then
            table.insert(petsToRemovePositions, i)

            -- unequip the pet if it's equipped
            if pet.equipped then
                self:EquipPet(pet.id, false)
            end

            -- if we have found numberOfPetsInMachine matching pets, stop because we don't want to remove all matching pets
            if #petsToRemovePositions == numberOfPetsInMachine then
                break
            end
        end
    end

    if #petsToRemovePositions < numberOfPetsInMachine then return false, self.ownedPets end

    -- sort the table by descending order
    table.sort(petsToRemovePositions, function(a, b)
        return a > b
    end)

    -- remove all the pets used for the upgrade (except the one with the id matching the given id) whether or not the upgrade succeeds
    for _,position : number in pairs(petsToRemovePositions) do
        table.remove(self.ownedPets, position)
    end

    -- calculate the chance of success of the upgrade
    -- (divide 0.2 by upgradeType because if it's a shiny (1) upgrade, there is a 0.2 * numberOfPets chance while if it's a rainbow (2) upgrade, there is a 0.1 * numberOfPets chance)
    local successChance : number = (0.2 / upgradeType) * (numberOfPetsInMachine + 1)

    if math.random() <= successChance then

        -- set the new upgrade for the pet
        petToUpgrade.upgrade = upgradeType

        -- if the pet to craft was equipped, update the pet size of the pet in the player's character
        if petToUpgrade.equipped then
            self:RemovePetFromCharacter(petToUpgrade)
            self:AddPetToCharacter(petToUpgrade)
        end

        petToUpgrade.activeBoost = self:CalculateActiveBoost(petToUpgrade)

        DataStore2("pets", self.plr):Set(self.ownedPets)

        self:UpdateFollowersMultiplier()

        return true, self.ownedPets

    else
        -- if the upgrade failed, also remove the pet with the id matching the given id
        for i : number, pet : pet in pairs(self.ownedPets) do
            if pet.id == id then
                table.remove(self.ownedPets, i)
                break
            end
        end

        return false, self.ownedPets
    end

    return false, self.ownedPets
end


--[[
    Upgrades a pet to magic
]]--
function PetModule:MagicUpgradePet()
    if self.magicUpgradePetId then
        local id : number = self.magicUpgradePetId

        for _,pet : pet in pairs(self.ownedPets) do
            if pet.id == id then
                pet.upgrade = upgrades.Magic

                -- if the pet to craft was equipped, update the pet size of the pet in the player's character
                if pet.equipped then
                    self:RemovePetFromCharacter(pet)
                    self:AddPetToCharacter(pet)
                end

                pet.activeBoost = self:CalculateActiveBoost(pet)

                DataStore2("pets", self.plr):Set(self.ownedPets)

                self:UpdateFollowersMultiplier()
            end
        end
    end
end


return PetModule