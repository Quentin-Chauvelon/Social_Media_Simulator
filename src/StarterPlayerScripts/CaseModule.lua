local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(script.Parent:WaitForChild("Utility"))
local GamePassModule = require(script.Parent:WaitForChild("GamePassModule"))

local CaseRF : RemoteFunction = ReplicatedStorage:WaitForChild("Case")

local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local caseOpenButton : ImageButton = playerGui:WaitForChild("Menu"):WaitForChild("SideButtons"):WaitForChild("CasesButton")
local casesScreenGui : ScreenGui = playerGui:WaitForChild("PhoneCases")
local casesBackground : Frame = casesScreenGui:WaitForChild("Background")
local casesCloseButton : ImageButton = casesBackground:WaitForChild("Close")
local casesListContainer : ScrollingFrame = casesBackground:WaitForChild("ContentContainer"):WaitForChild("PhoneCasesListContainer")
local casesListContainerUIGridLayout : UIGridLayout = casesListContainer:WaitForChild("UIGridLayout")
local caseButtonDeactivated : Frame = casesBackground.ContentContainer:WaitForChild("PhoneCaseUpgradeContainer"):WaitForChild("CaseButtonDeactivated")
local caseBuyButton : TextButton = casesBackground.ContentContainer.PhoneCaseUpgradeContainer:WaitForChild("CaseBuyButton")
local caseRobuxBuyButton : TextButton = casesBackground.ContentContainer.PhoneCaseUpgradeContainer:WaitForChild("CaseRobuxBuyButton")
local casePrice : TextLabel = caseBuyButton:WaitForChild("CasePrice")
local caseEquipped : Frame = casesBackground.ContentContainer.PhoneCaseUpgradeContainer:WaitForChild("CaseEquipped")
local speedBoostText : TextLabel = casesBackground.ContentContainer.PhoneCaseUpgradeContainer:WaitForChild("SpeedBoostText")


local DEFAULT_BACKGROUND_COLOR = Color3.fromRGB(230, 230, 230)
local OWNED_BACKGROUND_COLOR = Color3.fromRGB(58, 214, 68)
local EQUIPPED_BACKGROUND_COLOR = Color3.fromRGB(255, 212, 52)


export type CaseModule = {
    selectedCase : string,
    equippedCase : string,
    caseItemsClickConnections : {RBXScriptConnection},
    buyCaseButtonConnection : RBXScriptConnection,
    buyRobuxCaseButtonConnection : RBXScriptConnection,
    utility : Utility.Utility,
    new : (utility : Utility.Utility) -> CaseModule,
    OpenGui : (self : CaseModule) -> nil,
    UpdateAllCasesBackgroundColors : (self : CaseModule) -> nil,
    SelectCase : (self : CaseModule, caseListItem : ImageButton) -> nil,
    BuyCase : (self : CaseModule) -> nil,
    CaseBoughtSuccessfully : (self : CaseModule, caseColor : string) -> nil,
    CloseGui : (self : CaseModule) -> nil,
}

type savedCases = {
    equippedCase : string,
    ownedCases : {
        [string] : boolean
    }
}


local CaseModule : CaseModule = {}
CaseModule.__index = CaseModule


function CaseModule.new(utility : Utility.Utility)
    local caseModule = {}

    caseModule.selectedCase = ""
    caseModule.caseItemsClickConnections = {}
    caseModule.utility = utility

    -- store all UIStroke in a table to change them easily later
    local casesGuiUIStroke : {UIStroke} = {}
    for _,v : Instance in ipairs(casesBackground:GetDescendants()) do
        if v:IsA("UIStroke") then
            table.insert(casesGuiUIStroke, v)
        end
    end

    utility.ResizeUIOnWindowResize(function(viewportSize : Vector2)
        local thickness : number = utility.GetNumberInRangeProportionallyDefaultWidth(viewportSize.X, 2, 5)
        for _,uiStroke : UIStroke in pairs(casesGuiUIStroke) do
            uiStroke.Thickness = thickness
        end

        -- change the ui grid layout cell size to be the exact size of the first item (otherwise using and an aspect ratio of 1 creates huge margin around the item)
        local whiteCaseItemAbsoluteSize : Vector2 = casesListContainer:WaitForChild("WhiteCase").AbsoluteSize
        casesListContainerUIGridLayout.CellSize = UDim2.new(0, whiteCaseItemAbsoluteSize.X, 0, whiteCaseItemAbsoluteSize.Y)
    end)

    table.insert(utility.guisToClose, casesBackground)

    -- open the gui when clicking on the case button
    caseOpenButton.MouseButton1Down:Connect(function()
        caseModule:OpenGui()
    end)

    -- loads the ui according to the cases the player owns
    local savedCases : savedCases = CaseRF:InvokeServer()
    caseModule.equippedCase = savedCases.equippedCase

    for _,caseUIFrame : GuiObject in ipairs(casesListContainer:GetChildren()) do
        if caseUIFrame:IsA("ImageButton") then
            local caseColor : string = caseUIFrame.Color.Value

            if savedCases.ownedCases[caseColor] then
                -- mark the case as owned
                caseUIFrame.Owned.Value = true

                -- change the background color of the case ui
                caseUIFrame.BackgroundColor3 = OWNED_BACKGROUND_COLOR
            end

            if savedCases.equippedCase == caseColor then
                -- change the background color of the case ui
                caseUIFrame.BackgroundColor3 = EQUIPPED_BACKGROUND_COLOR
            end
        end
    end

    return setmetatable(caseModule, CaseModule)
end


--[[
	Opens the cases gui
]]--
function CaseModule:OpenGui()
    -- open the gui
    if self.utility.OpenGui(casesBackground) then

        for _,caseListItem : ImageButton | UIGridLayout in ipairs(casesListContainer:GetChildren()) do
            if caseListItem:IsA("ImageButton") then
                table.insert(self.caseItemsClickConnections, caseListItem.MouseButton1Down:Connect(function()
                    self:SelectCase(caseListItem)
                end))
            end
        end

        -- pick up clicks if the player wants to buy a case
        self.buyCaseButtonConnection = caseBuyButton.MouseButton1Down:Connect(function()
            self:BuyCase()
        end)

        -- pick up clicks if the player wants to buy a robux case
        self.buyRobuxCaseButtonConnection = caseRobuxBuyButton.MouseButton1Down:Connect(function()
            self:BuyCase()
        end)

        -- set the close gui connection (only do it if the gui was not already open, otherwise multiple connection exist and it is called multiple times)
        self.utility.SetCloseGuiConnection(
            casesCloseButton.MouseButton1Down:Connect(function()
                self:CloseGui()
            end)
        )
    end
end


--[[
    Updates the background colors for all the cases based on if they are owned and/or equipped
]]--
function CaseModule:UpdateAllCasesBackgroundColors()
    for _,caseUIFrame : GuiObject in ipairs(casesListContainer:GetChildren()) do
        if caseUIFrame:IsA("ImageButton") then

            -- if the player owns the case, set the background color to OWNED_BACKGROUND_COLOR
            if caseUIFrame.Owned.Value then

                -- if the player has the case equipped, set the background color to EQUIPPED_BACKGROUND_COLOR
                if caseUIFrame.Color.Value == self.equippedCase then
                    caseUIFrame.BackgroundColor3 = EQUIPPED_BACKGROUND_COLOR
                else
                    caseUIFrame.BackgroundColor3 = OWNED_BACKGROUND_COLOR
                end

            else
                caseUIFrame.BackgroundColor3 = DEFAULT_BACKGROUND_COLOR
            end
        end
    end
end


--[[
    Fires when the player clicks on one the case item. Displays information related to the case and allows the player to buy it

    @param caseListItem : ImageButton, the case image button selected by the player
]]--
function CaseModule:SelectCase(caseListItem : ImageButton)
    local color : string = caseListItem.Color.Value

    if self.selectedCase ~= color then
        self.selectedCase = color
        
        -- hide the deactivated button (which is only used before the player selects a case for the first time)
        caseButtonDeactivated.Visible = false

        -- show the owned or buy button based on if the player owns the case
        if caseListItem.Owned.Value then
            caseBuyButton.Visible = false
            caseRobuxBuyButton.Visible = false
            caseEquipped.Visible = true

            -- equip the case when the player selects a case he owns
            local success : boolean = CaseRF:InvokeServer(color)
            if success then
                self.equippedCase = color

                self:UpdateAllCasesBackgroundColors()
            end
        else
            -- robux case
            if color == "Space" then
                caseEquipped.Visible = false
                caseBuyButton.Visible = false
                caseRobuxBuyButton.Visible = true
            
            -- non robux cases
            else
                caseEquipped.Visible = false
                caseRobuxBuyButton.Visible = false
                caseBuyButton.Visible = true
            end
        end

        speedBoostText.Text = "-" .. tostring(caseListItem.SpeedBoost.Value) .. "s on auto post"
        casePrice.Text = self.utility.AbbreviateNumber(caseListItem.Price.Value)
    end
end


--[[
    The player wants to buy a case
]]--
function CaseModule:BuyCase()
    local caseColor : string = self.selectedCase

    -- the space case can only be bought with robux
    if caseColor == "Space" then
        
        -- if the player doesn't already own the game pass
        if not GamePassModule.PlayerOwnsGamePass(GamePassModule.gamePasses.SpaceCase) then
            -- prompt the purhcase to buy the case
            GamePassModule.PromptGamePassPurchase(GamePassModule.gamePasses.SpaceCase)
        end

        return
    end

    local success : boolean = CaseRF:InvokeServer(caseColor)
    if success then
        self:CaseBoughtSuccessfully(caseColor)
    end
end


--[[
    
]]--
function CaseModule:CaseBoughtSuccessfully(caseColor : string)
    -- mark the case as equipped
    self.equippedCase = caseColor
    
    -- set the owned value to true
    if casesListContainer:FindFirstChild(caseColor .. "Case") then
        casesListContainer[caseColor .. "Case"].Owned.Value = true
    end

    self:UpdateAllCasesBackgroundColors()

    caseBuyButton.Visible = false
    caseEquipped.Visible = true
end


--[[
	Closes the cases gui
]]--
function CaseModule:CloseGui()
    self.buyCaseButtonConnection:Disconnect()
    self.buyRobuxCaseButtonConnection:Disconnect()

    for _,caseItemsClickConnection : RBXScriptConnection in pairs(self.caseItemsClickConnections) do
        caseItemsClickConnection:Disconnect()
    end
    table.clear(self.caseItemsClickConnections)

    self.utility.CloseGui(casesBackground)
end


return CaseModule