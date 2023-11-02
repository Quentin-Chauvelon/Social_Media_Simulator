local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local lplr = Players.LocalPlayer
local playerGui = lplr:WaitForChild("PlayerGui")

local loadingScreenGui : ScreenGui = ReplicatedFirst:WaitForChild("LoadingScreenGui")
local loadingScreenBackground : CanvasGroup = loadingScreenGui:WaitForChild("Background")
local loadingScreenProgressBar : Frame = loadingScreenBackground:WaitForChild("ProgressBarContainer"):WaitForChild("ProgressBar")
local loadingScreenProgressBarStripes : ImageLabel = loadingScreenBackground.ProgressBarContainer.ProgressBar:WaitForChild("Stripes")
local loadingScreenPercentageTextLabel : TextLabel = loadingScreenBackground.ProgressBarContainer:WaitForChild("Percentage")
-- local loadingScreenLoadingTextLabel : TextLabel = loadingScreenBackground:WaitForChild("Loading")
loadingScreenGui.Parent = playerGui

local TWEEN_DURATION_FRAMES : number = 10 * 60


-- remove the default loading screen
ReplicatedFirst:RemoveDefaultLoadingScreen()


-- local text : string = "Loading..."
-- local defaultSize : number = loadingScreenLoadingTextLabel.TextBounds.Y

for i=1,TWEEN_DURATION_FRAMES do
    local progress : number = i / TWEEN_DURATION_FRAMES
    loadingScreenProgressBar.Size = UDim2.new(progress, 0, 1, 0)
    loadingScreenProgressBarStripes.TileSize = UDim2.new(1 / progress, 0, 1, 0)

    loadingScreenPercentageTextLabel.Text = string.format("%d%%", math.round(progress * 100))

    -- loading text "bouncing" animation
    -- local j : number = math.floor(1 + (0.2) * (i - 1)) % (math.round(TWEEN_DURATION_FRAMES / 60) + 5)

    -- if j ~= 0 and j <= #text then
    --     loadingScreenLoadingTextLabel.Text = string.format(
    --         '<font size="%d"><stroke color="#486c81" joins="miter" thickness="4" transparency="0">%s<font size="%d">%s</font>%s</stroke></font>',
    --         defaultSize,
    --         text:sub(1, j - 1),
    --         defaultSize + 7,
    --         text:sub(j,j),
    --         text:sub(j + 1)
    --     )
    -- end

    if lplr:FindFirstChild("HideLoadingScreen") and lplr.HideLoadingScreen.Value then
        break
    end

    RunService.Heartbeat:Wait()
end


-- loadingScreenPercentageTextLabel.Text = "100%"

-- loadingScreenProgressBar:TweenSize(
--     UDim2.new(1,0,1,0),
--     Enum.EasingDirection.InOut,
--     Enum.EasingStyle.Linear,
--     1
-- )

-- task.wait(1)

local done : number = loadingScreenProgressBar.Size.X.Scale
local left : number = 1 - done

for i=1,60 do
    local progress : number = left * (i / 60) + done
    loadingScreenProgressBar.Size = UDim2.new(progress, 0, 1, 0)
    loadingScreenProgressBarStripes.TileSize = UDim2.new(1 / progress, 0, 1, 0)

    loadingScreenPercentageTextLabel.Text = string.format("%d%%", math.round(progress * 100))

    RunService.Heartbeat:Wait()
end


-- tween the tranparency of the tween (fade out)
TweenService:Create(
    loadingScreenBackground,
    TweenInfo.new(
        1.5,
        Enum.EasingStyle.Linear
    ),
    {GroupTransparency = 1}
):Play()

task.wait(1.5)

loadingScreenGui:Destroy()
script:Destroy()