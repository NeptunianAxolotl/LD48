
local util = require("include/util")
local Resources = require("resourceHandler")
local Global = require("global")
local Font = require("include/font")

local PlayerHandler

local self = {}


local function DrawGameWon()
	local spacing = 23
	local spacingX = 40
	local offsetX = 86
	local offsetY = 260
	local popupWidth = 420

	Resources.DrawImage("popup_menu_big", offsetX, offsetY, 0 , 0.8)
	Font.SetSize(0)
	love.graphics.printf("You Win", offsetX, offsetY + spacing, popupWidth, "center")
	Font.SetSize(1)
	love.graphics.printf("You dug the deepest. There is nothing left to dig.", offsetX + spacingX, offsetY + spacing*3, popupWidth - spacingX*2)
	
	love.graphics.printf("Money Earned: $" .. self.world.GetPlayerHandler().GetTotalMoney(), offsetX + spacingX, offsetY + spacing*6, popupWidth - spacingX*2, "center")
	
	love.graphics.printf("Press R to restart", offsetX + spacingX, offsetY + spacing*8, popupWidth - spacingX*2, "center")
end

local function DrawGameLost(lossType)
end

local function DrawGamePaused()
	local spacing = 23
	local spacingX = 40
	local offsetX = 116
	local offsetY = 275
	local popupWidth = 360
	
	Resources.DrawImage("popup_menu", offsetX, offsetY, 0 , 0.8)
	Font.SetSize(0)
	love.graphics.printf("Paused", offsetX, offsetY + spacing, popupWidth, "center")
	Font.SetSize(1)
	love.graphics.printf("Press Space or Enter to unpause.\nPress Escape to quit.\nPress R to restart.", offsetX + spacingX, offsetY + spacing*3, popupWidth - spacingX*2)
end

function self.Initialize(world)
	PlayerHandler = world.GetPlayerHandler()
	self.world = world
end

function self.DrawInterface(dt)
	local gameOver, hasWon, hasLost, overType = self.world.GetGameOver()
	if gameOver then
		if hasWon then
			DrawGameWon()
			return
		end
		DrawGameLost(overType)
		return
	end
	
	if self.world.GetPaused() then
		DrawGamePaused()
	end
end

return self
