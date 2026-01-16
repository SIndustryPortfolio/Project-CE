local ProcessCommunicationsModule = {}

-- Dirs
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]
local ClientRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["Client"]["Remotes"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Elements
-- REMOTES
local EffectProcessRemote = ClientServerRemotesFolder["EffectProcess"]
local ClientProcessRemote = ClientRemotesFolder["ClientProcess"]
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]
local TiltReplicateRemote = ClientServerRemotesFolder["TiltReplicateRemote"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local EffectsHandlerModule = require(ModulesFolder["EffectsHandler"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local RequiredModules = {}

-- Functions
-- DIRECT


-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

local function onClientProcessRemoteFired(FunctionName, ...)
	-- Functions
	-- INIT
	local Args = {...}
	
	local Success, Error = pcall(function()
		local RequiredModule = RequiredModules[FunctionName] --require(UtilitiesModule:WaitForChildTimed(script, FunctionName))
		
		if RequiredModule.Initialise ~= nil then
			return RequiredModule:Initialise(unpack(Args))
		end
	end)
	
	if Success then
		return Error
	else
		DebugModule:Print("ProcessCommunications | Error | FunctionName: ".. tostring(FunctionName).. " | Args: ".. tostring({...}).. " | Error: ".. tostring(Error))
		--DebugModule:Print"Function Name: ".. tostring(FunctionName).. " | Parameters: ".. tostring({...}))		
		--DebugModule:PrintError, "Error")
	end
end

local function onEffectProcessRemoteFired(FunctionName, ...)
	return EffectsHandlerModule:ServerRequest(FunctionName, ...)
end

local function onTiltProcessRemoteFired(...)
	return RequiredModules["Tilt"]:Initialise(...)
end

-- INIT
RunSubModules()

-- Connectors
EffectProcessRemote.OnClientEvent:Connect(onEffectProcessRemoteFired)
GameProcessRemote.OnClientEvent:Connect(onClientProcessRemoteFired)
ClientProcessRemote.Event:Connect(onClientProcessRemoteFired)
TiltReplicateRemote.OnClientEvent:Connect(onTiltProcessRemoteFired)


return ProcessCommunicationsModule