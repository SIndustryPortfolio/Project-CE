local PowerSwitchModule = {}

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
local TouchingPowerSwitch = nil
local Connections = {}

local Billborads = {}

-- Services

-- Functions
-- MECHANICS
local function DeleteCache(PowerSwitchModel)
	-- Functions
	-- INIT
	if Billborads[PowerSwitchModel] then
		--Billborads[PowerSwitchModel]:Destroy()
		InterfacesModule:ClosePage(Billborads[PowerSwitchModel])
	end
	
	Billborads[PowerSwitchModel] = nil
end

local function DeleteAllCache()
	-- Functions
	-- INIT
	for PowerSwitchModel, Ui in pairs(Billborads) do
		DeleteCache(PowerSwitchModel)
	end
end

local function Initialise(PowerSwitchModel)
	-- Functions
	-- INIT
	--DebugModule:Print("Weapons | Touched Weapon Model: ".. tostring(PowerSwitchModel))
	
	if PowerSwitchModel == TouchingPowerSwitch then
		return nil
	end
	
	local TeamInfo = ShortcutsModule:GetPlayerTeamInfo(Player)
	
	if TeamInfo and TeamInfo["PickupWeapons"] == false then
		TouchingPowerSwitch = nil
		
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		return nil
	end
	
	
	if not PowerSwitchModel or PowerSwitchModel == "nil" or typeof(PowerSwitchModel) == "table" then
		TouchingPowerSwitch = nil
		
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		--DeleteCache(PowerSwitchModel)
		DeleteAllCache()
		
		return nil
	end
	
	if TouchingPowerSwitch ~= PowerSwitchModel then
		TouchingPowerSwitch = nil
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		--DeleteCache(PowerSwitchModel)
		DeleteAllCache()
	end
		
	----DebugModule:Print"Touched Weapon: ".. tostring(PowerSwitchModel.Name))
	if (TouchingPowerSwitch ~= PowerSwitchModel) and HudGuiModule and not PowerSwitchModel:GetAttributes()["On"] then
		--DebugModule:Print("Hinting to switch weapon: ".. tostring(PowerSwitchModel.Name))
		HudGuiModule:HudProcess("CollectionSwitch", "AddHint", script.Name, PowerSwitchModel.Name)
	end
	
	if not PowerSwitchModel:GetAttributes()["On"] then
		TouchingPowerSwitch = PowerSwitchModel
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
	TouchingPowerSwitch = nil
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
		TouchingPowerSwitch = nil

		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint")
		end

		return nil
	end]]
	
	if TouchingPowerSwitch == nil then
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | FireCollectionSwitch | TouchingPowerSwitch is nil")
		--DebugModule:Print("FPSInteraction | Weapons | Not touching weapon!")
		return nil
	end

	--DebugModule:Print("FPSInteraction | Weapons | Firing Server pickup weapon!")
	CharacterProcessRemote:FireServer("Collections", script.Name, "PowerOn", TouchingPowerSwitch)
	if HudGuiModule then
		HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
	end

	--DeleteCache(TouchingPowerSwitch)
	DeleteAllCache()
end

-- DIRECT
function PowerSwitchModule.GetTouching()
	return TouchingPowerSwitch
end

function PowerSwitchModule.Switch()
	return FireCollectionSwitch()
end

function PowerSwitchModule.Initialise(NilParam, Child)
	if not Child then
		--DebugModule:Print("FPSInteraction | Weapons | Touched | Dropping nil")
		return nil
	end
	
	Initialise(Child)
end

function PowerSwitchModule.SetTouching(NilParam, NewValue)
	TouchingPowerSwitch = NewValue
	
	if NewValue == nil then
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		--DeleteCache(TouchingPowerSwitch)
		DeleteAllCache()
	end
end

function PowerSwitchModule.GarbageCollect()
	GarbageCollect()
end

function PowerSwitchModule.End()
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
		--[[if TouchingPowerSwitch then
			CharacterProcessRemote:FireServer("PickupWeapon", TouchingPowerSwitch)
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

return PowerSwitchModule