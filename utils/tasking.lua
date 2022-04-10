local tasking = {}

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


return tasking