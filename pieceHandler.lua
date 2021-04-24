
local util = require("include/util")
local Resources = require("resourceHandler")
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

function self.Update(dt)
	if not currentPiece then
		local pieceDef = pieceDefNames[util.SampleList(pieceList)]
		currentPiece = {
			def = pieceDef,
			x = 1,
			y = 1,
		}
	end
end

function self.Initialize()

end

function self.Draw(dt)
	if currentPiece then
		for i = 1, #currentPiece.def.tiles do
			local tile = currentPiece.def.tiles[i]
			local x, y = tile[1], tile[2]
			Resources.DrawImage("pieceBlock", (currentPiece.x + x)*Global.BLOCK_SIZE, (currentPiece.y + y)*Global.BLOCK_SIZE)
		end
	end
end

return self