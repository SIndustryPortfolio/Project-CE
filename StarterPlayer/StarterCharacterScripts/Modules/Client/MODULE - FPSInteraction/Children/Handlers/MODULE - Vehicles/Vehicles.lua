local VehiclesModule = {}

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
local HintsFolder = script["Hints"]
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
local FPSHandlerModule = require(UtilitiesModule:GetPlayerCharacterModule(Player, "Client", "FPSHandler"))

local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud", true)

-- CORE
local CharacterVehicleValue = ShortcutsModule:GetCharacterCoreValueInstance(Player, "Vehicle")
local TouchingVehicle = nil
local Connections = {}

local Billborads = {}

-- Services

-- Functions
-- MECHANICS
local function DeleteCache(VehicleModel)
	-- Functions
	-- INIT
	if Billborads[VehicleModel] then
		--Billborads[VehicleModel]:Destroy()
		InterfacesModule:ClosePage(Billborads[VehicleModel])
	end
	
	Billborads[VehicleModel] = nil
end

local function DeleteAllCache()
	-- Functions
	-- INIT
	for VehicleModel, Ui in pairs(Billborads) do
		DeleteCache(VehicleModel)
	end
end

local function Initialise(VehicleModel)
	-- Functions
	-- INIT
	--DebugModule:Print("Vehicles | Touched Vehicle Model: ".. tostring(VehicleModel))
	
	if not VehicleModel or VehicleModel == "nil" or typeof(VehicleModel) == "table" then
		TouchingVehicle = nil
		
		DebugModule:Print("FpsInteraction | ".. script.Name.. " | Stopping hint - Check 1")
		
		if HudGuiModule then
			HudGuiModule:HudProcess("VehicleSwitch", "StopHint")
		end
		
		--DeleteCache(VehicleModel)
		DeleteAllCache()
		
		return nil
	end
	
	if TouchingVehicle ~= VehicleModel then
		
		if DebugModule then
			DebugModule:Print("FpsInteraction | ".. script.Name.. " | Stopping hint - Check 2 | TouchingVehicle: ".. tostring(TouchingVehicle).. " | VehicleModel: ".. tostring(VehicleModel))
		end
		
		TouchingVehicle = nil
		if HudGuiModule then
			HudGuiModule:HudProcess("VehicleSwitch", "StopHint")
		end
		
		--DeleteCache(VehicleModel)
		DeleteAllCache()
	end
		
	----DebugModule:Print"Touched Vehicle: ".. tostring(VehicleModel.Name))
	
	if TouchingVehicle ~= VehicleModel and HudGuiModule and VehicleModel then
		if VehicleModel:GetAttributes()["Occupant"] ~= nil and VehicleModel:GetAttributes()["Occupant"] ~= "" then
			DebugModule:Print("FpsInteraction | ".. script.Name.. " | Stopping hint - Check 3")
			HudGuiModule:HudProcess("VehicleSwitch", "StopHint")
			return nil
		end
		
		--DebugModule:Print("Hinting to switch Vehicle: ".. tostring(VehicleModel.Name))
		DebugModule:Print("FpsInteraction | ".. script.Name.. " | Adding vehicle hint for: ".. tostring(VehicleModel))
		HudGuiModule:HudProcess("VehicleSwitch", "AddHint", VehicleModel.Name)
		
		--[[if not Billborads[VehicleModel] and SettingsModule:GetSettingValue("Game", "Hints", true) then
			Billborads[VehicleModel] = InterfacesModule:LoadBillboard(HintsFolder, "GunInteract", VehicleModel)
			Billborads[VehicleModel].AlwaysOnTop = true
			Billborads[VehicleModel].Adornee = VehicleModel
		end]]
	end
	
	TouchingVehicle = VehicleModel
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
	TouchingVehicle = nil
	Connections = nil
	
end

local function End()
	-- Functions
	-- INIT
	if HudGuiModule then
		HudGuiModule:HudProcess("VehicleSwitch", "StopHint")
	end
	
	for i, Ui in pairs(HintsFolder:GetChildren()) do
		InterfacesModule:ClosePage(Ui)
	end
	
	UtilitiesModule:DisconnectConnections(Connections)
end

local function EquipVehicle(VehicleModel)
	-- Functions
	-- INIT
	local VehicleClientModule = nil

	pcall(function()
		if VehicleModel:FindFirstChild("Core") and #VehicleModel:FindFirstChild("Core"):GetChildren() > 0 then
			VehicleClientModule = ShortcutsModule:GetVehicleModule(VehicleModel, "Client")
		end
	end)

	if FPSHandlerModule:GetIsLoaded() and not FPSHandlerModule:IsFPSLocked() and not FPSHandlerModule:IsSwitchingWeapon() and (not VehicleClientModule or not VehicleClientModule:GetInitialised()) and TouchingVehicle and not TouchingVehicle:GetAttributes()["ServerLoaded"] then
		DebugModule:Print("FPSInteraction | ".. script.Name.. " | Equip Firing Server!")
		CharacterProcessRemote:FireServer("SwitchVehicle", TouchingVehicle, "Occupant")
		if HudGuiModule then
			HudGuiModule:HudProcess("VehicleSwitch", "StopHint")
		end
	end	
end

local function UnequipVehicle(VehicleModel)
	-- Functions
	-- INIT
	local VehicleClientModule = nil

	if VehicleModel:FindFirstChild("Core") and #VehicleModel:FindFirstChild("Core"):GetChildren() > 0 then
		VehicleClientModule = ShortcutsModule:GetVehicleModule(VehicleModel, "Client")
	end

	if not FPSHandlerModule:GetIsLoaded() and CharacterVehicleValue.Value:GetAttributes()["ServerLoaded"] and (not VehicleClientModule or VehicleClientModule:GetInitialised()) then
		DebugModule:Print("FPSInteraction | ".. script.Name.. " | Unequip Firing Server!")
		CharacterProcessRemote:FireServer("UnequipVehicle")
	end
end

-- DIRECT
function VehiclesModule.Initialise(NilParam, Child)
	if not Child then
		--DebugModule:Print("FPSInteraction | Vehicles | Touched | Dropping nil")
		return nil
	end
	
	Initialise(Child)
end

function VehiclesModule.SetTouching(NilParam, NewValue) --SetTouchingVehicle(NilParam, NewValue)
	TouchingVehicle = NewValue
	
	if NewValue == nil then
		if HudGuiModule then
			HudGuiModule:HudProcess("VehicleSwitch", "StopHint")
		end
		
		--DeleteCache(TouchingVehicle)
		DeleteAllCache()
	end
end

function VehiclesModule.GetTouching()
	return TouchingVehicle
end

function VehiclesModule.Switch()
	if CharacterVehicleValue.Value then
		UnequipVehicle(CharacterVehicleValue.Value)
	else
		EquipVehicle(TouchingVehicle)
	end

	--DeleteCache(TouchingVehicle)
	DeleteAllCache()
end

function VehiclesModule.GarbageCollect()
	GarbageCollect()
end

function VehiclesModule.End()
	End()
end

-- INIT
--[[local Connection1 = UserInputService.InputBegan:Connect(function(InputObject, GameProcessedEvent)
	if GameProcessedEvent then
		return nil
	end

	if table.find(KeybindsInfoModule:GetKeybindInfo("Interact"), InputObject.KeyCode) ~= nil then
		if TouchingVehicle == nil then
			--DebugModule:Print("FPSInteraction | Vehicles | Not touching Vehicle!")
			return nil
		end
		
		--DebugModule:Print("FPSInteraction | Vehicles | Firing Server pickup Vehicle!")
		
		if CharacterVehicleValue.Value then
			UnequipVehicle(CharacterVehicleValue.Value)
		else
			EquipVehicle(TouchingVehicle)
		end
		
		--DeleteCache(TouchingVehicle)
		DeleteAllCache()
	end
end)]]

local Connection2 = InterfaceRemote.Event:Connect(function(ActionName)
	if ActionName == "VehicleSwitch" then
		EquipVehicle(TouchingVehicle)
	elseif ActionName == "UnequipVehicle" then
		UnequipVehicle(CharacterVehicleValue.Value)
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

return VehiclesModule