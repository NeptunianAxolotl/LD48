
local util = require("include/util")

local progression = {}
local self = {}

local DISTANCE_MULT = 1

local distanceKeyframes = {
	{
		dist          = 0,
		lushFactor    = 0,
		
		specialType   = {
			bomb = 1,
			moneyMult = 1,
			vortex = 1,
			nuke = 1,
			none = 10,
		},
		specialCount = {
			[1] = 10,
			[2] = 1,
			[3] = 2,
			[4] = 1,
			[7] = 1,
		},
		pieceType = {
			tiny       = 1,
			small      = 4,
			smallFour  = 7,
			longFour   = 5,
			stumpyFive = 1,
			mediumFive = 1,
			bigFive    = 1,
			longFive   = 0,
		},
	},
	{
		dist          = 5,
		lushFactor    = 0,
		
		specialType   = {
			bomb = 10,
			moneyMult = 0,
			vortex = 1,
			nuke = 1,
			none = 5,
		},
		specialCount = {
			[1] = 10,
			[2] = 1,
			[3] = 2,
			[4] = 1,
			[7] = 1,
		},
		pieceType = {
			tiny       = 1,
			small      = 4,
			smallFour  = 7,
			longFour   = 5,
			stumpyFive = 1,
			mediumFive = 1,
			bigFive    = 1,
			longFive   = 0,
		},
	},
}

------------------------------------------------------------------
------------------------------------------------------------------

local function GetFrames(distance)
	local index = 1
	local first = distanceKeyframes[1]
	local second = distanceKeyframes[1]
	
	while second.dist <= distance do
		index = index + 1
		first = second
		if distanceKeyframes[index] then
			second = distanceKeyframes[index]
		else
			return first, second
		end
	end
	return first, second
end

local function Interpolate(distance, tableName)
	local first, second = GetFrames(distance)
	if first.dist == second.dist then
		if tableName then
			return first[tableName], second[tableName], 0
		end
		return first, second, 0
	end
	local factor =  1 - (distance - first.dist)/(second.dist - first.dist)
	if tableName then
		return first[tableName], second[tableName], factor
	end
	return first, second, factor
end

local function IntAndRand(factor, first, second, name)
	if type(first[name]) == "number" then
		return factor*first[name] + (1 - factor)*second[name]
	end
	local minInt = factor*first[name][1] + (1 - factor)*second[name][1]
	local maxInt = factor*first[name][2] + (1 - factor)*second[name][2]
	return minInt + math.random()*(maxInt - minInt)
end

------------------------------------------------------------------
------------------------------------------------------------------

function self.GetWeightTable(distance, tableName)
	local first, second, factor = Interpolate(distance*DISTANCE_MULT, tableName)
	local weightList = {}
	local keyList = {}
	for key, value in pairs(first) do
		weightList[#weightList + 1] = IntAndRand(factor, first, second, key)
		keyList[#keyList + 1] = key
	end
	
	return weightList, keyList
end

function self.SampleWeightedDistribution(distance, tableName)
	local weightList, keyList = self.GetWeightTable(distance, tableName)
	local spawnDistribution = util.WeightsToDistribution(weightList)
	local resultIndex = util.SampleDistribution(spawnDistribution, math.random)
	return keyList[resultIndex]
end

function self.GetRandomInt(distance, name)
	local first, second, factor = Interpolate(distance*DISTANCE_MULT)
	return math.floor(IntAndRand(factor, first, second, name))
end

------------------------------------------------------------------
------------------------------------------------------------------

function self.GetBackgroundColor(cameraDistance)
	local first, second, factor = Interpolate(cameraDistance*DISTANCE_MULT)
	
	local lushFactor = IntAndRand(factor, first, second, "lushFactor")/100
	
	local greenScale = math.max(0, math.min(0.4, lushFactor))
	local redScale = math.max(0, math.min(1, lushFactor))

	return {0.95 - 0.3*redScale, 0.8 + 0.2*greenScale, 1}
end

------------------------------------------------------------------
------------------------------------------------------------------

function self.Initialize()
end

return self
