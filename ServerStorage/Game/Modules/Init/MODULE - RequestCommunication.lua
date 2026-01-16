local RequestCommunicationModule = {}

-- Dirs
local ServerInitModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]["Init"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ClientServerSignalsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Signals"]

-- Elements
-- SIGNALS
local GameRequestSignal = ClientServerSignalsFolder["GameRequest"]
local ClientRequestSignal = ClientServerSignalsFolder["ClientRequest"]

-- Modules
local MainLoopModule = require(ServerInitModulesFolder["MainLoop"])
local ServerClientModule = require(ServerModulesFolder["Client"])

-- Functions
-- CORE FUNCTIONS
local ClientGameRequests = 
{
	["Main"] = function(Player, FunctionName, ...)
		return MainLoopModule:ClientRequest(Player, FunctionName, ...)
	end,	
}

-- MECHANICS
local function OnGameRequestSignalInvoked(Player, FunctionName, ...)
	return ClientGameRequests[FunctionName](Player, ...)
end

local function OnClientRequestSignalInvoked(Player, FunctionName, ...)
	return ServerClientModule:ClientRequest(Player, FunctionName, ...)
end

-- CONNECTORS
ClientRequestSignal.OnServerInvoke = OnClientRequestSignalInvoked
GameRequestSignal.OnServerInvoke = OnGameRequestSignalInvoked

return RequestCommunicationModule