
local util = require("include/util")

local progression = {}
local self = {}

local DISTANCE_MULT = 1

local distanceKeyframes = {
	{
		dist          = 12,
		lushFactor    = 0,
		
		specialType   = {
			bomb      = 10,
			moneyMult = 10,
			vortex    = 2,
			nuke      = 0,
			cutter    = 10,
			none      = 15,
		},
		specialCount = {
			[1] = 8,
			[2] = 1,
			[3] = 0,
			[4] = 0,
			[7] = 0,
		},
		pieceType = {
			tiny       = 2,
			small      = 7,
			smallFour  = 10,
			longFour   = 6,
			stumpyFive = 2,
			mediumFive = 1,
			bigFive    = 0,
			longFive   = 0,
		},
		blockType = {
			dirt      = 30,
			rock      = 2,
			hard_rock = 0,
			coal      = 4,
			gold      = 1,
			diamond   = 0,
		},
		veinChance = {
			rock      = 0,
			hard_rock = 0,
			coal      = 0.06,
			gold      = 0.05,
			diamond   = 0.02,
		},
		rockSpawnHealth = {
			[1] = 4,
			[2] = 8,
			[3] = 12
		},
		hardRockSpawnHealth = {
			[2] = 4,
			[4] = 8,
			[6] = 12
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

function self.GetRandomValue(distance, name, tableName)
	local first, second, factor = Interpolate(distance*DISTANCE_MULT, tableName)
	return IntAndRand(factor, first, second, name)
end

function self.GetRandomInt(distance, name, tableName)
	return math.floor(self.GetRandomValue(distance, name, tableName))
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
