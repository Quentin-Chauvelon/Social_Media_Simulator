local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = {}

local uiToResize = {}
local debounce = true


--[[
    Add a function to the uiToResize table so it can be updated when the window is resized

    @param func : function, the function to run when the window is resized
]]--
function Utility.ResizeUIOnWindowResize(func)
    func()

    table.insert(uiToResize, func)
end


--[[
    Run all the functions in the uiToResize table when the window is resized (mainly used to resize the ui on scren size change)
]]--
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if debounce then
        debounce = false
        task.wait(1)

        for _,func in pairs(uiToResize) do
            func()
        end

        debounce = true
    end

end)


return Utility