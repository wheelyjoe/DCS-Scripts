local utils = require 'DCS-Scripts.utils.utils'

local foundUnits = {}
local SwapCountry = {}

-- fcn: isUntInZone
-- takes a gp and a zone and returns whether gp is in zone
function SwapCountry.isUntInZone(gp, zone)
	local gpPoint = {
		x = gp:getPoint().x,
		y = gp:getPoint().z,
	}
	return utils.pointInZone(gpPoint, zone)
end

-- fnc: swapGp
-- takes a gp and country and respanws group in same location as new country
function SwapCountry.swapGp(gp, endCountry)
	local category = gp:getCategory()
	if not gp or #gp:getUnits() == 0 then
		return
	end
	if gp:getUnit(1):getCountry() == country.id[endCountry] then
		return
	end
	local gpTable = utils.gpToTableV2(gp)
	if gpTable ~= nil then
		gp:destroy()
		coalition.addGroup(country.id[endCountry], category, gpTable)
	end
end

-- fcn: swapGpCountry
-- takes two countries and respawns all units from first to second country
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

-- fcn: swapTypeCoa
-- swap all groups of type from coaStart to coaEnd
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

-- fcn: swapInRangeOfUnit
-- swap all groups of opposite or neutral side of a category in range of unit
-- to hostile side
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

-- fcn: swapGps
-- swap array of groups country to given country
function SwapCountry.swapGps(gpArray, cntry)
	for _, gpName in pairs(gpArray) do
		gp = Group.getByName(gpName)
		if gp then
			SwapCountry.swapGp(gp, cntry)
		else
			env.info("Gp: "..gpName.." not found")
		end
	end
end

return SwapCountry
