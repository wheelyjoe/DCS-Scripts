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

function utils.relPos(pt1, pt2)
	local xDif = pt1.x - pt2.x
	local yDif = pt1.y - pt2.y
	local zDif = pt1.z - pt2.z
	return {x = xDif, y = yDif, z = zDif}
end

function utils.relAngle(hdg1,hdg2)
	local ang = hdg1 - hdg2
	return (ang + 180) % 360 - 180
end

function utils.gpToTable(gp) --Issues with moving gps
	local gpTable = {
			["country"] = gp:getUnit(1):getCountry(),
			["category"] = gp:getCategory(),
			["heading"] = math.atan2(gp:getUnit(1):getPosition().x.z, gp:getUnit(1):getPosition().x.x),
			["groupId"] = gp:getID(),
			["y"] = gp:getUnit(1):getPoint().z,
			["x"] = gp:getUnit(1):getPoint().x,
			["name"] = gp:getName(),
			["units"] = {},
	}
	for _, unt in pairs(gp:getUnits()) do
			gpTable.units[#gpTable.units+1] = {
				["category"] = gp:getCategory(),
				["type"] = unt:getTypeName(),
				["offsets"] = {
					["x"] = utils.relPos({x = gpTable.x, y = 0, z = gpTable.y}, unt:getPoint()).x,
					["y"] = utils.relPos({x = gpTable.x, y = 0, z = gpTable.y}, unt:getPoint()).z,
					["heading"] = utils.relAngle(gpTable.heading, math.atan2(unt:getPosition().x.z, unt:getPosition().x.x)),
				},
				["unitId"] = unt:getID(),
				["x"] = unt:getPoint().x,
				["y"] = unt:getPoint().z,
				["name"] = unt:getName(),
				["heading"] =  math.atan2(unt:getPosition().x.z, unt:getPosition().x.x),
			}
	end
	return gpTable
end

function utils.getDistance(pt1, pt2)
  local dx = pt1.x - pt2.x
  local dz = pt1.z - pt2.z
  return math.sqrt(dx*dx + dz*dz)
end

function utils.getDistanceLL(ll1, ll2)
	local latDiff = ll1.latitude - ll2.latitude
	local longDiff = ll1.longitude - ll2.longitude
	return math.sqrt(latDiff*latDiff + longDiff*longDiff)*100
end

function utils.kmToNm(km)
	return km/1.852
end

function utils.nmToKm(nm)
	return km*1.852
end

function utils.brngToPtLO(pt1, pt2)
	local distance = ((pt1.x - pt2.x)^2 + (pt1.z - pt2.z)^2)^0.5
	local bearing_vector = {
		x = pt2.x - pt1.x,
		y = pt2.y - pt1.y,
		z = pt2.z - pt1.z
		}
	local bearing_rad = math.atan2(bearing_vector.z, bearing_vector.x)
	if bearing_rad < 0 then
			bearing_rad = bearing_rad + (2 * math.pi)
	end
  local bearing = math.deg(bearing_rad)
	return bearing
end

function utils.round(num, dp)
    --[[
    round a number to so-many decimal of places, which can be negative,
    e.g. -1 places rounds to 10's,

    examples
        173.2562 rounded to 0 dps is 173.0
        173.2562 rounded to 2 dps is 173.26
        173.2562 rounded to -1 dps is 170.0
    ]]--
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5)/mult
end

function utils.radToDeg(rad)
	return rad*(180/math.pi)
end

function utils.bearingToPtLL(pt1, pt2) --from pt1 to pt2
	-- local dL = pt2.longitude - pt1.longitude
	-- local x = math.cos(pt2.latitude)*math.sin(dL)
	-- local y = math.cos(pt1.latitude)*math.sin(pt2.latitude) - math.sin(pt1.latitude)*math.cos(pt2.latitude)*math.cos(dL)
	-- local brng = math.atan2(x,y)

	local y = math.sin(pt2.longitude - pt1.longitude)*math.cos(pt2.latitude)
	local x = math.cos(pt1.latitude)*math.cos(pt2.latitude) - math.sin(pt1.latitude)*math.cos(pt2.latitude)*math.cos(pt2.longitude - pt1.longitude)
	local phi = math.atan2(y, x)
	local brng = (phi*180/math.pi + 360) % 360
	return brng
end

function utils.LOtoMGRS(pt1)
	return coord.LLtoMGRS(coord.LOtoLL(pt1))
end

function utils.MGRStoString(mgrs)
	return mgrs.UTMZone .. ' ' .. mgrs.MGRSDigraph .. ' ' .. mgrs.Easting .. ' ' .. mgrs.Northing
end

function utils.bearingToPt(pt1, pt2)
	local bearing_vector = {
		x = pt2.x - pt1.x,
		y = pt2.y - pt1.y,
		z = pt2.z - pt1.z
		}
	local bearing_rad = math.atan2(bearing_vector.z, bearing_vector.x)
	if bearing_rad < 0 then
		bearing_rad = bearing_rad + (2 * math.pi)
	end
  local bearing = math.deg(bearing_rad)
	return bearing
end

function utils.gpInfoMiz(gp)
	local gpName = gp:getName()
	local coa = gp:getCoalition()
	for _, county in pairs(env.mission.coalition.neutrals.country) do
		for _, gpType in pairs(county) do
			for _, vehGp in pairs(county.vehicle.group) do
				if vehGp.name == gpName then
					gpInfo = vehGp
					return gpInfo
				end
			end
			for _, planeGp in pairs(county.plane.group) do
				if planeGp.name == gpName then
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
				if country.ship ~= nil then
					for _, shipGp in pairs(country.ship.group) do
						gps[#gps+1] = {table = shipGp, cntry = country.id, ctgry = Group.Category.SHIP}
					end
				end
				if country.static ~= nil then
					for _, staticGp in pairs(country.static.group) do
						for _, unt in pairs(staticGp.units) do
							gps[#gps+1] = {table = unt, cntry = country.id, ctgry = "static"}
						 end
					end
				end
			end
		end
		return gps
	else
		env.info("file doesn't exist")
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
	return current
end

function utils.pointInZone(pnt, zone)
	xP = pnt.x
	zP = pnt.y
	return utils.point_inside_poly(xP,zP, zone)
end

function utils.coaGpsInZone(coa, zone, type)
	local gps = {}
	local inZone = false
	for _, gp in pairs(coalition.getGroups(coa,type)) do
		inZone = false
		for _, unt in pairs(gp:getUnits()) do
			if utils.pointInZone(unt:getPoint(), zone) ~= nil then
				inZone=true
			end
		end
		if inZone then
			gps[#gps+1] = gp
		end
	end
	return gps
end

return utils
