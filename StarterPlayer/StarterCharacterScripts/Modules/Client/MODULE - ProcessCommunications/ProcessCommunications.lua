local ProcessCommunicationsModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Client
local Player = game.Players.LocalPlayer

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- Elements
-- EVENTS
local ProcessCommunicationsEvent = UtilitiesModule:GetPlayerCharacterClientRemote(Player, "ProcessCommunications")

-- CORE
local Connections = {}
local RequiredModules = {}

-- Elements
-- REMOTES
local CharacterProcessRemote = UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess")

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

local function onCharacterProcessRemoteFired(FunctionName, ...)
	-- Functions
	-- INIT
	local Args = {...}
	
	local Success, Error = pcall(function()
		local RequiredModule = RequiredModules[FunctionName] --require(UtilitiesModule:WaitForChildTimed(script, FunctionName))
		
		if RequiredModule and RequiredModule.Initialise ~= nil then
			return RequiredModule:Initialise(unpack(Args))
		end
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | onCharacterProcessRemoteFired | Error: ".. tostring(Error))
		--DebugModule:PrintError, "Error")
	else
		return Error
	end
end

local function Initialise()
	-- Functions
	-- INIT
	local Connection1 = CharacterProcessRemote.OnClientEvent:Connect(function(FunctionName, ...)
		return onCharacterProcessRemoteFired(FunctionName, ...)	
	end)
	
	local Connection2 = ProcessCommunicationsEvent.Event:Connect(function(FunctionName, ...)
		return onCharacterProcessRemoteFired(FunctionName, ...)
	end)
	
	-- Connections
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
end

local function End()
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections)
	
	for ModuleName, Module in pairs(RequiredModules) do
		if Module and Module.End ~= nil then
			Module:End()
		end
	end
end

local function GarbageCollect()
	-- Functions
	-- INIT
	for ModuleName, Module in pairs(RequiredModules) do
		if Module and Module.GarbageCollect ~= nil then
			Module:GarbageCollect()
		end
	end
	
	SharedModulesFolder = nil
	--
	Player = nil
	--
	UtilitiesModule = nil
	DebugModule = nil
	--
	Connections = nil
	RequiredModules = nil
	--
	CharacterProcessRemote = nil
	
end

-- DIRECT
--[[function ProcessCommunicationsModule.ClientFire(NilParam, ...)
	return onCharacterProcessRemoteFired(...)
end]]

function ProcessCommunicationsModule.GarbageCollect()
	GarbageCollect()
end

function ProcessCommunicationsModule.Initialise()
	return Initialise()	
end

function ProcessCommunicationsModule.End()
	return End()
end

-- INIT
RunSubModules()

return ProcessCommunicationsModule