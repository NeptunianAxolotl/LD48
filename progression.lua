
local util = require("include/util")

local progression = {}
local self = {}

local DISTANCE_MULT = 1

local distanceKeyframes = {
	{
		dist          = 15,
		lushFactor    = 0,
		
		specialType   = {
			bomb      = 2,
			moneyMult = 5,
			vortex    = 0,
			nuke      = 0,
			cutter    = 1,
			none      = 10,
		},
		specialCount = {
			[1] = 8,
			[2] = 0,
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
			rock      = 0.7,
			hard_rock = 0,
			coal      = 2.4,
			gold      = 0.9,
			diamond   = 0,
			space     = 0,
		},
		veinChance = {
			rock      = 0.01,
			hard_rock = 0,
			coal      = 0.09,
			gold      = 0.08,
			diamond   = 0,
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
	{
		dist          = 22,
		lushFactor    = 0,
		
		specialType   = {
			bomb      = 2,
			moneyMult = 5,
			vortex    = 0,
			nuke      = 0,
			cutter    = 4,
			none      = 9,
		},
		specialCount = {
			[1] = 8,
			[2] = 0,
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
			rock      = 4,
			hard_rock = 0,
			coal      = 1.5,
			gold      = 2.4,
			diamond   = 0,
			space     = 0,
		},
		veinChance = {
			rock      = 0,
			hard_rock = 0,
			coal      = 0.07,
			gold      = 0.08,
			diamond   = 0,
		},
		rockSpawnHealth = {
			[1] = 4,
			[2] = 8,
			[3] = 8
		},
		hardRockSpawnHealth = {
			[2] = 4,
			[4] = 8,
			[6] = 12
		},
	},
	{
		dist          = 23,
		lushFactor    = 0,
		
		specialType   = {
			bomb      = 3,
			moneyMult = 5,
			vortex    = 1,
			nuke      = 0,
			cutter    = 0,
			none      = 10,
		},
		specialCount = {
			[1] = 8,
			[2] = 0,
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
			rock      = 1,
			hard_rock = 0,
			coal      = 2,
			gold      = 1.5,
			diamond   = 0,
			space     = 0,
		},
		veinChance = {
			rock      = 0.02,
			hard_rock = 0,
			coal      = 0.06,
			gold      = 0.09,
			diamond   = 0,
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
	{
		dist          = 50,
		lushFactor    = 0,
		
		specialType   = {
			bomb      = 4,
			moneyMult = 4.5,
			vortex    = 4,
			nuke      = 0.2,
			cutter    = 5,
			none      = 10,
		},
		specialCount = {
			[1] = 7,
			[2] = 1,
			[3] = 0.5,
			[4] = 0,
			[7] = 0,
		},
		pieceType = {
			tiny       = 1.5,
			small      = 5,
			smallFour  = 9,
			longFour   = 8,
			stumpyFive = 5,
			mediumFive = 3,
			bigFive    = 2,
			longFive   = 1,
		},
		blockType = {
			dirt      = 30,
			rock      = 2,
			hard_rock = 0.1,
			coal      = 1.9,
			gold      = 2.3,
			diamond   = 0.01,
			space     = 0,
		},
		veinChance = {
			rock      = 0.09,
			hard_rock = 0.01,
			coal      = 0.1,
			gold      = 0.16,
			diamond   = 0,
		},
		rockSpawnHealth = {
			[1] = 2,
			[2] = 12,
			[3] = 30
		},
		hardRockSpawnHealth = {
			[2] = 4,
			[4] = 8,
			[6] = 12
		},
	},
	{
		dist          = 85,
		lushFactor    = 0,
		
		specialType   = {
			bomb      = 4,
			moneyMult = 6,
			vortex    = 6,
			nuke      = 1.5,
			cutter    = 6,
			none      = 7.5,
		},
		specialCount = {
			[1] = 6,
			[2] = 2,
			[3] = 1,
			[4] = 0.2,
			[7] = 0,
		},
		pieceType = {
			tiny       = 1,
			small      = 4,
			smallFour  = 8,
			longFour   = 8,
			stumpyFive = 7,
			mediumFive = 5,
			bigFive    = 4,
			longFive   = 3,
		},
		blockType = {
			dirt      = 30,
			rock      = 2.2,
			hard_rock = 0.35,
			coal      = 1.2,
			gold      = 2.6,
			diamond   = 0.2,
			space     = 0,
		},
		veinChance = {
			rock      = 0.2,
			hard_rock = 0.04,
			coal      = 0.1,
			gold      = 0.25,
			diamond   = 0.01,
		},
		rockSpawnHealth = {
			[1] = 0,
			[2] = 10,
			[3] = 30
		},
		hardRockSpawnHealth = {
			[2] = 4,
			[4] = 8,
			[6] = 16
		},
	},
	
	{
		dist          = 120,
		lushFactor    = 0,
		
		specialType   = {
			bomb      = 4,
			moneyMult = 7,
			vortex    = 7,
			nuke      = 3,
			cutter    = 7,
			none      = 6,
		},
		specialCount = {
			[1] = 4,
			[2] = 5,
			[3] = 3.5,
			[4] = 2,
			[7] = 1,
		},
		pieceType = {
			tiny       = 0.5,
			small      = 3,
			smallFour  = 6,
			longFour   = 6,
			stumpyFive = 6,
			mediumFive = 7,
			bigFive    = 7,
			longFive   = 6,
		},
		blockType = {
			dirt      = 30,
			rock      = 2,
			hard_rock = 0.9,
			coal      = 0.8,
			gold      = 2.8,
			diamond   = 0.8,
			space     = 0,
		},
		veinChance = {
			rock      = 0.26,
			hard_rock = 0.05,
			coal      = 0.05,
			gold      = 0.3,
			diamond   = 0.01,
		},
		rockSpawnHealth = {
			[1] = 0,
			[2] = 5,
			[3] = 30
		},
		hardRockSpawnHealth = {
			[2] = 1,
			[4] = 4,
			[6] = 20
		},
	},
	{
		dist          = 150,
		lushFactor    = 0,
		
		specialType   = {
			bomb      = 3,
			moneyMult = 7,
			vortex    = 7,
			nuke      = 4,
			cutter    = 7,
			none      = 2,
		},
		specialCount = {
			[1] = 1,
			[2] = 5,
			[3] = 6,
			[4] = 5,
			[7] = 3,
		},
		pieceType = {
			tiny       = 0.1,
			small      = 2,
			smallFour  = 6,
			longFour   = 6.5,
			stumpyFive = 7,
			mediumFive = 8,
			bigFive    = 7,
			longFive   = 6,
		},
		blockType = {
			dirt      = 30,
			rock      = 2.1,
			hard_rock = 0.8,
			coal      = 0,
			gold      = 3,
			diamond   = 1,
			space     = 0,
		},
		veinChance = {
			rock      = 0.35,
			hard_rock = 0.1,
			coal      = 0,
			gold      = 0.42,
			diamond   = 0.01,
		},
		rockSpawnHealth = {
			[1] = 0,
			[2] = 5,
			[3] = 30
		},
		hardRockSpawnHealth = {
			[2] = 1,
			[4] = 4,
			[6] = 20
		},
	},
	{
		dist          = 192,
		lushFactor    = 0,
		
		specialType   = {
			bomb      = 1,
			moneyMult = 7,
			vortex    = 7,
			nuke      = 7,
			cutter    = 12,
			none      = 0,
		},
		specialCount = {
			[1] = 0,
			[2] = 0,
			[3] = 0,
			[4] = 0,
			[7] = 10,
		},
		pieceType = {
			tiny       = 0.1,
			small      = 2,
			smallFour  = 6,
			longFour   = 6.5,
			stumpyFive = 7,
			mediumFive = 8,
			bigFive    = 7,
			longFive   = 6,
		},
		blockType = {
			dirt      = 30,
			rock      = 3,
			hard_rock = 1,
			coal      = 0,
			gold      = 2,
			diamond   = 1,
			space     = 0,
		},
		veinChance = {
			rock      = 0.12,
			hard_rock = 0.05,
			coal      = 0,
			gold      = 0.12,
			diamond   = 0,
		},
		rockSpawnHealth = {
			[1] = 0,
			[2] = 5,
			[3] = 40
		},
		hardRockSpawnHealth = {
			[2] = 1,
			[4] = 4,
			[6] = 35
		},
	},
	{
		dist          = 196,
		lushFactor    = 0,
		
		specialType   = {
			bomb      = 1,
			moneyMult = 7,
			vortex    = 7,
			nuke      = 7,
			cutter    = 12,
			none      = 0,
		},
		specialCount = {
			[1] = 0,
			[2] = 0,
			[3] = 0,
			[4] = 0,
			[7] = 10,
		},
		pieceType = {
			tiny       = 0.1,
			small      = 2,
			smallFour  = 6,
			longFour   = 6.5,
			stumpyFive = 7,
			mediumFive = 8,
			bigFive    = 7,
			longFive   = 6,
		},
		blockType = {
			dirt      = 0,
			rock      = 10,
			hard_rock = 25,
			coal      = 0,
			gold      = 1,
			diamond   = 5,
			space     = 0,
		},
		veinChance = {
			rock      = 0.1,
			hard_rock = 0.1,
			coal      = 0,
			gold      = 0.04,
			diamond   = 0.07,
		},
		rockSpawnHealth = {
			[1] = 0,
			[2] = 5,
			[3] = 60
		},
		hardRockSpawnHealth = {
			[2] = 1,
			[4] = 4,
			[6] = 50
		},
	},
	{
		dist          = 203,
		lushFactor    = 0,
		
		specialType   = {
			bomb      = 1,
			moneyMult = 7,
			vortex    = 7,
			nuke      = 7,
			cutter    = 12,
			none      = 0,
		},
		specialCount = {
			[1] = 0,
			[2] = 0,
			[3] = 0,
			[4] = 0,
			[7] = 10,
		},
		pieceType = {
			tiny       = 0.1,
			small      = 2,
			smallFour  = 6,
			longFour   = 6.5,
			stumpyFive = 7,
			mediumFive = 8,
			bigFive    = 7,
			longFive   = 6,
		},
		blockType = {
			dirt      = 0,
			rock      = 0,
			hard_rock = 8,
			coal      = 0,
			gold      = 0,
			diamond   = 0,
			space     = 10,
		},
		veinChance = {
			rock      = 0.1,
			hard_rock = 0.1,
			coal      = 0,
			gold      = 0.12,
			diamond   = 0.07,
		},
		rockSpawnHealth = {
			[1] = 0,
			[2] = 5,
			[3] = 60
		},
		hardRockSpawnHealth = {
			[2] = 1,
			[4] = 4,
			[6] = 50
		},
	},
	{
		dist          = 208,
		lushFactor    = 0,
		
		specialType   = {
			bomb      = 1,
			moneyMult = 7,
			vortex    = 7,
			nuke      = 7,
			cutter    = 12,
			none      = 0,
		},
		specialCount = {
			[1] = 0,
			[2] = 0,
			[3] = 0,
			[4] = 0,
			[7] = 10,
		},
		pieceType = {
			tiny       = 0.1,
			small      = 2,
			smallFour  = 6,
			longFour   = 6.5,
			stumpyFive = 7,
			mediumFive = 8,
			bigFive    = 7,
			longFive   = 6,
		},
		blockType = {
			dirt      = 0,
			rock      = 0,
			hard_rock = 0,
			coal      = 0,
			gold      = 0,
			diamond   = 0,
			space     = 10,
		},
		veinChance = {
			rock      = 0.1,
			hard_rock = 0.1,
			coal      = 0,
			gold      = 0.12,
			diamond   = 0.07,
		},
		rockSpawnHealth = {
			[1] = 0,
			[2] = 5,
			[3] = 60
		},
		hardRockSpawnHealth = {
			[2] = 1,
			[4] = 4,
			[6] = 50
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
