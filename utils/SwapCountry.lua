local utils = require 'DCS-Scripts.utils.utils'

local foundUnits = {}
local SwapCountry = {}

--[[
	fcn: isUntInZone
	parameters:
		gpName - name of group to check
		zone - zone to check presence in
]]--
function SwapCountry.isUntInZone(gpName, zone)
	local gp = Group.getByName(gpName)
	local gpPoint = {
		x = gp:getPoint().x,
		y = gp:getPoint().z,
	}
	return utils.pointInZone(gpPoint, zone)
end

--[[
	fcn: swapGp
	parameters:
		gpName - Name of group to swap country
		endCountry - country to swap to
]]--
function SwapCountry.swapGp(gpName, endCountry)
	Group.getByName(gpName)
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

--[[
	fcn: swapGpCountry
	parameters:
		startCountry - country to swap all groups from
		endCountry - country to swap all groups to
]]--
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

--[[
	fcn: swapTypeCoa
	parameters:
		coaStart - coalition from which to swap groups of type from
		coaEnd - coalition to which groups will be swapped
		type - group type to swap
]]--
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

--[[
	fcn: swapInRangeOfUnit
	parameters:
		unit - unit in range of which to swap neutral groups
		range - range in which to swap units
		ctgry - category of groups to swap
	]]--
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

--[[
	fcn: swapGps
	paramters:
		gpArray - Array of group names to swap
		cntry - country to swap to 
--]]
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
