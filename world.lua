

local EffectsHandler = require("effectsHandler")
local SoundHandler = require("soundHandler")
local MusicHandler = require("musicHandler")

local PriorityQueue = require("include/PriorityQueue")

local self = {}

function self.MousePressed()
end

function self.MouseReleased()
end

function self.Update(dt)
	--local playerPos, playerVelocity, playerSpeed = Player.GetPhysics()
	--local cameraX, cameraY, cameraScale = Camera.UpdateCamera(dt, playerPos, playerVelocity, playerSpeed, Player.IsDead() and 0.96 or 0.85)
	local windowX, windowY = love.window.getMode()
	local cameraX, cameraY, cameraScale = 0, 0, 1
	--self.cameraTransform:setTransformation(windowX/2, 160 + (1 - cameraScale)*60, 0, cameraScale*windowY/1080, cameraScale*windowY/1080, cameraX, cameraY)
	
	if math.random() < 0.03 then
		SoundHandler.PlaySound("health_down")
		EffectsHandler.Spawn("health_down", {0, 0})
		EffectsHandler.Spawn("fireball_explode", {math.random()*500, math.random()*500})
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
	
	EffectsHandler.Initialize()
    MusicHandler.Initialize()
	SoundHandler.Initialize()
end

return self