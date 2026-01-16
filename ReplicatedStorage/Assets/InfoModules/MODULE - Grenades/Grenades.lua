local GrenadesInfoModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local RequiredModules = {}

local GrenadeSettings = 
{
	["GrenadeOrder"] = UtilitiesModule:GetChildrenNames(script),
	["DirectionalPower"] = 5,
	["DirectionalUpThrust"] = 5,
	["ThrowRange"] = 20, -- studs
	--
	["MaxGrenades"] = 4
}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

-- DIRECT
function GrenadesInfoModule.GetAllGrenadeSettings()
	return GrenadeSettings
end

function GrenadesInfoModule.GetGrenadeSetting(NilParam, SettingName)
	return GrenadeSettings[SettingName]
end

function GrenadesInfoModule.GetGrenadeInfo(NilParam, SettingName)
	return RequiredModules[SettingName]
end

function GrenadesInfoModule.GetAllGrenadeInfo()
	return RequiredModules
end

-- INIT
RunSubModules()

return GrenadesInfoModule