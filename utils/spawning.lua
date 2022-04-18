local utils = require 'DCS-Scripts.utils.utils'

local spawning = {}

spawning.spawnedGps = {}

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

function spawning.isSTMspawn(gp)
	for _, spnd in paris(spawning.spawnedGps) do
		if spnd:getName() == gp:getName() then
			return true
		end
	end
	return nil
end

function spawning.gpRouteSTM(gp)
	for _, spnd in paris(spawning.spawnedGps) do
		if spnd:getName() == gp:getName() then
			return spnd.route
		end
	end
	return nil
end

function spawning.gpTaskSTM(gp)
	for _, spnd in paris(spawning.spawnedGps) do
		if spnd:getName() == gp:getName() then
			return spnd.task
		end
	end
	return nil
end

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

function spawning.gpInfoSTM(gp)
	for _, spnd in paris(spawning.spawnedGps) do
		if spnd:getName() == gp:getName() then
			return spnd
		end
	end
	return nil
end

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
