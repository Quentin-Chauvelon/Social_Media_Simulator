local ServerScriptService = game:GetService("ServerScriptService")
local PetModule = require(ServerScriptService:WaitForChild("PetModule"))
local PlayerModule = require(ServerScriptService:WaitForChild("Player"))
local DataStore2 = require(ServerScriptService:WaitForChild("DataStore2"))

local plr = game:GetService("Players").PlayerAdded:Wait()


local function TableEqual(t1, t2)
    if not t1 or not t2 or typeof(t1) ~= "table" or typeof(t2) ~= "table" then
        return false
    end

    if #t1 ~= #t2 then
        return false
    end

    for i,_ in pairs(t1) do
        if typeof(t1[i]) == "table" then
            if not TableEqual(t1[i], t2[i]) then
                return false
            end
        else
            if t1[i] ~= t2[i] then
                return false
            end
        end
    end

    return true
end


-- checks if the content of two tables is the same (even if it's not the same order)
local function TableContentEqual(t1, t2)
    if #t1 ~= #t2 then
        return false
    end

    for _,v in pairs(t1) do
        if not table.find(t2, v) then
            return false
        end
    end

    return true
end


local function TableContentEqual(t1, t2) : boolean
	if type(t1) ~= "table" or type(t2)~="table" then return false end

	if t1==t2 then return true end

	for k,v in pairs(t1) do
		if t2[k] ~= v and not TableContentEqual(v,t2[k]) then
			return false
		end
	end
	for k,v in pairs(t2) do
		if t1[k] ~= v and not TableContentEqual(v,t1[k]) then
			return false
		end
	end
	return true
end


local function GetNumberOfElementsInDictionary(dictionary) : number
    local numberOfElements : number = 0

    for _,_ in pairs(dictionary) do
        numberOfElements += 1
    end

    return numberOfElements
end


local function testPetModuleNew()
    DataStore2("pets", plr):Set(nil)

    local petModule : PetModule.PetModule = PetModule.new(plr)

    print(petModule.ownedPets)
    assert(TableContentEqual(petModule.ownedPets, {}) == true)
    assert(petModule.maxEquippedPets == 3, petModule.maxEquippedPets)
    assert(petModule.inventoryCapacity == 50, petModule.inventoryCapacity)
end


local function testIsPetInventoryNotFull()
    DataStore2("pets", plr):Set(nil)

    local petModule : PetModule.PetModule = PetModule.new(plr)

    for _=1,25 do
        table.insert(petModule.ownedPets, {})
    end

    assert(petModule:IsPetInventoryFull() == false, petModule:IsPetInventoryFull())
end


local function testIsPetInventoryFull()
    DataStore2("pets", plr):Set(nil)

    local petModule : PetModule.PetModule = PetModule.new(plr)

    for _=1,75 do
        table.insert(petModule.ownedPets, {})
    end

    assert(petModule:IsPetInventoryFull() == true, petModule:IsPetInventoryFull())
end


local function testAddPetToInventory()
    DataStore2("pets", plr):Set(nil)

    local petModule : PetModule.PetModule = PetModule.new(plr)

    local pet = {
        name = "Smiling",
        rarity = 0,
        size = 0,
        upgrade = 0,
        baseBoost = 1.1,
        activeBoost = 1.1,
        equipped = false
    }

    petModule:AddPetToInventory(pet)
    
    assert(TableContentEqual(petModule.ownedPets, {pet}) == true)
    assert(TableContentEqual(DataStore2("pets", plr):Get({}), {pet}) == true)
end


local function testGetNonExistingPet()
    DataStore2("pets", plr):Set(nil)

    local petModule : PetModule.PetModule = PetModule.new(plr)

    assert(petModule:GetPetFromPetId(999) == nil, petModule:GetPetFromPetId(999))
end


local function testGetPetFromPetId()
    DataStore2("pets", plr):Set(nil)

    local petModule : PetModule.PetModule = PetModule.new(plr)

    local pet = {
        name = "Smiling",
        rarity = 0,
        size = 0,
        upgrade = 0,
        baseBoost = 1.1,
        activeBoost = 1.1,
        equipped = false
    }

    assert(TableContentEqual(petModule:GetPetFromPetId(0), pet) == true)
end


local function testOpenEgg()
    DataStore2("pets", plr):Set(nil)

    local petModule : PetModule.PetModule = PetModule.new(plr)

    local pet = petModule:OpenEgg(0)

    assert(pet ~= nil, pet)
    assert(#petModule.ownedPets == 1, #petModule.ownedPets)
end


local function testOpenEggsNotEnoughCoins()
    DataStore2("pets", plr):Set(nil)
    DataStore2("coins", plr):Set(nil)

    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.coins = 0

    local openedPets = playerModule.petModule:OpenEggs(playerModule, 0, 1)

    assert(playerModule.coins == 0, playerModule.coins)
    
    assert(#openedPets == 0, #openedPets)
    assert(#playerModule.petModule.ownedPets == 0, #playerModule.petModule.ownedPets)
    assert(#DataStore2("pets", plr):Get({}) == 0, #DataStore2("pets", plr):Get({}))
end


local function testOpen1Egg()
    DataStore2("pets", plr):Set(nil)
    DataStore2("coins", plr):Set(nil)

    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.coins = 1000

    local openedPets = playerModule.petModule:OpenEggs(playerModule, 0, 1)

    assert(playerModule.coins == 999, playerModule.coins)

    assert(#openedPets == 1, #openedPets)
    assert(#playerModule.petModule.ownedPets == 1, #playerModule.petModule.ownedPets)
    assert(#DataStore2("pets", plr):Get({}) == 1, #DataStore2("pets", plr):Get({}))
end


local function testOpen3Eggs()
    DataStore2("pets", plr):Set(nil)
    DataStore2("coins", plr):Set(nil)

    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.coins = 1000

    local openedPets = playerModule.petModule:OpenEggs(playerModule, 0, 3)

    assert(playerModule.coins == 997, playerModule.coins)
    
    assert(#openedPets == 3, #openedPets)
    assert(#playerModule.petModule.ownedPets == 3, #playerModule.petModule.ownedPets)
    assert(#DataStore2("pets", plr):Get({}) == 3, #DataStore2("pets", plr):Get({}))
end


local function testOpen6Eggs()
    DataStore2("pets", plr):Set(nil)
    DataStore2("coins", plr):Set(nil)

    local playerModule : PlayerModule.PlayerModule = PlayerModule.new(plr)
    playerModule.coins = 1000

    local openedPets = playerModule.petModule:OpenEggs(playerModule, 0, 6)

    assert(playerModule.coins == 994, playerModule.coins)
    
    assert(#openedPets == 6, #openedPets)
    assert(#playerModule.petModule.ownedPets == 6, #playerModule.petModule.ownedPets)
    assert(#DataStore2("pets", plr):Get({}) == 6, #DataStore2("pets", plr):Get({}))
end


local function test()
    testPetModuleNew()
    testIsPetInventoryNotFull()
    testIsPetInventoryFull()
    testAddPetToInventory()
    testGetNonExistingPet()
    testGetPetFromPetId()
    testOpenEggsNotEnoughCoins()
    testOpenEgg()
    testOpen1Egg()
    testOpen3Eggs()
    testOpen6Eggs()

    print("All tests passed !")
end

test()