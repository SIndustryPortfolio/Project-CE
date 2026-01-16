local TagModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Info Modules
local CollectionsInfoModule = require(SharedInfoModulesFolder["Collections"])
local ObjectsInfoModule = require(SharedInfoModulesFolder["Objects"])
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])
local RoundTypesInfoModule = require(SharedInfoModulesFolder["RoundTypes"])

-- Modules
local WeaponsModule = require(ServerModulesFolder["Weapons"])
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

local function Initialise(AmmoContainer)
	-- Functions
	-- INIT
	--ObjectsModule:CreateInstancesFromDict(AmmoContainer, CollectionsInfoModule:GetCollectionItemInfo(script.Name):GetInfo("Properties"))
	
	-- INIT
end

local function End(AmmoContainer)	
	-- Functions
	-- INIT
	RemoveFromCache(AmmoContainer)
	task.wait(.3)
	ServerObjectsModule:ObjectProcess("Respawn", AmmoContainer)
	DebrisModule:AddItem(AmmoContainer)
end

local function GetWeaponModelFromCharacter(Character)
	-- Functions
	-- INIT
	for i, Model in pairs(Character:GetChildren()) do
		if Model:GetAttributes()["Weapon"] and Model.Name ~= "UnequipWeapon" then
			return Model
		end
	end
end

local function AddAmmo(Player, AmmoContainerModel)
	-- Functions
	-- INIT
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if not Character then
		return nil
	end
	
	local CharacterWeaponModel = GetWeaponModelFromCharacter(Character)
	local BackpackWeaponModel = Player:WaitForChild("Backpack"):FindFirstChildOfClass("Model")
	
	local Weapons = {CharacterWeaponModel, BackpackWeaponModel}
	
	for i, WeaponModel in pairs(Weapons) do
		
		if not WeaponModel then
			continue
		end
		
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | Weapon Name: ".. tostring(WeaponModel))
		
		local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponModel.Name)
			
		if not table.find(RoundTypesInfoModule:GetTypesOfRound("Round"), WeaponInfo["RoundType"]) then
			return nil
		end
			
		local TotalMaxAmmo = WeaponModel:GetAttribute("MaxMags") * WeaponModel:GetAttribute("MaxRoundsInMag")
		WeaponsModule:WeaponProcess("AddAmmo", WeaponModel, TotalMaxAmmo)
	end
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["AddAmmo"] = AddAmmo
}

-- DIRECT
function TagModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

function TagModule.Initialise(NilParam, AmmoContainer)
	return Initialise(AmmoContainer)
end

function TagModule.End(NilParam, AmmoContainer)
	return End(AmmoContainer)
end

return TagModule