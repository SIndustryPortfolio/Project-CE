local TeleporterModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent.Parent.Parent

-- EXT
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Elements
-- FOLDERS
local CharacterClientServerRemotesFolder = Character["Remotes"]["ClientServer"]["Remotes"]

-- Remotes
local CharacterProcessRemote = CharacterClientServerRemotesFolder["CharacterProcess"]

-- Info Modules
local ObjectsInfoModule = require(InfoModulesFolder["Objects"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function Initialise(Teleporter)
	if not Teleporter or typeof(Teleporter) ~= "Instance" then
		return nil
	end
		
	-- CORE
	local PrimaryPart = UtilitiesModule:GetPartToShift(Teleporter)
	local ObjectInfo = ObjectsInfoModule:GetObjectInfo(script.Name)
	local HumanoidRootPart = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")
	
	-- Functions
	-- INIT
	if not ObjectInfo then
		--DebugModule:Print"Cannot find Object Info for: ".. tostring(script.Name))
	end
	
	if not Teleporter:IsA("Model") then
		Teleporter = Teleporter:FindFirstAncestorOfClass("Model")
		
		--DebugModule:Print"Reassigning Teleporter: ".. tostring(Teleporter))
	end
	
	----DebugModule:Print"Touched Weapon: ".. tostring(WeaponModel.Name))
	--CharacterProcessRemote:FireServer("Collections", "Health Pack", "Heal", HealthPack)
	
	if PrimaryPart and HumanoidRootPart then
		if (PrimaryPart.Position - HumanoidRootPart.Position).Magnitude <= ObjectInfo["DistanceToTeleport"] then
			CharacterProcessRemote:FireServer("Collections", "Teleporter", "Teleport", Teleporter)
		end
	else
		--DebugModule:Print"Cannot find Teleporter primary part!")
	end
end

local function GarbageCollect()
	-- Functions
	-- INIT
	Character = nil
	--
	ModulesFolder = nil
	InfoModulesFolder = nil
	--
	CharacterClientServerRemotesFolder = nil
	--
	CharacterProcessRemote = nil
	--
	ObjectsInfoModule = nil
	--
	UtilitiesModule = nil
	DebugModule = nil
	
end

-- DIRECT
function TeleporterModule.Initialise(NilParam, Child)
	Initialise(Child)
end

function TeleporterModule.GarbageCollect()
	GarbageCollect()
end

return TeleporterModule