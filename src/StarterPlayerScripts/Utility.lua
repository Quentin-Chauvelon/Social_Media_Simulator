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
    Get a number between minRange and maxRange based on a and b proportionally.
    Example : 
        a = 1920, X = ?, b = 480, minRange = 0.5, maxRange = 0.8.
        Given 1920 -> 0.5 and 480 -> 0.8, what would the result be if X = 1200 ?
        1200 is the average of 1920 and 480, so proportionally our result would be 0.65 (the average of 0.5 and 0.8)
        But then it becomes harder to find the result when X = 783 for example.
    This is usually useful when calculating gui sizes based on screen size.
    For example if we want our gui to have an Size.X.Scale of 0.5 when the screen size is 1920 and 0.8 when the screen size 480. This will
    then be helpful to calculate any value in between by passing the parameters as follow : (0.5, 0.8, X, 480, 1920)

    @return number, the result
]]--
function Utility.GetNumberInRangeProportionally(a : number, X : number, b : number, minRange : number, maxRange : number) : number
    -- if X is lower or higher than minRange and maxRange, then we don't need to calculate and only return the right value
    if X <= a then return minRange end
    if X >= b then return maxRange end

    if maxRange > minRange then
        return (((maxRange - minRange) / (b - a)) * (X + a)) + (maxRange - minRange)
    else
        return ((maxRange - math.abs(((maxRange - minRange) / (b - a)) * (X + a))) + maxRange)
    end
end


--[[
    @see Utility.GetNumberInRangeProportionally
    Calculate the X between minRange and maxRange proportionally using 480 and 1920 as a and b

    @return number, the result
    ]]--
function Utility.GetNumberInRangeProportionallyDefaultWidth(X : number, minRange : number, maxRange : number) : number
    return Utility.GetNumberInRangeProportionally(480, X, 1920, minRange, maxRange)
end


--[[
    @see Utility.GetNumberInRangeProportionally
    Calculate the X between minRange and maxRange proportionally using 480 and 1920 as a and b
    
    @return number, the result
]]--
function Utility.GetNumberInRangeProportionallyDefaultHeight(X : number, minRange : number, maxRange : number) : number
    return Utility.GetNumberInRangeProportionally(320, X, 1080, minRange, maxRange)
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