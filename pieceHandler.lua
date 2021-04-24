
local util = require("include/util")
local Resources = require("resourceHandler")
local TerrainHandler = require("terrainHandler")
local Global = require("global")

local pieceDefs = require("gameData/pieceDefs")
local pieceDefNames = {}
for i = 1, #pieceDefs do
	pieceDefNames[pieceDefs[i].name] = pieceDefs[i]
end

local self = {}

local pieceList = {
	"r_3",
	"l_3",
	"r_5",
}

local dropSpeed = 0.9
local currentPiece = false
local currentPieceTimer = 0

function MovePiece(xChange, yChange, rotChange, blockInsteadOfPlace)
	local newX = currentPiece.x + xChange
	local newY = currentPiece.y + yChange
	local newRot = currentPiece.rotation + rotChange
	
	local piecePlacement = TerrainHandler.CheckPiecePlaceTrigger(newX, newY, newRot, currentPiece.def)
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
end

function self.Update(dt)
	if not currentPiece then
		local pieceDef = pieceDefNames[util.SampleList(pieceList)]
		currentPiece = {
			def = pieceDef,
			x = 8,
			y = 2,
			rotation = 0,
			dropTime = dropSpeed,
		}
	end
	
	currentPiece.dropTime = currentPiece.dropTime - dt
	if currentPiece.dropTime < 0 then
		currentPiece.dropTime = dropSpeed
		MovePiece(0, 1, 0)
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
		elseif key == "z" then
			MovePiece(0, 0, -1)
		elseif key == "x" then
			MovePiece(0, 0, 1)
		end
	end
end

function self.Initialize()

end

function self.Draw(dt)
	if currentPiece then
		local tiles = currentPiece.def.tiles
		for i = 1, #tiles do
			local tile = util.RotateVectorOrthagonal(tiles[i], currentPiece.rotation * math.pi/2)
			local x, y = tile[1], tile[2]
			Resources.DrawImage("pieceBlock", (currentPiece.x + x)*Global.BLOCK_SIZE, (currentPiece.y + y)*Global.BLOCK_SIZE)
		end
	end
end

return self