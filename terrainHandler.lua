
local util = require("include/util")
local Resources = require("resourceHandler")
local Global = require("global")

local self = {}

local blockMap = {}
local MAP_WIDTH = 30
local currentMinY = 1
local currentMaxY = 30

function self.Update(dt)

end

function self.CheckPieceFullyCovered(pX, pY, pRot, pDef)
	local tiles = pDef.tiles
	for i = 1, #tiles do
		local tile = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
		local x, y = pX + tile[1], pY + tile[2]
		local blockType = blockMap[x] and blockMap[x][y]
		if (not blockType) or (blockType == "empty") then
			return false
		end
	end
	return true
end

function self.CarveTerrain(pX, pY, pRot, pDef)
	local tiles = pDef.tiles
	for i = 1, #tiles do
		local tile = util.RotateVectorOrthagonal(tiles[i], pRot * math.pi/2)
		local x, y = pX + tile[1], pY + tile[2]
		local blockType = blockMap[x] and blockMap[x][y]
		if blockType and blockType ~= "empty" then
			blockMap[x][y] = "empty"
		end
	end
end

function self.Initialize()
	for x = 1, MAP_WIDTH do
		blockMap[x] = {}
		for y = 1, currentMaxY do
			blockMap[x][y] = "dirt"
		end
	end
end

function self.Draw()
	for x = 1, MAP_WIDTH do
		for y = currentMinY, currentMaxY do
			local block = blockMap[x][y]
			Resources.DrawImage(block, x*Global.BLOCK_SIZE, y*Global.BLOCK_SIZE)
		end
	end
end

return self
