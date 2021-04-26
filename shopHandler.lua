
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
	local specialType = Progression.SampleWeightedDistribution(distance, "specialType")
	local pieceName, pieceCategory = GetRandomPieceType(distance)
	
	local pieceDef = GetNewPieceByName(pieceName)
	pieceDef.category = pieceCategory
	local pieceCost = pieceCategory.cost + pieceCategory.cost*2*math.random()
	
	if specialType ~= "none" then
		local specialCount = Progression.SampleWeightedDistribution(spawnDepth or 0, "specialCount")
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
		return
	end
	
	if item.isRefresh then
		for i = 1, #self.options do
			if self.options[i].pDef then
				self.options[i].pDef, self.options[i].price = GetNewItem()
			end
		end
		item.price = item.price * 2
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

function self.GetStartingDeck()
	return {
		GetNewPieceByName("3I"),
		GetNewPieceByName("3L"),
		GetNewPieceByName("4S"),
		GetNewPieceByName("4Z"),
		GetNewPieceByName("4O"),
	}
end

function self.GetPieceDesc()
	if not self.interactedWithShop then
		return "Use the Arrow Keys to navigate and Enter/Return to select an item."
	end
	local item = self.options[self.selectedItem]
	if item.isRefresh then
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
end

function self.OnScreenScroll()
	self.active = true
	self.selectedItem = 1
	for i = 1, #self.options do
		if self.options[i].isRefresh then
			self.options[i].price = Global.REFRESH_COST
		end
	end
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
	
	PlayerHandler = world.GetPlayerHandler()
	
	self.options = {}
	for i = 1, 6 do
		self.options[i] = {
			position = i,
			label = (i == 3 and "Refresh") or (i == 6 and "Done"),
			price = (i ~= 6) and Global.REFRESH_COST,
			isRefresh = (i == 3),
			isDone = (i == 6),
		}
		if (i ~= 3 and i ~= 6) then
			self.options[i].pDef, self.options[i].price = GetNewItem()
		end
	end
end

function self.DrawCardOnInterface(cardX, cardY, pDef, label, price)
	local centX = cardX + 2*Global.BLOCK_SIZE - Global.SHOP_BLOCK_SIZE/2
	local centY = cardY + 2*Global.BLOCK_SIZE - Global.SHOP_BLOCK_SIZE*1.1
	Resources.DrawImage("cardFront", cardX, cardY)
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
	if label then
		Font.SetSize(1)
		love.graphics.setColor(1, 1, 1)
		
		love.graphics.printf(label, cardX, centY + 0.25*Global.BLOCK_SIZE, 4*Global.BLOCK_SIZE, "center")
	end
	if price then
		Font.SetSize(1)
		if PlayerHandler.GetMoney() < price then
			love.graphics.setColor(0.5, 0.5, 0.5)
		else
			love.graphics.setColor(1, 1, 1)
		end
		
		love.graphics.print("$" .. price, cardX + 16, cardY + 2.82*Global.BLOCK_SIZE)
	end
end

local function DrawItem(opt)
	local cardX, cardY = itemPositions[opt.position][1], itemPositions[opt.position][2]
	self.DrawCardOnInterface(cardX, cardY, opt.pDef, opt.label, opt.price)
end

function self.DrawInterface()
	for i = 1, #self.options do
		DrawItem(self.options[i])
	end
	
	if self.active then
		local cardX, cardY = itemPositions[self.selectedItem][1], itemPositions[self.selectedItem][2]
		Resources.DrawImage("select", cardX, cardY)
	end
end

return self
