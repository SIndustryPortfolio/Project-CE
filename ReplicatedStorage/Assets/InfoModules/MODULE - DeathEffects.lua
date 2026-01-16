local DeathEffectInfoModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local RequiredModules = {}

local DeathEffects = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

local function GetDeathEffectFromId(Id)
	-- Functions
	-- INIT
	Id = tostring(Id)

	for EffectName, EffectInfo in pairs(DeathEffects) do
		if Id == tostring(EffectInfo["Id"]) then
			return EffectName
		end
	end
end

-- DIRECT
function DeathEffectInfoModule.UnpackId(NilParam, Id)
	return GetDeathEffectFromId(Id)
end

function DeathEffectInfoModule.GetInfo(NilParam, SettingName)
	return RequiredModules[SettingName]
end

function DeathEffectInfoModule.GetAllInfo()
	return RequiredModules
end

-- INIT
RunSubModules()

return DeathEffectInfoModule