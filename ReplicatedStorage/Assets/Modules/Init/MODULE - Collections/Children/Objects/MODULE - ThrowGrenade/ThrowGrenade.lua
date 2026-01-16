local TagModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local RequiredModules = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

local function Initialise(GrenadeModel)
	-- Functions
	-- INIT
	if RequiredModules[GrenadeModel.Name] then
		RequiredModules[GrenadeModel.Name]:Initialise(GrenadeModel)
	end
end

-- DIRECT
function TagModule.Initialise(NilParam, GrenadeModel)
	return Initialise(GrenadeModel)
end

function TagModule.End()
	
end

-- INIT
RunSubModules()

return TagModule