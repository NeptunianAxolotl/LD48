
local util = require("include/util")
local Resources = require("resourceHandler")
local Global = require("global")
local Font = require("include/font")

local PlayerHandler

local self = {}

local function DrawGameWon()
	local spacing = 23
	local spacingX = 40
	local offsetX = 78
	local offsetY = 260
	local popupWidth = 420

	Resources.DrawImage("popup_menu_big", offsetX, offsetY, 0 , 0.8)
	offsetY = offsetY + 4
	
	Font.SetSize(0)
	love.graphics.printf("You Win", offsetX, offsetY + spacing, popupWidth, "center")
	Font.SetSize(1)
	love.graphics.printf("You dug the deepest. There is nothing left to dig.", offsetX + spacingX, offsetY + spacing*3, popupWidth - spacingX*2)

	love.graphics.printf("Money Earned: $" .. self.world.GetPlayerHandler().GetTotalMoney() .. "\nPieces Used: " .. self.world.GetPlayerHandler().GetTotalPiecesUsed(),
			offsetX + spacingX, offsetY + spacing*6, popupWidth - spacingX*2, "center")
	
	if self.world.GetDifficulty() == 1 then
		love.graphics.printf("Type 'thick' for hard mode.", offsetX + spacingX, offsetY + spacing*9, popupWidth - spacingX*2, "center")
	elseif self.world.GetDifficulty() == 2 then
		love.graphics.printf("Type 'atuin' to go harder.", offsetX + spacingX, offsetY + spacing*9, popupWidth - spacingX*2, "center")
	elseif self.world.GetDifficulty() == 3 then
		love.graphics.printf("I dare you to type 'omega'.", offsetX + spacingX, offsetY + spacing*9, popupWidth - spacingX*2, "center")
	else
		love.graphics.printf("You did the impossible.", offsetX + spacingX, offsetY + spacing*9, popupWidth - spacingX*2, "center")
	end
end

local function DrawGameLost(lossType)
	local spacing = 23
	local spacingX = 40
	local offsetX = 78
	local offsetY = 260
	local popupWidth = 420

	if lossType == "out_of_pieces" then
		Resources.DrawImage("popup_menu_big", offsetX, offsetY, 0 , 0.8)
		offsetY = offsetY + 4
		
		Font.SetSize(0)
		love.graphics.printf("Out of Pieces!", offsetX, offsetY + spacing, popupWidth, "center")
		Font.SetSize(1)
		love.graphics.printf("Make a large deck and clear screens to get extra pieces.", offsetX + spacingX, offsetY + spacing*3, popupWidth - spacingX*2)
		
		love.graphics.printf("Money Earned: $" .. self.world.GetPlayerHandler().GetTotalMoney() .. "\nPieces Used: " .. self.world.GetPlayerHandler().GetTotalPiecesUsed(),
				offsetX + spacingX, offsetY + spacing*6, popupWidth - spacingX*2, "center")
		
		love.graphics.printf("Press R to restart", offsetX + spacingX, offsetY + spacing*9, popupWidth - spacingX*2, "center")
	elseif lossType == "empty_deck" then
		Resources.DrawImage("popup_menu_big", offsetX, offsetY, 0 , 0.8)
		offsetY = offsetY + 4
	
		Font.SetSize(0)
		love.graphics.printf("No Deck!", offsetX, offsetY + spacing, popupWidth, "center")
		Font.SetSize(1)
		love.graphics.printf("The vortex is hungry. Do not overfeed the vortex.", offsetX + spacingX, offsetY + spacing*3, popupWidth - spacingX*2)
		
		love.graphics.printf("Money Earned: $" .. self.world.GetPlayerHandler().GetTotalMoney() .. "\nPieces Used: " .. self.world.GetPlayerHandler().GetTotalPiecesUsed(),
				offsetX + spacingX, offsetY + spacing*6, popupWidth - spacingX*2, "center")
		
		love.graphics.printf("Press R to restart", offsetX + spacingX, offsetY + spacing*9, popupWidth - spacingX*2, "center")
	end
end

local function DrawGamePaused()
	local spacing = 23
	local spacingX = 40
	local offsetX = 110
	local offsetY = 275
	local popupWidth = 360
	
	Resources.DrawImage("popup_menu", offsetX, offsetY, 0 , 0.8)
	if self.world.MusicEnabled() then
		Resources.DrawImage("music_on", offsetX + popupWidth - 56, offsetY + 24, 0 , 0.8)
	else
		Resources.DrawImage("music_off", offsetX + popupWidth - 56, offsetY + 24, 0 , 0.8)
	end
	
	offsetY = offsetY + 4
	Font.SetSize(0)
	love.graphics.printf("Paused", offsetX, offsetY + spacing, popupWidth, "center")
	Font.SetSize(1)
	love.graphics.printf("Toggle with Space.\nPress Enter to continue.\nPress Escape to quit.\nPress R to restart.", offsetX + spacingX, offsetY + spacing*3, popupWidth - spacingX*2)
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
