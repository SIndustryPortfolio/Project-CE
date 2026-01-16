local WeaponsInfoModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local WeaponInfos = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	WeaponInfos = UtilitiesModule:RunSubModules(script, true)
end

-- DIRECT
function WeaponsInfoModule.GetAllWeaponInfos()
	-- Functions
	-- INIT
	return WeaponInfos
end

function WeaponsInfoModule.GetWeaponInfo(NilParam, GunName)
	--[[local Success, RequiredModule = pcall(function()
		return require(UtilitiesModule:WaitForChildTimed(script, GunName))
	end)
	
	if Success then
		return RequiredModule
	else
		--print("Error: ".. tostring(RequiredModule))
	end]]
	
	return WeaponInfos[GunName]
end

-- INIT
RunSubModules()

return WeaponsInfoModule