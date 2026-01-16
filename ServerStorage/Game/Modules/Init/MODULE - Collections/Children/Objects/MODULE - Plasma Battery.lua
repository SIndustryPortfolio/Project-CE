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
local DebugModule = require(SharedModulesFolder["Debug"])
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

local function Initialise(PlasmaBattery)
	-- Functions
	-- INIT
	--DebugModule:Print"Plasma Battery Info: ".. tostring(CollectionsInfoModule:GetCollectionItemInfo(script.Name):GetInfo("Properties")))
	
	ObjectsModule:CreateInstancesFromDict(PlasmaBattery, CollectionsInfoModule:GetCollectionItemInfo(script.Name):GetInfo("Properties"))
	
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(PlasmaBattery, "Humanoid")
	
	-- DIRECT
	local Connection1 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health <= 0 then
			TagModule:End(PlasmaBattery)
		end
	end)
	
	-- INIT
	AddToCache(PlasmaBattery, {Connection1})
end

local function End(PlasmaBattery)	
	-- Functions
	-- INIT
	RemoveFromCache(PlasmaBattery)
	task.wait(.3)
	ServerObjectsModule:ObjectProcess("Respawn", PlasmaBattery)
	ServerObjectsModule:ObjectProcess("Explosion", PlasmaBattery, true)
	--DebrisService:AddItem(PlasmaBattery, 1)
	DebrisModule:AddItem(PlasmaBattery, 1)
end

-- DIRECT
function TagModule.Initialise(NilParam, PlasmaBattery)
	return Initialise(PlasmaBattery)
end

function TagModule.End(NilParam, PlasmaBattery)
	return End(PlasmaBattery)
end

return TagModule