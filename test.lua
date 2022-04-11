package.path = package.path..";"..lfs.writedir().."/Scripts/?.lua"

local refreshRate = 10

local swapSides = require 'DCS-Scripts.utils.SwapCountry'
local tasking = require 'DCS-Scripts.utils.tasking'
local utils = require 'DCS-Scripts.utils.utils'
local test = {}
local TRNC_all = {{00053152, -00293470}, {00017400, -00287523},
 {00029323, -00228633}, {00080672, -00112222},
  {00029749, -00228633}, {00006260, -00223009}, {00011106,-00167628}}



local function trackPlanes()
	for _, gp in pairs(coalition.getGroups(2, Group.Category.AIRPLANE)) do
		for _, unt in pairs(gp:getUnits()) do
			if swapSides.isUntInZone(unt, TRNC_all) then
--				swapSides.swapInRangeOfUnit(unt:getName(), 5000)
				swapSides.swapInRangeOfUnit(unt:getName(), 1000000, Group.Category.AIRPLANE)
--				This isn't working
--					tasking.newTaskFollowGp("Turkey F16", gp:getName())
--					tasking.nearestGpFromCoaFollow(gp:getName(), coalition.side.NEUTRAL,
--					 Group.Category.AIRPLANE)
			end
		end
	end
end

function test.main()
	timer.scheduleFunction(function()
	  utils.protectedCall(trackPlanes)
	  return timer.getTime() + refreshRate
	end,
	{},
	timer.getTime() + refreshRate
	)
end

--swapSides.swapGpCountry("TURKEY","CJTF_RED")

--tasking.newTaskFollowGp("Turkey F16", "UK Tornado")

--tasking.newTaskAttackGp("Turkey F16", "UK Tornado")

return test
