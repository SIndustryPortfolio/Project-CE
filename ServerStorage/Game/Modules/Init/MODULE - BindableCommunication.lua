local BindableCommunicationModule = {}

-- Dirs
local SharedServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["Server"]["Remotes"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Modules
local WebhookModule = require(ServerModulesFolder["Webhook"])

-- Elements
-- REMOTES
local ServerProcessRemote = SharedServerRemotesFolder["ServerProcess"]

-- Functions
-- CORE FUNCTIONS
local ServerRequests = 
{
	["Webhook"] = function(...)
		return WebhookModule:ServerRequest(...)
	end,		
}

-- MECAHNICS
local function ServerRequest(FunctionName, ...)
	-- Functions
	-- INIT
	return ServerRequests[FunctionName](...)
end

-- DIRECT
ServerProcessRemote.Event:Connect(ServerRequest)

return BindableCommunicationModule