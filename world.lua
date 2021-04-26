local EffectsHandler = require("effectsHandler")
local MusicHandler = require("musicHandler")
SoundHandler = require("soundHandler")

local util = require("include/util")
local Resources = require("resourceHandler")

local PriorityQueue = require("include/PriorityQueue")

local Camera = require("cameraUtilities")
local PopupHandler = require("popupHandler")

local Global = require("global")
local PieceHandler = require("pieceHandler")
local TerrainHandler = require("terrainHandler")
local PlayerHandler = require("playerHandler")
local ShopHandler = require("shopHandler")
local Progression = require("progression")

local lastDt = 0

local WINDOW_HEIGHT = 832
local WINDOW_WIDTH = 1120

local hardMode = {
	index = 1,
	code = {"t", "h", "i", "c", "k"},
	difficulty = 2,
}
local impossibleMode = {
	index = 1,
	code = {"a", "t", "u", "i", "n"},
	difficulty = 3,
}

local self = {}

local function ProcessModeChange(modeData, key)
	if key == modeData.code[modeData.index] then
		modeData.index = modeData.index + 1
		if not modeData.code[modeData.index] then
			modeData.index = 1
			self.Initialize(modeData.difficulty)
		end
	else
		modeData.index = 1
	end
end

function self.GetDifficulty()
	return self.difficulty
end

function self.GetPaused()
	return self.paused
end

function self.MusicEnabled()
	return self.musicEnabled
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

function self.MousePressed(x, y)
	if x > 415 and y > 297 and x < 415 + 32 and y < 297 + 32 then
		self.musicEnabled = not self.musicEnabled
		if self.musicEnabled then
			MusicHandler.SwitchTrack("music")
		else
			MusicHandler.SwitchTrack("none")
			MusicHandler.StopCurrentTrack()
		end
	end
end

function self.MouseReleased()
end

function self.KeyPressed(key, scancode, isRepeat)
	ProcessModeChange(hardMode, key)
	ProcessModeChange(impossibleMode, key)
	
	if key == "space" or key == "escape" then
		if self.paused and key == "escape" then
			love.event.quit() 
			return
		end
		self.paused = not self.paused
		SoundHandler.PlaySound("pause")
	end
	if key == "r" and (self.GetPaused() or self.GetGameOver()) then
		self.Initialize(self.difficulty)
	end
	if self.GetPaused() then
		if key == "return" or key == "kpenter" then
			self.paused = false
			SoundHandler.PlaySound("pause")
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
	local windowScale = windowY / WINDOW_HEIGHT
	local windowPad = math.floor((windowX - windowScale * WINDOW_WIDTH) / 2)
	local cameraX, cameraY = Camera.UpdateCamera(dt, {Global.BLOCK_SIZE, TerrainHandler.GetWantedDrawY()}, {0, 0}, 0, 0.99, 0.3, 4)
	self.cameraTransform:setTransformation(-cameraX*windowScale, -cameraY*windowScale, 0, windowScale, windowScale, -Global.WORLD_SCREEN_X - windowPad, -Global.WORLD_Y)

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
	local windowX, windowY = love.window.getMode()
	local windowScale = windowY / WINDOW_HEIGHT
	local windowPad = math.floor((windowX - windowScale * WINDOW_WIDTH) / 2)
	love.graphics.replaceTransform(self.cameraTransform)

	local drawQueue = PriorityQueue.new(function(l, r) return l.y < r.y end)

	EffectsHandler.Draw(drawQueue)
	-- Draw world
	local cameraPos = Camera.GetPos()
	local winDist = util.AverageScalar(Progression.GetWinDistance() * Global.BLOCK_SIZE, cameraPos[2], 0.85)
	Resources.DrawImage("the_space", Global.WORLD_X, math.floor(winDist))
	TerrainHandler.Draw(lastDt)
	PieceHandler.Draw()
	
	while true do
		local d = drawQueue:pop()
		if not d then break end
		d.f()
	end
	
	self.interfaceTransform:setTransformation(0, 0, 0, windowScale, windowScale, -windowPad, 0)
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
	self.musicEnabled = true
	
	--self.SetGameOver(true, "empty_deck")
	
	self.cameraTransform = love.math.newTransform()
	self.interfaceTransform = love.math.newTransform()
	self.emptyTransform = love.math.newTransform()
	
	Progression.Initialize(self)
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
