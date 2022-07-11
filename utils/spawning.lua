local utils = require 'DCS-Scripts.utils.utils'

local spawning = {}



spawning.spawnedGps = {}
spawning.unspawnedGps = {}

--[[
	fcn: loadSTMs
	parameters:
		stmFileLink - Link to a folder containing STMs
	loads all STMs in linked folder into table "unspawnedGps"
]]--
function spawning.loadSTMs(stmFileLink)
	local path = system.pathForFile( nil, stmFileLink )
	for file in lfs.dir( path ) do
			if file:lower:match "%.stm$" then
				dofile(file)
				for _, coa in pairs(staticTemplate.coalition) do
					for _, country in pairs(coa.country) do
						if country.vehicle ~= nil then
							for _, vehGp in pairs(country.vehicle.group) do
								unspawnedGps[#unspawnedGps+1] = {table = vehGp, cntry = country.id, ctgry = Group.Category.GROUND}
							end
						end
						if country.helicopter ~= nil then
							for _, heliGp in pairs(country.helicopter.group) do
								unspawnedGps[#unspawnedGps+1] = {table = heliGp, cntry = country.id, ctgry = Group.Category.HELICOPTER}
							end
						end
						if country.plane ~= nil then
							for _, planeGp in pairs(country.plane.group) do
								unspawnedGps[#unspawnedGps+1] = {table = planeGp, cntry = country.id, ctgry = Group.Category.AIRPLANE}
							end
						end
						if country.ship ~= nil then
							for _, shipGp in pairs(country.ship.group) do
								unspawnedGps[#unspawnedGps+1] = {table = shipGp, cntry = country.id, ctgry = Group.Category.SHIP}
							end
						end
						if country.static ~= nil then
							for _, staticGp in pairs(country.static.group) do
								for _, unt in pairs(staticGp.units) do
									unspawnedGps[#unspawnedGps+1] = {table = unt, cntry = country.id, ctgry = "static"}
								end
							end
						end
					end
				end
     end
	end
end

function spawning.spawnSTMtable(stmName)
	for pairs _, gpData in pairs(spawning.unspawnedGps) do
		if gpData:getName() == stmName then
			spawning.spawnedGps[#spawning.spawnedGps + 1] = gpData
			gpData = nil
	end
end

function spawning.unspawnSTMtable(stmName)
	for pairs _, gpData in pairs(spawning.unspawnedGps) do
		if gpData:getName() == stmName then
			spawning.unspawnedGps[#spawning.unspawnedGps + 1] = gpData
			gpData = nil
	end
	group:getByName(stmName):delete()
end

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
