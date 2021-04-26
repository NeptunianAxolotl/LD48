
local Resources = require("resourceHandler")
local EffectsHandler = require("effectsHandler")
local SoundHandler = require("soundHandler")

local self = {}
local animDt = 0

function self.Update(dt)
	animDt = Resources.UpdateAnimation("test_anim", animDt, dt/5)
	if math.random() < 0.03 then
		SoundHandler.PlaySound("health_down")
		EffectsHandler.SpawnEffect("health_down", {0, 0})
		EffectsHandler.SpawnEffect("fireball_explode", {math.random()*500, math.random()*500})
	end
end


function self.Draw()
	Resources.DrawAnimation("test_anim", 100, 100, animDt)
end

return self
