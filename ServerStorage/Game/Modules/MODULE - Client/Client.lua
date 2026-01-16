local ClientModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local RequiredModules = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

local function ClientRequest(Player, FunctionName, ...)
	return RequiredModules[FunctionName]:Initialise(Player, ...)
end

-- DIRECT
function ClientModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequest(Player, FunctionName, ...)
end

-- INIT
RunSubModules()

return ClientModule