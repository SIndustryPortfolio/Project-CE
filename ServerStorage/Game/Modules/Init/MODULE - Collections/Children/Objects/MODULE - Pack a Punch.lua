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

local function Initialise(PackAPunch)
	-- Functions
	-- INIT
	--ObjectsModule:CreateInstancesFromDict(PackAPunch, CollectionsInfoModule:GetCollectionItemInfo(script.Name):GetInfo("Properties"))
	
	-- INIT
end

local function End(PackAPunch)	
	-- Functions
	-- INIT
	RemoveFromCache(PackAPunch)
	task.wait(.3)
	ServerObjectsModule:ObjectProcess("Respawn", PackAPunch)
	DebrisModule:AddItem(PackAPunch)
end

local function OpenCycle(Player, PackAPunch)
	-- Functions
	-- INIT
	
end

local function Purchase(Player, PackAPunch)
	-- CORE
	local CollectionInfoModule = CollectionsInfoModule:GetCollectionItemInfo(PackAPunch.Name)
	local FoundPlayerLobbyValue = SharedGameLobbyFolder:FindFirstChild(Player.Name)
	
	-- Functions
	-- INIT
	if PackAPunch:GetAttributes()["Working"] or not FoundPlayerLobbyValue then
		return nil
	end
	
	if FoundPlayerLobbyValue:GetAttributes()["Score"] < CollectionInfoModule:GetInfo("Price") then
		DebugModule:Print(script.Name.. " | Purchase failed | Insufficient funds | Player: ".. tostring(Player).. " | Player Score: ".. tostring(FoundPlayerLobbyValue:GetAttributes()["Score"]))
		return nil
	end
	
	FoundPlayerLobbyValue:SetAttribute("Score", FoundPlayerLobbyValue:GetAttribute("Score") - CollectionInfoModule:GetInfo("Price"))
	
	DebugModule:Print(script.Name.. " | Purchasing | Player: ".. tostring(Player))
	
	if not PackAPunch or not Player then
		DebugModule:Print(script.Name.. " | Purchase | Cannot purchase V")
		DebugModule:Print(script.Name.. " | PackAPunch: ".. tostring(PackAPunch))
		DebugModule:Print(script.Name.. " | Player: ".. tostring(Player))
		return nil
	end
	
	PackAPunch:SetAttribute("Occupant", Player.Name)
	PackAPunch:SetAttribute("Working", true)
	
	task.wait(1)
	local ReturnedModel = OpenCycle(Player, PackAPunch)
	
	if ReturnedModel and not ReturnedModel:GetAttributes()["Technology"] then
		DebrisModule:AddItem(ReturnedModel)
	end
	
	PackAPunch:SetAttribute("Occupant", "")
	PackAPunch:SetAttribute("CurrentWeapon", "")
	PackAPunch:SetAttribute("Working", false)
	
	ObjectsModule:ObjectProcess("Raycastable", PackAPunch)
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Purchase"] = Purchase
}

-- DIRECT
function TagModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

function TagModule.Initialise(NilParam, PackAPunch)
	return Initialise(PackAPunch)
end

function TagModule.End(NilParam, PackAPunch)
	return End(PackAPunch)
end

return TagModule