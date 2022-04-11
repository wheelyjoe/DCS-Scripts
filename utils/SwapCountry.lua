package.path = package.path..";"..lfs.writedir().."/Scripts/?.lua"

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
	for _, found in pairs(foundUnits) do
		foundUnit = Unit.getByName(found)
		if ctgry ~= nil then
			if foundUnit:getGroup():getCategory() == ctgry then
				env.info("category: "..ctgry)
				env.info("foundUnit category is: "..foundUnit:getGroup():getCategory())
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
