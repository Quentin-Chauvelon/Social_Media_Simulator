local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local Utility = require(script.Parent:WaitForChild("Utility"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))

local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local mobilePotionsOpenButton : ImageButton = playerGui:WaitForChild("Menu"):WaitForChild("SideButtons"):WaitForChild("PotionsButton")
local potions : ScreenGui = playerGui:WaitForChild("Potions")
local mobilePotionsBackground : Frame = potions:WaitForChild("Mobile")
local mobilePotionsCloseButton : TextButton = mobilePotionsBackground:WaitForChild("Close")
local mobilePotionTemplate : Frame = mobilePotionsBackground:WaitForChild("PotionTemplate")
local mobileActivePotionsContainer : ScrollingFrame = mobilePotionsBackground:WaitForChild("ActivePotionsContainer")
local mobileNoActivePotions : TextLabel = mobilePotionsBackground:WaitForChild("NoActivePotions")
local pcPotionsBackground : Frame = potions:WaitForChild("PC")


export type PotionModule = {
    activePotions : {potion},
    mobileGui : boolean,
    timerPromise : Promise.Promise,
    utility : Utility.Utility,
    new : (utility : Utility.Utility) -> PotionModule,
    DisplayActivePotions : (self : PotionModule) -> nil,
    StartPotionsTimer : (self : PotionModule) -> nil,
    ClearAllPotions : (self : PotionModule) -> nil,
    GetPotionImage : (self : PotionModule, potion : potion) -> string,
    OpenMobileGui : (self : PotionModule) -> nil,
    CloseMobileGui : (self : PotionModule) -> nil
}

export type potion = {
    type : number,
    value : number,
    duration : number,
    timeLeft : number,
    timeLeftText : TextLabel
}

type potionTypes = {
    Followers : number,
    Coins : number,
    AutoPostSpeed : number,
    FollowersCoins : number
}

local potionTypes : potionTypes = {
    Followers = 0,
    Coins = 1,
    AutoPostSpeed = 2,
    FollowersCoins = 3
}


local PotionModule : PotionModule = {}
PotionModule.__index = PotionModule


function PotionModule.new(utility : Utility.Utility)
    local potionModule : PotionModule = {}
    
    potionModule.activePotions = {}
    
    -- detect if the player is on mobile to display the correct gui
    if UserInputService.TouchEnabled and not UserInputService.GamepadEnabled and not GuiService:IsTenFootInterface() then
        potionModule.mobileGui = true
    else
        potionModule.mobileGui = false
    end

    -- while the non mobile version does not have a better gui, we consider all players as mobile players
    potionModule.mobileGui = true

    if potionModule.mobileGui then
        mobilePotionsOpenButton.Visible = true
    end

    potionModule.utility = utility

    -- store all UIStroke in a table to change them easily later
    local potionsGuiUIStroke : {UIStroke} = {}
    for _,v : Instance in ipairs(potions:GetDescendants()) do
        if v:IsA("UIStroke") then
            table.insert(potionsGuiUIStroke, v)
        end
    end

    utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
        local thickness : number = utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 2, 5)
        for _,uiStroke : UIStroke in pairs(potionsGuiUIStroke) do
            uiStroke.Thickness = thickness
        end
    end)

    table.insert(utility.guisToClose, mobilePotionsBackground)

    -- open the gui when clicking on the potions button
    mobilePotionsOpenButton.MouseButton1Down:Connect(function()
        potionModule:OpenMobileGui()
    end)

    return setmetatable(potionModule, PotionModule)
end


--[[
    Displays all the active potions sent by the server
]]--
function PotionModule:DisplayActivePotions()
    self:ClearAllPotions()

    if self.mobileGui then
        -- if the player has no active potions, show the no active potions text
        if #self.activePotions == 0 then
            mobileActivePotionsContainer.Visible = false
            mobileNoActivePotions.Visible = true

        -- if the player does have active potions, show the container
        else
            mobileNoActivePotions.Visible = false
            mobileActivePotionsContainer.Visible = true

            for i : number, potion : potion in pairs(self.activePotions) do

                local potionTemplateClone : Frame = mobilePotionTemplate:Clone()
                potionTemplateClone.Potion.Image = self:GetPotionImage(potion)

                if potion.type == potionTypes.Followers then 
                    potionTemplateClone.PotionDetails.Text = "Followers x" .. tostring(potion.value)
                    potionTemplateClone.PotionDetails.TextColor3 = Color3.fromRGB(221, 142, 255)
                    potionTemplateClone.PotionDetails.UIStroke.Color = Color3.fromRGB(59, 38, 72)

                elseif potion.type == potionTypes.Coins then 
                    potionTemplateClone.PotionDetails.Text = "Coins x" .. tostring(potion.value)
                    potionTemplateClone.PotionDetails.TextColor3 = Color3.fromRGB(255, 212, 52)
                    potionTemplateClone.PotionDetails.UIStroke.Color = Color3.fromRGB(65, 54, 13)

                elseif potion.type == potionTypes.AutoPostSpeed then 
                    potionTemplateClone.PotionDetails.Text = "Auto post speed -" .. tostring(potion.value / 1000) .. "s"
                    potionTemplateClone.PotionDetails.TextColor3 = Color3.fromRGB(82, 255, 82)
                    potionTemplateClone.PotionDetails.UIStroke.Color = Color3.fromRGB(18, 57, 18)

                elseif potion.type == potionTypes.FollowersCoins then 
                    potionTemplateClone.PotionDetails.Text = "Followers & Coins x" .. tostring(potion.value)
                    potionTemplateClone.PotionDetails.TextColor3 = Color3.fromRGB(221, 142, 255)
                    potionTemplateClone.PotionDetails.UIStroke.Color = Color3.fromRGB(59, 38, 72)
                end

                self.activePotions[i]["timeLeftText"] = potionTemplateClone.Potion.TimeLeft

                potionTemplateClone.Visible = true
                potionTemplateClone.Parent = mobileActivePotionsContainer
            end
        end
    end
end


--[[
    Counts down and updates the time left for all the displayed potions
    Stops once there are no more active potions
]]--
function PotionModule:StartPotionsTimer()
    if not self.timerPromise then
        self.timerPromise = Promise.new(function(resolve)
            
            while #self.activePotions ~= 0 do
                for _,potion : potion in pairs(self.activePotions) do
                    potion.timeLeft -= 1
                    
                    if potion.timeLeft > 0 then
                        potion.timeLeftText.Text = string.format("%0.2i", math.floor(potion.timeLeft / 60)) .. ":" .. string.format("%0.2i", potion.timeLeft % 60)
                    end
                end

                task.wait(1)
            end

            resolve()
            self.timerPromise = nil
            print("updated timer")
        end)
    end
end


--[[
    Clears all potions ui
]]--
function PotionModule:ClearAllPotions()
    if self.mobileGui then
        for _,v : GuiObject in ipairs(mobileActivePotionsContainer:GetChildren()) do
            if v:IsA("Frame") then
                v:Destroy()
            end
        end
    end
end


--[[
    Returns the image link for the given potion (based on the type and duration)

    @param potion : potion, the potion to use to return the image
    @return string, the image link for the given potion
]]--
function PotionModule:GetPotionImage(potion : potion) : string
    if potion.type == potionTypes.Followers then
        return "http://www.roblox.com/asset/?id=14660180469"
    elseif potion.type == potionTypes.Coins then
        return "http://www.roblox.com/asset/?id=14660200620"
    elseif potion.type == potionTypes.AutoPostSpeed then
        return "http://www.roblox.com/asset/?id=14660207162"
    elseif potion.type == potionTypes.FollowersCoins then
        return "http://www.roblox.com/asset/?id=14660209764"
    else
        return "http://www.roblox.com/asset/?id=14660180469"
    end
end


--[[
    Opens the mobile gui
]]--
function PotionModule:OpenMobileGui()
    -- open the gui
    if self.utility.OpenGui(mobilePotionsBackground) then

        -- set the close gui connection (only do it if the gui was not already open, otherwise multiple connection exist and it is called multiple times)
        self.utility.SetCloseGuiConnection(
            mobilePotionsCloseButton.MouseButton1Down:Connect(function()
                self:CloseMobileGui()
            end)
        )
    end
end


--[[
    Closes the mobile gui
]]--
function PotionModule:CloseMobileGui()
    self.utility.CloseGui(mobilePotionsBackground)
end


return PotionModule