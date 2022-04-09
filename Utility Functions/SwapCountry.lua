toSwap = {}
local foundUnits = {}
local inside = false
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

local TRNC_all = {{00053152, -00293470}, {00017400, -00287523}, {00029323, -00228633}, {00080672, -00112222}, {00029749, -00228633}, {00006260, -00223009}, {00011106,-00167628}}


local function protectedCall(...)
  local status, retval = pcall(...)
  if not status then
    env.warning("Splash damage script error... gracefully caught! " .. retval, true)
  end
end

local function vecMag(vec)
	return (vec.x^2 + vec.y^2 + vec.z^2)^0.5
end

function point_inside_poly(x,y,poly)
	-- poly is like { {x1,y1},{x2,y2} .. {xn,yn}}
	-- x,y is the point
	local inside = false
	local p1x = poly[1][1]
	local p1y = poly[1][2]

	for i=0,#poly do
		
		local p2x = poly[((i)%#poly)+1][1]
		local p2y = poly[((i)%#poly)+1][2]
		
		if y > math.min(p1y,p2y) then
			if y <= math.max(p1y,p2y) then
				if x <= math.max(p1x,p2x) then
					if p1y ~= p2y then
						xinters = (y-p1y)*(p2x-p1x)/(p2y-p1y)+p1x
					end
					if p1x == p2x or x <= xinters then
						inside = not inside
					end
				end
			end
		end
		p1x,p1y = p2x,p2y	
	end
	return inside
end

local function pointInZone(pnt, zone)
	xP = pnt.x
	zP = pnt.y
	x1 = zone.p1.x
	z1 = zone.p1.z
	x2 = zone.p2.x
	z2 = zone.p2.z
	x3 = zone.p3.x
	z3 = zone.p3.z
	x4 = zone.p4.x
	z4 = zone.p4.z
	--return pointInPolygon(xP,zP,x1,z1,x2,z2,x3,z3,x4,z4)
	return point_inside_poly(xP,zP, TRNC_all)
	
end

local function isUntInZone(gp, zone)
	local gpPoint = {
		x = gp:getPoint().x,
		y = gp:getPoint().z,
	}
	
	return pointInZone(gpPoint, zone)	
end

local function gpInfoMiz(gp)
	local gpName = gp:getName()
	local coa = gp:getCoalition()
	for _, county in pairs(env.mission.coalition.neutrals.country) do
		for _, gpType in pairs(county) do
			for _, vehGp in pairs(county.vehicle.group) do
				if vehGp.name == gpName then
					env.info("found "..gpName.." in miz")
					gpInfo = vehGp
					return gpInfo					
				end
			end
			for _, planeGp in pairs(county.plane.group) do
				if planeGp.name == gpName then
					env.info("found "..gpName.." in miz")
					gpInfo = planeGp
					return gpInfo					
				end
			end
		end
	end
end

local function swapGp(gp, endCountry)
	local gpTable = gpInfoMiz(gp)
	if gpTable ~= nil then
		gp:destroy()
		coalition.addGroup(country.id[endCountry], gp:getCategory(), gpTable)
	end
end

local function swapGpCountry(startCountry, endCountry)	
	for _, coa in pairs(coalition.side) do
		for _, gp in pairs(coalition.getGroups(coa)) do		
			if gp:getUnit(1):getCountry() == country.id[startCountry] then	
				toSwap[#toSwap+1] = gp
				env.info("swapping gp ".. gp:getName())
			end
		end
	end	
	for _, gp in pairs(toSwap) do	
		swapGp(gp, endCountry)	
	end
end

local ifFound = function(foundItem, val)
	foundUnits[#foundUnits+1] = foundItem:getName()
	return true
end

local function swapInRangeOfUnit(untName, range, ctgry)
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
							swapGp(foundUnit:getGroup(), "CJTF_BLUE")
						elseif unt:getCoalition() == 2 then
							swapGp(foundUnit:getGroup(), "CJTF_RED")
						end		
					end
				end	
			end				
		elseif foundUnit:getCoalition() == 0 then
			if foundUnit:getCoalition() ~= unt:getCoalition() then		
				if unt:getCoalition() == 1 then
					swapGp(foundUnit:getGroup(), "CJTF_BLUE")
				elseif unt:getCoalition() == 2 then
					swapGp(foundUnit:getGroup(), "CJTF_RED")
				end		
			end
		end
	end	
end

local function changeTaskForGp(gpName, newTask)

	local gp = Group.getByName(gpName)
	local gpCtrlr = gp:getController()
	gpCtrlr:pushTask(newTask)

end

local function newTaskAttackGp(atkName, tgtName)
	local tgtGp = Group.getByName(tgtName)
	local taskTable = {
	
		id = 'AttackGroup', 
		params = {		
			groupId = tgtGp:getID(),		
		}	
	}
	changeTaskForGp(atkName, taskTable)
end

local function trackPlanes()
	for _, gp in pairs(coalition.getGroups(2, Group.Category.AIRPLANE)) do
		env.info("Plane gp ".. gp:getName())
		for _, unt in pairs(gp:getUnits()) do
			if isUntInZone(unt, Zone_TRNC_1) then		
				env.info("blue plane in zone is "..unt:getName())
				swapInRangeOfUnit(unt:getName(), 5000)
				swapInRangeOfUnit(unt:getName(), 20000, Unit.Category.AIRPLANE)
			elseif isUntInZone(unt, Zone_TRNC_2) then
				swapInRangeOfUnit(unt:getName(), 5000)
				swapInRangeOfUnit(unt:getName(), 20000, Unit.Category.AIRPLANE)
				env.info("blue plane in zone is "..unt:getName())
			end
		end
	end
end

timer.scheduleFunction(function() 
  protectedCall(trackPlanes)
  return timer.getTime() + 1
end, 
{}, 
timer.getTime() + 1
)

--swapGpCountry("TURKEY","CJTF_RED")