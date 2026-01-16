local VehicleServerModule = {}

-- Dirs
local ModelRoot = script.Parent.Parent

-- EXT
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Modules
local ServerWeaponsModule = require(ServerModulesFolder["Weapons"])
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Elements
-- REMOTES
local TiltReplicateRemote = ClientServerRemotesFolder["TiltReplicateRemote"]

-- MODELS
local GunModel = UtilitiesModule:WaitForChildTimed(ModelRoot, "Gun")

-- PARTS
local CharacterPlaceholderPart = UtilitiesModule:WaitForChildTimed(ModelRoot, "CharacterPlaceholder")
local BasePart = GunModel["Base"]

-- WELDS
local RootWeld = BasePart["Root"]

-- CORE
local OriginalC0 = RootWeld.C0
local OriginalC1 = RootWeld.C1
local Player = nil
local Character = nil

local RequiredSubModules = {}

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function EndSubModules()
	-- Functions
	-- INIT
	for ModuleName, Module in pairs(RequiredSubModules) do
		local Success, Error = pcall(function()
			if Module.End ~= nil then
				return Module:End()
			end
		end)
		
		if not Success then
			DebugModule:Print(ModelRoot.Name.. " | ".. script.Name.. " | Module: ".. Module.Name.. " | Error: ".. tostring(Error))
		else
			RequiredSubModules[ModuleName] = nil
		end
	end
end

local function RunSubModules()
	-- Functions
	-- INIT
	RequiredSubModules = UtilitiesModule:RunSubModules(script, nil, VehicleServerModule)
end

local function Initialise()
	-- Functions
	-- INIT
	DebugModule:Print("Mounted Turret | Starting Initialise: ".. tick())
	
	local PlayerName = ModelRoot:GetAttributes()["Occupant"]
	Player = game.Players:FindFirstChild(PlayerName)
	
	if not Player then
		DebugModule:Print("Mounted Turret | ".. script.Name.. " | Player not found")
		return nil
	end	
	
	Character = UtilitiesModule:GetCharacter(Player, true)
	
	if not Character then
		DebugModule:Print("Mounted Turret | ".. script.Name.. " | Character not found")
		return nil
	end
	
	Character:SetPrimaryPartCFrame(CharacterPlaceholderPart.CFrame)
	--Character.PrimaryPart.Anchored = true
	
	RootWeld:SetAttribute("CFramePlayerToIgnore", PlayerName)
	
	RunSubModules()
	ModelRoot:SetAttribute("ServerLoaded", true)
	DebugModule:Print("Mounted Turret | Finished Initialise: ".. tick())
	CollectionService:AddTag(RootWeld, "CFrameUpdater")
end

local function End()
	-- Functions
	-- INIT
	DebugModule:Print(script.Name.. " | End | Unequipping Vehicle")
	
	CollectionService:RemoveTag(RootWeld, "CFrameUpdater")
	
	if Character then
		Character.PrimaryPart.Anchored = false
	end
	
	RootWeld.C0 = OriginalC0
	RootWeld.C1 = OriginalC1
	
	CollectionService:RemoveTag(ModelRoot, "MachineGunTurret")
	EndSubModules()
	ModelRoot:SetAttribute("ServerLoaded", false)
end

local function UpdateTilt(Player, RootWeldProperties)
	-- Functions
	-- INIT
	--RootWeld.C0 = RootWeldProperties.C0
	--RootWeld.C1 = RootWeldProperties.C1
	--TiltReplicateRemote:FireAllClients(Player, RootWeld, RootWeldProperties)
	RootWeld:SetAttribute("C0", RootWeldProperties.C0)
	RootWeld:SetAttribute("C1", RootWeldProperties.C1)
end

local function SpinUp(Player)
	-- Functions
	-- INIT
	if not table.find(CollectionService:GetTags(GunModel), "MachineGunTurret") then
		CollectionService:AddTag(ModelRoot, "MachineGunTurret")
	end
end

local function StopSpinning(Player)
	-- Functions
	-- INIT
	CollectionService:RemoveTag(ModelRoot, "MachineGunTurret")
end

local function Fire(Player, RaycastResult)
	-- Functions
	-- INIT
	if not table.find(CollectionService:GetTags(ModelRoot), "MachineGunTurret") then
		return nil
	end
	
	return ServerWeaponsModule:FireWeapon(Player, ModelRoot, RaycastResult, true, "Machine Gun Turret")
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["UpdateTilt"] = UpdateTilt,
	["SpinUp"] = SpinUp,
	["StopSpinning"] = StopSpinning,
	["Fire"] = Fire
}

-- DIRECT
function VehicleServerModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

function VehicleServerModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function VehicleServerModule.End()
	return End()
end

return VehicleServerModule