local tasking = {}
local utils = require 'DCS-Scripts.utils.utils'

function tasking.nearestGpFromCoalition(gpName, coa, cat)
	local gp = Group.getByName(gpName)
	local lowest = nil
	local dist
	local current = nil
	for _, coaGp in pairs(coalition.getGroups(coa, cat)) do
		if #coalition.getGroups(coa) > 0 then
			dist = utils.getDistance(gp:getUnit(1):getPoint(), coaGp:getUnit(1):getPoint())
			if  lowest == nil then
				lowest = dist
				current = coaGp:getName()
			elseif dist < lowest then
				lowest = dist
				current = coaGp:getName()
			end
		else
			env.info("No groups returned")
			return current
		end
	end
	env.info("Nearest Group: "..current)
	return current
end

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
	local esctName = tasking.nearestGpFromCoalition(gpName, coa, cat)
	tasking.newTaskFollowGp(esctName, gpName)
end

return tasking
