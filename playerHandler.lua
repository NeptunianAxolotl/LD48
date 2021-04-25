
local util = require("include/util")
local Resources = require("resourceHandler")
local TerrainHandler = require("terrainHandler")
local Global = require("global")
local Font = require("include/font")

local pieceDefs = require("gameData/pieceDefs")

local PIECE_CARRYOVER = 0.8
local SUFFLE_PER_PIECE_DOWN = 5
local PIECE_DOWN_REDUCE = 1

local self = {}

local function DiscardAndDrawNextPiece()
	if self.nextPiece then
		self.discardPile[#self.discardPile + 1] = self.nextPiece
	end
	if #self.drawPile == 0 then
		self.drawPile = self.discardPile
		self.discardPile = {}
		self.shufflesUntilPiecePerScreenDown = self.shufflesUntilPiecePerScreenDown - 1
		if self.shufflesUntilPiecePerScreenDown <= 0 then
			self.shufflesUntilPiecePerScreenDown = SUFFLE_PER_PIECE_DOWN
			self.piecesPerScreen = self.piecesPerScreen - PIECE_DOWN_REDUCE
		end
	end
	local pieceName, index = util.SampleList(self.drawPile)
	self.drawPile[index] = self.drawPile[#self.drawPile]
	self.drawPile[#self.drawPile] = nil
	return pieceName
end

function self.UseNextPiece()
	local nextPiece = self.nextPiece
	self.nextPiece = DiscardAndDrawNextPiece()
	self.piecesRemaining = self.piecesRemaining - 1
	return nextPiece
end

function self.CollectBlockValues(blockDestroyValues)
	if #blockDestroyValues == 0 then
		return
	end
	local multiplier = 1 + (#blockDestroyValues - 1) / 2
	for i = 1, #blockDestroyValues do
		self.money = self.money + math.floor(multiplier * blockDestroyValues[i] + 0.5)
	end
end

function self.OnScreenScroll()
	self.piecesRemaining = math.floor(self.piecesRemaining * PIECE_CARRYOVER) + self.piecesPerScreen
end

function self.Update(dt)
end

function self.KeyPressed(key, scancode, isRepeat)
end

function self.Initialize()
	self.money = 0
	self.piecesRemaining = 46
	self.piecesPerScreen = 20
	self.drawPile = {
		"3I",
		"3L",
		"4S",
	}
	self.discardPile = {}
	self.shufflesUntilPiecePerScreenDown = SUFFLE_PER_PIECE_DOWN

	self.nextPiece = DiscardAndDrawNextPiece()
end

function self.DrawInterface()
	Font.SetSize(1)
	love.graphics.setColor(1, 1, 1)
	
	local offsetX = 580
	local offset = 30
	local spacing = 30
	
	love.graphics.print("Pieces: 34  (" .. self.piecesRemaining .. " x 80% + " .. self.piecesPerScreen .. " Bonus)", offsetX, offset)
	offset = offset + spacing
	love.graphics.print("Dig Deeper for Bonus: " .. self.piecesPerScreen, offsetX, offset)
	offset = offset + spacing
	love.graphics.print("Dig Bonus Shuffles: " .. self.shufflesUntilPiecePerScreenDown, offsetX, offset)
	offset = offset + spacing
	
	offset = offset + spacing*0.618
	love.graphics.print("Next Piece:", offsetX, offset)
	offset = offset + spacing
	if self.nextPiece then
		local pieceDef = pieceDefs.names[self.nextPiece]
		local tiles = pieceDef.tiles
		for i = 1, #tiles do
			local tile = tiles[i]
			local dx, dy = offsetX + 70 + tile[1]*Global.BLOCK_SIZE, offset + 40 + tile[2]*Global.BLOCK_SIZE
			Resources.DrawImage(pieceDef.imageFile, dx, dy)
		end
	end
	offset = offset + spacing*4
	
	love.graphics.print("Deck: " .. #self.drawPile, offsetX, offset)
	offset = offset + spacing
	love.graphics.print("Discard: " .. #self.discardPile, offsetX, offset)
	offset = offset + spacing
	
	offset = offset + spacing*0.618
	love.graphics.print("Money: $" .. self.money, offsetX, offset)
	offset = offset + spacing
end

return self