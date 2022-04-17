local tasking = {}
local utils = require 'DCS-Scripts.utils.utils'
local SwapCountry = require 'DCS-Scripts.utils.SwapCountry'
local afac = require "DCS-Scripts.utils.faca"

function tasking.changeTaskForGp(gpName, newTask)
	local gp = Group.getByName(gpName)
	local gpCtrlr = gp:getController()
	gpCtrlr:pushTask(newTask)
end

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

function tasking.nearestGpFromCoaFollow(gpName, coa, cat)
	local esctName = utils.nearestGpFromCoalition(gpName, coa, cat)
	tasking.newTaskFollowGp(esctName, gpName)
end

function tasking.noFlyZonePlyr(enfGroup, coaDef, coaOut, zone)
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

function tasking.noFlyZone(enfGroup, coaDef, coaOut, zone)
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

function tasking.noFlyZoneV2(enfGroup, coaDef, coaOut, zone)
	if utils.coaGpsInZone(coaOut, zone, Group.Category.AIRPLANE) or
		utils.coaGpsInZone(coaOut, zone, Group.Category.HELICOPTER) then
		for _, gpName in pairs(enfGroup) do
			if coaDef == 1 then
				SwapCountry.swapGp(Group.getByName(gpName), "CJTF_RED")
			else
				SwapCountry.swapGp(Group.getByName(gpName), "CJTF_BLUE")
			end
		end
	else
		env.info("No hostiles in NFZ") --TODO: chcek this
		for _, gpName in pairs(enfGroup) do
			if gp:getCoalition() ~= 0 then
				SwapCountry.swapGp(Group.getByName(gpName), "UN_PEACEKEEPERS")
			end
		end
	end
end

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

function tasking.FACA(gpName, location, code, freq)
	local gp = Group.getByName(gpName)
	local unt = gp:getUnit(1)
	tasking.newTaskOrbitPt(gpName, 5000, {x= location.x, y = location.z})
	afac.startAFAC(unt:getName(),code, freq)
end

return tasking
