local TagModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Info Modules
local CollectionsInfoModule = require(SharedInfoModulesFolder["Collections"])

-- Modules
local ServerObjectsModule = require(ServerModulesFolder["Objects"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local DebugModule = require(SharedModulesFolder["Debug"])

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

local function Initialise(Window)
	-- Functions
	-- INIT
	----DebugModule:Print"Creating Instance Dict")
	
	ObjectsModule:CreateInstancesFromDict(Window, CollectionsInfoModule:GetCollectionItemInfo(script.Name):GetInfo("Properties"))
	
	----DebugModule:Print"Finished making Instance Dict")
	
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Window, "Humanoid")
	
	-- DIRECT
	local Connection1 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health <= 0 then
			TagModule:End(Window)
		end
	end)
	
	-- INIT
	AddToCache(Window, {Connection1})
end

local function End(Window)	
	-- Functions
	-- INIT
	RemoveFromCache(Window)
	ServerObjectsModule:ObjectProcess("SpawnScrap", Window)
	--DebrisService:AddItem(Window, 1)
	DebrisModule:AddItem(Window, .1)
end

-- DIRECT
function TagModule.Initialise(NilParam, Window)
	return Initialise(Window)
end

function TagModule.End(NilParam, Window)
	return End(Window)
end

return TagModule