local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local plots : Folder = workspace:WaitForChild("Plots")


export type PlotModule = {
	phone : Model,
	screen : Frame,
	followerGoal : Frame,
	popSound : Sound,
	new : () -> PlotModule,
	AssignPlayerToPlot : (self : PlotModule, playerName : string) -> boolean,
	AssignPlot : (self : PlotModule, plr : Player) -> boolean,
	OnLeave : (self : PlotModule) -> nil
}


local PlotModule : PlotModule = {}
PlotModule.__index = PlotModule


function PlotModule.new()
	local plotModule = {}

	return setmetatable(plotModule, PlotModule)
end


--[[
	Reset the owner values for all the plots where the owners isn't in the game anymore. It shouldn't happen.
]]--
local function ClearUnusedPlots()
	for _,plot : Model in ipairs(plots:GetChildren()) do
		if not Players:FindFirstChild(plot.Owner.Value) then
			plot.Owner.Value = ""
		end
	end
end


--[[
	Assigns plr to the first free plot and teleports them to the plot

	@param playerName string, the name of the player whom to assign the plot to
	@return true if the player has been assigned to a plot, false otherwise (if all plots were taken)
]]--
function PlotModule:AssignPlayerToPlot(playerName : string) : boolean
	ClearUnusedPlots()

	for _,plot : Model in ipairs(plots:GetChildren()) do

		-- if the plot is free, assign the player to it
		if plot.Owner.Value == "" then
			plot.Owner.Value = playerName

			self.phone = plot
			self.screen = plot.PhoneModel.Screen.ScreenUI.Background.App
			self.followerGoal = plot.FollowerGoal.Progress.FollowerGoal
			self.popSound = plot.PrimaryPart.Pop

			self.screen.Parent.NavBar.Visible = true
			self.screen.Parent.BackgroundColor3 = Color3.fromRGB(71,71,71)

			return true
		end
	end

	return false
end


--[[
	Assign a plot to plr when they join

	@param plr : Player, the player whom to assign to a plot
	@param p, the player Module
	@return boolean, true if the player has been assigned a plot, false if he has been kicked
]]--
function PlotModule:AssignPlot(plr : Player) : boolean
	-- we try to assign the player to a plot
	if not self:AssignPlayerToPlot(plr.Name) then
		-- if all plots are taken, there has been a problem, so we clear all the unused plots
		ClearUnusedPlots()

		-- try to assin the player to a plot again, if we still can't succeed, kick the player and tell them something went wrong
		if not self:AssignPlayerToPlot(plr.Name) then
			plr:Kick("There seems to have been a problem loading you in. Please try to restart your game. We apologize for the inconvenience.")
			return false
		end
	end

	return true
end


--[[
	Unassign the plot from the player when he leaves
]]--
function PlotModule:OnLeave()
	if self and self.phone and self.screen then
		self.phone.Owner.Value = ""

		self.screen.Parent.NavBar.Visible = false
		self.screen.Parent.BackgroundColor3 = Color3.fromRGB(60,60,60)
	end

	setmetatable(self, nil)
	self = nil
end


return PlotModule
