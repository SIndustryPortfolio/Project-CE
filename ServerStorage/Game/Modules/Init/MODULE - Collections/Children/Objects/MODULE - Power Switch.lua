local TagModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedPartsServerWeaponsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]
local SharedGameLobbyFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Lobby"]

-- Info Modules
local CollectionsInfoModule = require(SharedInfoModulesFolder["Collections"])
local ObjectsInfoModule = require(SharedInfoModulesFolder["Objects"])
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])

-- Modules
local ServerObjectsModule = require(ServerModulesFolder["Objects"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local DebugModule = require(SharedModulesFolder["Debug"])
local PhysicsModule = require(SharedModulesFolder["Physics"])
local MapLoaderModule = require(ServerModulesFolder["Maps"]["MapLoader"])

local Connections = {}

-- Services
--local DebrisService = game:GetService("Debris")
local RunService = game:GetService("RunService")

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

local function Initialise(PowerSwitch)
	-- Functions
	-- INIT
	--ObjectsModule:CreateInstancesFromDict(PowerSwitch, CollectionsInfoModule:GetCollectionItemInfo(script.Name):GetInfo("Properties"))
	
	-- INIT
end

local function End(PowerSwitch)	
	-- Functions
	-- INIT
	
end


local function PowerOn(Player, PowerSwitchModel)
	-- Functions
	-- INIT
	PowerSwitchModel:SetAttribute("On", true)
	
	local FoundGameModeFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game"):FindFirstChild("GameMode")
	
	if not FoundGameModeFolder then
		return nil
	end
	
	FoundGameModeFolder:SetAttribute("Power", true)
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["PowerOn"] = PowerOn
}

-- DIRECT
function TagModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

function TagModule.Initialise(NilParam, PowerSwitch)
	return Initialise(PowerSwitch)
end

function TagModule.End(NilParam, PowerSwitch)
	return End(PowerSwitch)
end

return TagModule