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

local function Initialise(WoodenPallet)
	-- Functions
	-- INIT
	----DebugModule:Print"Creating Instance Dict")
	
	ServerObjectsModule:InitialiseObject(WoodenPallet)
	ObjectsModule:CreateInstancesFromDict(WoodenPallet, CollectionsInfoModule:GetCollectionItemInfo(script.Name):GetInfo("Properties"))
	
	----DebugModule:Print"Finished making Instance Dict")
	
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(WoodenPallet, "Humanoid")
	
	-- DIRECT
	local Connection1 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health <= 0 then
			TagModule:End(WoodenPallet)
		end
	end)
	
	-- INIT
	AddToCache(WoodenPallet, {Connection1})
end

local function End(WoodenPallet)	
	-- Functions
	-- INIT
	RemoveFromCache(WoodenPallet)
	ServerObjectsModule:ObjectProcess("Respawn", WoodenPallet)
	ServerObjectsModule:ObjectProcess("SpawnScrap", WoodenPallet)
	--DebrisService:AddItem(WoodenPallet, 1)
	DebrisModule:AddItem(WoodenPallet, .1)
end

-- DIRECT
function TagModule.Initialise(NilParam, WoodenPallet)
	return Initialise(WoodenPallet)
end

function TagModule.End(NilParam, WoodenPallet)
	return End(WoodenPallet)
end

return TagModule