local utils = {}

function utils.protectedCall(...)
  local status, retval = pcall(...)
  if not status then
    env.warning("test script error caught " .. retval, true)
  end
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

function utils.pointInZone(pnt, zone)
	xP = pnt.x
	zP = pnt.y
	return utils.point_inside_poly(xP,zP, zone)	
end

return utils