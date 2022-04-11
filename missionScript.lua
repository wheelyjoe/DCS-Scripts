package.path = package.path..";"..lfs.writedir().."/Scripts/?.lua"

local test = require('DCS-Scripts.test')

test.main()
