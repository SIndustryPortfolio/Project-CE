local PackAPunchModule = {}

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
local TouchingPackAPunch = nil
local Connections = {}

local Billborads = {}

-- Services

-- Functions
-- MECHANICS
local function DeleteCache(PackAPunchModel)
	-- Functions
	-- INIT
	if Billborads[PackAPunchModel] then
		--Billborads[PackAPunchModel]:Destroy()
		InterfacesModule:ClosePage(Billborads[PackAPunchModel])
	end
	
	Billborads[PackAPunchModel] = nil
end

local function DeleteAllCache()
	-- Functions
	-- INIT
	for PackAPunchModel, Ui in pairs(Billborads) do
		DeleteCache(PackAPunchModel)
	end
end

local function Initialise(PackAPunchModel)
	-- Functions
	-- INIT
	--DebugModule:Print("Weapons | Touched Weapon Model: ".. tostring(PackAPunchModel))
	
	if PackAPunchModel == TouchingPackAPunch then
		return nil
	end
	
	local TeamInfo = ShortcutsModule:GetPlayerTeamInfo(Player)
	
	if TeamInfo and TeamInfo["PickupWeapons"] == false then
		TouchingPackAPunch = nil
		
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		return nil
	end
	
	
	if not PackAPunchModel or PackAPunchModel == "nil" or typeof(PackAPunchModel) == "table" then
		TouchingPackAPunch = nil
		
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		--DeleteCache(PackAPunchModel)
		DeleteAllCache()
		
		return nil
	end
	
	if TouchingPackAPunch ~= PackAPunchModel or not TouchingPackAPunch:GetAttributes()["Opened"] then
		TouchingPackAPunch = nil
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		--DeleteCache(PackAPunchModel)
		DeleteAllCache()
	end
		
	----DebugModule:Print"Touched Weapon: ".. tostring(PackAPunchModel.Name))
	local CharacterWeapons = {Character:GetAttribute("Primary"), Character:GetAttribute("Secondary")}
	if (TouchingPackAPunch ~= PackAPunchModel) and HudGuiModule and PackAPunchModel then
		--DebugModule:Print("Hinting to switch weapon: ".. tostring(PackAPunchModel.Name))
		HudGuiModule:HudProcess("CollectionSwitch", "AddHint", PackAPunchModel.Name)
	end
	
	if not PackAPunchModel:GetAttributes()["Opened"] then
		TouchingPackAPunch = PackAPunchModel
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
	TouchingPackAPunch = nil
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
		TouchingPackAPunch = nil

		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint")
		end

		return nil
	end]]
	
	if TouchingPackAPunch == nil then
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | FireCollectionSwitch | TouchingPackAPunch is nil")
		--DebugModule:Print("FPSInteraction | Weapons | Not touching weapon!")
		return nil
	end

	--DebugModule:Print("FPSInteraction | Weapons | Firing Server pickup weapon!")
	CharacterProcessRemote:FireServer("Collections", "Mystery Box", "Purchase", TouchingPackAPunch)
	if HudGuiModule then
		HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
	end

	--DeleteCache(TouchingPackAPunch)
	DeleteAllCache()
end

-- DIRECT
function PackAPunchModule.GetTouching()
	return TouchingPackAPunch
end

function PackAPunchModule.Switch()
	return FireCollectionSwitch()
end

function PackAPunchModule.Initialise(NilParam, Child)
	if not Child then
		--DebugModule:Print("FPSInteraction | Weapons | Touched | Dropping nil")
		return nil
	end
	
	Initialise(Child)
end

function PackAPunchModule.SetTouching(NilParam, NewValue)
	TouchingPackAPunch = NewValue
	
	if NewValue == nil then
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		--DeleteCache(TouchingPackAPunch)
		DeleteAllCache()
	end
end

function PackAPunchModule.GarbageCollect()
	GarbageCollect()
end

function PackAPunchModule.End()
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
		--[[if TouchingPackAPunch then
			CharacterProcessRemote:FireServer("PickupWeapon", TouchingPackAPunch)
		end]]
		return FireCollectionSwitch()
	end
end)

local Connection3 = SettingsModule:GetSettingValueInstance("Game", "Hints"):GetPropertyChangedSignal("Value"):Connect(function()
	if not SettingsModule:GetSettingValue("Game", "Hints", true) then
		DeleteAllCache()
	end
end)

-- CONNECTIONS
--table.insert(Connections, Connection1)
table.insert(Connections, Connection2)
table.insert(Connections, Connection3)

return PackAPunchModule