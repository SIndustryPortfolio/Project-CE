local TagModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedPartsServerWeaponsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
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
local CharacterActionsModule = require(ServerModulesFolder["CharacterActions"])

local Connections = {}
local Drinking = {}

-- Services
--local DebrisService = game:GetService("Debris")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

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

local function Initialise(DrinkMachine)
	-- Functions
	-- INIT
	--ObjectsModule:CreateInstancesFromDict(DrinkMachine, CollectionsInfoModule:GetCollectionItemInfo(script.Name):GetInfo("Properties"))
	
	-- INIT
end

local function End(DrinkMachine)	
	
end

local function Purchase(Player, DrinkMachine)
	-- CORE
	local SharedGameModeFolder = SharedGameFolder:FindFirstChild("GameMode")
	local CollectionInfoModule = CollectionsInfoModule:GetCollectionItemInfo(DrinkMachine.Name)
	local FoundPlayerLobbyValue = SharedGameLobbyFolder:FindFirstChild(Player.Name)
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	-- Functions
	-- INIT
	if DrinkMachine:GetAttributes()["Opened"] or not FoundPlayerLobbyValue or not Character or Drinking[Player] or not SharedGameModeFolder or not SharedGameModeFolder:GetAttributes()["Power"] then
		return nil
	end
	
	Drinking[Player] = true
	
	local CharacterDrinksFolder = Character:FindFirstChild("Drinks")
	
	if table.find(CollectionService:GetTags(Character), "Drinking") or not CharacterDrinksFolder or CharacterDrinksFolder:FindFirstChild(DrinkMachine.Name) then
		Drinking[Player] = nil
		return nil
	end	
	
	if FoundPlayerLobbyValue:GetAttributes()["Score"] < CollectionInfoModule:GetInfo("Price") then
		Drinking[Player] = nil
		DebugModule:Print(script.Name.. " | Purchase failed | Insufficient funds | Player: ".. tostring(Player).. " | Player Score: ".. tostring(FoundPlayerLobbyValue:GetAttributes()["Score"]))
		return nil
	end
	
	FoundPlayerLobbyValue:SetAttribute("Score", FoundPlayerLobbyValue:GetAttribute("Score") - CollectionInfoModule:GetInfo("Price"))
	
	DebugModule:Print(script.Name.. " | Purchasing | Player: ".. tostring(Player))
	
	if not DrinkMachine or not Player then
		Drinking[Player] = nil
		DebugModule:Print(script.Name.. " | Purchase | Cannot purchase V")
		DebugModule:Print(script.Name.. " | DrinkMachine: ".. tostring(DrinkMachine))
		DebugModule:Print(script.Name.. " | Player: ".. tostring(Player))
		return nil
	end
	
	CollectionService:AddTag(Character, "Drinking")
	local Success, Error = pcall(function()
		return CharacterActionsModule:ClientRequest(Player, "DrinkPerk", DrinkMachine)
	end)
	Drinking[Player] = nil
	
	DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | Purchase | Error: ".. tostring(Error))
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

function TagModule.Initialise(NilParam, DrinkMachine)
	return Initialise(DrinkMachine)
end

function TagModule.End(NilParam, DrinkMachine)
	return End(DrinkMachine)
end

return TagModule