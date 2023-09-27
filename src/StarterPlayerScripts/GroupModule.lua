local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utility = require(script.Parent:WaitForChild("Utility"))
local Promise = require(ReplicatedStorage:WaitForChild("Promise"))

local lplr = Players.LocalPlayer

local playerGui : PlayerGui = lplr.PlayerGui

local groupChestScreenGui : ScreenGui = playerGui:WaitForChild("GroupChestReward")
local groupChestBackground : Frame = groupChestScreenGui:WaitForChild("Background")
local groupChestCloseButton : ImageButton = groupChestBackground:WaitForChild("Close")
local groupChestDescription : TextLabel = groupChestBackground:WaitForChild("Description")

local groupChestTouchDetector : Part = workspace:WaitForChild("GroupChest"):WaitForChild("TouchDetector")

local FLOAT_GAMES_GROUP_ID : number = 33137062


export type GroupModule = {
    isInGroupLoaded : boolean,
    isInGroup : boolean,
    rainbowTextPromise : Promise.Promise,
    utility : Utility.Utility,
    closeGuiConnection : RBXScriptSignal,
    new : (utility : Utility.Utility) -> GroupModule,
    IsInGroup : (self : GroupModule) -> boolean,
    CollectReward : (self : GroupModule) -> nil,
    OpenGui : (self : GroupModule) -> nil,
    CloseGui : (self : GroupModule) -> nil
}


local GroupModule : GroupModule = {}
GroupModule.__index = GroupModule


function GroupModule.new(utility : Utility.Utility)
    local groupModule : GroupModule = {}
    setmetatable(groupModule, GroupModule)

    groupModule.isInGroupLoaded = false
    groupModule.isInGroup = false

    groupModule.rainbowTextPromise = nil

    groupModule.utility = utility
    groupModule.closeGuiConnection = nil

    groupChestTouchDetector.Touched:Connect(function(hit : BasePart)
        if hit.Parent and hit.Name == "HumanoidRootPart" then
            if Players:GetPlayerFromCharacter(hit.Parent) == lplr then
                if not groupModule:IsInGroup() then
                    groupModule:OpenGui()
                end
            end
        end
    end)

    groupChestTouchDetector.TouchEnded:Connect(function(hit : BasePart)
        if hit.Parent and hit.Name == "HumanoidRootPart" then
            if Players:GetPlayerFromCharacter(hit.Parent) == lplr then
                groupModule:CloseGui()
            end
        end
    end)

    -- load the value to know if the player is in a group
    groupModule:IsInGroup()

    return groupModule
end


--[[
    Checks if the player is in the group


    @return boolean, true if the player is in the group, false otherwise
]]--
function GroupModule:IsInGroup() : boolean
    if self.isInGroupLoaded then
        return self.isInGroup

    else
        local success, isInGroup = pcall(function()
            return lplr:IsInGroup(FLOAT_GAMES_GROUP_ID)
        end)

        if success then
            self.isInGroupLoaded = true
            self.isInGroup = isInGroup

            return self.isInGroup
        end
    end

    return false
end


--[[
    Opens the gui
]]--
function GroupModule:OpenGui()
    if not groupChestBackground.Visible then

        local uiOriginalSize : UDim2 = groupChestBackground.Size
        groupChestBackground.Size = UDim2.new(0,0,0,0)

        self.utility.BlurBackground(true)

        groupChestBackground.Visible = true

        groupChestBackground:TweenSize(
            uiOriginalSize,
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Linear,
            0.2
        )

        -- rainbow color cycling effect on the text
        if not self.rainbowTextPromise then
            self.rainbowTextPromise = Promise.new(function(resolve)
                while groupChestBackground.Visible do
                    for i=0,1,0.01 do
                        groupChestDescription.TextColor3 = Color3.fromHSV(i,0.67,1)
            
                        for _=1,10 do
                            RunService.Heartbeat:Wait()
                        end
                    end
                end

                resolve()
            end)
            :finally(function()
                self.rainbowTextPromise = nil
            end)
        end

        self.closeGuiConnection = groupChestCloseButton.MouseButton1Down:Connect(function()
            self:CloseGui()
        end)
    end
end


--[[
    Closes the gui
]]--
function GroupModule:CloseGui()
    -- disconnect the close gui connection
    if self.closeGuiConnection then
        self.closeGuiConnection:Disconnect()
        self.closeGuiConnection = nil
    end

    if groupChestBackground.Visible then
        local upgradesOriginalSize : UDim2 = groupChestBackground.Size

        self.utility.BlurBackground(false)

        groupChestBackground:TweenSize(
            UDim2.new(0,0,0,0),
            Enum.EasingDirection.InOut,
            Enum.EasingStyle.Linear,
            0.2,
            false,
            function()
                groupChestBackground.Visible = false
                groupChestBackground.Size = upgradesOriginalSize
            end
        )
    end
end


--[[
    Displays the collect reward gui
]]--
function GroupModule:CollectReward()
    groupChestDescription.Text = "Thanks for joining \"Float Games\"! You receive:"
    self:OpenGui()
end


return GroupModule