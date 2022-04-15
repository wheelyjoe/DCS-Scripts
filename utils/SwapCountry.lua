package.path = package.path..";"..lfs.writedir().."/Scripts/?.lua"

local utils = 'DCS-Scripts.utils.utils'

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
	if not gp then
		return
	end
	if gp:getUnit(1):getCountry() == country.id[endCountry] then
		return
	end
	local gpTable = utils.gpInfoMiz(gp)
	if gpTable ~= nil then
		for i, unt in pairs(gp:getUnits()) do
			gpTable.units[i].alt = gp:getUnit(i):getPoint().y
			gpTable.units[i].speed = utils.getMag(gp:getUnit(i):getVelocity())
			gpTable.units[i].x = gp:getUnit(i):getPoint().x
			gpTable.units[i].y = gp:getUnit(i):getPoint().z
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
		env.info("found units")
		env.info("category: "..ctgry)
		if ctgry~=nil then
			env.info("foundUnit category is: "..foundUnit:getGroup():getCategory())
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
			env.info("in here")
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

return SwapCountry
