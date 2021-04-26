
local util = require("include/util")
local Resources = require("resourceHandler")
local Global = require("global")
local Font = require("include/font")

local Progression = require("progression")
local TerrainHandler = require("terrainHandler")
local PlayerHandler

local pieceDefs = require("game_data/pieceDefs")
local pieceCategories = require("game_data/pieceCategories")
local specialDefs = require("game_data/specialDefs")

local itemPositions = {
	{19 * 32, 14.25 * 32 - 8},
	{24 * 32, 14.25 * 32 - 8},
	{29 * 32, 14.25 * 32 - 8},
	{19 * 32, 19 * 32 - 8},
	{24 * 32, 19 * 32 - 8},
	{29 * 32, 19 * 32 - 8},
}

local self = {}

local function AddSpecialToPiece(pieceDef, specialName)
	local specialDef = specialDefs[specialName]
	local tile, index = util.SampleList(pieceDef.tiles)
	if specialDef.tileFunc then
		pieceDef.tiles[index] = specialDef.tileFunc(tile)
	end
	if specialDef.pieceFunc then
		pieceDef.tiles[index].pieceFunc = specialDef.pieceFunc -- To be called later.
	end
	return pieceDef
end

local function GetNewPieceByName(defName)
	local pieceDef = util.CopyTable(pieceDefs.names[defName], true)
	pieceDef.uniqueID = math.random() -- Enables pieces to be found in the deck
	return pieceDef
end

local function GetRandomPieceType(distance)
	local category = Progression.SampleWeightedDistribution(distance, "pieceType")
	return util.SampleList(pieceCategories[category].list), pieceCategories[category]
end

local function GetNewItem()
	local distance = TerrainHandler.GetSpawnDepth() or 0
	local pieceName, pieceCategory = GetRandomPieceType(distance)
	
	local pieceDef = GetNewPieceByName(pieceName)
	pieceDef.category = pieceCategory
	local pieceCost = pieceCategory.cost + pieceCategory.cost*1.5*math.random()
	
	local specialType = Progression.SampleWeightedDistribution(distance, "specialType")
	if pieceDef.plainRedraw and specialType == "none" then
		specialType = Progression.SampleWeightedDistribution(distance, "specialType")
	end
	
	if specialType ~= "none" then
		local specialCount = Progression.SampleWeightedDistribution(distance, "specialCount")
		for i = 1, specialCount do
			pieceDef = AddSpecialToPiece(pieceDef, specialType)
		end
		pieceCost = pieceCost + pieceCategory.specialCost + pieceCategory.specialCost*2*math.random()
		pieceCost = pieceCost + (math.min(specialCount, pieceCategory.size) - 1) * specialCount
		
		for i = 1, #pieceDef.tiles do
			if pieceDef.tiles[i].pieceFunc then
				pieceDef.tiles[i].pieceFunc(pieceDef)
			end
		end
	end
	
	pieceCost = math.floor((pieceCost + 25)/50)*50
	return pieceDef, pieceCost
end

local function PurchaseCurrentItem()
	local item = self.options[self.selectedItem]
	if item.price and not PlayerHandler.SpendMoney(item.price) then
		return
	end
	
	if item.isDone then
		self.active = false
		self.shopDeactiveProp = 0
		for i = 1, #self.options do
			if self.options[i].isRefresh then
				self.options[i].price = 0
			end
		end
		return
	end
	
	if item.isRefresh then
		for i = 1, #self.options do
			if self.options[i].pDef then
				self.options[i].pDef, self.options[i].price = GetNewItem()
			end
		end
		if item.price > 0 then
			item.price = item.price * 2
		else
			item.price = Global.REFRESH_COST
		end
		return
	end
	
	if item.pDef then
		PlayerHandler.AddCard(item.pDef)
		item.pDef, item.price = GetNewItem()
	end
end

function self.IsActive()
	return self.active
end

function self.GetInteractedWithShop()
	return self.interactedWithShop
end

function self.GetStartingDeck()
	return {
		AddSpecialToPiece(GetNewPieceByName("3I"), "nuke"),
		AddSpecialToPiece(GetNewPieceByName("3L"), "nuke"),
		AddSpecialToPiece(GetNewPieceByName("4S"), "nuke"),
		AddSpecialToPiece(GetNewPieceByName("4Z"), "nuke"),
		AddSpecialToPiece(GetNewPieceByName("4O"), "nuke"),
		AddSpecialToPiece(GetNewPieceByName("4T"), "nuke"),
	}
end

function self.GetPieceDesc()
	if not self.interactedWithShop then
		return "Use the Arrow Keys to navigate and Enter/Return to select an item."
	end
	local item = self.options[self.selectedItem]
	if item.isRefresh then
		if item.price == 0 then
			return "Clear the shop and draw four new options. First time is free."
		elseif item.price <= 150 then
			return "Clear the shop and draw four new options, for a small fee."
		end
		return "Clear the shop and draw four new options, for a 'small' fee."
	end
	if item.isDone then
		return "Leave the shop."
	end
	
	if item.pDef then
		if item.pDef.desc then
			return item.pDef.desc
		end
		return item.pDef.category.desc
	end
	
	return "An ordinary piece."
end

function self.Update(dt)
	self.shopActiveProp = util.UpdateProportion(dt, self.shopActiveProp, 4)
	self.shopDeactiveProp = util.UpdateProportion(dt, self.shopDeactiveProp, 2.5)
	self.pulseDt = Resources.UpdateAnimation("button_pulse", self.pulseDt, dt)
end

function self.OnScreenScroll()
	self.active = true
	self.selectedItem = 1
	self.shopActiveProp = 0
end

function self.KeyPressed(key, scancode, isRepeat)
	if self.active and not isRepeat then
		if key == "right" then
			if self.selectedItem ~= 3 and self.selectedItem ~= 6 then
				self.selectedItem = self.selectedItem + 1
			end
			self.interactedWithShop = true
		elseif key == "left" then
			if self.selectedItem ~= 1 and self.selectedItem ~= 4 then
				self.selectedItem = self.selectedItem - 1
			end
		elseif key == "up" then
			if self.selectedItem > 3 then
				self.selectedItem = self.selectedItem - 3
			end
		elseif key == "down" then
			if self.selectedItem <= 3 then
				self.selectedItem = self.selectedItem + 3
			end
			self.interactedWithShop = true
		elseif key == "return" or key == "kpenter" then
			PurchaseCurrentItem()
			self.interactedWithShop = true
		end
	end
end

function self.Initialize(world)
	self.active = false
	self.selectedItem = 1
	self.interactedWithShop = false
	self.shopActiveProp = false
	self.shopDeactiveProp = false
	self.pulseDt = 0
	
	PlayerHandler = world.GetPlayerHandler()
	
	self.options = {}
	for i = 1, 6 do
		self.options[i] = {
			position = i,
			label = (i == 3 and "Refresh") or (i == 6 and "Done"),
			price = (i ~= 6) and 0,
			isRefresh = (i == 3),
			isDone = (i == 6),
		}
		if (i ~= 3 and i ~= 6) then
			self.options[i].pDef, self.options[i].price = GetNewItem()
		end
	end
end

function self.DrawCardOnInterface(cardX, cardY, pDef, label, price, disabledAmount)
	local centX = cardX + 2*Global.BLOCK_SIZE - Global.SHOP_BLOCK_SIZE/2
	local centY = cardY + 2*Global.BLOCK_SIZE - Global.SHOP_BLOCK_SIZE*1.1
	Resources.DrawImage("cardFront", cardX, cardY)
	if disabledAmount then
		Resources.DrawImage("cardDisabled", cardX, cardY, 0, 0.7*disabledAmount)
	end
	if pDef then
		local tiles = pDef.tiles
		for i = 1, #tiles do
			local tile = tiles[i]
			local dx, dy = centX + tile[1]*Global.SHOP_BLOCK_SIZE, centY + tile[2]*Global.SHOP_BLOCK_SIZE
			Resources.DrawImage(pDef.imageFile, dx, dy, 0, 1, Global.SHOP_BLOCK_SIZE/Global.BLOCK_SIZE)
		end
		local tiles = pDef.tiles
		for i = 1, #tiles do
			local tile = tiles[i]
			local dx, dy = centX + tile[1]*Global.SHOP_BLOCK_SIZE, centY + tile[2]*Global.SHOP_BLOCK_SIZE
			if tile.imageFile then
				Resources.DrawImage(tile.imageFile, dx, dy, 0, 1, Global.SHOP_BLOCK_SIZE/Global.BLOCK_SIZE)
			end
		end
	end
	if disabledAmount then
		Resources.DrawImage("cardDisabled", cardX, cardY, 0, 0.5*disabledAmount)
	end
	
	if label then
		Font.SetSize(1)
		local canAfford = not (price and (PlayerHandler.GetMoney() < price))
		if disabledAmount then
			if canAfford then
				love.graphics.setColor(1 - 0.5*disabledAmount, 1 - 0.5*disabledAmount, 1 - 0.5*disabledAmount)
			else
				love.graphics.setColor(0.5, 0.5, 0.5)
			end
		elseif not canAfford then
			love.graphics.setColor(0.5, 0.5, 0.5)
		else
			love.graphics.setColor(1, 1, 1)
		end
		
		love.graphics.printf(label, cardX, centY + 0.25*Global.BLOCK_SIZE, 4*Global.BLOCK_SIZE, "center")
		love.graphics.setColor(1, 1, 1)
	end
	if price then
		Font.SetSize(1)
		local canAfford = not ((PlayerHandler.GetMoney() < price))
		if disabledAmount then
			if canAfford then
				love.graphics.setColor(1 - 0.5*disabledAmount, 1 - 0.5*disabledAmount, 1 - 0.5*disabledAmount)
			else
				love.graphics.setColor(0.5, 0.5, 0.5)
			end
		elseif not canAfford then
			love.graphics.setColor(0.5, 0.5, 0.5)
		else
			love.graphics.setColor(1, 1, 1)
		end
		
		if price > 0 then
			love.graphics.print("$" .. price, cardX + 16, cardY + 2.82*Global.BLOCK_SIZE)
		else
			love.graphics.print("Free", cardX + 16, cardY + 2.82*Global.BLOCK_SIZE)
		end
	end
end

local function DrawItem(opt)
	local cardX, cardY = itemPositions[opt.position][1], itemPositions[opt.position][2]
	local disabledAmount = false
	if self.shopActiveProp then
		disabledAmount = (1 - self.shopActiveProp)
	elseif self.shopDeactiveProp then
		disabledAmount = self.shopDeactiveProp
	elseif not self.IsActive() then
		disabledAmount = 1
	end
	self.DrawCardOnInterface(cardX, cardY, opt.pDef, opt.label, opt.price, disabledAmount)
end

function self.DrawInterface()
	if (not self.active) and (not self.interactedWithShop) then
		return
	end
	for i = 1, #self.options do
		DrawItem(self.options[i])
	end
	
	if self.active then
		local cardX, cardY = itemPositions[self.selectedItem][1], itemPositions[self.selectedItem][2]
		Resources.DrawAnimation("button_pulse", cardX, cardY, self.pulseDt)
	end
end

return self
