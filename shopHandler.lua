
local util = require("include/util")
local Resources = require("resourceHandler")
local Global = require("global")
local Font = require("include/font")

local PlayerHandler

local pieceDefs = require("gameData/pieceDefs")

local itemPositions = {
	{19 * 32, 14.25 * 32},
	{24 * 32, 14.25 * 32},
	{29 * 32, 14.25 * 32},
	{19 * 32, 19 * 32},
	{24 * 32, 19 * 32},
	{29 * 32, 19 * 32},
}

local self = {}

local function GetNewItem()
	return util.SampleList(pieceDefs)
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
				self.options[i].pDef = GetNewItem()
			end
		end
		return
	end
	
	if item.pDef then
		PlayerHandler.AddCard(item.pDef)
		item.pDef = GetNewItem()
	end
end

function self.IsActive()
	return self.active
end

function self.GetStartingDeck()
	return {
		util.CopyTable(pieceDefs.names["3I"], true),
		util.CopyTable(pieceDefs.names["3L"], true),
		util.CopyTable(pieceDefs.names["4S"], true),
		util.CopyTable(pieceDefs.names["4Z"], true),
		util.CopyTable(pieceDefs.names["4O"], true),
	}
end

function self.Update(dt)
end

function self.OnScreenScroll()
	self.active = true
	self.selectedItem = 1
end

function self.KeyPressed(key, scancode, isRepeat)
	if self.active then
		if key == "right" then
			if self.selectedItem ~= 3 and self.selectedItem ~= 6 then
				self.selectedItem = self.selectedItem + 1
			end
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
		elseif key == "return" or key == "kpenter" then
			PurchaseCurrentItem()
		end
	end
end

function self.Initialize(world)
	self.active = false
	self.selectedItem = 1
	
	PlayerHandler = world.GetPlayerHandler()
	
	self.options = {}
	for i = 1, 6 do
		self.options[i] = {
			position = i,
			pDef = (i ~= 3 and i ~= 6) and GetNewItem(),
			label = (i == 3 and "Refresh") or (i == 6 and "Done"),
			price = (i ~= 6) and 50,
			isRefresh = (i == 3),
			isDone = (i == 6),
		}
	end
end

function self.DrawCardOnInterface(cardX, cardY, pDef, label, price)
	local centX = cardX + 2*Global.BLOCK_SIZE - Global.SHOP_BLOCK_SIZE/2
	local centY = cardY + 2*Global.BLOCK_SIZE - Global.SHOP_BLOCK_SIZE*1.1
	if pDef then
		local tiles = pDef.tiles
		for i = 1, #tiles do
			local tile = tiles[i]
			local dx, dy = centX + tile[1]*Global.SHOP_BLOCK_SIZE, centY + tile[2]*Global.SHOP_BLOCK_SIZE
			Resources.DrawImage(pDef.imageFile, dx, dy, 0, 1, Global.SHOP_BLOCK_SIZE/Global.BLOCK_SIZE)
		end
	end
	if label then
		Font.SetSize(1)
		love.graphics.setColor(1, 1, 1)
		
		love.graphics.printf(label, cardX, centY - 0.1*Global.BLOCK_SIZE, 4*Global.BLOCK_SIZE, "center")
	end
	if price then
		Font.SetSize(1)
		love.graphics.setColor(0, 0, 0)
		
		love.graphics.print("$" .. price, cardX + 5, cardY + 2.8*Global.BLOCK_SIZE)
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
