local utils = {}
local foundUnits =  {}
local ifFound = function(foundItem, val)
	foundUnits[#foundUnits+1] = foundItem:getName()
	return true
end

local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function utils.protectedCall(...)
  local status, retval = pcall(...)
  if not status then
    env.warning("test script error caught " .. retval, true)
  end
end

function utils.getMag(vector)
  return math.sqrt(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z)
end

function utils.getDistance(pt1, pt2)
  local dx = pt1.x - pt2.x
  local dz = pt1.z - pt2.z
  return math.sqrt(dx*dx + dz*dz)
end

function utils.gpInfoMiz(gp)
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

function utils.STMtoGpTable(stmLink)
	local gps = {}
	if file_exists(stmLink) then
		dofile(stmLink)
		for _, coa in pairs(staticTemplate.coalition) do
			for _, country in pairs(coa.country) do
				if country.vehicle ~= nil then
					env.info("There's a vehicle gp in "..country.name)
					for _, vehGp in pairs(country.vehicle.group) do
						gps[#gps+1] = {table = vehGp, cntry = country.id, ctgry = Group.Category.GROUND}
					end
				end
				if country.helicopter ~= nil then
					for _, heliGp in pairs(country.helicopter.group) do
						gps[#gps+1] = {table = heliGp, cntry = country.id, ctgry = Group.Category.HELICOPTER}
					end
				end
				if country.plane ~= nil then
					for _, planeGp in pairs(country.plane.group) do
						gps[#gps+1] = {table = planeGp, cntry = country.id, ctgry = Group.Category.AIRPLANE}
					end
				end
			end
		end
		return gps
	else
		env.info("file doesn't exist")
	end
end

function utils.spawnSTM(stmLink)
	local toSpawn = utils.STMtoGpTable(stmLink)
	for _, gp in pairs(toSpawn) do
		coalition.addGroup(gp.cntry, gp.ctgry, gp.table)
	end
end

function utils.point_inside_poly(x,y,poly)
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

function utils.detected_in_poly(unitName, poly)

  --TODO: This function
end

function utils.nearestHostileInRange(untName, range, type)
  foundUnit= {}
	local nearest
	local distance
  local unt = Unit.getByName(untName)
  local untPt = unt:GetPoint()
  local volS = {
    id = world.VolumeType.SPHERE,
    params = {
      point = untPt,
      radius = range
    	}
  	}
  world.searchObjects(Object.Category.UNIT, volS, ifFound)
	for _, foundUnt in pairs(foundUnits) do
		if (unt:getCoalition() == 1 and Unit.getByName(foundUnt):getCoalition() == 2)	or (unt:getCoalition() == 2 and Unit.getByName(foundUnt):getCoalition() == 1) then
			if distance == nil then
				nearest = fountUnt
				distance = utils.getDistance(unt, Unit.getByName(foundUnt))
			elseif utils.getDistance(unt, Unit.getByName(foundUnt)) < distance then
				distance = utils.getDistance(unt, Unit.getByName(foundUnt))
				nearest = foundUnt
			end
		end
	end
	return nearest
end

function utils.nearestGpFromCoalition(gpName, coa, cat)
	local gp = Group.getByName(gpName)
	local lowest = nil
	local dist
	local current = nil
	for _, coaGp in pairs(coalition.getGroups(coa, cat)) do
		if #coalition.getGroups(coa) > 0 then
			dist = utils.getDistance(gp:getUnit(1):getPoint(), coaGp:getUnit(1):getPoint())
			if  lowest == nil then
				lowest = dist
				current = foundUnt:getName()
			elseif dist < lowest then
				lowest = dist
				current = foundUnt:getName()
			end
		end
	end
	env.info("Nearest Group: "..current)
	return current
end

function utils.pointInZone(pnt, zone)
	xP = pnt.x
	zP = pnt.y
	return utils.point_inside_poly(xP,zP, zone)
end

return utils
