local utils = require 'DCS-Scripts.utils.utils'

local spawning = {}

function spawning.spawnSTM(stmLink)
	local toSpawn = utils.STMtoGpTable(stmLink)
	if toSpawn == nil then
		return
	else
		for _, gp in pairs(toSpawn) do
			if gp.ctgry == "static" then
				coalition.addStaticObject(gp.cntry, gp.table)
			else
				coalition.addGroup(gp.cntry, gp.ctgry, gp.table)
			end
		end
	end
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
	--TODO: Stop spawning in wrong place
end

return spawning
