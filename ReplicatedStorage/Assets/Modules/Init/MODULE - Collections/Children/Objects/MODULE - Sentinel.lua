local TagModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local ObjectsInfoModule = require(InfoModulesFolder["Objects"])

-- Modules
local SoundsModule = require(ModulesFolder["Sounds"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])
local ObjectsModule = require(ModulesFolder["Objects"])

-- CORE
local ObjectInfo = ObjectsInfoModule:GetObjectInfo(script.Name)
local Connections = {}

local ReferenceToObject = {}

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

local function SpawnSentinel(Sentinel)
	-- Functions
	-- INIT
	local SentinelFolder = ObjectsModule:GetObject("Objects", "Sentinel")
	local SentinelModel = SentinelFolder:WaitForChild("Model")["Sentinel"]:Clone()
	SentinelModel:SetPrimaryPartCFrame(Sentinel.CFrame)
	SentinelModel.Parent = workspace["Dump"]["Misc"]
	
	ReferenceToObject[Sentinel] = SentinelModel
	
	return ObjectsModule:LoadObject(SentinelModel, Sentinel)
end

local function Initialise(Sentinel)
	-- INIT
	SpawnSentinel(Sentinel)
end

function End(Sentinel)
	-- Functions
	-- INIT
	local SentinelModel = ReferenceToObject[Sentinel]
	
	if SentinelModel then
		ObjectsModule:UnloadObject(SentinelModel)
		ReferenceToObject[Sentinel] = nil
	end
	
	RemoveFromCache(Sentinel)
end

-- DIRECT
function TagModule.Initialise(NilParam, Sentinel)
	return Initialise(Sentinel)
end

function TagModule.End(NilParam, Sentinel)
	return End(Sentinel)
end

return TagModule