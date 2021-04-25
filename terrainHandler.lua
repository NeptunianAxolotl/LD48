local EffectsHandler = require("effectsHandler")

local util = require("include/util")
local Resources = require("resourceHandler")
local Global = require("global")

local self = {}

local blockMap = {}
local currentMinY = 1
local currentMaxY = 30

function self.BlockAt(x, y)
	return blockMap[x] and blockMap[x][y]
end

function self.Empty(x, y)
	return blockMap[x] and blockMap[x][y] and blockMap[x][y].toughness == 0
end

function self.Update(dt)

end

function self.PieceInsidePlayArea(pX, pY, pRot, pDef)
	local tiles = pDef.tiles
	for i = 1, #tiles do
		local tile = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
		local x, y = pX + tile[1], pY + tile[2]
		local blockData = blockMap[x] and blockMap[x][y]
		if not blockData then
			return false
		end
	end
	return true
end

function self.CheckPiecePlaceTrigger(pX, pY, pRot, pDef)
	local tiles = pDef.tiles
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
	local tiles = pDef.tiles
	
	for i = 1, #tiles do
		local tile = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
		local x, y = pX + tile[1], pY + tile[2]
		EffectsHandler.Spawn("piece_fade", {x * Global.BLOCK_SIZE, y * Global.BLOCK_SIZE})
	end
	
	-- Only affect blocks that are not behind barriers, such as rocks.
	local reCheck = true
	local processedBlocks = {}
	while reCheck do
		reCheck = false
		for i = 1, #tiles do
			local tile = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
			local x, y = pX + tile[1], pY + tile[2]
			if not (processedBlocks[x] and processedBlocks[x][y]) then
				local blockData = self.BlockAt(x, y)
				if blockData and blockData.toughness ~= 0 and 
						(self.Empty(x - 1, y) or self.Empty(x + 1, y) or self.Empty(x, y - 1) or self.Empty(x, y + 1)) then
					processedBlocks[x] = processedBlocks[x] or {}
					processedBlocks[x][y] = true
					if blockData.toughness > pDef.carveStrength then
						blockData.hitPoints = blockData.hitPoints - 1
						blockData.image = blockData.imageBase .. blockData.hitPoints
						if blockData.hitPoints <= 0 then
							blockData.image = "empty"
							blockData.toughness = 0
							reCheck = true
						end
					else
						blockData.image = "empty"
						blockData.toughness = 0
						reCheck = true
					end
				end
			end
		end
	end
end

function self.GetPieceSpawnPos()
	return 8, 2
end

function self.Initialize()
	for x = 1, Global.MAP_WIDTH do
		blockMap[x] = {}
		for y = 1, currentMaxY do
			if y <= 2 then
				blockMap[x][y] = {
					image = "sky",
					toughness = 0,
				}
			elseif y == 3 then
				blockMap[x][y] = {
					image = "dirt_grass_n",
					toughness = 1,
				}
			elseif math.random() < 0.04 then
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
	for x = 1, Global.MAP_WIDTH do
		for y = currentMinY, currentMaxY do
			local block = blockMap[x][y]
			Resources.DrawImage(block.image, x*Global.BLOCK_SIZE, y*Global.BLOCK_SIZE)
		end
	end
end

return self
