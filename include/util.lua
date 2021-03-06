local util = {}

local sqrt = math.sqrt
local pi = math.pi
local cos = math.cos
local sin = math.sin

--------------------------------------------------
-- Vector funcs
--------------------------------------------------

function util.DistSq(x1, y1, x2, y2)
	return (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2)
end

function util.Dist(x1, y1, x2, y2)
	return sqrt(util.DistSq(x1,y1,x2,y2))
end

function util.DistSqVectors(u, v)
	return util.DistSq(u[1], u[2], v[1], v[2])
end

function util.DistVectors(u, v)
	return util.Dist(u[1], u[2], v[1], v[2])
end

function util.Dist3D(x1,y1,z1,x2,y2,z2)
	return sqrt((x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2) + (z1 - z2)*(z1 - z2))
end

function util.Add(v1, v2)
	return {v1[1] + v2[1], v1[2] + v2[2]}
end

function util.Subtract(v1, v2)
	return {v1[1] - v2[1], v1[2] - v2[2]}
end

function util.Mult(b, v)
	return {b*v[1], b*v[2]}
end

function util.AbsVal(x, y, z)
	if z then
		return sqrt(x*x + y*y + z*z)
	elseif y then
		return sqrt(x*x + y*y)
	elseif x[3] then
		return sqrt(x[1]*x[1] + x[2]*x[2] + x[3]*x[3])
	else
		return sqrt(x[1]*x[1] + x[2]*x[2])
	end
end

function util.Unit(v)
	local mag = util.AbsVal(v)
	if mag > 0 then
		return {v[1]/mag, v[2]/mag}
	else
		return v
	end
end

function util.SetLength(b, v)
	local mag = util.AbsVal(v)
	if mag > 0 then
		return {b*v[1]/mag, b*v[2]/mag}
	else
		return v
	end
end

function util.Angle(x, z)
	if not z then
		x, z = x[1], x[2]
	end
	if x == 0 and z == 0 then
		return 0
	end
	local mult = 1/util.AbsVal(x, z)
	x, z = x*mult, z*mult
	if z > 0 then
		return math.acos(x)
	elseif z < 0 then
		return 2*math.pi - math.acos(x)
	elseif x < 0 then
		return math.pi
	end
	-- x < 0
	return 0
end

function util.Dot(v1, v2)
	if v1[3] then
		return v1[1]*v2[1] + v1[2]*v2[2] + v1[3]*v2[3]
	else
		return v1[1]*v2[1] + v1[2]*v2[2]
	end
end

function util.Cross(v1, v2)
	return {v1[2]*v2[3] - v1[3]*v2[2], v1[3]*v2[1] - v1[1]*v2[3], v1[1]*v2[2] - v1[2]*v2[1]}
end

function util.Cross2D(v1, v2)
	return v1[1]*v2[2] - v1[2]*v2[1]
end

-- Projection of v1 onto v2
function util.Project(v1, v2)
	local uV2 = util.Unit(v2)
	return util.Mult(util.Dot(v1, uV2), uV2)
end

-- The normal of v1 onto v2. Returns such that v1 = normal + projection
function util.Normal(v1, v2)
	local projection = Project(v1, v2)
	return util.Subtract(v1, projection), projection
end

function util.GetAngleBetweenUnitVectors(u, v)
	return math.acos(util.Dot(u, v))
end

-- Get the average position between two vectors
function util.Average(u, v, uFactor)
	uFactor = uFactor or 0.5
	return util.Add(util.Mult(uFactor, util.Subtract(v, u)), u)
end

function util.AverageScalar(u, v, uFactor)
	uFactor = uFactor or 0.5
	return u*(1 - uFactor) + v * uFactor
end

function util.AngleSubtractShortest(angleA, angleB)
	local dist = angleA - angleB
	if dist > 0 then
		if dist < pi then
			return dist
		end
		return dist - 2*pi
	else
		if dist > -pi then
			return dist
		end
		return dist + 2*pi
	end
end

function util.AngleAverageShortest(angleA, angleB)
	local diff = util.AngleSubtractShortest(angleA, angleB)
	return angleA - diff/2
end

function util.SignPreserveMax(val, mag)
	if val > mag then
		return mag
	end
	if val < -mag then
		return -mag
	end
	return val
end

--------------------------------------------------
--------------------------------------------------
-- Transforms

function util.CartToPolar(v)
	return util.AbsVal(v), util.Angle(v)
end

function util.PolarToCart(mag, dir)
	return {mag*cos(dir), mag*sin(dir)}
end

function util.RotateVector(v, angle)
	local cosAngle = math.cos(angle)
	local sinAngle = math.sin(angle)
	return {v[1]*cosAngle - v[2]*sinAngle, v[1]*sinAngle + v[2]*cosAngle}
end

function util.RotateVectorOrthagonal(v, angle)
	local cosAngle = math.floor(math.cos(angle) + 0.5)
	local sinAngle = math.floor(math.sin(angle) + 0.5)
	return {v[1]*cosAngle - v[2]*sinAngle, v[1]*sinAngle + v[2]*cosAngle}
end

function util.ReflectVector(v, angle)
	return {v[1]*math.cos(2*angle) + v[2]*math.sin(2*angle), v[1]*math.sin(2*angle) - v[2]*math.cos(2*angle)}
end

function util.DirectionToCardinal(direction, start, segments)
	start = start or 0
	segments = segments or 4
	return math.floor((direction + start + math.pi/segments) / (2*math.pi/segments)) % segments + 1
end

function util.AngleToCardinal(angle, cardinal, start, segments)
	start = start or 0
	segments = segments or 4
	local cardinalAngle = (cardinal - 1)*math.pi*2/segments + start
	return cardinalAngle - angle
end

function util.InverseBasis(a, b, c, d)
	local det = a*d - b*c
	return d/det, -b/det, -c/det, a/det
end

function util.ChangeBasis(v, a, b, c, d)
	return {v[1]*a + v[2]*b, v[1]*c + v[2]*d}
end

--------------------------------------------------
--------------------------------------------------
-- Lines

function util.GetBoundedLineIntersection(line1, line2)
	local x1, y1, x2, y2 = line1[1][1], line1[1][2], line1[2][1], line1[2][2]
	local x3, y3, x4, y4 = line2[1][1], line2[1][2], line2[2][1], line2[2][2]
	
	local denominator = ((x1 - x2)*(y3 - y4) - (y1 - y2)*(x3 - x4))
	if denominator == 0 then
		return false
	end
	local first = ((x1 - x3)*(y3 - y4) - (y1 - y3)*(x3 - x4))/denominator
	local second = -1*((x1 - x2)*(y1 - y3) - (y1 - y2)*(x1 - x3))/denominator
	
	if first < 0 or first > 1 or (second < 0 or second > 1) then
		return false
	end
	
	local px = x1 + first*(x2 - x1)
	local py = y1 + first*(y2 - y1)
	
	return {px, py}
end

function util.IsPositiveIntersect(lineInt, lineMid, lineDir)
	return util.Dot(util.Subtract(lineInt, lineMid), lineDir) > 0
end

function util.DistanceToBoundedLineSq(point, line)
	local startToPos = util.Subtract(point, line[1])
	local startToEnd = util.Subtract(line[2], line[1])
	local normal, projection = util.Normal(startToPos, startToEnd)
	local projFactor = util.Dot(projection, startToEnd)
	local normalFactor = util.Dot(normalFactor, startToEnd)
	if projFactor < 0 then
		return util.Dist(line[1], point)
	end
	if projFactor > 1 then
		return util.Dist(line[2], point)
	end
	return util.AbsValSq(util.Subtract(startToPos, normal)), normalFactor
end

function util.DistanceToBoundedLine(point, line)
	local distSq, normalFactor = util.DistanceToBoundedLineSq(point, line)
	return sqrt(distSq), normalFactor
end

function util.DistanceToLineSq(point, line)
	local startToPos = util.Subtract(point, line[1])
	local startToEnd = util.Subtract(line[2], line[1])
	local normal, projection = util.Normal(startToPos, startToEnd)
	return util.AbsValSq(normal)
end

--------------------------------------------------
--------------------------------------------------
-- Rectangles

function util.IntersectingRectangles(x1, y1, w1, h1, x2, y2, w2, h2)
	return ((x1 + w1 >= x2 and x1 <= x2) or (x2 + w2 >= x1 and x2 <= x1)) and ((y1 + h1 >= y2 and y1 <= y2) or (y2 + h2 >= y1 and y2 <= y1))
end

function util.PosInRectangle(pos, x1, y1, w1, h1)
	return (x1 + w1 > pos[1] and x1 <= pos[1]) and (y1 + h1 > pos[2] and y1 <= pos[2])
end

--------------------------------------------------
--------------------------------------------------
-- Circles

function util.PosInCircle(pos1, pos2, radius)
	local distSq = util.DistSqVectors(pos1, pos2)
	if distSq <= radius*radius then
		return true, distSq
	end
end

function util.IntersectingCircles(pos1, radius1, pos2, radius2)
	local distSq = util.DistSqVectors(pos1, pos2)
	if distSq <= (radius1 + radius2)*(radius1 + radius2) then
		return true, distSq
	end
end

--------------------------------------------------
--------------------------------------------------
-- Probability

function util.WeightsToDistribution(weights)
	local sum = 0
	for i = 1, #weights do
		sum = sum + weights[i]
	end
	local normWeights = {}
	for i = 1, #weights do
		 normWeights[i] =  weights[i]/sum
	end
	return normWeights
end

function util.GenerateBoundedRandomWeight(bounds, rngIn)
	local rngFunc = rngIn or math.random
	local weights = {}
	for i = 1, #bounds do
		weights[i] = bounds[i][1] + rngFunc()*(bounds[i][2] - bounds[i][1])
	end
	return weights
end

function util.GenerateDistributionFromBoundedRandomWeights(bounds, rngIn)
	local weights = util.GenerateBoundedRandomWeight(bounds, rngIn)
	return util.WeightsToDistribution(weights)
end

function util.SampleList(list)
	if (not list) or (#list == 0) then
		return false, false
	end
	local index = math.floor(math.random()*#list) + 1
	return list[index], index
end

function util.SampleDistribution(distribution, rngIn)
	local rngFunc = rngIn or math.random
	local value = rngFunc()
	for i = 1, #distribution do
		if value < distribution[i] then
			return i
		end
		value = value - distribution[i]
	end
	return #distribution
end

function util.RandomPointInCircle(radius, startAngle, endAngle)
	startAngle = startAngle or 0
	endAngle = endAngle or 2*pi
	
	local r = math.random()
	local angle = startAngle + math.random()*(endAngle - startAngle)
	return util.PolarToCart(radius*math.sqrt(r), angle)
end

function util.RandomPointInAnnulus(innerRadius, outerRadius, startAngle, endAngle)
	startAngle = startAngle or 0
	endAngle = endAngle or 2*pi
	
	local minRadiusProp = math.sqrt(innerRadius/outerRadius)
	local r = minRadiusProp + math.random()*(1 - minRadiusProp)
	local angle = startAngle + math.random()*(endAngle - startAngle)
	return util.PolarToCart(outerRadius*math.sqrt(r), angle)
end

function util.RandomPointInEllipse(width, height, startAngle, endAngle)
	startAngle = startAngle or 0
	endAngle = endAngle or 2*pi
	
	local r = math.random()
	local angle = startAngle + math.random()*(endAngle - startAngle)
	local pos = util.PolarToCart(math.sqrt(r), angle)
	pos[1] = pos[1]*width
	pos[2] = pos[2]*height
	return pos
end

function util.GetRandomCardinalDirection()
	if math.random() < 0.5 then
		if math.random() < 0.5 then
			return {1, 0}
		else
			return {-1, 0}
		end
	else
		if math.random() < 0.5 then
			return {0, 1}
		else
			return {0, -1}
		end
	end
end

function util.GetRandomKingDirection()
	if math.random() < 0.5 then
		return util.GetRandomCardinalDirection()
	else
		if math.random() < 0.5 then
			if math.random() < 0.5 then
				return {1, 1}
			else
				return {1, -1}
			end
		else
			if math.random() < 0.5 then
				return {-1, 1}
			else
				return {-1, -1}
			end
		end
	end
end

--------------------------------------------------
--------------------------------------------------
-- Group Utilities

function util.Permute(list)
	for i = #list, 2, -1 do
		local j = math.random(i)
		list[i], list[j] = list[j], list[i]
	end
end

--------------------------------------------------
--------------------------------------------------
-- Nice Functions

function util.SmoothZeroToOne(value, factor)
	return 1 / (1 + math.exp( - factor * (value - 0.5)))
end

--------------------------------------------------
--------------------------------------------------
-- Time

function util.SecondsToString(seconds, dashForEmpty)
	if (seconds or 0) == 0 and dashForEmpty then
		return "-"
	end
	if seconds <= 0 then
		return "0:00"
	end
	local hours = math.floor(seconds/3600)			
	local minutes = math.floor(seconds/60)%60
	local seconds = math.floor(seconds)%60
	
	if hours > 0 then
		return string.format("%d:%02.f:%02.f", hours, minutes, seconds)
	end
	return string.format("%d:%02.f", minutes, seconds)
end

function util.UpdateProportion(dt, value, speed)
	if value then
		value = value + speed*dt
		if value > 1 then
			value = false
		end
	end
	return value
end

--------------------------------------------------
--------------------------------------------------
-- Table Utilities

function util.TableKeysToList(keyTable, indexToKey)
	local list = {}
	for i = 1, #indexToKey do
		list[i] = keyTable[indexToKey[i]]
	end
	return list
end

function util.PrintTable(data, name, indent, tableChecked)
	name = name or "PrintTable"
	indent = indent or ""
	if (not tableChecked) and type(data) ~= "table" then
		print(indent .. name, data)
		return
	end
	print(indent .. name .. " = {")
	local newIndent = indent .. "	"
	for nameRaw, v in pairs(data) do
		local name = tostring(nameRaw)
		local ty = type(v)
		if ty == "userdata" then
			print("warning, userdata")
		end
		if ty == "table" then
			util.PrintTable(v, name, newIndent, true)
		elseif ty == "boolean" then
			print(newIndent .. name .. " = " .. (v and "true" or "false"))
		elseif ty == "string" or ty == "number" then
			print(newIndent .. name .. " = " .. v)
		else
			print(newIndent .. name .. " = ", v)
		end
	end
	print(indent .. "},")
end

function util.CopyTable(tableToCopy, deep, appendTo)
	local copy = appendTo or {}
	for key, value in pairs(tableToCopy) do
		if (deep and type(value) == "table") then
			copy[key] = util.CopyTable(value, true)
		else
			copy[key] = value
		end
	end
	return copy
end

--------------------------------------------------
--------------------------------------------------

function util.GetDefDirList(dir)
	local files = love.filesystem.getDirectoryItems(dir)
	local defList = {}
	for i = 1, #files do
		local name = string.sub(files[i], 0, -5)
		defList[i] = name
	end
	return defList
end

function util.LoadDefDirectory(dir)
	local files = love.filesystem.getDirectoryItems(dir)
	local defTable = {}
	for i = 1, #files do
		local name = string.sub(files[i], 0, -5)
		defTable[name] = love.filesystem.load(dir .. "/" .. name .. ".lua")()
	end
	return defTable
end

--------------------------------------------------
--------------------------------------------------

return util
