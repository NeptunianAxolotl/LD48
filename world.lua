local EffectsHandler = require("effectsHandler")
local SoundHandler = require("soundHandler")
local MusicHandler = require("musicHandler")

local PriorityQueue = require("include/PriorityQueue")

local Camera = require("cameraUtilities")

local Global = require("global")
local PieceHandler = require("pieceHandler")
local TerrainHandler = require("terrainHandler")

local self = {}

function self.MousePressed()
end

function self.MouseReleased()
end

function self.KeyPressed(key, scancode, isRepeat)
	if Camera.GetSpeed() < 0.05 then
		PieceHandler.KeyPressed(key, scancode, isRepeat)
	end
end

function self.Update(dt)
	local windowX, windowY = love.window.getMode()
	local cameraX, cameraY = Camera.UpdateCamera(dt, {Global.BLOCK_SIZE, TerrainHandler.GetWantedDrawY()}, {0, 0}, 0, 0.99, 0.3, 4)
	self.cameraTransform:setTransformation(-cameraX, -cameraY, 0, 1, 1, -Global.BLOCK_SIZE, 0)

	TerrainHandler.Update(dt)
	if Camera.GetSpeed() < 0.05 then
		PieceHandler.Update(dt)
		TerrainHandler.UpdateAreaCulling()
	end

	EffectsHandler.Update(dt)
	MusicHandler.Update(dt)
	SoundHandler.Update(dt)
	
	--love.graphics.replaceTransform(self.cameraTransform)
end

function self.Draw()
	love.graphics.replaceTransform(self.cameraTransform)

	local drawQueue = PriorityQueue.new(function(l, r) return l.y < r.y end)

	EffectsHandler.Draw(drawQueue)
	-- Draw world
	
	TerrainHandler.Draw()
	PieceHandler.Draw()
	
	while true do
		local d = drawQueue:pop()
		if not d then break end
		d.f()
	end
	
	local windowX, windowY = love.window.getMode()
	self.interfaceTransform:setTransformation(0, 0, 0, windowX/1920, windowX/1920, 0, 0)
	love.graphics.replaceTransform(self.interfaceTransform)
	
	-- Draw interface
	EffectsHandler.DrawInterface()
	
	love.graphics.replaceTransform(self.emptyTransform)
end

function self.Initialize()
	self.cameraTransform = love.math.newTransform()
	self.interfaceTransform = love.math.newTransform()
	self.emptyTransform = love.math.newTransform()
	
	TerrainHandler.Initialize()
	PieceHandler.Initialize()
	Camera.Initialize(Global.BLOCK_SIZE, Global.BLOCK_SIZE)
	
	EffectsHandler.Initialize()
	MusicHandler.Initialize()
	SoundHandler.Initialize()
end

return self
