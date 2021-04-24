
local IterableMap = require("include/IterableMap")
local util = require("include/util")

local EffectDefs = util.LoadDefDirectory("effects")
local NewEffect = require("objects/effect")

local self = {}
local api = {}

function api.Spawn(name, pos, scale, velocity)
	local def = EffectDefs[name]
	local data = {
		pos = pos,
		scale = scale, -- optional
		velocity = velocity, -- optional
	}
	if def.interface then
		IterableMap.Add(self.interfaceEffects, NewEffect(data, def))
	else
		IterableMap.Add(self.worldEffects, NewEffect(data, def))
	end
end

function api.Update(dt)
	IterableMap.ApplySelf(self.worldEffects, "Update", dt)
	IterableMap.ApplySelf(self.interfaceEffects, "Update", dt)
end

function api.Draw(drawQueue)
	IterableMap.ApplySelf(self.worldEffects, "Draw", drawQueue)
end

function api.DrawInterface()
	IterableMap.ApplySelf(self.interfaceEffects, "DrawInterface")
end

function api.GetActivity()
	return IterableMap.Count(self.worldEffects)
end

function api.GetActivityInterface()
	return IterableMap.Count(self.interfaceEffects)
end

function api.Initialize()
	self = {
		worldEffects = IterableMap.New(),
		interfaceEffects = IterableMap.New(),
		animationTimer = 0
	}
end

return api
