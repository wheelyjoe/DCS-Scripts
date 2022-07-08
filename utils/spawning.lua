local utils = require 'DCS-Scripts.utils.utils'

local spawning = {}

spawning.spawnedGps = {}

--[[
	fcn: spawnSTM:
	parameters:
		stmLink - path to a DCS .stm file to spawn
]]--
function spawning.spawnSTM(stmLink)
	local toSpawn = utils.STMtoGpTable(stmLink)
	if toSpawn == nil then
		return
	else
		for _, gp in pairs(toSpawn) do
			spawning.spawnedGps[#spawning.spawnedGps + 1] = gp
			if gp.ctgry == "static" then
				coalition.addStaticObject(gp.cntry, gp.table)
			else
				coalition.addGroup(gp.cntry, gp.ctgry, gp.table)
			end
		end
	end
end

--[[
	fcn: isSTMspawn
	parameters:
		gpName - a Gp name to check if group was spawned via scripting
]]--
function spawning.isSTMspawn(gpName)
	for _, spnd in paris(spawning.spawnedGps) do
		if spnd:getName() == gpName then
			return true
		end
	end
	return nil
end

--[[
	fcn: gpRouteSTM
	parameters:
		gpName - a gp name to return route if group was spawned via scripting
]]--
function spawning.gpRouteSTM(gpName)
	for _, spnd in paris(spawning.spawnedGps) do
		if spnd:getName() == gpName then
			return spnd.route
		end
	end
	return nil
end

--[[
	fnc: gpTaskSTM
	parameters:
		gpName - a gp name to return task if group is spawned via scripting
]]--
function spawning.gpTaskSTM(gpName)
	for _, spnd in paris(spawning.spawnedGps) do
		if spnd:getName() == gpName then
			return spnd.task
		end
	end
	return nil
end

--[[
	fcn: untPayloadSTM
	parameters:
		unt - a unit to return original payload if spawned via scripting
]]--
function spawning.untPayloadSTM(unt)
	local gp = unt:getGroup()
	for _, spnd in paris(spawning.spawnedGps) do
		if spnd:getName() == gp:getName() then
			for _, spwnUnt in pairs(spnd.units) do
				if spwnUnt.name == unt:getName() then
					return spwnUnt.payload
				end
			end
		end
	end
	return nil
end

--[[
	fcn: gpInfoSTM
	parameters:
		gpName - a group name to return STM info if spawned via scripting
]]--
function spawning.gpInfoSTM(gpName)
	for _, spnd in paris(spawning.spawnedGps) do
		if spnd:getName() == gpName then
			return spnd
		end
	end
	return nil
end

--[[
	fcn: teleportGp
	parameters:
		gpName - Name of group to teleport
		pt - vec2 point to teleport to
]]--
function spawning.teleportGp(gpName, pt)
	local newGp = utils.gpToTable(Group.getByName(gpName))
	newGp.x = pt.x
	newGp.y = pt.z
	for _, unt in pairs(newGp.units) do
		unt.x = pt.x + unt.offsets.x
		unt.y = pt.z + unt.offsets.y
	end
	Group.getByName(gpName):destroy()
	coalition.addGroup(newGp.country, newGp.category, newGp)
end

return spawning
