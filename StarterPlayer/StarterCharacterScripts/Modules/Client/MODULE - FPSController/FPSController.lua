local FPSController = {}

-- Dirs
local Character = script.Parent.Parent.Parent
local CharacterClientServerRemotesFolder = Character:WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- EXT
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Client
local Player = game.Players.LocalPlayer

-- Info Modules
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])
local KeybindsInfoModule = require(InfoModulesFolder["Keybinds"])
local GrenadesInfoModule = require(InfoModulesFolder["Grenades"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local FPSHandlerModule = require(UtilitiesModule:WaitForChildTimed(script.Parent, "FPSHandler"))
local InterfacesModule = require(ModulesFolder["Interfaces"])
local DebugModule = require(ModulesFolder["Debug"])
local SettingsModule = require(ModulesFolder["Settings"])
local ShortcutsModule = require(ModulesFolder["Shortcuts"])

-- Elements
-- HUMANOIDS
local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")

-- REMOTES
local CharacterProcessRemote = CharacterClientServerRemotesFolder["CharacterProcess"]

-- VALUES
local CharacterVehicleValue = ShortcutsModule:GetCharacterCoreValueInstance(Player, "Vehicle")

-- CORE
local Connections = {}
local ReturningToMenu = false

local RequiredSubModules = {}

local Binds = {"SwitchWeapon", "SwitchGrenade", "Ads", "Melee", "Reload", "Fire", "ScoreBoard", "InGameSettings", "Crouch", "ChangeTeam", "Menu", "DebugConsole", "Grenade", "Keybinds"}
local MovementBinds = {"Crouch", "StopCrouch"}

local KeybindToWeapon = 
{
	[Enum.KeyCode.One] = "Primary",
	[Enum.KeyCode.Two] = "Secondary"	
}

local Mouse = Player:GetMouse()

-- Services
local ContextActionService = game:GetService("ContextActionService")

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredSubModules = UtilitiesModule:RunSubModules(script)
end

local function CanPerformAction()
	-- CORE
	local CanPerform = true
	
	-- Functions
	-- INIT
	pcall(function()
		if (FPSHandlerModule and not FPSHandlerModule:GetIsLoaded() and CharacterVehicleValue and not CharacterVehicleValue.Value) then
			CanPerform = false
		end
	end)
	
	pcall(function()
		if InterfacesModule:IsPageOpen("Custom", "Loading") then
			CanPerform = false
		end
	end)
	
	return CanPerform
end

local function GetEquippedWeaponType()
	-- Functions
	-- INIT
	return Character:GetAttribute("EquippedWeapon")
end

local function Crouch()
	-- Functions
	-- INIT
	if not SettingsModule:GetSettingValue("Game", "ToggleCrouch", true) then
		FPSHandlerModule:Crouch()
	else
		if Humanoid:GetAttribute("Crouch") then
			FPSHandlerModule:StopCrouch()			
		else
			FPSHandlerModule:Crouch()
		end
	end	
end

local function StopCrouch()
	-- Functions
	-- INIT
	if not SettingsModule:GetSettingValue("Game", "ToggleCrouch", true) then
		return FPSHandlerModule:StopCrouch()
	end
end

local function ToggleChangeTeams()
	-- Functions
	-- INIT
	local Page = InterfacesModule:IsPageOpen("Custom", "ChangeTeam")

	if Page then
		InterfacesModule:ClosePage(Page, true)
		FPSController:Rebind()

		return nil
	end

	UnbindActions()
	InterfacesModule:LoadPage("Custom", "ChangeTeam", true, true)
end

local function ShowKeybinds()
	-- Functions
	-- INIT
	local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	if HudGuiModule then
		HudGuiModule:HudProcess("KeybindHints", "Show")
	end
end

local function HideKeybinds()
	-- Functions
	-- INIT
	local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	if HudGuiModule then
		HudGuiModule:HudProcess("KeybindHints", "Hide")
	end
end

local function BackToMenu()
	-- Functions
	-- INIT
	-- Functions
	-- INIT
	local Page = InterfacesModule:IsPageOpen("Custom", "ChangeTeam")

	--[[if Page then
		InterfacesModule:ClosePage(Page)
		FPSController:Rebind()

		return nil
	end]]
	
	pcall(function()
		FPSHandlerModule:SetReturningToMenu(true)
	end)
	
	UnbindActions()
	
	if Humanoid then
		Humanoid:TakeDamage(Humanoid.MaxHealth + Humanoid:GetAttribute("MaxShield") * 2) -- SLUICIDE
	end
	
	local _Character = UtilitiesModule:GetCharacter(Player, true)
	
	repeat
		task.wait()
		if UtilitiesModule then
			_Character = UtilitiesModule:GetCharacter(Player, true)
		end
	until not _Character or _Character.Parent == nil or not UtilitiesModule
	
	--DebugModule:Print("Loading Multiplayer Gui")
	if InterfacesModule then
		InterfacesModule:LoadPage("Custom", "Multiplayer", true)
	end
end

local function ToggleGameSettings()
	-- Functions
	-- INIT
	local Page = InterfacesModule:IsPageOpen("Custom", "Settings")
		
	if Page then
		InterfacesModule:ClosePage(Page, true)
		FPSController:Rebind()
		
		return nil
	end
	
	UnbindActions()
	InterfacesModule:LoadPage("Custom", "Settings", true, true)
end

function Reload(InputObject)
	-- Functions
	-- INIT
	if Humanoid:GetAttribute("Reload") or FPSHandlerModule:IsFPSLocked() or Humanoid:GetAttribute("Grenade") then
		return nil
	end
	
	if FPSHandlerModule:CanReload() then
		FPSHandlerModule:Reload()
	end
end

local function Ads()
	-- Functions
	-- INIT
	if FPSHandlerModule:IsSwitchingWeapon() or FPSHandlerModule:IsFPSLocked() or Humanoid:GetAttribute("Reload") or Humanoid:GetAttribute("Grenade") then
		return nil
	end
	
	if not SettingsModule:GetSettingValue("Game", "ToggleAds", true) then
		Humanoid:SetAttribute("Ads", true)
	else
		Humanoid:SetAttribute("Ads", not Humanoid:GetAttribute("Ads"))
	end
	
	--[[local HudModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")

	if HudModule then
		HudModule:HudProcess("Ads", "Initialise")
	end]]
end

local function StopAds()
	-- Functions
	-- INIT
	if not SettingsModule:GetSettingValue("Game", "ToggleAds", true) then
		Humanoid:SetAttribute("Ads", false)
	end
	
	--[[local HudModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	if HudModule then
		HudModule:HudProcess("Ads", "End")
	end]]
end

local function Fire(InputObject)
	-- CORE
	local EquippedServerWeaponModel = FPSHandlerModule:GetEquippedServerWeaponModel()
	
	if not EquippedServerWeaponModel then
		return nil
	end
	
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedServerWeaponModel.Name)
	
	-- Functions
	-- INIT
	if FPSHandlerModule:IsFPSLocked() --[[or not FPSHandlerModule:GetIsLoaded()]] then
		return nil
	end
	
	if not WeaponInfo["ChargeShot"] then
		return FPSHandlerModule:Fire()
	else
		return FPSHandlerModule:Charge()
	end
end

local function StopFire(InputObject)
	-- Functions
	-- INIT
	-- CORE
	local EquippedServerWeaponModel = FPSHandlerModule:GetEquippedServerWeaponModel()
	local WeaponInfo = nil
	
	if EquippedServerWeaponModel then
		WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedServerWeaponModel.Name)
	end
	
	if not WeaponInfo or not WeaponInfo["ChargeShot"] then
		if FPSHandlerModule.StopFiring then
			return FPSHandlerModule:StopFiring()
		end
	else
		return FPSHandlerModule:Fire()
	end
end

local function Grenade(InputObject)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player)
	
	-- Functions
	-- INIT
	if not Character or Humanoid:GetAttribute("Grenade") or FPSHandlerModule:IsFPSLocked() then
		return nil
	end
	
	FPSHandlerModule:ThrowGrenade()
end

function Melee(InputObject)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player)
	
	-- Functions
	-- INIT
	if not Character or Humanoid:GetAttribute("Melee") or FPSHandlerModule:IsFPSLocked() then
		return nil
	end
	
	--DebugModule:Print"Melee-ing")
	--local raycastResult = FPSHandlerModule:MeleeProcedure()
	--DebugModule:Print"Finished Melee-ing Client")
	
	FPSHandlerModule:Melee()
	
	--DebugModule:Print"Firing Melee Server")
	--CharacterProcessRemote:FireServer("Melee", raycastResult)
end

function SwitchGrenade(InputObject)
	-- CORE
	local GrenadeOrder = GrenadesInfoModule:GetGrenadeSetting("GrenadeOrder")
	
	-- Functions
	-- INIT
	local CurrentEquippedIndex = table.find(GrenadeOrder, Character:GetAttribute("EquippedGrenade"))
	
	if CurrentEquippedIndex == #GrenadeOrder then
		CurrentEquippedIndex = 0
	end
	
	FPSHandlerModule:SwitchGrenade(GrenadeOrder[CurrentEquippedIndex + 1])
end

function SwitchWeapon(InputObject)
	if FPSHandlerModule:IsFPSLocked() then
		return nil
	end
	
	-- CORE
	local VariantToSwitchTo = nil
	
	pcall(function()
		VariantToSwitchTo = KeybindToWeapon[InputObject.KeyCode]
	end)
	
	if VariantToSwitchTo == nil then
		local EquippedWeaponType = GetEquippedWeaponType()
		
		if EquippedWeaponType == "Primary" then
			VariantToSwitchTo = "Secondary"
		else
			VariantToSwitchTo = "Primary"
		end
	end
	
	-- Functions
	-- INIT
	if GetEquippedWeaponType() == VariantToSwitchTo then
		return nil
	end
	
	if FPSHandlerModule:IsSwitchingWeapon() or  Humanoid:GetAttributes()["Grenade"] then
		--DebugModule:Print"Is switching weapon") --print("Is switching weapon")
		return nil
	end
	
	FPSHandlerModule:SwitchWeapon(VariantToSwitchTo)
	
	--CharacterProcessRemote:FireServer("SwitchWeapon", VariantToSwitchTo)
end

local function OpenDebugConsole()
	-- Functions
	-- INIT
	InterfacesModule:LoadPage("Custom", "DebugConsole", true)
end

local function CloseDebugConsole()
	-- Functions
	-- INIT
	InterfacesModule:UnloadPage("Custom", "DebugConsole")
end

local function OpenScoreBoard()
	-- Functions
	-- INIT
	if FPSHandlerModule:IsFPSLocked() then
		return nil
	end
	
	InterfacesModule:LoadPage("Custom", "ScoreBoard", true)
end

local function CloseScoreBoard()
	-- Functions
	-- INIT
	InterfacesModule:UnloadPage("Custom", "ScoreBoard")
end

local function Interact()
	-- Functions
	-- INIT
	ShortcutsModule:GetVehicleModule(CharacterVehicleValue.Value, "VehicleController"):InputBegin(tostring("Interact"))
	
	if CharacterVehicleValue.Value then
		
	end
end

-- CORE FUNCTIONS
InputBeginActions = 
{	
	["Interact"] = Interact,
	["SwitchWeapon"] = SwitchWeapon,
	["SwitchGrenade"] = SwitchGrenade,
	["Grenade"] = Grenade,	
	["Ads"] = Ads,
	["Melee"] = Melee,
	["Reload"] = Reload,
	["Fire"] = Fire,
	["Keybinds"] = ShowKeybinds,
	["ScoreBoard"] = OpenScoreBoard,
	["DebugConsole"] = OpenDebugConsole,
	["InGameSettings"] = ToggleGameSettings,
	["ChangeTeam"] = ToggleChangeTeams,
	["Crouch"] = Crouch,
	["Menu"] = BackToMenu
}

InputEndedActions = 
{
	["Ads"] = StopAds,
	["Fire"] = StopFire,
	["Keybinds"] = HideKeybinds,
	["ScoreBoard"] = CloseScoreBoard,
	["DebugConsole"] = CloseDebugConsole,
	["Crouch"] = StopCrouch
}

-- MECHANICS
function HandleAction(ActionName, InputState, InputObject)
	-- CORE
	local ActionResponse, ResponseState = nil, nil
	
	-- Functions
	-- INIT
	
	if not CanPerformAction() then
		DebugModule:Print("FPSController | Cannot perform action: ".. tostring(ActionName).. " | State: ".. tostring(InputState.Name))
		return nil
	end
	
	----DebugModule:Print"ACTION | Action Name: ".. tostring(ActionName).. " | Input State: ".. tostring(InputState).. " | Input Object: ".. tostring(InputObject))	
	
	if InputState == Enum.UserInputState.Begin then
		if not InputBeginActions[tostring(ActionName)] then
			return nil
		end
		
		if not CharacterVehicleValue.Value then
			ActionResponse, ResponseState = InputBeginActions[tostring(ActionName)](InputObject)
		else
			local VehicleModule = ShortcutsModule:GetVehicleModule(CharacterVehicleValue.Value, "VehicleController")
			
			if table.find(UtilitiesModule:GetDictKeys(VehicleModule:GetInputs()), ActionName) then
				ActionResponse, ResponseState = VehicleModule:InputBegin(tostring(ActionName), InputObject)
			else
				ActionResponse, ResponseState = InputBeginActions[tostring(ActionName)](InputObject)
			end
		end
	elseif InputState == Enum.UserInputState.End then
		if not InputEndedActions[tostring(ActionName)] then
			return nil
		end
		
		if not CharacterVehicleValue.Value then
			ActionResponse, ResponseState = InputEndedActions[tostring(ActionName)](InputObject)
		else
			local VehicleModule = ShortcutsModule:GetVehicleModule(CharacterVehicleValue.Value, "VehicleController")

			if table.find(UtilitiesModule:GetDictKeys(VehicleModule:GetInputs()), ActionName) then
				ActionResponse, ResponseState = VehicleModule:InputEnd(tostring(ActionName), InputObject)
			else
				ActionResponse, ResponseState = InputEndedActions[tostring(ActionName)](InputObject)
			end
		end
	end
	
	if ActionResponse and ResponseState then
		return HandleAction(ActionResponse, ResponseState)
	end
end

local function BindActions(Except)
	-- Functions
	-- INIT
	--DebugModule:Print"BINDING FPS")
	
	local TouchKeybinds = KeybindsInfoModule:GetTouchKeybinds()
	
	DebugModule:Print(script.Name.. " | Binding all actions")
	
	for i, BindName in pairs(Binds) do
		if Except and table.find(Except, BindName) then
			continue
		end
		
		if table.find(UtilitiesModule:GetDictKeys(TouchKeybinds), BindName) then
			--DebugModule:Print("FPSController | Binding Mobile Button: ".. tostring(BindName))
			
			ContextActionService:BindAction(BindName, HandleAction, true, unpack(KeybindsInfoModule:GetKeybindInfo(BindName)))
			local Success, Error = pcall(function()
				if Player:GetAttributes()["Device"] == "Mobile" then
					ContextActionService:SetImage(BindName, TouchKeybinds[BindName]["Icon"]["Id"])
					ContextActionService:SetPosition(BindName, TouchKeybinds[BindName]["Position"])
					--
					local Button = ContextActionService:GetButton(BindName)
					Button.BackgroundTransparency = 1
					Button.ImageTransparency = 1
					
					if TouchKeybinds[BindName]["SizeMultiplier"] then
						local Multiplier = TouchKeybinds[BindName]["SizeMultiplier"]
						Button.Size = UDim2.new(Button.Size.X.Scale * Multiplier, Button.Size.X.Offset * Multiplier, Button.Size.Y.Scale * Multiplier, Button.Size.Y.Offset * Multiplier)
					end
					
					Button["ActionIcon"].Size = UDim2.fromScale(1, 1)
					Button["ActionIcon"].ScaleType = Enum.ScaleType.Fit
				end
			end)
		else
			--DebugModule:Print("FPSController | Binding Button: ".. tostring(BindName))
			ContextActionService:BindAction(BindName, HandleAction, false, unpack(KeybindsInfoModule:GetKeybindInfo(BindName)))
		end
	end
	
	-- DIRECT
	local Connection1 = Mouse.WheelForward:Connect(function()
		if CharacterVehicleValue.Value then
			return nil
		end
		
		SwitchWeapon(Enum.UserInputType.MouseWheel, true)
	end)

	local Connection2 = Mouse.WheelBackward:Connect(function()
		if CharacterVehicleValue.Value then
			return nil
		end
		
		SwitchWeapon(Enum.UserInputType.MouseWheel, false)
	end)

	-- Connections
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
end

local function BindOnly(ToBind)
	-- CORE
	local ToIgnore = {}
	
	-- Functions
	-- INIT
	for BindName, Info in pairs(InputBeginActions) do
		if not table.find(ToBind, BindName) then
			table.insert(ToIgnore, BindName)
		end
	end
	
	BindActions(ToIgnore)
end

local function RoundEnd()
	-- Functions
	-- INIT
	
	if UtilitiesModule and Connections then
		UtilitiesModule:DisconnectConnections(Connections)
	end
	
	if Humanoid then
		Humanoid:SetAttribute("Ads", false)
	end
	
	DebugModule:Print("FPSController | Round Ending | Setting Binds to nil")
	
	for BindName, BindFunction in pairs(InputBeginActions) do
		if table.find(MovementBinds, BindName) then
			continue
		end
		
		--DebugModule:Print("FPSController | Setting Bind: ".. tostring(BindName).. " to nil")
		
		InputBeginActions[BindName] = nil
	end
	
	for BindName, BindFunction in pairs(InputEndedActions) do
		if table.find(MovementBinds, BindName) then
			continue
		end
		
		DebugModule:Print("FPSController | Setting Bind: ".. tostring(BindName).. " to nil")
		
		InputEndedActions[BindName] = nil
	end
end

function UnbindActions()
	-- Functions
	-- INIT
	--DebugModule:Print"UNBINDING FPS")
	
	for i, BindName in pairs(Binds) do
		pcall(function()
			ContextActionService:UnbindAction(BindName)
		end)
	end
	
	for ModuleName, Module in pairs(RequiredSubModules) do
		local Success, Error = pcall(function()
			if Module.End ~= nil then
				Module:End()
			end
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | Module: ".. ModuleName.." | Error: ".. tostring(Error))
		end
	end	
	
	if Connections then
		UtilitiesModule:DisconnectConnections(Connections)
	end
end

-- DIRECT
function FPSController.Initialise()
	-- Functions
	-- INIT
	local Success, Error = pcall(function()
		return UnbindActions()
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | Initialise | Error: ".. tostring(Error))
	end
	
	RunSubModules()
	BindActions()
	
	--[[ContextActionService:BindAction("SwitchWeapon", HandleAction, true, unpack(KeybindsInfoModule:GetKeybindInfo("SwitchWeapon")))
	ContextActionService:BindAction("Ads", HandleAction, true, unpack(KeybindsInfoModule:GetKeybindInfo("Ads")))
	ContextActionService:BindAction("Melee", HandleAction, true, unpack(KeybindsInfoModule:GetKeybindInfo("Melee")))
	ContextActionService:BindAction("Reload", HandleAction, true, unpack(KeybindsInfoModule:GetKeybindInfo("Reload")))
	ContextActionService:BindAction("Fire", HandleAction, true, unpack(KeybindsInfoModule:GetKeybindInfo("Fire")))
	ContextActionService:BindAction("ScoreBoard", HandleAction, true, unpack(KeybindsInfoModule:GetKeybindInfo("ScoreBoard")))
	ContextActionService:BindAction("InGameSettings", HandleAction, true, unpack(KeybindsInfoModule:GetKeybindInfo("InGameSettings")))]]
	
end

function FPSController.GetReturningToMenu()
	return ReturningToMenu
end

function FPSController.BindOnly(NilParam, ...)
	return BindOnly(...)
end

function FPSController.RebindExcept(NilParam, ...)
	return BindActions(...)
end

function FPSController.Rebind()
	-- Functions
	-- INIT
	--DebugModule:Print"REBINDING FPS")
	
	UnbindActions()
	RunSubModules()
	BindActions()
end

function FPSController.UnbindActions()
	return UnbindActions()
end

function FPSController.RoundEnd()
	return RoundEnd()
end

function FPSController.Dead()
	-- Functions
	-- INIT
	return FPSHandlerModule:Dead()
end

function FPSController.GarbageCollect()
	-- Functions
	-- Init
	UtilitiesModule:DisconnectConnections(Connections)
	Character = nil
	CharacterClientServerRemotesFolder = nil
	ModulesFolder = nil
	InfoModulesFolder = nil
	MovementBinds = nil
	--
	Player = nil
	--
	KeybindsInfoModule = nil
	--
	UtilitiesModule = nil
	FPSHandlerModule = nil
	InterfacesModule = nil
	DebugModule = nil
	--
	Humanoid = nil
	--
	CharacterProcessRemote = nil
	--
	Connections = nil
	ReturningToMenu = nil
	--
	Binds = nil
	KeybindToWeapon = nil
	Mouse = nil
	--
	ContextActionService = nil
	
end

function FPSController.End()
	-- Functions
	-- INIT
	--DebugModule:Print"Unbinding Actions")
	UtilitiesModule:DisconnectConnections(Connections)

	UnbindActions()
	--[[ContextActionService:UnbindAction("SwitchWeapon")
	ContextActionService:UnbindAction("Melee")
	ContextActionService:UnbindAction("Reload")
	ContextActionService:UnbindAction("Fire")
	ContextActionService:UnbindAction("Ads")
	ContextActionService:UnbindAction("ScoreBoard")
	ContextActionService:UnbindAction("InGameSettings")]]
end

return FPSController