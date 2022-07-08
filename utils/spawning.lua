local utils = require 'DCS-Scripts.utils.utils'

local spawning = {}

spawning.spawnedGps = {}

-- fcn: spawnSTM:
--	takes a stm file location "stmLink" and spawns relevant group
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

-- fcn: isSTMspawn
-- takes a group (gp) and checks if it has been spawned via script
function spawning.isSTMspawn(gp)
	for _, spnd in paris(spawning.spawnedGps) do
		if spnd:getName() == gp:getName() then
			return true
		end
	end
	return nil
end

-- fcn: gpRouteSTM
-- takes a group and if it is a spawned group then returns the route table
function spawning.gpRouteSTM(gp)
	for _, spnd in paris(spawning.spawnedGps) do
		if spnd:getName() == gp:getName() then
			return spnd.route
		end
	end
	return nil
end

-- fnc: gpTaskSTM
-- takes a group and if it is a spawned group then returns the task table
function spawning.gpTaskSTM(gp)
	for _, spnd in paris(spawning.spawnedGps) do
		if spnd:getName() == gp:getName() then
			return spnd.task
		end
	end
	return nil
end

-- fcn: untPayloadSTM
-- takes a unit and if it is from a spawned group then ir returns the original
-- payload
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

-- fcn: gpInfoSTM
-- takes a group and if it is a spawned group then returns the spawned STM table
function spawning.gpInfoSTM(gp)
	for _, spnd in paris(spawning.spawnedGps) do
		if spnd:getName() == gp:getName() then
			return spnd
		end
	end
	return nil
end

-- fnc teleportGp
-- takes a groupName and vec 2 location and respawns it at location
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
