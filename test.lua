package.path = package.path..";"..lfs.writedir().."/Scripts/?.lua"

local swapSides = require 'DCS-Scripts.utils.SwapCountry'
local tasking = require 'DCS-Scripts.utils.tasking'
local utils = require 'DCS-Scripts.utils.utils'
local spawning = require 'DCS-Scripts.utils.spawning'
local locations = require 'DCS-Scripts.utils.locations'

local test = {}

local STMLink = 'E:\\wheel\\Documents\\Documents not game stuff\\DCS Stuff\\Dev\\DCS-Scripts\\research\\testSTM2.stm'

local refreshRate = 10

local TRNC_all = {{00053152, -00293470}, {00017400, -00287523},
 {00029323, -00228633}, {00080672, -00112222},
  {00029749, -00228633}, {00006260, -00223009}, {00011106,-00167628}}

local enforcingGps = {"Turkey F16"}

local function trackPlanes()
  tasking.noFlyZoneV2(enforcingGps, coalition.side.RED, coalition.side.BLUE, TRNC_all)
end

function test.main()
	timer.scheduleFunction(function()
	  utils.protectedCall(trackPlanes)
	  return timer.getTime() + refreshRate
	end,
	{},
	timer.getTime() + refreshRate
  )

return test
