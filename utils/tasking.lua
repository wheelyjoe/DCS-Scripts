local tasking = {}
local utils = require 'DCS-Scripts.utils.utils'
local SwapCountry = require 'DCS-Scripts.utils.SwapCountry'
local afac = require "DCS-Scripts.utils.faca"
local iads = require "DCS-Scripts.utils.IADS"

--[[
	fcn: changeTaskForGp
	Paramters:
		gpName - Name of an AI group to assign a task
		newTask - The task table
--]]
function tasking.changeTaskForGp(gpName, newTask)
	local gp = Group.getByName(gpName)
	local gpCtrlr = gp:getController()
	gpCtrlr:pushTask(newTask)
end

--[[
	fcn: netTaskAttackGp
	parameters:
		atkName - group to be assigned to attacking
		tgtName - group to be attacked
--]]
function tasking.newTaskAttackGp(atkName, tgtName)
	local tgtGp = Group.getByName(tgtName)
	local taskTable = {

		id = 'AttackGroup',
		params = {
			groupId = tgtGp:getID(),
		}
	}
	tasking.changeTaskForGp(atkName, taskTable)
end

--[[
	fcn: newTaskEscortGp
	parameters:
		esctName - groupName of group to conduct escort
		tgtName - groupName of group to be escorted
--]]
function tasking.newTaskEscortGp(esctName, tgtName)
	local tgtGp = Group.getByName(tgtName)
	local taskTable = {
		id = 'Escort',
		params = {
			groupId = tgtGp:getID(),
			pos = {x = 200, y = 0, z = -100},
			engagementDistMax = 15000,
			targetTypes = {}
		}
	}
	tasking.changeTaskForGp(esctName, taskTable)
end

--[[
	fcn: newTaskFollowGp
	parameters:
		followName - name of group to recieve new tasking
		tgtName - name of group to be followed
]]--
function tasking.newTaskFollowGp(followName, tgtName)
	local tgtGp = Group.getByName(tgtName)
	local taskTable = {
		id = 'Escort',
		params = {
			groupId = tgtGp:getID(),
			pos = {x = 200, y = 0, z = -100},
			lastWptIndexFlag = false,
		}
	}
	tasking.changeTaskForGp(followName, taskTable)
end

--[[
	fcn: nearestGpFromCoaFollow
	parameters:
		gpName - name of group to recieve tasking
		coa - name of coa to be followed
		cat - category of group to be followed
]]--
function tasking.nearestGpFromCoaFollow(gpName, coa, cat)
	local esctName = utils.nearestGpFromCoalition(gpName, coa, cat)
	tasking.newTaskFollowGp(esctName, gpName)
end

--[[
	fcn: noFlyZonePlyr
	parameters:
		gpName - group to recieve tasking
		coaDef - the coalition defending the no fly zone
		coaOut - the coalition unallowed to encroach the NFZ
		zone - the zone to be policed
	action:
		upon a player from coaOut encroaching zone, the neutral aircraft given tasking
		will switch to the coaDef side
]]--
function tasking.noFlyZonePlyr(gpName, coaDef, coaOut, zone)
	for _, plyr in pairs(coalition.getPlayers(coaOut)) do
		if utils.point_inside_poly(plyr:getPoint().x, plyr:getPoint().z, zone) then
			for _, gpName in pairs(enfGroup) do
				if coaDef == 1 then
					SwapCountry.swapGp(Group.getByName(gpName), "CJTF_RED")
				else
					SwapCountry.swapGp(Group.getByName(gpName), "CJTF_BLUE")
				end
			end
		end
	end
end

function tasking.noFlyZonePlyrDetec(cntryDef, coaOut, zone) --TODO: Check this works
	for _, plyr in pairs(coalition.getPlayers(coaOut)) do
		if utils.point_inside_poly(plyr:getPoint().x, plyr:getPoint().z, zone) and
			iads.playerDetected(plyr:getName()) then
			if coaDef == 1 then
				swapSides.swapGpCountry(cntryDef, "CJTF_RED")
			else
				swapSides.swapGpCountry(cntryDef, "CJTF_BLUE")
			end
		end
	end
end

--[[
	fcn: noFlyZone
	parameters:
		gpName - group to recieve tasking
		coaDef - the coalition defending the no fly zone
		coaOut - the coalition unallowed to encroach the NFZ
		zone - the zone to be policed
	action:
		upon a group from coaOut encroaching zone, the neutral aircraft given tasking
		will switch to the coaDef side
]]--
function tasking.noFlyZone(gpName, coaDef, coaOut, zone)
	for _, gp in pairs(coalition.getGroups(coaOut,Group.Category.AIRPLANE)) do
		for _, unt in pairs(gp:getUnits()) do
			if utils.point_inside_poly(unt:getPoint().x, unt:getPoint().z, zone) then
				for _, gpName in pairs(enfGroup) do
					if coaDef == 1 then
						SwapCountry.swapGp(Group.getByName(gpName), "CJTF_RED")
					else
						SwapCountry.swapGp(Group.getByName(gpName), "CJTF_BLUE")
					end
				end
			end
		end
	end
	for _, gp in pairs(coalition.getGroups(coaOut,Group.Category.HELICOPTER)) do
		for _, unt in pairs(gp:getUnits()) do
			if utils.point_inside_poly(unt:getPoint().x, unt:getPoint().z, zone) then
				for _, gpName in pairs(enfGroup) do
					if coaDef == 1 then
						SwapCountry.swapGp(Group.getByName(gpName), "CJTF_RED")
					else
						SwapCountry.swapGp(Group.getByName(gpName), "CJTF_BLUE")
					end
				end
			end
		end
	end
end

--[[
	fcn: noFlyZoneV2
	parameters:
		gpNames -array of group names to recieve tasking
		coaDef - the coalition defending the no fly zone
		coaOut - the coalition unallowed to encroach the NFZ
		zone - the zone to be policed
	action:
		upon a group from coaOut encroaching zone, the neutral aircraft given tasking
		will switch to the coaDef side
]]--
function tasking.noFlyZoneV2(gpNames, coaDef, coaOut, zone)
	local trespGps = utils.coaGpsInZone(coaOut, zone, Group.Category.AIRPLANE)
	trigger.action.outText("There are: "..#trespGps.." hostile gps in the NFZ", 5)
	if  #trespGps<1 then
		trigger.action.outText("No hostiles in NFZ", 5)
		SwapCountry.swapGps(enfGroup, "UN_PEACEKEEPERS")
	else
		trigger.action.outText("Hostiles in NFZ", 5)
		if coaDef == 1 then
			SwapCountry.swapGps(enfGroup, "CJTF_RED")
		else
			SwapCountry.swapGps(enfGroup, "CJTF_BLUE")
		end
	end
end

--[[
	fcn: startFACTask
	parameters:
		gpName - group to start acting as FAC
		freq - freq for radio calls
]]--
function tasking.startFACTask(gpName, freq)
	taskTable = {
	  id = 'FAC',
	  params = {
	    frequency = freq,
	    modulation = 0,
	    callname = math.random(1,8),
	    number = math.random(1,9)
	  }
	}
	tasking.changeTaskForGp(gpName, taskTable)
end

--[[
	fcn: newTaskOrbitPt
	parameters:
		gpName - group name to recieve tasking
		alt - altitude to orbit at (m)
		pt - vec2 pos to orbit
	get a gp (by name) to orbit a pt at an alt
]]--
function tasking.newTaskOrbitPt(gpName, alt, pt)
	--TODO: Work out distance from gp to pt and speed, use SDT to work out ETA. Schedule search for then
	taskTable = {
		id = 'Orbit',
		params = {
	  	pattern = "Circle",
	  	point = pt,
	  	altitude = alt
	 	}
	}
	tasking.changeTaskForGp(gpName, taskTable)
end

--[[
	fcn: FACA
	parameters:
		gpName - name of group to become FAC(A)
		location - locaiton to orbit (vec2)
		alt - altitude to orbit at
		code - laser code
		freq - radio freq to operate on
]]--
function tasking.FACA(gpName, location, alt, code, freq)
	local gp = Group.getByName(gpName)
	local unt = gp:getUnit(1)
	tasking.newTaskOrbitPt(gpName, alt, {x= location.x, y = location.z})
	afac.startAFAC(unt:getName(),code, freq)
end

return tasking
