
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

function self.Initialize()
	for x = 1, MAP_WIDTH do
		blockMap[x] = {}
		for y = 1, currentMaxY do
			blockMap[x][y] = {
				image = "dirt"
			}
			Resources.DrawImage("dirt", x, y)
		end
	end
end

function self.Draw()
	for x = 1, MAP_WIDTH do
		for y = currentMinY, currentMaxY do
			local block = blockMap[x][y]
			Resources.DrawImage("dirt", x*Global.BLOCK_SIZE, y*Global.BLOCK_SIZE)
		end
	end
end

return self
