local GrenadesModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent.Parent.Parent

-- Client
local Player = game.Players.LocalPlayer

-- EXT
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Elements
-- FOLDERS
local CharacterClientServerRemotesFolder = Character["Remotes"]["ClientServer"]["Remotes"]

-- Remotes
local CharacterProcessRemote = CharacterClientServerRemotesFolder["CharacterProcess"]

-- Info Modules
local KeybindsInfoModule = require(InfoModulesFolder["Keybinds"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local InterfacesModule = require(ModulesFolder["Interfaces"])
local DebugModule = require(ModulesFolder["Debug"])

local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")

-- CORE
local Connections = {}

-- Services

-- Functions
-- MECHANICS
local function Initialise(GrenadeModel)
	-- Functions
	-- INIT
	--DebugModule:Print(script.Parent.Name.. " | Picking up grenade | Name: ".. tostring(GrenadeModel.Name).. "Grenades")
	
	if not Character then
		--DebugModule:Print(script.Parent.Parent.Name.. " | ".. script.Name.. " | Player: ".. tostring(Player).. " | GrenadeModel: ".. tostring(GrenadeModel).. " | Error: No Character")
		return nil
	end
	
	if tonumber(Character:GetAttributes()[tostring(GrenadeModel.Name).. "Grenades"]) < 4 then
		CharacterProcessRemote:FireServer("PickupGrenade", GrenadeModel)
	end
end

local function GarbageCollect()
	-- Functions
	-- INIT
	Character = nil
	---
	ModulesFolder = nil
	InfoModulesFolder = nil
	--
	CharacterClientServerRemotesFolder = nil
	--
	CharacterProcessRemote = nil
	--
	KeybindsInfoModule = nil
	--
	UtilitiesModule = nil
	InterfacesModule = nil
	--DebugModule = nil

	HudGuiModule = nil
	--
	Connections = nil
	--
	--UserInputService = nil
	
end

local function End()
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections)
end

-- DIRECT
function GrenadesModule.Initialise(NilParam, Child)
	if not Child then
		DebugModule:Print("FpsInteraction | Grenades | Touched | Child is nil")
		--DebugModule:Print("FPSInteraction | Weapons | Touched | Dropping nil")
		return nil
	end
	
	return Initialise(Child)
end

function GrenadesModule.GarbageCollect()
	GarbageCollect()
end

function GrenadesModule.End()
	End()
end

return GrenadesModule