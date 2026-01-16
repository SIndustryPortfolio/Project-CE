local GameModesInfoModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local RequiredSubModules = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	for x, BaseGameModeFolder in pairs(script:GetChildren()) do
		local _Required = UtilitiesModule:RunSubModules(BaseGameModeFolder, true)
		
		for ModuleName, Module in pairs(_Required) do
			RequiredSubModules[ModuleName] = Module
		end
	end
end

-- DIRECT
function GameModesInfoModule.GetGameModeInfo(NilParam, SettingName)
	return RequiredSubModules[SettingName]
end

function GameModesInfoModule.GetAllGameModesInfo()
	return RequiredSubModules
end

-- INIT
RunSubModules()

return GameModesInfoModule