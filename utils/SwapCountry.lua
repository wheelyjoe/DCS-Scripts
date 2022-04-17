local utils = require 'DCS-Scripts.utils.utils'

local foundUnits = {}
local SwapCountry = {}

function SwapCountry.isUntInZone(gp, zone)
	local gpPoint = {
		x = gp:getPoint().x,
		y = gp:getPoint().z,
	}

	return utils.pointInZone(gpPoint, zone)
end

function SwapCountry.swapGp(gp, endCountry)
	local remUnt = 1
	if not gp or #gp:getUnits() == 0 then
		return
	end
	if gp:getUnit(1):getCountry() == country.id[endCountry] then
		return
	end
	local gpTable = utils.gpInfoMiz(gp)
	gpTable.units = {}
	if gpTable ~= nil then
		for i, unt in pairs(gp:getUnits()) do
			if unt:isExist() == true and unt:isActive() == true and unt:getLife() >= 2 then
				env.info("Unt alive: "..unt:getName()..", with health: "..unt:getLife())
				gpTable.units[remUnt].alt = unt:getPoint().y
				gpTable.units[remUnt].speed = utils.getMag(gp:getUnit(i):getVelocity())
				gpTable.units[remUnt].x = unt:getPoint().x
				gpTable.units[remUnt].y = unt:getPoint().z
				gpTable.units[remUnt].heading = utils.getHeading(unt)
			else
				env.info("Unt "..unt:getName().." is dead")
				--gpTable.units[i] = nil
			end
		end
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

function SwapCountry.swapTypeCoa(coaStart, coaEnd, type)
	local toSwap = {}
	for _, gp in pairs(coalition.getGroups(coaStart)) do
		if type ~= nil then
			if gp:getType() == type then
				if coaEnd == 1 then
					swapCountry.swapGp(gp, "CJTF_RED")
				elseif coaEnd == 2 then
					swapCountry.swapGp(gp, "CJTF_BLUE")
				end
			end
		else
			if coaEnd == 1 then
				swapCountry.swapGp(gp, "CJTF_RED")
			elseif coaEnd == 2 then
				swapCountry.swapGp(gp, "CJTF_BLUE")
			end
		end
	end
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
	for _, found in pairs(foundUnits) do
		foundUnit = Unit.getByName(found)
		if ctgry~=nil then
			if foundUnit:getGroup():getCategory() == ctgry then
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
		else
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
	end
end

function SwapCountry.swapGps(gpArray, cntry)
	for _, gpName in pairs(gpArray) do
		gp = Group.getByName(gpName)
		SwapCountry.swapGp(gp, cntry)
	end
end

return SwapCountry
