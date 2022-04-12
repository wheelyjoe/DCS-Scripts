local utils = require 'DCS-Scripts.utils.utils'
local afac = {}
local jtacName
local foundUnitsRed = {}
local targetUnit
local ray
local lCode
deathHandler = {}
local nineline = {["text"] = "No targets"}

--TODO: Make work for multiple FAC(A)

local function LLstrings(pos) -- pos is a Vec3	THIS Converts DCS coordiantes to Lat/Long

	local LLposN, LLposE = coord.LOtoLL(pos)
	local LLposfixN, LLposdegN = math.modf(LLposN)
	LLposdegN = LLposdegN * 60
	local LLposdegN2, LLposdegN3 = math.modf(LLposdegN)
	LLposdegN3 = LLposdegN3 * 1000

	local LLposfixE, LLposdegE = math.modf(LLposE)
	LLposdegE = LLposdegE * 60
	local LLposdegE2, LLposdegE3 = math.modf(LLposdegE)
	LLposdegE3 = LLposdegE3 * 1000

	local LLposNstring = string.format('%+.2i %.2i %.3d', LLposfixN, LLposdegN2, LLposdegN3)
	local LLposEstring = string.format('%+.3i %.2i %.3d', LLposfixE, LLposdegE2, LLposdegE3)
	return LLposNstring, LLposEstring
end

local function blank()
	return
end

local function destroyRay(ray)	--function to remove spot

	Spot.destroy(ray)
end

local function generateNineline(target, afacName)		--called to generate nineline text
	local N, E = LLstrings(target:getPoint())
	local grid = coord.LLtoMGRS(coord.LOtoLL(target))
	env.info("N: "..N.."\nE: "..E)
	nineline = {["text"] = "This is ".. afacName..",\nTarget = "..target:getTypeName().."\nTarget Location = \n"..N.." N\n".. E .." E\nMGRS: "..grid.UTMZone .. ' ' .. grid.MGRSDigraph .. ' ' .. grid.Easting .. ' ' .. grid.Northing .."\nTarget Mark = Laser, Code: "..lCode}
end

local function laseTarget(target, afacName, code)		-- turns on laser for target and generates nineline
	lCode = code
	ray = Spot.createLaser(Unit.getByName(afacName), {x = 0, y=1, z=0}, target:getPoint(), lCode)
	generateNineline(target, afacName)
end

local function ifFoundU(foundItem, val)		--run on any units found
	if foundItem:getCoalition() == 1 and foundItem:getLife() > 0 then
		env.info("Found red unit, name: "..foundItem:getName())
		foundUnitsRed[#foundUnitsRed+1] = foundItem
	end
end

local function ifFoundS(foundItem, val)		-- run on any statics found
	if foundItem:getCoalition() == 1 and foundItem:getLife() > 0 then
		env.info("Found red static, name: "..foundItem:getName())
		foundUnitsRed[#foundUnitsRed+1] = foundItem
	end
end

local function generateTasking(params)		--sends nineline and starts laser
	afacName = params[1]
	code = params[2]
	laseTarget(targetUnit, afacName, code)
	trigger.action.outTextForCoalition(2, nineline.text, 15)
	env.info(nineline.text)
	missionCommands.removeItemForCoalition(2, "Request Tasking - "..jtacName)
	missionCommands.addCommandForCoalition(2, nineline.text, nil, blank, {})
end


local function onDeathEvent(event)			-- run when something dies
	if event.id == world.event.S_EVENT_DEAD then
		if event.initiator and event.initiator:getName() == targetUnit:getName() then
			missionCommands.removeItemForCoalition(2, nineline.text)
			destroyRay(ray)
			foundUnitsRed={}
			local volS = {
				id = world.VolumeType.SPHERE,
				params = {
			     point = Unit.getByName(jtacName):getPoint(),
			     radius = 15000
			   }
			 }
			world.searchObjects(Object.Category.UNIT, volS, ifFoundU)
			world.searchObjects(Object.Category.STATIC, volS, ifFoundU)
			if #foundUnitsRed > 0 then
				trigger.action.outTextForCoalition(2, "Target Destroyed, marking next target", 15)
				targetUnit = foundUnitsRed[math.random(1, #foundUnitsRed)]
				env.info("Targeting " ..targetUnit:getName())
				missionCommands.addCommandForCoalition(2, "Request Tasking - "..jtacName, nil, generateTasking, {afacName, code})
			else
				trigger.action.outTextForCoalition(2, "Target Destroyed, no more targets in range of FAC(A)", 15)
				nineline = {["text"] = "No targets in range of JTAC"}
			end
		end
	end
end

function deathHandler:onEvent(event)
  utils.protectedCall(onDeathEvent,event)
end


local function main(afacName, code, freq) -- runs once after delay
		foundUnitsRed = {}
		local volS = {
			id = world.VolumeType.SPHERE,
			params = {
				 point = Unit.getByName(afacName):getPoint(),
				 radius = 15000
			 }
		 }
		world.searchObjects(Object.Category.UNIT, volS, ifFoundU)
		world.searchObjects(Object.Category.STATIC, volS, ifFoundU)
		targetUnit = foundUnitsRed[math.random(1, #foundUnitsRed)]
end

function afac.startAFAC(afacName, code, freq)
	jtacName = afacName
	local volS = {
		id = world.VolumeType.SPHERE,
		params = {
	     point = Unit.getByName(afacName):getPoint(),
	     radius = 15000
	   }
	 }
	world.searchObjects(Object.Category.UNIT, volS, ifFoundU)
	world.searchObjects(Object.Category.STATIC, volS, ifFoundU)
	world.addEventHandler(deathHandler)
	missionCommands.addCommandForCoalition(2, "Request Tasking - "..jtacName, nil, generateTasking, {afacName, code})
	main(afacName, code, freq)
end

return afac
