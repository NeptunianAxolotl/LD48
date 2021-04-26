
local util = require("include/util")
local Resources = require("resourceHandler")
local Global = require("global")
local Font = require("include/font")

local PlayerHandler
local World

local self = {}

local spacing = 23
local spacingX = 40
local offsetX = 116
local offsetY = 275
local popupWidth = 360

function self.Initialize(world)
	PlayerHandler = world.GetPlayerHandler()
	World = world
end

function self.DrawInterface(dt)
	if World.GetPaused() then
		Resources.DrawImage("popup_menu", offsetX, offsetY, 0 , 0.8)
		Font.SetSize(0)
		love.graphics.printf("Paused", offsetX, offsetY + spacing, popupWidth, "center")
		Font.SetSize(1)
		love.graphics.printf("Press space to unpause.\nPress Escape to quit.\nPress R to restart.", offsetX + spacingX, offsetY + spacing*3, popupWidth - spacingX*2)
	end
end

return self
