
local util = require("include/util")
local Resources = require("resourceHandler")
local EffectsHandler = require("effectsHandler")
local Global = require("global")

local Progression = require("progression")
local PlayerHandler
local ShopHandler

local terrainDefs = require("game_data/terrainDefs")

local self = {}

local blockMap -- Note that this is blockMap[y][x] for easy cleanup.

local spawnX, spawnY
local cullWait

local currentMinY, currentMaxY, scrollTrigger, desiredTopDraw
local greatestDepth = 0
local oldGreatestDepth = 0

------------------------------------------------------------------------
------------------------------------------------------------------------
-- Local Utilities

local function DoScroll(triggerX, triggerY)
	spawnX, spawnY = triggerX, triggerY
	if spawnX < 3 then
		spawnX = 3
	end
	if spawnX > Global.MAP_WIDTH - 3 then
		spawnX = Global.MAP_WIDTH - 3
	end
	desiredTopDraw = (spawnY - 1) * Global.BLOCK_SIZE
	scrollTrigger = scrollTrigger + Global.TRIGGER_OFFSET
	cullWait = 3
	PlayerHandler.OnScreenScroll()
	ShopHandler.OnScreenScroll()
end

local function RandomiseHealth(distance, blockData)
	if not blockData.spawnHealth then
		return blockData
	end
	blockData.hitPoints = Progression.SampleWeightedDistribution(distance, blockData.spawnHealth)
	blockData.image = blockData.imageBase .. blockData.hitPoints
	return blockData
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
				wantDirt = true,
				isGrass = true,
			}
		else
			local blockType = Progression.SampleWeightedDistribution(row, "blockType")
			blockMap[row][x] = RandomiseHealth(row, util.CopyTable(terrainDefs[blockType]))
		end
	end
end

local function TryBlockConversion(x, y, blockData)
	local dir = util.GetRandomKingDirection()
	local ox, oy = x + dir[1], y + dir[2]
	local otherBlockData = self.BlockAt(ox, oy)
	if otherBlockData and not otherBlockData.canVein and not otherBlockData.isGrass then
		blockMap[oy][ox] = RandomiseHealth(y, util.CopyTable(blockData))
		return true
	end
	return false
end

local function SpawnArea(minY, maxY)
	for y = minY, maxY do
		SpawnRow(y)
	end
	for y = minY, maxY do
		for x = 1, Global.MAP_WIDTH do
			local blockData = blockMap[y][x]
			if blockData.canVein and math.random() < Progression.GetRandomValue(y, blockData.name, "veinChance") then
				-- Try three times
				if not TryBlockConversion(x, y, blockData) then
					if not TryBlockConversion(x, y, blockData) then
						TryBlockConversion(x, y, blockData)
					end
				end
			end
		end
	end
end

local function DestroyBlock(x, y, valueList, moneyMult, ignoreVortex, valueMinY)
	local blockData = self.BlockAt(x, y)
	if (not blockData) or (blockData.toughness == 0) then
		return valueMinY
	end
	if ignoreVortex and blockData.vortex then
		return valueMinY
	end
	blockData.image = "empty"
	blockData.backImage = false
	blockData.vortex = false
	blockData.toughness = 0
	blockData.animateImage = false
	blockData.wantDirt = false
	
	if valueList and blockData.value then
		valueList[#valueList + 1] = blockData.value * (moneyMult or 1)
		local moneyValue = math.floor(blockData.value * (moneyMult or 1) + 0.5)
		local eX, eY = self.WorldToScreen(x + 0.5, y + 0.5)
		EffectsHandler.SpawnEffect("money_popup", {eX, eY}, {velocity = {0, (-0.55 - math.random()*0.2) * (0.4 + 0.6*(50 / math.max(50, moneyValue)))}, text = "$" .. moneyValue})
		if (not valueMinY) or (y < valueMinY) then
			valueMinY = y
		end
	end
	blockData.value = false
	
	if y >= scrollTrigger then
		DoScroll(x, y)
	end
	if y > greatestDepth then
		greatestDepth = y
	end
	return valueMinY
end

local function ExplodeBlock(x, y, strength, damage)
	local blockData = self.BlockAt(x, y)
	if not blockData then
		return true
	end
	if blockData.toughness <= strength or (blockData.hitPoints and blockData.hitPoints <= damage) then
		DestroyBlock(x, y, false, false, true)
		return true
	end
	if blockData.hitPoints then
		blockData.hitPoints = blockData.hitPoints - damage
		blockData.image = blockData.imageBase .. blockData.hitPoints
	end
	return false
end

local function CreateVortex(x, y)
	DestroyBlock(x, y)
	local blockData = self.BlockAt(x, y)
	if not blockData then
		return
	end
	blockData.vortex = true
	blockData.wantDirt = false
	blockData.toughness = 1
	blockData.image = "empty"
	blockData.animateImage = "vortex"
	blockData.animateRot = math.random()*2*math.pi
end

local function DoExplosion(tileX, tileY, radius)
	if radius == 1 then
		ExplodeBlock(tileX, tileY, 2, 3)
		local left   = ExplodeBlock(tileX - 1, tileY, 1, 3)
		local right  = ExplodeBlock(tileX + 1, tileY, 1, 3)
		local top    = ExplodeBlock(tileX, tileY - 1, 1, 3)
		local bottom = ExplodeBlock(tileX, tileY + 1, 1, 3)
		if left or top then
			ExplodeBlock(tileX - 1, tileY - 1, 1, 2)
		end
		if right or top then
			ExplodeBlock(tileX + 1, tileY - 1, 1, 2)
		end
		if right or bottom then
			ExplodeBlock(tileX + 1, tileY + 1, 1, 2)
		end
		if left or bottom then
			ExplodeBlock(tileX - 1, tileY + 1, 1, 2)
		end
		
		local x, y = self.WorldToScreen(tileX + 0.5, tileY + 0.5)
		EffectsHandler.SpawnEffect("bomb_explode", {x, y})
		SoundHandler.PlaySound("explosion")
	elseif radius == 2 then
		-- Do it like this for scroll ordering.
		ExplodeBlock(tileX, tileY, 3)
		ExplodeBlock(tileX + 1, tileY, 3)
		ExplodeBlock(tileX - 1, tileY, 3)
		ExplodeBlock(tileX, tileY + 1, 3)
		ExplodeBlock(tileX, tileY - 1, 3)
		ExplodeBlock(tileX + 1, tileY + 1, 3)
		ExplodeBlock(tileX + 1, tileY - 1, 3)
		ExplodeBlock(tileX - 1, tileY + 1, 3)
		ExplodeBlock(tileX - 1, tileY - 1, 3)
		ExplodeBlock(tileX + 2, tileY, 2, 3)
		ExplodeBlock(tileX - 2, tileY, 2, 3)
		ExplodeBlock(tileX, tileY + 2, 2, 3)
		ExplodeBlock(tileX, tileY - 2, 2, 3)
		ExplodeBlock(tileX + 2, tileY + 1, 1, 2)
		ExplodeBlock(tileX + 2, tileY - 1, 1, 2)
		ExplodeBlock(tileX - 2, tileY + 1, 1, 2)
		ExplodeBlock(tileX - 2, tileY - 1, 1, 2)
		ExplodeBlock(tileX + 1, tileY + 2, 1, 2)
		ExplodeBlock(tileX + 1, tileY - 2, 1, 2)
		ExplodeBlock(tileX - 1, tileY + 2, 1, 2)
		ExplodeBlock(tileX - 1, tileY - 2, 1, 2)
		
		SoundHandler.PlaySound("nuke")
	end
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- External Utilities

function self.GetPieceSpawnPos()
	return spawnX, spawnY
end

function self.GetSpawnDepth()
	return spawnY
end

function self.WorldToScreen(x, y)
	return x*Global.BLOCK_SIZE, y*Global.BLOCK_SIZE
end

function self.BlockAt(x, y)
	return blockMap[y] and blockMap[y][x]
end

function self.Empty(x, y)
	return blockMap[y] and blockMap[y][x] and not blockMap[y][x].wantDirt
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- Piece Checking Utilities

function self.PieceInsidePlayArea(pX, pY, pRot, pDef)
	local tiles = pDef.tiles
	for i = 1, #tiles do
		local tilePos = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
		local x, y = pX + tilePos[1], pY + tilePos[2]
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
	local hitRock = false
	local spaceFound = false
	local nonSpaceEmptyHere = false
	local somethingHere = false
	local moneyToMake = 0
	for i = 1, #tiles do
		local tilePos = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
		local x, y = pX + tilePos[1], pY + tilePos[2]
		local blockData = blockMap[y] and blockMap[y][x]
		if blockData then
			-- Placement is triggered if there are no empty squares
			if blockData.toughness == 0 then
				fullyCovered = false
			end
			-- Detect space
			if blockData.isSpace then
				spaceFound = true
			elseif blockData.toughness == 0 then
				nonSpaceEmptyHere = true
			else
				somethingHere = true
			end
			-- Always get sucked into vortex
			if blockData.vortex then
				hitRock = true
			end
			-- Placement is triggered if the piece moves off econ blocks.
			if blockData.value then
				moneyToMake = moneyToMake + blockData.value*(tiles[i].moneyMult or 1)
			end
			-- Placement is triggered if the block hits something that is too tough.
			if blockData.toughness > pDef.carveStrength then
				hitRock = true
			end
		end
	end
	return (hitRock or fullyCovered) or (spaceFound and (not nonSpaceEmptyHere) and somethingHere), moneyToMake
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- Terrain Modification

function self.CarveTerrain(pX, pY, pRot, pDef, tiles)
	local tiles = pDef.tiles
	
	for i = 1, #tiles do
		local tilePos = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
		local x, y = self.WorldToScreen(pX + tilePos[1], pY + tilePos[2])
		EffectsHandler.SpawnEffect("piece_fade", {x, y}, {actualImageOverride = pDef.imageFile})
	end
	
	-- Explode bombs
	for i = 1, #tiles do
		if tiles[i].explosionRadius then
			local tilePos = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
			local tileX, tileY = pX + tilePos[1], pY + tilePos[2]
			DoExplosion(tileX, tileY, tiles[i].explosionRadius)
		end
	end
	
	-- Only affect blocks that are not behind barriers, such as rocks.
	local reCheck = true
	local trashPiece = false
	local processedBlocks = {}
	local blockDestroyValues = {}
	local valueMinY = false
	local hitRock = false
	while reCheck do
		reCheck = false
		for i = 1, #tiles do
			local tilePos = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
			local x, y = pX + tilePos[1], pY + tilePos[2]
			if not (processedBlocks[x] and processedBlocks[x][y]) then
				local blockData = self.BlockAt(x, y)
				if blockData then
					if tiles[i].vortex then
						processedBlocks[x] = processedBlocks[x] or {}
						processedBlocks[x][y] = true
						CreateVortex(x, y)
						trashPiece = true
					else
						if blockData.toughness ~= 0 and (self.Empty(x - 1, y) or self.Empty(x + 1, y) or self.Empty(x, y - 1) or self.Empty(x, y + 1)) then
							processedBlocks[x] = processedBlocks[x] or {}
							processedBlocks[x][y] = true
							if blockData.vortex then
								trashPiece = true
							end
							if blockData.toughness > pDef.carveStrength then
								hitRock = true
								blockData.hitPoints = blockData.hitPoints - pDef.carveStrength^2
								blockData.image = blockData.imageBase .. blockData.hitPoints
								if blockData.hitPoints <= 0 then
									valueMinY = DestroyBlock(x, y, blockDestroyValues, tiles[i].moneyMult, false, valueMinY)
									reCheck = true
								end
							else
								valueMinY = DestroyBlock(x, y, blockDestroyValues, tiles[i].moneyMult, false, valueMinY)
								reCheck = true
							end
						end
					end
				end
			end
		end
	end
	
	if hitRock then
		SoundHandler.PlaySound("rock_hit")
	end
	
	if not PlayerHandler.CollectBlockValues(pX, pY, blockDestroyValues, valueMinY or pY) then
		SoundHandler.PlaySound("coin_collect_1")
	end
	if trashPiece then
		PlayerHandler.TrashPiece(pDef.uniqueID)
	end
	
	if greatestDepth > oldGreatestDepth then
		oldGreatestDepth = greatestDepth
		PlayerHandler.OnDepthIncrease(greatestDepth - 3) -- Three air tiles
	end
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
	SpawnArea(currentMaxY + 1, spawnY + Global.BLOCK_SPAWN_SPAN)
	currentMaxY = spawnY + Global.BLOCK_SPAWN_SPAN
end

function self.Update(dt)
end

function self.Initialize(world)
	blockMap = {}

	PlayerHandler = world.GetPlayerHandler()
	ShopHandler = world.GetShopHandler()

	spawnX = 8
	spawnY = 2
	cullWait = 0
	currentMinY = spawnY - 1
	currentMaxY = currentMinY + Global.BLOCK_SPAWN_SPAN
	greatestDepth = 0
	oldGreatestDepth = 0

	scrollTrigger = spawnY + Global.TRIGGER_OFFSET
	desiredTopDraw = (spawnY - 1) * Global.BLOCK_SIZE
	
	SpawnArea(1, currentMaxY)
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- Drawing

function self.GetWantedDrawY()
	return desiredTopDraw
end

local function DrawBackground(x, y)
	local block = blockMap[y][x]
	if block.noBackground then
		return
	end
	local dx, dy = self.WorldToScreen(x, y)

	if not block.dirtStyle then
		block.dirtStyle = {}
		for i = 1, 4 do
			block.dirtStyle[i] = math.floor(math.random()*4 + 1)
			if block.dirtStyle[i] < 1 or block.dirtStyle[i] > 4 then
				block.dirtStyle[i] = 1
			end
		end
	end
	
	Resources.DrawImage("empty_" .. block.dirtStyle[1], dx, dy)
	Resources.DrawImage("empty_" .. block.dirtStyle[2], dx + Global.BLOCK_SIZE/2, dy)
	Resources.DrawImage("empty_" .. block.dirtStyle[3], dx, dy + Global.BLOCK_SIZE/2)
	Resources.DrawImage("empty_" .. block.dirtStyle[4], dx + Global.BLOCK_SIZE/2, dy + Global.BLOCK_SIZE/2)
end

local function DrawDirt(x, y)
	local block = blockMap[y][x]
	if not block.wantDirt then
		return
	end
	local dx, dy = self.WorldToScreen(x, y)

	local top = not self.Empty(x, y - 1)
	local bot = not self.Empty(x, y + 1)
	local left = not self.Empty(x - 1, y)
	local right = not self.Empty(x + 1, y)

	if block.isGrass then
		if left then
			if right then
				Resources.DrawImage("dirt_grass_n", dx, dy)
			else
				Resources.DrawImage("dirt_grass_ne", dx, dy)
			end
		elseif right then
			Resources.DrawImage("dirt_grass_nw", dx, dy)
		end
		return
	end

	if not block.dirtStyle then
		block.dirtStyle = {}
		for i = 1, 4 do
			block.dirtStyle[i] = math.floor(math.random()*4 + 1)
			if block.dirtStyle[i] < 1 or block.dirtStyle[i] > 4 then
				block.dirtStyle[i] = 1
			end
		end
	end
	
	-- North West
	if top then
		if left then
			if self.Empty(x - 1, y - 1) then
				Resources.DrawImage("dirt_inner_nw_" .. block.dirtStyle[1], dx, dy)
			else
				Resources.DrawImage("dirt_" .. block.dirtStyle[1], dx, dy)
			end
		else
			Resources.DrawImage("dirt_outer_w_" .. block.dirtStyle[1], dx, dy)
		end
	else
		if left then
			Resources.DrawImage("dirt_outer_n_" .. block.dirtStyle[1], dx, dy)
		else
			Resources.DrawImage("dirt_outer_nw_" .. block.dirtStyle[1], dx, dy)
		end
	end
	
	-- North East
	if top then
		if right then
			if self.Empty(x + 1, y - 1) then
				Resources.DrawImage("dirt_inner_ne_" .. block.dirtStyle[2], dx + Global.BLOCK_SIZE/2, dy)
			else
				Resources.DrawImage("dirt_" .. block.dirtStyle[2], dx + Global.BLOCK_SIZE/2, dy)
			end
		else
			Resources.DrawImage("dirt_outer_e_" .. block.dirtStyle[2], dx + Global.BLOCK_SIZE/2, dy)
		end
	else
		if right then
			Resources.DrawImage("dirt_outer_n_" .. block.dirtStyle[2], dx + Global.BLOCK_SIZE/2, dy)
		else
			Resources.DrawImage("dirt_outer_ne_" .. block.dirtStyle[2], dx + Global.BLOCK_SIZE/2, dy)
		end
	end
	
	-- South West
	if bot then
		if left then
			if self.Empty(x - 1, y + 1) then
				Resources.DrawImage("dirt_inner_sw_" .. block.dirtStyle[3], dx, dy + Global.BLOCK_SIZE/2)
			else
				Resources.DrawImage("dirt_" .. block.dirtStyle[3], dx, dy + Global.BLOCK_SIZE/2)
			end
		else
			Resources.DrawImage("dirt_outer_w_" .. block.dirtStyle[3], dx, dy + Global.BLOCK_SIZE/2)
		end
	else
		if left then
			Resources.DrawImage("dirt_outer_s_" .. block.dirtStyle[3], dx, dy + Global.BLOCK_SIZE/2)
		else
			Resources.DrawImage("dirt_outer_sw_" .. block.dirtStyle[3], dx, dy + Global.BLOCK_SIZE/2)
		end
	end
	
	-- South East
	if bot then
		if right then
			if self.Empty(x + 1, y + 1) then
				Resources.DrawImage("dirt_inner_se_" .. block.dirtStyle[4], dx + Global.BLOCK_SIZE/2, dy + Global.BLOCK_SIZE/2)
			else
				Resources.DrawImage("dirt_" .. block.dirtStyle[4], dx + Global.BLOCK_SIZE/2, dy + Global.BLOCK_SIZE/2)
			end
		else
			Resources.DrawImage("dirt_outer_e_" .. block.dirtStyle[4], dx + Global.BLOCK_SIZE/2, dy + Global.BLOCK_SIZE/2)
		end
	else
		if right then
			Resources.DrawImage("dirt_outer_s_" .. block.dirtStyle[4], dx + Global.BLOCK_SIZE/2, dy + Global.BLOCK_SIZE/2)
		else
			Resources.DrawImage("dirt_outer_se_" .. block.dirtStyle[4], dx + Global.BLOCK_SIZE/2, dy + Global.BLOCK_SIZE/2)
		end
	end
end

function self.Draw(dt)
	for x = 1, Global.MAP_WIDTH do
		for y = currentMinY, currentMaxY do
			--DrawBackground(x, y)
			local block = blockMap[y][x]
			if not block.noBackground then
				local dx, dy = self.WorldToScreen(x, y)
				Resources.DrawImage("empty", dx, dy)
			end
		end
	end
	
	for x = 1, Global.MAP_WIDTH do
		for y = currentMinY, currentMaxY do
			DrawDirt(x, y)
		end
	end
	for x = 1, Global.MAP_WIDTH do
		for y = currentMinY, currentMaxY do
			local block = blockMap[y][x]
			local dx, dy = self.WorldToScreen(x, y)
			if block.image and block.image ~= "dirt" and block.image ~= "empty" and not block.isGrass then
				Resources.DrawImage(block.image, dx, dy)
			end
		end
	end
	
	for x = 1, Global.MAP_WIDTH do
		for y = currentMinY, currentMaxY do
			local block = blockMap[y][x]
			local dx, dy = self.WorldToScreen(x + 0.5, y + 0.5)
			if block.animateImage then
				block.animateRot = (block.animateRot + dt)%(2*math.pi)
				Resources.DrawImage(block.animateImage, dx, dy, block.animateRot)
			end
		end
	end
end

return self
