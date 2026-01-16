local DrinkMachineModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent.Parent.Parent

-- EXT
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local ClientRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["Client"]["Remotes"]

-- Client
local Player = game.Players.LocalPlayer

-- Elements
-- FOLDERS
local GameModeFolder = SharedGameFolder:FindFirstChild("GameMode")
local DrinksFolder = Character:WaitForChild("Drinks")
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
local TouchingDrinkMachine = nil
local Connections = {}

local Billborads = {}

-- Services

-- Functions
-- MECHANICS
local function DeleteCache(DrinkMachineModel)
	-- Functions
	-- INIT
	if Billborads[DrinkMachineModel] then
		--Billborads[DrinkMachineModel]:Destroy()
		InterfacesModule:ClosePage(Billborads[DrinkMachineModel])
	end
	
	Billborads[DrinkMachineModel] = nil
end

local function DeleteAllCache()
	-- Functions
	-- INIT
	for DrinkMachineModel, Ui in pairs(Billborads) do
		DeleteCache(DrinkMachineModel)
	end
end

local function Initialise(DrinkMachineModel)
	-- Functions
	-- INIT
	--DebugModule:Print("Weapons | Touched Weapon Model: ".. tostring(DrinkMachineModel))
	
	if DrinkMachineModel == TouchingDrinkMachine then
		return nil
	end
	
	local TeamInfo = ShortcutsModule:GetPlayerTeamInfo(Player)
	
	if TeamInfo and TeamInfo["PickupWeapons"] == false then
		TouchingDrinkMachine = nil
		
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		return nil
	end
	
	
	if not DrinkMachineModel or DrinkMachineModel == "nil" or typeof(DrinkMachineModel) == "table" then
		TouchingDrinkMachine = nil
		
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		--DeleteCache(DrinkMachineModel)
		DeleteAllCache()
		
		return nil
	end
	
	if TouchingDrinkMachine ~= DrinkMachineModel then
		TouchingDrinkMachine = nil
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		--DeleteCache(DrinkMachineModel)
		DeleteAllCache()
	end
	
	local CharacterAlreadyHas = DrinksFolder:FindFirstChild(DrinkMachineModel.Name)
	
	----DebugModule:Print"Touched Weapon: ".. tostring(DrinkMachineModel.Name))
	if (TouchingDrinkMachine ~= DrinkMachineModel) and HudGuiModule and not CharacterAlreadyHas then
		--DebugModule:Print("Hinting to switch weapon: ".. tostring(DrinkMachineModel.Name))
		if GameModeFolder:GetAttributes()["Power"] then
			HudGuiModule:HudProcess("CollectionSwitch", "AddHint", script.Name, DrinkMachineModel.Name)
		else
			HudGuiModule:HudProcess("CollectionSwitch", "AddHint", script.Name, DrinkMachineModel.Name, "Turn the power on!")
		end
	end
	
	if not CharacterAlreadyHas then
		TouchingDrinkMachine = DrinkMachineModel
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
	TouchingDrinkMachine = nil
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
		TouchingDrinkMachine = nil

		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint")
		end

		return nil
	end]]
	
	if TouchingDrinkMachine == nil then
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | FireCollectionSwitch | TouchingDrinkMachine is nil")
		--DebugModule:Print("FPSInteraction | Weapons | Not touching weapon!")
		return nil
	end

	--DebugModule:Print("FPSInteraction | Weapons | Firing Server pickup weapon!")
	CharacterProcessRemote:FireServer("Collections", script.Name, "Purchase", TouchingDrinkMachine)
	if HudGuiModule then
		HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
	end

	--DeleteCache(TouchingDrinkMachine)
	DeleteAllCache()
end

-- DIRECT
function DrinkMachineModule.Initialise(NilParam, Child)
	if not Child then
		--DebugModule:Print("FPSInteraction | Weapons | Touched | Dropping nil")
		return nil
	end
	
	Initialise(Child)
end

function DrinkMachineModule.GetTouching()
	return TouchingDrinkMachine
end

function DrinkMachineModule.Switch()
	return FireCollectionSwitch()
end

function DrinkMachineModule.SetTouching(NilParam, NewValue)
	TouchingDrinkMachine = NewValue
	
	if NewValue == nil then
		if HudGuiModule then
			HudGuiModule:HudProcess("CollectionSwitch", "StopHint", script.Name)
		end
		
		--DeleteCache(TouchingDrinkMachine)
		DeleteAllCache()
	end
end

function DrinkMachineModule.GarbageCollect()
	GarbageCollect()
end

function DrinkMachineModule.End()
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
		--[[if TouchingDrinkMachine then
			CharacterProcessRemote:FireServer("PickupWeapon", TouchingDrinkMachine)
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
table.insert(Connections, Connection2)
table.insert(Connections, Connection3)

return DrinkMachineModule