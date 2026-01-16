local PlayerManagementModule = {}

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

local function PlayerProcess(ModuleName, FunctionName, ...)
	-- Functions
	-- INIT
	local Args = {...}
	
	local Success, Response = pcall(function()
		return RequiredModules[ModuleName][FunctionName](nil, PlayerManagementModule, unpack(Args))
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | PlayerProcess | ModuleName: ".. tostring(ModuleName).. " | FunctionName: ".. tostring(FunctionName).. " | Error: ".. tostring(Response))
	else
		return Response
	end	
end

-- DIRECT
function PlayerManagementModule.PlayerProcess(NilParam, ModuleName, FunctionName, ...)
	--DebugModule:Print(script.Name.. " | PlayerProcess | NilParam: ".. tostring(NilParam))
	return PlayerProcess(ModuleName, FunctionName, ...)
end

-- INIT
RunSubModules()

return PlayerManagementModule