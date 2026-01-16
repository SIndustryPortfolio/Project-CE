local RequestCommunicationsModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ClientServerSignalsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Signals"]
local ClientSignalsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["Client"]["Signals"]

-- Elements
-- SIGNALS
local PhysicsRequestSignal = ClientServerSignalsFolder["PhysicsRequest"]
local ClientRequestSignal = ClientSignalsFolder["ClientRequest"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local PhysicsModule = require(UtilitiesModule:WaitForChildTimed(ModulesFolder, "Physics"))
local InterfacesModule = require(UtilitiesModule:WaitForChildTimed(ModulesFolder, "Interfaces"))

-- Functions
-- CORE FUNCTIONS
local ClientRequests = 
{
	["Interfaces"] = function(...)
		return InterfacesModule:Request(...)
	end,
}

-- MECHANICS
local function PhysicsRequest(FunctionName, ...)
	-- Functions
	-- INIT
	return PhysicsModule:ServerRequest(FunctionName, ...)
end

local function onClientRequestSignalInvoked(FunctionName, ...)
	-- Functions
	-- INIT
	return ClientRequests[FunctionName](...)
end

-- DIRECT
function RequestCommunicationsModule.PhysicsRequest(NilParam, ...)
	return PhysicsRequest(...)
end

-- Connectors
PhysicsRequestSignal.OnClientInvoke = PhysicsRequest
ClientRequestSignal.OnInvoke = onClientRequestSignalInvoked

return RequestCommunicationsModule