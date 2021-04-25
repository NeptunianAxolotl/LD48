
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

local function UpdateProportion(dt, name, speed)
	if self[name] then
		self[name] = self[name] + speed*dt
		if self[name] > 1 then
			self[name] = false
		end
	end
end

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
			self.bonusUpdateProp = 0
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
	local moneyMade = 0
	for i = 1, #blockDestroyValues do
		moneyMade = moneyMade + math.floor(multiplier * blockDestroyValues[i] + 0.5)
	end
	
	if moneyMade <= 0 then
		return
	end
	
	self.money = self.money + moneyMade
	
	self.moneyUpdateProp = 0
	self.moneyUpdateAmount = moneyMade
	self.moneyUpdateMultiplier = multiplier*100
end

function self.OnScreenScroll()
	self.pieceUpdateProp = 0
	self.pieceUpdateOld = self.piecesRemaining
	self.piecesRemaining = math.floor(self.piecesRemaining * PIECE_CARRYOVER) + self.piecesPerScreen
end

function self.Update(dt)
	UpdateProportion(dt, "pieceUpdateProp", 0.4)
	UpdateProportion(dt, "bonusUpdateProp", 0.8)
	UpdateProportion(dt, "moneyUpdateProp", 0.6)
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
	
	self.bonusUpdateProp = false
	
	self.pieceUpdateProp = false
	self.pieceUpdateOld = false
	
	self.moneyUpdateProp = false
	self.moneyUpdateAmount = false
	self.moneyUpdateMultiplier = false
end

function self.DrawInterface()
	Font.SetSize(1)
	love.graphics.setColor(1, 1, 1)
	
	local offsetX = 580
	local offset = 30
	local spacing = 30
	
	if self.pieceUpdateProp then
		local prop = (self.pieceUpdateProp > 0.25 and util.SmoothZeroToOne((self.pieceUpdateProp - 0.25) / 0.75, 7)) or 0
		love.graphics.print("Pieces: " .. math.floor(util.AverageScalar(self.pieceUpdateOld, self.piecesRemaining, prop) + 0.5), offsetX, offset)
		local oldBracket = math.floor(util.AverageScalar(self.pieceUpdateOld, 0, prop) + 0.5)
		local oldBonus = math.floor(util.AverageScalar(self.piecesPerScreen, 0, prop) + 0.5)
		love.graphics.setColor(1, 1, 1, (self.pieceUpdateProp < 0.9 and 1) or (1 - (self.pieceUpdateProp - 0.9) / 0.1))
		love.graphics.print("(" .. oldBracket .. " x 80% + " .. oldBonus .. " Bonus)", offsetX + 140, offset)
		love.graphics.setColor(1, 1, 1, 1)
	else
		love.graphics.print("Pieces: " .. self.piecesRemaining, offsetX, offset)
	end
	offset = offset + spacing
	love.graphics.print("Dig Deeper for Bonus: " .. self.piecesPerScreen, offsetX, offset)
	if self.bonusUpdateProp then
		local prop = util.SmoothZeroToOne(self.bonusUpdateProp, 7)
		love.graphics.setColor(1, 1, 1, (self.bonusUpdateProp < 0.8 and 1) or (1 - (self.bonusUpdateProp - 0.8) / 0.2))
		love.graphics.print("-1", offsetX + 296, offset)
		love.graphics.setColor(1, 1, 1, 1)
	end
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
	if self.moneyUpdateProp then
		local prop = (self.moneyUpdateProp > 0.2 and util.SmoothZeroToOne((self.moneyUpdateProp - 0.2) / 0.8, 7)) or 0
		local newMoney = math.floor(util.AverageScalar(self.money - self.moneyUpdateAmount, self.money, prop) + 0.5)
		local addMoney = math.floor(util.AverageScalar(self.moneyUpdateAmount, 0, prop) + 0.5)
		love.graphics.print("Money: $" .. newMoney, offsetX, offset)
		
		love.graphics.setColor(1, 1, 1, (self.moneyUpdateProp < 0.9 and 1) or (1 - (self.moneyUpdateProp - 0.9) / 0.1))
		love.graphics.print(" + " .. addMoney .. " x " .. self.moneyUpdateMultiplier .. "%", offsetX + 180, offset)
		love.graphics.setColor(1, 1, 1, 1)
	else
		love.graphics.print("Money: $" .. self.money, offsetX, offset)
	end
	offset = offset + spacing
end

return self