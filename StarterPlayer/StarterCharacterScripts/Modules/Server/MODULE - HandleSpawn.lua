local HandleSpawnModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent

-- EXT
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Elements
-- PARTS
local HumanoidRootPart = Character.PrimaryPart

-- Modules
local MapsModule = require(ServerModulesFolder["Maps"])
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ObjectsModule = require(SharedModulesFolder["Objects"])

-- CORE
local Player = game.Players:GetPlayerFromCharacter(Character)

-- Services
local PhysicsService = game:GetService("PhysicsService")

-- Functions
-- MECHANICS
local function Initialise()
	-- Functions
	-- INIT
	----DebugModule:Print"Character Loading!")
	--DebugModule:Print"Handle Spawn phase 1")
	
	local CharacterRequestSignal = UtilitiesModule:GetPlayerCharacterSignal(Player, "CharacterRequest")
	
	if CharacterRequestSignal then
		task.wait(1)
		--DebugModule:Print"Handle Spawn phase 2")
		CharacterRequestSignal:InvokeClient(Player, "HasLoaded")
	end
	
	ObjectsModule:ObjectProcess("SetCollisionGroup", Character, tostring(Player:GetAttributes()["CollisionGroup"]).. "Characters")

	----DebugModule:Print"Character Loaded!")
	--DebugModule:Print"Handle Spawn phase 3")
	MapsModule:HandleSpawn(Character)
	HumanoidRootPart.Anchored = false
	
	for i, Part in pairs(Character:GetDescendants()) do
		if Part:IsA("BasePart") then
			Part:SetNetworkOwner(Player)
		end
	end
end

local function GarbageCollect()
	-- Functions
	-- INIT
	Character = nil
	--
	SharedModulesFolder = nil
	ServerModulesFolder = nil
	--
	HumanoidRootPart = nil
	--
	MapsModule = nil
	DebugModule = nil
	UtilitiesModule = nil
	--
	Player = nil
	
end

-- DIRECT
function HandleSpawnModule.Initialise()
	Initialise()
end

function HandleSpawnModule.GarbageCollect()
	GarbageCollect()
end

return HandleSpawnModule