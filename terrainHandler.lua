local EffectsHandler = require("effectsHandler")

local util = require("include/util")
local Resources = require("resourceHandler")
local Global = require("global")

local self = {}

local blockMap = {}
local MAP_WIDTH = 30
local currentMinY = 1
local currentMaxY = 30

function self.Update(dt)

end

function self.CarveTerrain(pX, pY, pRot, pDef)
	local tiles = pDef.tiles
	for i = 1, #tiles do
		local tile = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
		local x, y = pX + tile[1], pY + tile[2]
		EffectsHandler.Spawn("piece_fade", {x * Global.BLOCK_SIZE, y * Global.BLOCK_SIZE})
		local blockData = blockMap[x] and blockMap[x][y]
		if blockData and blockData.toughness ~= 0 then
			if blockData.toughness > pDef.carveStrength then
				blockData.hitPoints = blockData.hitPoints - 1
				blockData.image = blockData.imageBase .. blockData.hitPoints
				if blockData.hitPoints <= 0 then
					blockData.image = "empty"
					blockData.toughness = 0
				end
			else
				blockData.image = "empty"
				blockData.toughness = 0
			end
		end
	end
end

function self.GetValidPiecePlace(pDef, pX, pY, pRot)
	local tiles = pDef.tiles
	local border = pDef.border
	for i = 1, #tiles do
		local tile = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
		local tx, ty = pX + tile[1], pY + tile[2]
		local blockData = blockMap[tx] and blockMap[tx][ty]
		if (not blockData) or blockData.toughness == 0 or blockData.toughness > pDef.carveStrength then
			return false
		end
	end
	for i = 1, #border do
		local pos = util.RotateVectorOrthagonal(border[i], pRot * math.pi/2)
		local tx, ty = pX + pos[1], pY + pos[2]
		local blockData = blockMap[tx] and blockMap[tx][ty]
		if (not blockData) or blockData.toughness == 0 then
			return true
		end
	end
	return false
end

function self.GetClosestPlacement(mX, mY, rotation, pDef)
	local bestDistSq = false
	local bestX = 0
	local bestY = 0
	for x = 1, MAP_WIDTH do
		for y = currentMinY, currentMaxY do
			local distSq = util.DistSq((x + pDef.offsetX)*Global.BLOCK_SIZE, (y + pDef.offsetY)*Global.BLOCK_SIZE, mX, mY)
			if ((not bestDistSq) or distSq < bestDistSq) and self.GetValidPiecePlace(pDef, x, y, rotation) then
				bestDistSq = distSq
				bestX = x
				bestY = y
			end
		end
	end
	return bestX, bestY
end

function self.Initialize()
	for x = 1, MAP_WIDTH do
		blockMap[x] = {}
		for y = 1, currentMaxY do
			if math.random() < 0.04 then
				blockMap[x][y] = {
					image = "rock",
					imageBase = "rock_",
					toughness = 2,
					hitPoints = 3,
				}
			elseif math.random() < 0.04 then
				blockMap[x][y] = {
					image = "gold",
					toughness = 1,
					value = 10,
				}
			else
				blockMap[x][y] = {
					image = "dirt",
					toughness = 1,
				}
			end
		end
	end
end

function self.Draw()
	for x = 1, MAP_WIDTH do
		for y = currentMinY, currentMaxY do
			local block = blockMap[x][y]
			Resources.DrawImage(block.image, x*Global.BLOCK_SIZE, y*Global.BLOCK_SIZE)
		end
	end
end

return self
