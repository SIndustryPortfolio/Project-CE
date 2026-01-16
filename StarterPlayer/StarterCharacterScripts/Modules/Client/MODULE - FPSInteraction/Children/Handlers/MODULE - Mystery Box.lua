local MysteryBoxModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent.Parent.Parent

-- EXT
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ClientRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["Client"]["Remotes"]

-- Client
local Player = game.Players.LocalPlayer

-- Elements
-- FOLDERS
local CharacterClientServerRemotesFolder = Character["Remotes"]["ClientServer"]["Remotes"]

-- Remotes
local CharacterProcessRemote = CharacterClientServerRemotesFolder["CharacterProcess"]
local InterfaceRemote = ClientRemotesFolder["Interface"]

-- Info Modules
local KeybindsInfoModule = require(InfoModulesFolder["Keybinds"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local InterfacesModule = require(ModulesFolder["Interfaces"])
local SettingsModule = require(ModulesFolder["Settings"])
local DebugModule = require(ModulesFolder["Debug"])
local ShortcutsModule = require(ModulesFolder["Shortcuts"])
--
local FPSHandlerModule = require(UtilitiesModule:GetPlayerCharacterModule(Player, "Client", "FPSHandler"))

local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud", true)

-- CORE
local TouchingMysteryBox = nil
local Connections = {}

local Billborads = {}

-- Services

-- Functions
-- MECHANICS
local function GetMysteryBoxModelFromCharacter(WeaponName)
	-- Functions
	-- INIT
	local FoundServerWeapon = Character:FindFirstChild(WeaponName)
	
	if not FoundServerWeapon then
		FoundServerWeapon = Player:WaitForChild("Backpack"):FindFirstChild(WeaponName)
	end
	
	return FoundServerWeapon
end

local function DeleteCache(MysteryBoxModel)
	-- Functions
	-- INIT
	if Billborads[MysteryBoxModel] then
		--Billborads[MysteryBoxModel]:Destroy()
		InterfacesModule:ClosePage(Billborads[MysteryBoxModel])
	end
	
	Billborads[MysteryBoxModel] = nil
end

local function DeleteAllCache()
	-- Functions
	-- INIT
	for MysteryBoxModel, Ui in pairs(Billborads) do
		DeleteCache(MysteryBoxModel)
	end
end

local function Initialise(MysteryBoxModel)
	-- Functions
	-- INIT
	--DebugModule:Print("Weapons | Touched Weapon Model: ".. tostring(MysteryBoxModel))
	
	if MysteryBoxModel == TouchingMysteryBox then
		return nil
	end
	
	local TeamInfo = ShortcutsModule:GetPlayerTeamInfo(Player)
	
	if TeamInfo and TeamInfo["PickupWeapons"] == false then
		TouchingMysteryBox = nil
		
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		return nil
	end
	
	
	if not MysteryBoxModel or MysteryBoxModel == "nil" or typeof(MysteryBoxModel) == "table" then
		TouchingMysteryBox = nil
		
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		--DeleteCache(MysteryBoxModel)
		DeleteAllCache()
		
		return nil
	end
	
	if TouchingMysteryBox ~= MysteryBoxModel or not TouchingMysteryBox:GetAttributes()["Opened"] then
		TouchingMysteryBox = nil
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		--DeleteCache(MysteryBoxModel)
		DeleteAllCache()
	end
		
	----DebugModule:Print"Touched Weapon: ".. tostring(MysteryBoxModel.Name))
	local CharacterWeapons = {Character:GetAttribute("Primary"), Character:GetAttribute("Secondary")}
	if (TouchingMysteryBox ~= MysteryBoxModel) and HudGuiModule and MysteryBoxModel and not MysteryBoxModel:GetAttributes()["Opened"] then
		--DebugModule:Print("Hinting to switch weapon: ".. tostring(MysteryBoxModel.Name))
		HudGuiModule:HudProcess("CollectionSwitch", "AddHint", MysteryBoxModel.Name)
	end
	
	if not MysteryBoxModel:GetAttributes()["Opened"] then
		TouchingMysteryBox = MysteryBoxModel
	end
end

local function GarbageCollect()
	-- Functions
	-- INIT
	
	Character = nil
	--
	ModulesFolder = nil
	InfoModulesFolder = nil
	ClientRemotesFolder = nil
	--
	CharacterClientServerRemotesFolder = nil
	--
	CharacterProcessRemote = nil
	InterfaceRemote = nil
	--
	KeybindsInfoModule = nil
	--
	UtilitiesModule = nil
	InterfacesModule = nil
	DebugModule = nil
	HudGuiModule = nil
	--
	TouchingMysteryBox = nil
	Connections = nil
	
end

local function End()
	-- Functions
	-- INIT
	if HudGuiModule then
		HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
	end
	
	UtilitiesModule:DisconnectConnections(Connections)
end

local function FireCollectionSwitch()
	-- Functions
	-- INIT
	
	--[[local TeamInfo = ShortcutsModule:GetPlayerTeamInfo(Player)

	if TeamInfo and TeamInfo["PickupWeapons"] == false then
		TouchingMysteryBox = nil

		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint")
		end

		return nil
	end]]
	
	if TouchingMysteryBox == nil then
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | FireCollectionSwitch | TouchingMysteryBox is nil")
		--DebugModule:Print("FPSInteraction | Weapons | Not touching weapon!")
		return nil
	end

	--DebugModule:Print("FPSInteraction | Weapons | Firing Server pickup weapon!")
	CharacterProcessRemote:FireServer("Collections", "Mystery Box", "Purchase", TouchingMysteryBox)
	if HudGuiModule then
		HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
	end

	--DeleteCache(TouchingMysteryBox)
	DeleteAllCache()
end

-- DIRECT
function MysteryBoxModule.GetTouching()
	return TouchingMysteryBox
end

function MysteryBoxModule.Switch()
	return FireCollectionSwitch()
end

function MysteryBoxModule.Initialise(NilParam, Child)
	if not Child then
		--DebugModule:Print("FPSInteraction | Weapons | Touched | Dropping nil")
		return nil
	end
	
	Initialise(Child)
end

function MysteryBoxModule.SetTouching(NilParam, NewValue)
	TouchingMysteryBox = NewValue
	
	if NewValue == nil then
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		--DeleteCache(TouchingMysteryBox)
		DeleteAllCache()
	end
end

function MysteryBoxModule.GarbageCollect()
	GarbageCollect()
end

function MysteryBoxModule.End()
	End()
end

-- INIT
--[[local Connection1 = UserInputService.InputBegan:Connect(function(InputObject, GameProcessedEvent)
	if GameProcessedEvent then
		DebugModule:Print(script.Name.. " | Game processed Event")
		return nil
	end
	
	if table.find(KeybindsInfoModule:GetKeybindInfo("Interact"), InputObject.KeyCode) ~= nil then
		return FireCollectionSwitch()
	end
end)]]

local Connection2 = InterfaceRemote.Event:Connect(function(ActionName)
	if ActionName == "CollectionSwitch" then
		--[[if TouchingMysteryBox then
			CharacterProcessRemote:FireServer("PickupWeapon", TouchingMysteryBox)
		end]]
		return FireCollectionSwitch()
	end
end)


-- CONNECTIONS
--table.insert(Connections, Connection1)
table.insert(Connections, Connection2)

return MysteryBoxModule