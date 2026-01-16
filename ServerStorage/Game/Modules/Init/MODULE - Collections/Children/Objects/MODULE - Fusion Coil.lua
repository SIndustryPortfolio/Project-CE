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

local function Initialise(FusionCoil)
	-- Functions
	-- INIT
	ObjectsModule:CreateInstancesFromDict(FusionCoil, CollectionsInfoModule:GetCollectionItemInfo(script.Name):GetInfo("Properties"))
	
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(FusionCoil, "Humanoid")
	
	-- DIRECT
	local Connection1 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health <= 0 then
			TagModule:End(FusionCoil)
		end
	end)
	
	-- INIT
	AddToCache(FusionCoil, {Connection1})
end

local function End(FusionCoil)	
	-- Functions
	-- INIT
	RemoveFromCache(FusionCoil)
	task.wait(.3)
	ServerObjectsModule:ObjectProcess("Respawn", FusionCoil)
	ServerObjectsModule:ObjectProcess("Explosion", FusionCoil, true)
	--DebrisService:AddItem(FusionCoil, 1)
	DebrisModule:AddItem(FusionCoil, 1)
end

-- DIRECT
function TagModule.Initialise(NilParam, FusionCoil)
	return Initialise(FusionCoil)
end

function TagModule.End(NilParam, FusionCoil)
	return End(FusionCoil)
end

return TagModule