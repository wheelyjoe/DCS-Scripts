package.path = package.path..";"..lfs.writedir().."/Scripts/?.lua"
local STMLink = 'C:\\Users\\wheel\\Documents\\DCS\\DCS-Scripts\\research\\StaticsSTM.stm'
local refreshRate = 10
local swapSides = require 'DCS-Scripts.utils.SwapCountry'
local tasking = require 'DCS-Scripts.utils.tasking'
local utils = require 'DCS-Scripts.utils.utils'
local spawning = require 'DCS-Scripts.utils.spawning'
local locations = require 'DCS-Scripts.utils.locations'

local test = {}
local TRNC_all = {{00053152, -00293470}, {00017400, -00287523},
 {00029323, -00228633}, {00080672, -00112222},
  {00029749, -00228633}, {00006260, -00223009}, {00011106,-00167628}}
local enforcingGps = {"Turkey F16"}

local function trackPlanes()
  -- 	for _, gp in pairs(coalition.getGroups(2, Group.Category.AIRPLANE)) do
-- 		for _, unt in pairs(gp:getUnits()) do
-- 			if swapSides.isUntInZone(unt, TRNC_all) then
-- --				swapSides.swapInRangeOfUnit(unt:getName(), 5000)
-- 				swapSides.swapInRangeOfUnit(unt:getName(), 1000000, Group.Category.AIRPLANE)
--s
-- --					tasking.newTaskFollowGp("Turkey F16", gp:getName())
-- --					tasking.nearestGpFromCoaFollow(gp:getName(), coalition.side.NEUTRAL,
-- --					 Group.Category.AIRPLANE)
-- 			end
-- 		end
-- 	end
  tasking.noFlyZone(enforcingGps, coalition.side.RED, coalition.side.BLUE, TRNC_all)
end

function test.main()
  --tasking.FACA("Drone",Group.getByName("target"):getUnit(1):getPoint(), math.random(1111,1788), 244)
	-- timer.scheduleFunction(function()
	--   utils.protectedCall(trackPlanes)
	--   return timer.getTime() + refreshRate
	-- end,
	-- {},
	-- timer.getTime() + refreshRate
	-- )
  -- env.info("Running test.lua")
  local ret = locations.getNearestTown(env.mission.theatre, Group.getByName("Cyprus 40mm -9"):getUnit(1):getPoint())
  env.info("Nearest town is: ".. ret.loc..", it is: "..ret.dis.." km, or "..utils.kmToNm(ret.dis).." nautical miles, heading: "..ret.brng)
  --utils.teleportGp("target-1", Group.getByName("target"):getUnit(1):getPoint())
end

--swapSides.swapGpCountry("TURKEY","CJTF_RED")

--tasking.newTaskFollowGp("Turkey F16", "UK Tornado")

--tasking.newTaskAttackGp("Turkey F16", "UK Tornado")

return test
