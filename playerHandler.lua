
local util = require("include/util")
local Resources = require("resourceHandler")
local EffectsHandler = require("effectsHandler")
local TerrainHandler = require("terrainHandler")
local Global = require("global")
local Font = require("include/font")

local PopupHandler = require("PopupHandler")
local ShopHandler

local PIECE_CARRYOVER = 0.8
local SUFFLE_PER_PIECE_DOWN = 1
local PIECE_DOWN_REDUCE = 1
local INITIAL_PIECES = 40
local PIECES_PER_SCREEN = 40
local PIECES_DOWN_STR = "1"

local seconds = 0
local self = {}

local function DiscardAndDrawNextPiece()
	if self.nextPiece then
		self.discardPile[#self.discardPile + 1] = self.nextPiece
	end
	if #self.drawPile == 0 then
		self.drawPile = self.discardPile
		self.discardPile = {}
		self.shufflesUntilPiecePerScreenDown = self.shufflesUntilPiecePerScreenDown - 1
		self.bonusUpdateProp = 0
		if self.shufflesUntilPiecePerScreenDown <= 0 then
			self.shufflesUntilPiecePerScreenDown = SUFFLE_PER_PIECE_DOWN
			self.piecesPerScreen = self.piecesPerScreen - PIECE_DOWN_REDUCE
		end
	end
	local pieceDef, index = util.SampleList(self.drawPile)
	self.drawPile[index] = self.drawPile[#self.drawPile]
	self.drawPile[#self.drawPile] = nil
	return pieceDef
end

function self.UseNextPiece()
	local nextPiece = self.nextPiece
	self.nextPiece = DiscardAndDrawNextPiece()
	self.piecesRemaining = self.piecesRemaining - 1
	return nextPiece
end

function self.SpendMoney(amount)
	if self.money < amount then
		return false
	end
	self.money = self.money - amount
	return true
end

function self.GetMoney()
	return self.money
end

function self.AddCard(pieceDef)
	self.discardPile[#self.discardPile + 1] = pieceDef
end

function self.TrashPiece(uniqueID)
	if self.nextPiece.uniqueID == uniqueID then
		self.nextPiece = nil
		self.nextPiece = DiscardAndDrawNextPiece()
		return
	end
	for i = 1, #self.drawPile do
		if self.drawPile[i].uniqueID == uniqueID then
			self.drawPile[i] = self.drawPile[#self.drawPile]
			self.drawPile[#self.drawPile] = nil
			return
		end
	end
	for i = 1, #self.discardPile do
		if self.discardPile[i].uniqueID == uniqueID then
			self.discardPile[i] = self.discardPile[#self.discardPile]
			self.discardPile[#self.discardPile] = nil
			return
		end
	end
end

function self.CollectBlockValues(pX, pY, blockDestroyValues, valueMinY)
	if #blockDestroyValues == 0 then
		return
	end
	local multiplier = 1 + (#blockDestroyValues - 1) / 2
	local moneyMade = 0
	for i = 1, #blockDestroyValues do
		moneyMade = moneyMade + blockDestroyValues[i]
	end
	
	if moneyMade <= 0 then
		return
	end
	
	if multiplier > 1 then
		local eX, eY = TerrainHandler.WorldToScreen(pX + 0.5, valueMinY + 0.5)
		EffectsHandler.SpawnEffect("mult_popup", {eX + 10, eY - 40}, {velocity = {1.3, 0}, text = "x" .. math.floor(multiplier*100 + 0.5) .. "%"})
	end
	
	self.money = self.money + math.floor(moneyMade * multiplier + 0.5)
	
	self.moneyUpdateProp = 0
	self.moneyUpdateAmount = moneyMade
	self.moneyUpdateMultiplier = multiplier
end

function self.OnScreenScroll()
	self.pieceUpdateProp = 0
	self.pieceUpdateOld = self.piecesRemaining
	self.piecesRemaining = math.floor(self.piecesRemaining * PIECE_CARRYOVER) + self.piecesPerScreen
end

function self.OnDepthIncrease(newDepth)
	newDepth = newDepth * Global.METRES_PER_TILE
	
	self.depthUpdateProp = 0
	self.depthUpdateAmount = newDepth - self.greatestDepth
	self.greatestDepth = newDepth
end

function self.Update(dt)
	self.pieceUpdateProp = util.UpdateProportion(dt, self.pieceUpdateProp, 0.25)
	self.bonusUpdateProp = util.UpdateProportion(dt, self.bonusUpdateProp, 0.6)
	self.moneyUpdateProp = util.UpdateProportion(dt, self.moneyUpdateProp, 0.25)
	self.depthUpdateProp = util.UpdateProportion(dt, self.depthUpdateProp, 0.9)
	if ShopHandler.IsActive() then
		self.moneyUpdateProp = false
	end
end

function self.KeyPressed(key, scancode, isRepeat)
end

function self.Initialize(world)
	self.money = 0
	self.piecesRemaining = INITIAL_PIECES
	self.piecesPerScreen = PIECES_PER_SCREEN
	self.discardPile = {}
	self.shufflesUntilPiecePerScreenDown = SUFFLE_PER_PIECE_DOWN

	ShopHandler = world.GetShopHandler()
	self.drawPile = ShopHandler.GetStartingDeck()

	self.nextPiece = DiscardAndDrawNextPiece()
	
	self.bonusUpdateProp = false
	
	self.pieceUpdateProp = false
	self.pieceUpdateOld = false
	
	self.moneyUpdateProp = false
	self.moneyUpdateAmount = false
	self.moneyUpdateMultiplier = false
	
	self.greatestDepth = 0
	self.depthUpdateProp = false
	self.depthUpdateAmount = false
end

function self.DrawInterface(dt)
	Resources.DrawImage("interface", 0, 0)

	Font.SetSize(0)
	love.graphics.setColor(1, 1, 1)
	
	love.graphics.print("Deck", 795, 36)
	love.graphics.print("Shop", 795, 355)
	
	Font.SetSize(1)
	
	local offsetX = 618
	local offset = 93
	local spacing = 32
	local textWidth = 440
	
	if self.pieceUpdateProp then
		local prop = (self.pieceUpdateProp > 0.2 and util.SmoothZeroToOne((self.pieceUpdateProp - 0.1) / 0.7, 7)) or 0
		love.graphics.print("Pieces remaining: " .. math.floor(util.AverageScalar(self.pieceUpdateOld, self.piecesRemaining, prop) + 0.5), offsetX, offset)
		local oldBracket = math.floor(util.AverageScalar(self.pieceUpdateOld, 0, prop) + 0.5)
		local oldBonus = math.floor(util.AverageScalar(self.piecesPerScreen, 0, prop) + 0.5)
		love.graphics.setColor(1, 1, 1, (self.pieceUpdateProp < 0.95 and 1) or (1 - (self.pieceUpdateProp - 0.95) / 0.05))
		love.graphics.print(" + " .. oldBonus, offsetX + 248, offset)
		love.graphics.setColor(1, 1, 1, 1)
	else
		love.graphics.print("Pieces remaining: " .. self.piecesRemaining, offsetX, offset)
	end
	offset = offset + spacing
	love.graphics.print("Extra pieces per level: " .. self.piecesPerScreen, offsetX, offset)
	if self.bonusUpdateProp then
		local prop = util.SmoothZeroToOne(self.bonusUpdateProp, 7)
		love.graphics.setColor(1, 1, 1, (self.bonusUpdateProp < 0.8 and 1) or (1 - (self.bonusUpdateProp - 0.8) / 0.2))
		love.graphics.print(" -" .. PIECES_DOWN_STR, offsetX + 292, offset)
		love.graphics.setColor(1, 1, 1, 1)
	end
	
	offset = 170
	
	if self.nextPiece then
		ShopHandler.DrawCardOnInterface(768, offset, self.nextPiece)
	end
	
	offset = 188
	for i = 1, math.min(6, #self.drawPile) do
		Resources.DrawImage("cardBack", offsetX + 20 + i*3, offset - i * 3)
	end
	love.graphics.print("Draw: " .. #self.drawPile, offsetX + 18, offset + 78)
	
	for i = 1, math.min(6, #self.discardPile) do
		Resources.DrawImage("cardBack", offsetX + 330 + i*3, offset - i * 3)
	end
	love.graphics.print("Discard: " .. #self.discardPile, offsetX + 320, offset + 78)
	

	offset = 413
	if self.moneyUpdateProp then
		local prop = (self.moneyUpdateProp > 0.2 and math.min(1, (util.SmoothZeroToOne((self.moneyUpdateProp - 0.1) / 0.7, 7) + 0.02))) or 0
		local newMoney = math.floor(util.AverageScalar(self.money - self.moneyUpdateAmount*self.moneyUpdateMultiplier, self.money, prop) + 0.5)
		local addMoney = math.floor(util.AverageScalar(self.moneyUpdateAmount, 0, prop) + 0.5)
		love.graphics.print("Money: $" .. newMoney, offsetX, offset)
		
		love.graphics.setColor(1, 1, 1, (self.moneyUpdateProp < 0.95 and 1) or (1 - (self.moneyUpdateProp - 0.95) / 0.05))
		love.graphics.print(" + $" .. addMoney .. " x " .. math.floor(self.moneyUpdateMultiplier*100 + 0.5) .. "%", offsetX + 190, offset)
		love.graphics.setColor(1, 1, 1, 1)
	else
		love.graphics.print("Money: $" .. self.money, offsetX, offset)
	end
	
	if ShopHandler.IsActive() then
		seconds = seconds + dt
		if not self.moneyUpdateProp then
			--love.graphics.setColor(1, 1, 1, 0.58 + 0.36*math.sin(seconds*4))
			love.graphics.print("Enter to Select", offsetX + 282, offset)
			--love.graphics.setColor(1, 1, 1, 1)
		end
		
		offset = 740
		love.graphics.printf(ShopHandler.GetPieceDesc(), offsetX, offset, textWidth)
	else
		if not ShopHandler.GetInteractedWithShop() then
			spacing = 28
			offset = offset + 50
			
			love.graphics.printf("These are the weiredest 'pieces' of mining equipment you've ever seen!", offsetX, offset, textWidth)
			offset = offset + spacing*2
			love.graphics.printf(" - Arrow Keys to Move.", offsetX, offset, textWidth)
			offset = offset + spacing
			love.graphics.printf(" - Z/X/Up to Rotate.", offsetX, offset, textWidth)
			offset = offset + spacing
			love.graphics.printf(" - Bury pieces to dig.", offsetX, offset, textWidth)
			offset = offset + spacing
			love.graphics.printf(" - Free falling pieces dig resources.", offsetX, offset, textWidth)
			offset = offset + spacing
			love.graphics.printf(" - Bunch resources for multipliers.", offsetX, offset, textWidth)
			offset = offset + spacing
			love.graphics.printf(" - Dig deep, there is little profit near the surface!", offsetX, offset, textWidth)
			offset = offset + spacing
		
		end
		offset = 750
		if self.depthUpdateProp then
			local prop = util.SmoothZeroToOne(self.depthUpdateProp, 3)
			local newDepth = math.floor(util.AverageScalar(self.greatestDepth - self.depthUpdateAmount, self.greatestDepth, prop) + 0.5)
			local addDepth = math.floor(util.AverageScalar(self.depthUpdateAmount, 0, prop) + 0.5)
			love.graphics.print("Depth: " .. newDepth .. "m", offsetX, offset)
			
			love.graphics.setColor(1, 1, 1, (self.depthUpdateProp < 0.95 and 1) or (1 - (self.depthUpdateProp - 0.95) / 0.05))
			love.graphics.print(" + " .. addDepth .. "m", offsetX + 170, offset)
			love.graphics.setColor(1, 1, 1, 1)
		else
			love.graphics.print("Depth: " .. self.greatestDepth .. "m", offsetX, offset)
		end
	end
end

return self
