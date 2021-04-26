local EffectsHandler = require("effectsHandler")
local SoundHandler = require("soundHandler")
local MusicHandler = require("musicHandler")

local util = require("include/util")
local Resources = require("resourceHandler")

local PriorityQueue = require("include/PriorityQueue")

local Camera = require("cameraUtilities")
local PopupHandler = require("PopupHandler")

local Global = require("global")
local PieceHandler = require("pieceHandler")
local TerrainHandler = require("terrainHandler")
local PlayerHandler = require("playerHandler")
local ShopHandler = require("shopHandler")

local lastDt = 0

local self = {}

function self.GetDifficulty()
	return self.difficulty
end

function self.GetPaused()
	return self.paused
end

function self.GetGameOver()
	return self.gameWon or self.gameLost, self.gameWon, self.gameLost, self.overType
end

function self.SetGameOver(hasWon, overType)
	if self.gameWon or self.gameLost then
		return
	end
	if hasWon then
		self.gameWon = true
	else
		self.gameLost = true
		self.overType = overType
	end
end

function self.MousePressed()
end

function self.MouseReleased()
end

function self.KeyPressed(key, scancode, isRepeat)
	if key == "space" or key == "escape" then
		if self.paused and key == "escape" then
			love.event.quit() 
		end
		self.paused = not self.paused
	end
	if key == "r" and (self.GetPaused() or self.GetGameOver()) then
		self.Initialize()
	end
	if self.GetPaused() then
		if key == "return" or key == "kpenter" then
			self.paused = false
		end
		return
	end
	if not self.GetGameOver() then
		if Camera.GetMovementDone() then
			PieceHandler.KeyPressed(key, scancode, isRepeat)
		end
		ShopHandler.KeyPressed(key, scancode, isRepeat)
	end
end

function self.Update(dt)
	local windowX, windowY = love.window.getMode()
	local cameraX, cameraY = Camera.UpdateCamera(dt, {Global.BLOCK_SIZE, TerrainHandler.GetWantedDrawY()}, {0, 0}, 0, 0.99, 0.3, 4)
	self.cameraTransform:setTransformation(-cameraX, -cameraY, 0, 1, 1, -Global.WORLD_SCREEN_X, -Global.WORLD_Y)

	if not self.GetPaused() then
		if Camera.GetMovementDone() and not ShopHandler.IsActive() and not self.GetGameOver() then
			TerrainHandler.UpdateAreaCulling(dt)
			PieceHandler.Update(dt)
		end
		TerrainHandler.Update(dt)
		PlayerHandler.Update(dt)
		ShopHandler.Update(dt)
		
		EffectsHandler.Update(dt)
	end

	MusicHandler.Update(dt)
	SoundHandler.Update(dt)
	
	--love.graphics.replaceTransform(self.cameraTransform)
	lastDt = dt
end

function self.Draw()
	love.graphics.replaceTransform(self.cameraTransform)

	local drawQueue = PriorityQueue.new(function(l, r) return l.y < r.y end)

	EffectsHandler.Draw(drawQueue)
	-- Draw world
	local cameraPos = Camera.GetPos()
	Resources.DrawImage("the_space", Global.WORLD_X, math.floor(util.AverageScalar(Global.PIECE_WIN_DISTANCE * Global.BLOCK_SIZE, cameraPos[2], 0.85)))
	TerrainHandler.Draw(lastDt)
	PieceHandler.Draw()
	
	while true do
		local d = drawQueue:pop()
		if not d then break end
		d.f()
	end
	
	local windowX, windowY = love.window.getMode()
	self.interfaceTransform:setTransformation(0, 0, 0, 1, 1, 0, 0)
	love.graphics.replaceTransform(self.interfaceTransform)
	
	-- Draw interface
	EffectsHandler.DrawInterface()
	PlayerHandler.DrawInterface(lastDt)
	ShopHandler.DrawInterface()
	PopupHandler.DrawInterface(lastDt)
	
	love.graphics.replaceTransform(self.emptyTransform)
end

function self.Initialize(difficulty)
	self.paused = true
	self.gameWon = false
	self.gameLost = false
	self.overType = false
	self.difficulty = difficulty or 1
	
	self.SetGameOver(true, overType)
	
	self.cameraTransform = love.math.newTransform()
	self.interfaceTransform = love.math.newTransform()
	self.emptyTransform = love.math.newTransform()
	
	PlayerHandler.Initialize(self)
	TerrainHandler.Initialize(self)
	ShopHandler.Initialize(self)
	PieceHandler.Initialize(self)
	PopupHandler.Initialize(self)
	
	Camera.Initialize(Global.BLOCK_SIZE, Global.BLOCK_SIZE)
	
	EffectsHandler.Initialize()
	MusicHandler.Initialize()
	SoundHandler.Initialize()
	
	MusicHandler.SwitchTrack("music")
end

function self.GetPlayerHandler()
	return PlayerHandler
end

function self.GetShopHandler()
	return ShopHandler
end

return self
