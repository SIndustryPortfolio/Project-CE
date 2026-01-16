local TagModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Info Modules
local CollectionsInfoModule = require(SharedInfoModulesFolder["Collections"])
local ObjectsInfoModule = require(SharedInfoModulesFolder["Objects"])

-- Modules
local ServerObjectsModule = require(ServerModulesFolder["Objects"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebrisModule = require(SharedModulesFolder["Debris"])

local Connections = {}

-- Services
--local DebrisService = game:GetService("Debris")

-- Functions
-- MECHANICS
local function AddToCache(Model, _Connections)
	-- Functions
	-- INIT
	if Connections[Model] == nil then
		Connections[Model] = {}
	end

	for i, Connection in pairs(_Connections) do
		table.insert(Connections[Model], Connection)
	end
end

local function RemoveFromCache(Model)
	-- Functions
	-- INIT
	if not Connections[Model] then
		return nil
	end

	UtilitiesModule:DisconnectConnections(Connections[Model])
	Connections[Model] = nil
end

local function Initialise(HealthPack)
	-- Functions
	-- INIT
	--ObjectsModule:CreateInstancesFromDict(HealthPack, CollectionsInfoModule:GetCollectionItemInfo(script.Name):GetInfo("Properties"))
	
	-- INIT
end

local function End(HealthPack)	
	-- Functions
	-- INIT
	RemoveFromCache(HealthPack)
	task.wait(.3)
	ServerObjectsModule:ObjectProcess("Respawn", HealthPack)
	DebrisModule:AddItem(HealthPack)
end

local function Heal(Player, HealthPack)
	-- Functions
	-- INIT
	if not HealthPack or not Player then
		return nil
	end
	
	local Response = ServerObjectsModule:ObjectProcess("Heal", Player, HealthPack)
	
	if Response then
		End(HealthPack)
	end
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Heal"] = 	Heal
}

-- DIRECT
function TagModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

function TagModule.Initialise(NilParam, HealthPack)
	return Initialise(HealthPack)
end

function TagModule.End(NilParam, HealthPack)
	return End(HealthPack)
end

return TagModule