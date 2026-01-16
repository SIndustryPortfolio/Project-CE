local VehiclesInfoModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local VehicleInfos = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	VehicleInfos = UtilitiesModule:RunSubModules(script, true)
end

-- DIRECT
function VehiclesInfoModule.GetAllVehicleInfos()
	-- Functions
	-- INIT
	return VehicleInfos
end

function VehiclesInfoModule.GetVehicleInfo(NilParam, GunName)
	--[[local Success, RequiredModule = pcall(function()
		return require(UtilitiesModule:WaitForChildTimed(script, GunName))
	end)
	
	if Success then
		return RequiredModule
	else
		--print("Error: ".. tostring(RequiredModule))
	end]]
	
	return VehicleInfos[GunName]
end

-- INIT
RunSubModules()

return VehiclesInfoModule