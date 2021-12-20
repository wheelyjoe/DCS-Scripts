
assert(loadfile("C:\\Users\\spenc\\OneDrive\\Documents\\Eclipe_LDT\\dcs splash damage\\src\\mist.lua"))()
--[[
2 October 2020
FrozenDroid:
- Added error handling to all event handler and scheduled functions. Lua script errors can no longer bring the server down.
- Added some extra checks to which weapons to handle, make sure they actually have a warhead (how come S-8KOM's don't have a warhead field...?)
28 October 2020
FrozenDroid: 
- Uncommented error logging, actually made it an error log which shows a message box on error.
- Fixed the too restrictive weapon filter (took out the HE warhead requirement)
18 December 2021
spencershepard (GRIMM):
- added suppression features from Suppression Script by Marc "MBot" Marbot v20Dec2013
--]]

explTable = {
  ["FAB_100"] = 45,
  ["FAB_250"] = 100,
  ["FAB_250M54TU"]= 100,
  ["FAB_500"] = 213,
  ["FAB_1500"]  = 675,
  ["BetAB_500"] = 98,
  ["BetAB_500ShP"]= 107,
  ["KH-66_Grom"]  = 108,
  ["M_117"] = 201,
  ["Mk_81"] = 60,
  ["Mk_82"] = 118,
  ["AN_M64"]  = 121,
  ["Mk_83"] = 274,
  ["Mk_84"] = 582,
  ["MK_82AIR"]  = 118,
  ["MK_82SNAKEYE"]= 118,
  ["GBU_10"]  = 582,
  ["GBU_12"]  = 118,
  ["GBU_16"]  = 274,
  ["KAB_1500Kr"]  = 675,
  ["KAB_500Kr"] = 213,
  ["KAB_500"] = 213,
  ["GBU_31"]  = 582,
  ["GBU_31_V_3B"] = 582,
  ["GBU_31_V_2B"] = 582,
  ["GBU_31_V_4B"] = 582,
  ["GBU_32_V_2B"] = 202,
  ["GBU_38"]  = 118,
  ["AGM_62"]  = 400,
  ["GBU_24"]  = 582,
  ["X_23"]  = 111,
  ["X_23L"] = 111,
  ["X_28"]  = 160,
  ["X_25ML"]  = 89,
  ["X_25MP"]  = 89,
  ["X_25MR"]  = 140,
  ["X_58"]  = 140,
  ["X_29L"] = 320,
  ["X_29T"] = 320,
  ["X_29TE"]  = 320,
  ["AGM_84E"] = 488,
  ["AGM_88C"] = 89,
  ["AGM_122"] = 15,
  ["AGM_123"] = 274,
  ["AGM_130"] = 582,
  ["AGM_119"] = 176,
  ["AGM_154C"]  = 305,
  ["S-24A"] = 24,
  --["S-24B"] = 123,
  ["S-25OF"]  = 194,
  ["S-25OFM"] = 150,
  ["S-25O"] = 150,
  ["S_25L"] = 190,
  ["S-5M"]  = 1,
  ["C_8"]   = 4,
  ["C_8OFP2"] = 3,
  ["C_13"]  = 21,
  ["C_24"]  = 123,
  ["C_25"]  = 151,
  ["HYDRA_70M15"] = 2,
  ["Zuni_127"]  = 5,
  ["ARAKM70BHE"]  = 4,
  ["BR_500"]  = 118,
  ["Rb 05A"]  = 217,
  ["HEBOMB"]  = 40,
  ["HEBOMBD"] = 40,
  ["MK-81SE"] = 60,
  ["AN-M57"]  = 56,
  ["AN-M64"]  = 180,
  ["AN-M65"]  = 295,
  ["AN-M66A2"]  = 536,
  ["HYDRA_70_M151"] = 2,
  ["HYDRA_70_MK5"] = 2,
}

splash_damage_options = {
  ["cascading_explosions"] = true,
  ["larger_explosions"] = true,
  ["damage_model"] = true, 
  ["rockets_frag_infantry"] = false,
  ["rocket_blast_radius"] = 10,
  ["blast_stun"] = false,
  ["cascade_statics"] = true,
  ["game_messages"] = true, 
  ["unit_disabled_health"] = 90,
  ["unit_cant_fire_health"] = 95,
  ["infantry_cant_fire_health"] = 99,
  ["debug"] = false,
}

local weaponDamageEnable = 1
WpnHandler = {}
tracked_weapons = {}
refreshRate = 0.1

local function debugMsg(str)
  if splash_damage_options.debug == true then
    trigger.action.outText(str , 10)
  end
end

local function gameMsg(str)
  if splash_damage_options.game_messages == true then
    trigger.action.outText(str , 10)
  end
end

local function getDistance(point1, point2)
  local x1 = point1.x
  local y1 = point1.y
  local z1 = point1.z
  local x2 = point2.x
  local y2 = point2.y
  local z2 = point2.z
  local dX = math.abs(x1-x2)
  local dZ = math.abs(z1-z2)
  local distance = math.sqrt(dX*dX + dZ*dZ)
  return distance
end

local function getDistance3D(point1, point2)
  local x1 = point1.x
  local y1 = point1.y
  local z1 = point1.z
  local x2 = point2.x
  local y2 = point2.y
  local z2 = point2.z
  local dX = math.abs(x1-x2)
  local dY = math.abs(y1-y2)
  local dZ = math.abs(z1-z2)
  local distance = math.sqrt(dX*dX + dZ*dZ + dY*dY)
  return distance
end

local function vec3Mag(speedVec)

  mag = speedVec.x*speedVec.x + speedVec.y*speedVec.y+speedVec.z*speedVec.z
  mag = math.sqrt(mag)
  --trigger.action.outText("X = " .. speedVec.x ..", y = " .. speedVec.y .. ", z = "..speedVec.z, 10)
  --trigger.action.outText("Speed = " .. mag, 1)
  return mag

end

local function lookahead(speedVec)

  speed = vec3Mag(speedVec)
  dist = speed * refreshRate * 1.5 
  return dist

end

local function track_wpns()
--  env.info("Weapon Track Start")
  for wpn_id_, wpnData in pairs(tracked_weapons) do   
    if wpnData.wpn:isExist() then  -- just update speed, position and direction.
      wpnData.pos = wpnData.wpn:getPosition().p
      wpnData.dir = wpnData.wpn:getPosition().x
      wpnData.speed = wpnData.wpn:getVelocity()
      --wpnData.lastIP = land.getIP(wpnData.pos, wpnData.dir, 50)
    else -- wpn no longer exists, must be dead.
--      trigger.action.outText("Weapon impacted, mass of weapon warhead is " .. wpnData.exMass, 2)
      local ip = land.getIP(wpnData.pos, wpnData.dir, lookahead(wpnData.speed))  -- terrain intersection point with weapon's nose.  Only search out 20 meters though.
      local impactPoint
      if not ip then -- use last calculated IP
        impactPoint = wpnData.pos
  --        trigger.action.outText("Impact Point:\nPos X: " .. impactPoint.x .. "\nPos Z: " .. impactPoint.z, 2)
      else -- use intersection point
        impactPoint = ip
  --        trigger.action.outText("Impact Point:\nPos X: " .. impactPoint.x .. "\nPos Z: " .. impactPoint.z, 2)
      end
      --env.info("Weapon is gone") -- Got to here -- 
      --trigger.action.outText("Weapon Type was: ".. wpnData.name, 20)
      if explTable[wpnData.name] and splash_damage_options.larger_explosions == true then
          --env.info("triggered explosion size: "..explTable[wpnData.name])
          trigger.action.explosion(impactPoint, explTable[wpnData.name])
          --trigger.action.smoke(impactPoint, 0)
      else trigger.action.outText("Splash Damage script, not in DB:  "..tostring(wpnData.name), 2)
      end
      if wpnData.cat == Weapon.Category.ROCKET then
        rocketBlast(impactPoint, splash_damage_options.rocket_blast_radius, wpnData.ordnance)
      end
      tracked_weapons[wpn_id_] = nil -- remove from tracked weapons first.         
    end
  end
--  env.info("Weapon Track End")
end

function onWpnEvent(event)
  if event.id == world.event.S_EVENT_SHOT then
    if event.weapon then
      local ordnance = event.weapon
      local weapon_desc = ordnance:getDesc()
      if (weapon_desc.category ~= 0) and event.initiator then
    if (weapon_desc.category == 1) then
      if (weapon_desc.MissileCategory ~= 1 and weapon_desc.MissileCategory ~= 2) then
        tracked_weapons[event.weapon.id_] = { wpn = ordnance, init = event.initiator:getName(), pos = ordnance:getPoint(), dir = ordnance:getPosition().x, name = ordnance:getTypeName(), speed = ordnance:getVelocity(), cat = ordnance:getCategory() }
      end
    else
      tracked_weapons[event.weapon.id_] = { wpn = ordnance, init = event.initiator:getName(), pos = ordnance:getPoint(), dir = ordnance:getPosition().x, name = ordnance:getTypeName(), speed = ordnance:getVelocity(), cat = ordnance:getCategory() }
    end
      end
    end
  end

end

local function protectedCall(...)
  local status, retval = pcall(...)
  if not status then
    env.warning("Splash damage script error... gracefully caught! " .. retval, true)
  end
end


function WpnHandler:onEvent(event)
  protectedCall(onWpnEvent, event)
end

if (weaponDamageEnable == 1) then
  timer.scheduleFunction(function() 
      protectedCall(track_wpns)
      return timer.getTime() + refreshRate
    end, 
    {}, 
    timer.getTime() + refreshRate
  )
  world.addEventHandler(WpnHandler)
end

  local SuppressedUnits = {} --Table to temporary store data for suppressed units
  
  local function SuppressionEnd(id) 
    --id.ctrl:setOption(AI.Option.Ground.id.ROE , AI.Option.Ground.val.ROE.OPEN_FIRE)       ------------------OFFF
    --id.ctrl:setOnOff(true)
    SuppressedUnits[id.unitName] = nil
     
    debugMsg(id.unitName .. " suppression end")
  end
 
 
function suppressUnit(tgt, severity, weapon)
    if weapon ~= nil then
       if weapon:getDesc().category == Weapon.Category.SHELL then
         debugMsg("weapon is a shell")
         return --implement a non-stacking suppression later
       end
    end
    local delay = math.random(2*severity, 5*severity) --Time in seconds the group of a hit unit will be unable to fire
    
    local id = {
      unitName = tgt:getName(),
      ctrl = tgt:getController()
      
    }
    
    if SuppressedUnits[id.unitName] == nil then --If group is currently not suppressed, add to table.
      SuppressedUnits[id.unitName] = {
        SuppressionEndTime = timer.getTime() + delay,
        SuppressionEndFunc = nil
      }
      SuppressedUnits[id.unitName].SuppressionEndFunc = timer.scheduleFunction(SuppressionEnd, id, SuppressedUnits[id.unitName].SuppressionEndTime) --Schedule the SuppressionEnd() function  
    else  --If group is already suppressed, update table and increase delay
      local timeleft = SuppressedUnits[id.unitName].SuppressionEndTime - timer.getTime()  --Get how long to the end of the suppression
      local addDelay = (delay / timeleft) * delay --The longer the suppression is going to last, the smaller it is going to be increased by additional hits
      if timeleft < delay then  --But if the time left is shorter than a complete delay, add another full delay
        addDelay = delay
      end
      SuppressedUnits[id.unitName].SuppressionEndTime = SuppressedUnits[id.unitName].SuppressionEndTime + addDelay
      timer.setFunctionTime(SuppressedUnits[id.unitName].SuppressionEndFunc, SuppressedUnits[id.unitName].SuppressionEndTime) --Update the execution time of the existing instance of the SuppressionEnd() scheduled function
    end
    
    id.ctrl:setOption(AI.Option.Ground.id.ROE , AI.Option.Ground.val.ROE.WEAPON_HOLD) --Set ROE weapons hold to initate suppression
    id.ctrl:setOnOff(false) 
    gameMsg(tgt:getTypeName().." suppressed for "..delay.."s")
    --debugMsg(id.unitName .. " suppressed until " .. SuppressedUnits[id.unitName].SuppressionEndTime)
  end





function rocketBlast(_point, _radius, weapon)
 local foundUnits = {}
 local volS = {
   id = world.VolumeType.SPHERE,
   params = {
     point = _point,
     radius = _radius
   }
 }
 
 local ifFound = function(foundUnit, val)
    if foundUnit:getDesc().category == Unit.Category.GROUND_UNIT then
      foundUnits[#foundUnits + 1] = foundUnit
    end
    --debugMsg("found unit: "..foundUnit:getTypeName())
    if foundUnit:hasAttribute("Infantry") and splash_damage_options.rockets_frag_infantry == true then
      --debugMsg("found infantry unit: "..foundUnit:getName())
      trigger.action.explosion(foundUnit:getPoint(), 1)  --kill infantry in blast radius
    end
    if foundUnit:getDesc().category == Unit.Category.GROUND_UNIT and splash_damage_options.blast_stun == true then --if ground unit
      suppressUnit(foundUnit, 2, weapon)
    end
    if splash_damage_options.cascading_explosions == true then
      local timing = getDistance(_point, foundUnit:getPoint())/300
      local id = timer.scheduleFunction(explodeUnit, foundUnit, timer.getTime() + timing)
    end
    return true
 end
 
 world.searchObjects(Object.Category.UNIT, volS, ifFound)
 world.searchObjects(Object.Category.STATIC, volS, ifFound)
 world.searchObjects(Object.Category.SCENERY, volS, ifFound)
 
 if splash_damage_options.damage_model == true then --if ground unit
   local id = timer.scheduleFunction(damageUnits, foundUnits, timer.getTime() + 1) --allow some time for the game to adjust health levels before running our function  --do we need to create new instances of this?
 end
end




function damageUnits(units)
  --debugMsg("units table: "..mist.utils.tableShow(units))
  for i, unit in ipairs(units)
  do
    --debugMsg("unit table: "..mist.utils.tableShow(unit))
    if unit:isExist() then  --if units are not already dead
      local health = (unit:getLife() / unit:getLife0()) * 100
      debugMsg(unit:getTypeName().." health %"..health) 
      local unit_controller = unit:getController()
      if unit:hasAttribute("Infantry") then
        if health <= splash_damage_options.infantry_cant_fire_health then
          --debugMsg("infantry cant fire")
          unit_controller:setOption(AI.Option.Ground.id.ROE , AI.Option.Ground.val.ROE.WEAPON_HOLD)
        end
      end
      if unit:getDesc().category == Unit.Category.GROUND_UNIT then
        if health <= splash_damage_options.unit_cant_fire_health then
          unit_controller:setOption(AI.Option.Ground.id.ROE , AI.Option.Ground.val.ROE.WEAPON_HOLD)
          gameMsg(unit:getTypeName().." weapons disabled")
        end
        if health <= splash_damage_options.unit_disabled_health then
          unit_controller:setOnOff(false) 
          gameMsg(unit:getTypeName().." engine disabled")
        end
      end
      
    else
      --debugMsg("unit no longer exists")
    end
  end
end

function explodeUnit(unit)
  if unit:isExist() then
    trigger.action.explosion(unit:getPoint(), 1) 
  end
end

