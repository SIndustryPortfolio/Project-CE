local GrenadesModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local RequiredModules = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

-- DIRECT
function GrenadesModule.Initialise(NilParam, GrenadeModel, ...)
	-- Functions
	-- INIT
	if RequiredModules[GrenadeModel.Name] then
		return RequiredModules[GrenadeModel.Name]:Initialise(GrenadeModel, ...)
	else
		DebugModule:Print("Grenades | Cannot find Sub Module for Grenade: ".. tostring(GrenadeModel))
	end
end

function GrenadesModule.End(NilParam, GrenadeModel, ...)
	-- Functions
	-- INIT
	if RequiredModules[GrenadeModel.Name] then
		return RequiredModules[GrenadeModel.Name]:End(GrenadeModel, ...)
	else
		DebugModule:Print("Grenades | Cannot find Sub Module for Grenade: ".. tostring(GrenadeModel))
	end
end

-- INIT
RunSubModules()

return GrenadesModule