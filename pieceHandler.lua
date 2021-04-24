
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

local currentPiece = false
local currentPieceTimer = 0

local function UpdatePiecePos()
	local mX, mY = love.mouse.getX(), love.mouse.getY()
	local px, py = TerrainHandler.GetClosestPlacement(mX, mY, currentPiece.rotation, currentPiece.def)
	currentPiece.x = px
	currentPiece.y = py
end

local function RotatePiece(rotChange)
	currentPiece.rotation = currentPiece.rotation + rotChange
	UpdatePiecePos()
end

function self.Update(dt)
	if not currentPiece then
		local pieceDef = pieceDefNames[util.SampleList(pieceList)]
		currentPiece = {
			def = pieceDef,
			tiles = util.CopyTable(pieceDef.tiles, true),
			x = 15,
			y = 1,
			rotation = 0,
		}
	end
	
	UpdatePiecePos()
end

function self.MousePressed(x, y, button, istouch, presses)
	if button == 1 then
		if currentPiece then
			TerrainHandler.CarveTerrain(currentPiece.x, currentPiece.y, currentPiece.rotation, currentPiece.def)
			currentPiece = false
		end
	else
		if currentPiece then
			RotatePiece(-1)
		end
	end
end

function self.KeyPressed(key, scancode, isRepeat)
	if currentPiece then
		if key == "z" then
			RotatePiece(-1)
		elseif key == "x" then
			RotatePiece(1)
		end
	end
end

function self.Initialize()

end

function self.Draw(dt)
	if currentPiece then
		for i = 1, #currentPiece.tiles do
			local tile = util.RotateVectorOrthagonal(currentPiece.tiles[i], currentPiece.rotation * math.pi/2)
			local x, y = tile[1], tile[2]
			Resources.DrawImage("pieceBlock", (currentPiece.x + x)*Global.BLOCK_SIZE, (currentPiece.y + y)*Global.BLOCK_SIZE)
		end
	end
end

return self