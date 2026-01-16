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

local function Initialise(GrenadeModel)
	-- CORE
	local ObjectInfo = ObjectsInfoModule:GetObjectInfo(script.Name)
	local OriginalClone = GrenadeModel:Clone()
	local OldParent = GrenadeModel.Parent
	
	-- Functions
	-- DIRECT
	repeat
		task.wait()
	until GrenadeModel:IsDescendantOf(workspace:WaitForChild("Dump"))
	
	--DebugModule:Print("Weapons Collection | Initialising weapon: ".. tostring(WeaponModel))
	
	local Connection1 = nil
	
	Connection1 = GrenadeModel:GetPropertyChangedSignal("Parent"):Connect(function()
		UtilitiesModule:DisconnectConnections({Connection1})
		End(GrenadeModel)
		
		
		if OldParent and OriginalClone and ObjectInfo and not GrenadeModel:GetAttributes()["NoneRespawnable"] then
			task.wait(ObjectInfo["RespawnTime"])
			
			OriginalClone.Parent = OldParent
			Initialise(OriginalClone)
		end
	end)
	
	-- Connections
end

function End(GrenadeModel)
	AddToCache(GrenadeModel, {Connection1})
	-- Functions
	-- INIT
	RemoveFromCache(GrenadeModel)
end

-- DIRECT
function TagModule.Initialise(NilParam, GrenadeModel)
	return Initialise(GrenadeModel)
end

function TagModule.End(NilParam, GrenadeModel)
	return End(GrenadeModel)
end

return TagModule