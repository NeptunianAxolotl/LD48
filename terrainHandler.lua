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

function self.CheckPiecePlaceTrigger(pX, pY, pRot, pDef, tiles)
	local fullyCovered = true
	for i = 1, #tiles do
		local tile = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
		local x, y = pX + tile[1], pY + tile[2]
		local blockData = blockMap[x] and blockMap[x][y]
		if blockData then
			-- Placement is triggered if there are no empty squares
			if blockData.toughness == 0 then
				fullyCovered = false
			end
			-- Placement is triggered if the block hits something that is too tough.
			if blockData.toughness > pDef.carveStrength then
				return true
			end
		end
	end
	return fullyCovered
end

function self.CarveTerrain(pX, pY, pRot, pDef, tiles)
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

function self.CarveLeavingTiles(pX, pY, pRot, oldX, oldY, oldRot, pDef, tiles)
	local newTiles = {}
	for i = 1, #tiles do
		local tile = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
		local x, y = pX + tile[1], pY + tile[2]
		local blockData = blockMap[x] and blockMap[x][y]
		if blockData and blockData.toughness ~= 0 then
			tiles[i].covered = true
			newTiles[#newTiles + 1] = tiles[i]
		elseif tiles[i].covered then
			tile = util.RotateVectorOrthagonal(tiles[i], oldRot * math.pi/2)
			x, y = oldX + tile[1], oldY + tile[2]
			EffectsHandler.Spawn("piece_fade", {x * Global.BLOCK_SIZE, y * Global.BLOCK_SIZE})
			local blockData = blockMap[x] and blockMap[x][y]
			if blockData then
				blockData.image = "empty"
				blockData.toughness = 0
			end
		else
			newTiles[#newTiles + 1] = tiles[i]
		end
	end
	return newTiles
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
