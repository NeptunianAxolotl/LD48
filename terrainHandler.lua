local EffectsHandler = require("effectsHandler")

local util = require("include/util")
local Resources = require("resourceHandler")
local Global = require("global")

local self = {}

local blockMap = {}
local currentMinY = 1
local currentMaxY = 50

local spawnX = 8
local spawnY = 2

local scrollTrigger = spawnY + Global.TRIGGER_OFFSET

local drawMinY = 1
local desiredTopDraw = 1 * Global.BLOCK_SIZE
local drawMaxY = 50

------------------------------------------------------------------------
------------------------------------------------------------------------
-- Local Utilities

local function DoScroll(triggerX, triggerY)
	-- Clean up old areas.
	drawMinY = spawnY - 5
	for y = currentMinY, drawMinY - 1 do
		blockMap[y] = nil
	end
	currentMinY = drawMinY
	
	spawnX, spawnY = triggerX, triggerY
	print(spawnX, spawnY)
	desiredTopDraw = (spawnY - 1) * Global.BLOCK_SIZE
	scrollTrigger = scrollTrigger + Global.TRIGGER_OFFSET
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- External Utilities

function self.GetPieceSpawnPos()
	return spawnX, spawnY
end

function self.WorldToScreen(x, y)
	return x*Global.BLOCK_SIZE, y*Global.BLOCK_SIZE
end

function self.BlockAt(x, y)
	return blockMap[y] and blockMap[y][x]
end

function self.Empty(x, y)
	return blockMap[y] and blockMap[y][x] and blockMap[y][x].toughness == 0
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- Piece Checking Utilities

function self.PieceInsidePlayArea(pX, pY, pRot, pDef)
	local tiles = pDef.tiles
	for i = 1, #tiles do
		local tile = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
		local x, y = pX + tile[1], pY + tile[2]
		local blockData = blockMap[y] and blockMap[y][x]
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
		local blockData = blockMap[y] and blockMap[y][x]
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

------------------------------------------------------------------------
------------------------------------------------------------------------
-- Terrain Modification

function self.CarveTerrain(pX, pY, pRot, pDef, tiles)
	local tiles = pDef.tiles
	
	for i = 1, #tiles do
		local tile = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
		local x, y = self.WorldToScreen(pX + tile[1], pY + tile[2])
		EffectsHandler.Spawn("piece_fade", {x, y})
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
							if y >= scrollTrigger then
								DoScroll(x, y)
							end
						end
					else
						blockData.image = "empty"
						blockData.toughness = 0
						reCheck = true
						if y >= scrollTrigger then
							DoScroll(x, y)
						end
					end
				end
			end
		end
	end
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- Callins

function self.Update(dt)
	
end

function self.Initialize()
	for y = 1, currentMaxY do
		blockMap[y] = {}
		for x = 1, Global.MAP_WIDTH do
			if y <= 3 then
				blockMap[y][x] = {
					image = "sky",
					toughness = 0,
				}
			elseif y == 4 then
				blockMap[y][x] = {
					image = "dirt_grass_n",
					toughness = 1,
				}
			elseif math.random() < 0.04 then
				blockMap[y][x] = {
					image = "rock",
					imageBase = "rock_",
					toughness = 2,
					hitPoints = 3,
				}
			elseif math.random() < 0.04 then
				blockMap[y][x] = {
					image = "gold",
					toughness = 1,
					value = 10,
				}
			else
				blockMap[y][x] = {
					image = "dirt",
					toughness = 1,
				}
			end
		end
	end
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- Drawing

function self.GetWantedDrawY()
	return desiredTopDraw
end

function self.Draw(xOffset, yOffset)
	for x = 1, Global.MAP_WIDTH do
		for y = drawMinY, drawMaxY do
			local block = blockMap[y][x]
			local dx, dy = self.WorldToScreen(x, y)
			Resources.DrawImage(block.image, dx, dy)
		end
	end
end

return self
