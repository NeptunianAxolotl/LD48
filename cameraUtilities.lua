
local util = require("include/util")

local self = {}
local api = {}

function api.UpdateCamera(dt, playerPos, playerVelocity, playerSpeed, smoothness, attraction, slowdown)
	self.cameraVelocity = util.Average(self.cameraVelocity, util.Subtract(util.Mult(attraction, util.Subtract(playerPos, self.cameraPos)), util.Mult(slowdown, self.cameraVelocity)), 2*(1 - smoothness))
	self.cameraPos = util.Add(util.Mult(dt*60, self.cameraVelocity), self.cameraPos)
	self.cameraSpeed = util.AbsVal(self.cameraVelocity)
	
	local wantedScale = math.min(0.93, math.max(0.5, 12/(12 + playerSpeed)))
	self.cameraScale = self.cameraScale*smoothness + wantedScale*(1 - smoothness)
	
	return self.cameraPos[1], self.cameraPos[2], self.cameraScale
end

function api.GetSpeed()
	return self.cameraSpeed
end

function api.Initialize(posX, posY)
	self = {
		cameraPos = {posX or 0, posY or 0},
		cameraVelocity = {0, 0},
		cameraScale = 0.93,
		cameraSpeed = 0
	}
end

return api

