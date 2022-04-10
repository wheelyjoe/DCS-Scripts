package.path = package.path..";"..lfs.writedir().."/Scripts/?.lua"

local utils = require 'DCS-Scripts.utils.utils'

local foundUnits = {}
local Zone_TRNC_1 = {
	p1 = {x = 00053152, z = -00293470},
	p2 = {x = 00017400, z = -00287523},
	p3 = {x = 00029323, z = -00228633},
	p4 = {x = 00080672, z = -00112222},
}
local Zone_TRNC_2 = {
	p1 = {x = 00080672, y = -00112222},
	p2 = {x = 00029749, y = -00228633},
	p3 = {x = 00006260, y = -00223009},
	p4 = {x = 00011106, y = -00167628},
}

local SwapCountry = {}

function SwapCountry.isUntInZone(gp, zone)
	local gpPoint = {
		x = gp:getPoint().x,
		y = gp:getPoint().z,
	}
	
	return utils.pointInZone(gpPoint, zone)	
end



function SwapCountry.swapGp(gp, endCountry)
	local gpTable = utils.gpInfoMiz(gp)
	if gpTable ~= nil then
		gp:destroy()
		coalition.addGroup(country.id[endCountry], gp:getCategory(), gpTable)
	end
end

function SwapCountry.swapGpCountry(startCountry, endCountry)	
	local toSwap = {}
	for _, coa in pairs(coalition.side) do
		for _, gp in pairs(coalition.getGroups(coa)) do		
			if gp:getUnit(1):getCountry() == country.id[startCountry] then	
				toSwap[#toSwap+1] = gp
				env.info("swapping gp ".. gp:getName())
			end
		end
	end	
	for _, gp in pairs(toSwap) do	
		SwapCountry.swapGp(gp, endCountry)	
	end
end

local ifFound = function(foundItem, val)
	foundUnits[#foundUnits+1] = foundItem:getName()
	return true
end

function SwapCountry.swapInRangeOfUnit(untName, range, ctgry)
	unt = Unit.getByName(untName)
	local untPt = unt:getPoint()
	foundUnits = {}
	local volS = {	
		id = world.VolumeType.SPHERE,
		params = {		
			point = untPt,
			radius = range		
		}	
	}
	world.searchObjects(Object.Category.UNIT, volS, ifFound)
	env.info("Found "..#foundUnits.." units in range")
	for _, found in pairs(foundUnits) do
		foundUnit = Unit.getByName(found)
		if ctgry ~= nil then
			if foundUnit:getCategory() == ctgry then
				if foundUnit:getCoalition() == 0 then
					if foundUnit:getCoalition() ~= unt:getCoalition() then		
						if unt:getCoalition() == 1 then
							SwapCountry.swapGp(foundUnit:getGroup(), "CJTF_BLUE")
						elseif unt:getCoalition() == 2 then
							SwapCountry.swapGp(foundUnit:getGroup(), "CJTF_RED")
						end		
					end
				end	
			end				
		elseif foundUnit:getCoalition() == 0 then
			if foundUnit:getCoalition() ~= unt:getCoalition() then		
				if unt:getCoalition() == 1 then
					SwapCountry.swapGp(foundUnit:getGroup(), "CJTF_BLUE")
				elseif unt:getCoalition() == 2 then
					SwapCountry.swapGp(foundUnit:getGroup(), "CJTF_RED")
				end		
			end
		end
	end	
end

function SwapCountry.changeTaskForGp(gpName, newTask)

	local gp = Group.getByName(gpName)
	local gpCtrlr = gp:getController()
	gpCtrlr:pushTask(newTask)

end

function SwapCountry.newTaskAttackGp(atkName, tgtName)
	local tgtGp = Group.getByName(tgtName)
	local taskTable = {
	
		id = 'AttackGroup', 
		params = {		
			groupId = tgtGp:getID(),		
		}	
	}
	SwapCountry.changeTaskForGp(atkName, taskTable)
end


return SwapCountry

