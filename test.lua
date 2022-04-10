package.path = package.path..";"..lfs.writedir().."/Scripts/?.lua"

local swapSides = require 'DCS-Scripts.utils.SwapCountry'

local TRNC_all = {{00053152, -00293470}, {00017400, -00287523}, {00029323, -00228633}, {00080672, -00112222}, {00029749, -00228633}, {00006260, -00223009}, {00011106,-00167628}}

local function protectedCall(...)
  local status, retval = pcall(...)
  if not status then
    env.warning("test script error caught " .. retval, true)
  end
end

local function trackPlanes()
	for _, gp in pairs(coalition.getGroups(2, Group.Category.AIRPLANE)) do
		env.info("Plane gp ".. gp:getName())
		for _, unt in pairs(gp:getUnits()) do
			if swapSides.isUntInZone(unt, TRNC_all) then		
				swapSides.swapInRangeOfUnit(unt:getName(), 5000)
				swapSides.swapInRangeOfUnit(unt:getName(), 250000, Unit.Category.AIRPLANE)
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