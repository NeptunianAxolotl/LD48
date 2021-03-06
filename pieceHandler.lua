
local util = require("include/util")
local Resources = require("resourceHandler")
local TerrainHandler = require("terrainHandler")
local Global = require("global")
local Progression = require("progression")

local PlayerHandler

local self = {}

local dropSpeed = 0.9
local currentPiece = false
local currentPieceTimer = 0

function MovePiece(xChange, yChange, rotChange, econCheckCarve)
	local newX = currentPiece.x + xChange
	local newY = currentPiece.y + yChange
	local newRot = currentPiece.rotation + rotChange
	
	if not TerrainHandler.PieceInsidePlayArea(newX, newY, newRot, currentPiece.def) then
		if rotChange == 0 then
			return
		end
		local offset = ((newX > Global.MAP_WIDTH / 2) and -1) or 1
		local tries = 8
		newX = newX + offset
		while not TerrainHandler.PieceInsidePlayArea(newX, newY, newRot, currentPiece.def) do
			newX = newX + offset
			tries = tries - 1
			if tries <= 0 then
				return
			end
		end
	end
	
	-- Shift rotated pieces to not place.
	if rotChange ~= 0 and TerrainHandler.CheckPiecePlaceTrigger(newX, newY, newRot, currentPiece.def) then
		if not TerrainHandler.CheckPiecePlaceTrigger(newX - 1, newY, newRot, currentPiece.def) then
			newX = newX - 1
		elseif not TerrainHandler.CheckPiecePlaceTrigger(newX + 1, newY, newRot, currentPiece.def) then
			newX = newX + 1
		end
	end
	
	local piecePlacement, moneyToMake = TerrainHandler.CheckPiecePlaceTrigger(newX, newY, newRot, currentPiece.def)
	if econCheckCarve and moneyToMake and moneyToMake < currentPiece.moneyToMake then
		TerrainHandler.CarveTerrain(currentPiece.x, currentPiece.y, currentPiece.rotation, currentPiece.def)
		currentPiece = false
		return
	end
	currentPiece.moneyToMake = (moneyToMake or 0)
	
	if piecePlacement then
		if blockInsteadOfPlace then
			return
		end
		
		TerrainHandler.CarveTerrain(newX, newY, newRot, currentPiece.def)
		currentPiece = false
		return
	end
	
	currentPiece.x = newX
	currentPiece.y = newY
	currentPiece.rotation = newRot
	
	if newY >= Progression.GetWinDistance() then
		self.world.SetGameOver(true)
	end
end

local function PlacePiece()
	TerrainHandler.CarveTerrain(currentPiece.x, currentPiece.y, currentPiece.rotation, currentPiece.def)
	currentPiece = false
end

local function GetNewPiece()
	local pieceDef = PlayerHandler.UseNextPiece()
	if pieceDef then
		local spawnX, spawnY = TerrainHandler.GetPieceSpawnPos()
		currentPiece = {
			def = pieceDef,
			x = spawnX,
			y = spawnY,
			rotation = 0,
			dropTime = dropSpeed,
			moneyToMake = 0,
		}
		MovePiece(0, 0, 4) -- Rotate to get out of wall
	else
		self.world.SetGameOver(false, "empty_deck")
	end
end

function self.Update(dt)
	if not currentPiece then
		GetNewPiece()
	end
	
	if currentPiece then
		currentPiece.dropTime = currentPiece.dropTime - dt
		if currentPiece.dropTime < 0 then
			currentPiece.dropTime = dropSpeed
			MovePiece(0, 1, 0, true)
		end
	end
end

function self.KeyPressed(key, scancode, isRepeat)
	if currentPiece then
		if key == "left" then
			MovePiece(-1, 0, 0)
		elseif key == "right" then
			MovePiece(1, 0, 0)
		elseif key == "down" then
			currentPiece.dropTime = dropSpeed
			MovePiece(0, 1, 0)
		elseif key == "z" or key == "up" then
			currentPiece.dropTime = dropSpeed
			MovePiece(0, 0, -1)
		elseif key == "x" then
			currentPiece.dropTime = dropSpeed
			MovePiece(0, 0, 1)
		elseif key == "return" or key == "kpenter" then
			--PlacePiece()
		end
	end
end

function self.Initialize(world)
	currentPiece = false
	currentPieceTimer = 0
	self.world = world
	
	PlayerHandler = world.GetPlayerHandler()
end

function self.Draw()
	if currentPiece then
		local tiles = currentPiece.def.tiles
		for i = 1, #tiles do
			local tile = util.RotateVectorOrthagonal(tiles[i], currentPiece.rotation * math.pi/2)
			local dx, dy = TerrainHandler.WorldToScreen(currentPiece.x + tile[1], currentPiece.y + tile[2])
			Resources.DrawImage(currentPiece.def.imageFile, dx, dy)
		end
		for i = 1, #tiles do
			local tile = util.RotateVectorOrthagonal(tiles[i], currentPiece.rotation * math.pi/2)
			local dx, dy = TerrainHandler.WorldToScreen(currentPiece.x + tile[1], currentPiece.y + tile[2])
			if tiles[i].imageFile then
				Resources.DrawImage(tiles[i].imageFile, dx, dy)
			end
		end
	end
end

return self