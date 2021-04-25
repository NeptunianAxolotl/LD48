local EffectsHandler = require("effectsHandler")

local util = require("include/util")
local Resources = require("resourceHandler")
local Global = require("global")

local PlayerHandler

local self = {}

local blockMap -- Note that this is blockMap[y][x] for easy cleanup.

local spawnX, spawnY
local cullWait

local currentMinY, currentMaxY, scrollTrigger, desiredTopDraw

------------------------------------------------------------------------
------------------------------------------------------------------------
-- Local Utilities

local function DoScroll(triggerX, triggerY)
	spawnX, spawnY = triggerX, triggerY
	desiredTopDraw = (spawnY - 1) * Global.BLOCK_SIZE
	scrollTrigger = scrollTrigger + Global.TRIGGER_OFFSET
	cullWait = 3
	PlayerHandler.OnScreenScroll()
end

local function SpawnRow(row)
	blockMap[row] = {}
	for x = 1, Global.MAP_WIDTH do
		if row <= 3 then
			blockMap[row][x] = {
				image = "sky",
				toughness = 0,
			}
		elseif row == 4 then
			blockMap[row][x] = {
				image = "dirt_grass_n",
				toughness = 1,
			}
		elseif math.random() < 0.05 then
			blockMap[row][x] = {
				image = "rock",
				imageBase = "rock_",
				backImage = "dirt",
				toughness = 2,
				hitPoints = 3,
			}
		elseif math.random() < 0.1 then
			blockMap[row][x] = {
				image = "gold",
				toughness = 1,
				value = 50,
			}
		else
			blockMap[row][x] = {
				image = "dirt",
				toughness = 1,
			}
		end
	end
end

local function DestroyBlock(x, y, valueList)
	local blockData = self.BlockAt(x, y)
	blockData.image = "empty"
	blockData.backImage = false
	blockData.toughness = 0
	
	if valueList and blockData.value then
		valueList[#valueList + 1] = blockData.value
	end
	
	if y >= scrollTrigger then
		DoScroll(x, y)
	end
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
	local blockDestroyValues = {}
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
							DestroyBlock(x, y, blockDestroyValues)
							reCheck = true
						end
					else
						DestroyBlock(x, y, blockDestroyValues)
						reCheck = true
					end
				end
			end
		end
	end
	
	PlayerHandler.CollectBlockValues(blockDestroyValues)
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- Callins

function self.UpdateAreaCulling(dt)
	if spawnY <= currentMinY + 4 then
		return
	end
	
	if cullWait then
		cullWait = cullWait - dt
		if cullWait < 0 then
			cullWait = false
		end
	end
	
	-- Delete old blocks
	for y = currentMinY, spawnY - 5 do
		blockMap[y] = nil
	end
	currentMinY = spawnY - 4
	
	-- Add new blocks
	for y = currentMaxY + 1, spawnY + Global.BLOCK_SPAWN_SPAN do
		SpawnRow(y)
	end
	currentMaxY = spawnY + Global.BLOCK_SPAWN_SPAN
end

function self.Update(dt)
end

function self.Initialize(world)
	blockMap = {}

	PlayerHandler = world.GetPlayerHandler()

	spawnX = 8
	spawnY = 2
	cullWait = 0
	currentMinY = spawnY - 1
	currentMaxY = currentMinY + Global.BLOCK_SPAWN_SPAN

	scrollTrigger = spawnY + Global.TRIGGER_OFFSET
	desiredTopDraw = (spawnY - 1) * Global.BLOCK_SIZE
	
	for y = 1, currentMaxY do
		SpawnRow(y)
	end
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- Drawing

function self.GetWantedDrawY()
	return desiredTopDraw
end

local function DrawEdges(x, y)
	local block = blockMap[y][x]
	if block.toughness ~= 0 then
		return
	end
	local dx, dy = self.WorldToScreen(x, y)

	local top = not self.Empty(x, y - 1)
	local bot = not self.Empty(x, y + 1)
	local left = not self.Empty(x - 1, y)
	local right = not self.Empty(x + 1, y)
	
	-- North West
	if top then
		if left then
			Resources.DrawImage("edge_nw_inner", dx, dy)
		else
			Resources.DrawImage("edge_n", dx, dy)
		end
	else
		if left then
			Resources.DrawImage("edge_w", dx, dy)
		elseif not self.Empty(x - 1, y - 1) then
			Resources.DrawImage("edge_nw_outer", dx, dy)
		end
	end
	
	-- North East
	if top then
		if right then
			Resources.DrawImage("edge_ne_inner", dx + Global.BLOCK_SIZE/2, dy)
		else
			Resources.DrawImage("edge_n", dx + Global.BLOCK_SIZE/2, dy)
		end
	else
		if right then
			Resources.DrawImage("edge_e", dx + Global.BLOCK_SIZE/2, dy)
		elseif not self.Empty(x + 1, y - 1) then
			Resources.DrawImage("edge_ne_outer", dx + Global.BLOCK_SIZE/2, dy)
		end
	end
	
	-- South West
	if bot then
		if left then
			Resources.DrawImage("edge_sw_inner", dx, dy + Global.BLOCK_SIZE/2)
		else
			Resources.DrawImage("edge_s", dx, dy + Global.BLOCK_SIZE/2)
		end
	else
		if left then
			Resources.DrawImage("edge_w", dx, dy + Global.BLOCK_SIZE/2)
		elseif not self.Empty(x - 1, y + 1) then
			Resources.DrawImage("edge_sw_outer", dx, dy + Global.BLOCK_SIZE/2)
		end
	end
	
	-- South East
	if bot then
		if right then
			Resources.DrawImage("edge_se_inner", dx + Global.BLOCK_SIZE/2, dy + Global.BLOCK_SIZE/2)
		else
			Resources.DrawImage("edge_s", dx + Global.BLOCK_SIZE/2, dy + Global.BLOCK_SIZE/2)
		end
	else
		if right then
			Resources.DrawImage("edge_e", dx + Global.BLOCK_SIZE/2, dy + Global.BLOCK_SIZE/2)
		elseif not self.Empty(x + 1, y + 1) then
			Resources.DrawImage("edge_se_outer", dx + Global.BLOCK_SIZE/2, dy + Global.BLOCK_SIZE/2)
		end
	end
end

function self.Draw(xOffset, yOffset)
	for x = 1, Global.MAP_WIDTH do
		for y = currentMinY, currentMaxY do
			local block = blockMap[y][x]
			local dx, dy = self.WorldToScreen(x, y)
			if block.backImage then
				Resources.DrawImage(block.backImage, dx, dy)
			end
			Resources.DrawImage(block.image, dx, dy)
		end
	end
	
	for x = 1, Global.MAP_WIDTH do
		for y = currentMinY, currentMaxY do
			DrawEdges(x, y)
		end
	end
end

return self
