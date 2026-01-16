local WeaponsModule = {}

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
local RoundTypesInfoModule = require(InfoModulesFolder["RoundTypes"])
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])
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
local TouchingWeapon = nil
local Connections = {}

local Billborads = {}

-- Services


-- Functions
-- MECHANICS
local function GetWeaponModelFromCharacter(WeaponName)
	-- Functions
	-- INIT
	local FoundServerWeapon = Character:FindFirstChild(WeaponName)
	
	if not FoundServerWeapon then
		FoundServerWeapon = Player:WaitForChild("Backpack"):FindFirstChild(WeaponName)
	end
	
	return FoundServerWeapon
end

local function DeleteCache(WeaponModel)
	-- Functions
	-- INIT
	if Billborads[WeaponModel] then
		--Billborads[WeaponModel]:Destroy()
		InterfacesModule:ClosePage(Billborads[WeaponModel])
	end
	
	Billborads[WeaponModel] = nil
end

local function DeleteAllCache()
	-- Functions
	-- INIT
	for WeaponModel, Ui in pairs(Billborads) do
		DeleteCache(WeaponModel)
	end
end

local function Initialise(WeaponModel)
	-- Functions
	-- INIT
	--DebugModule:Print("Weapons | Touched Weapon Model: ".. tostring(WeaponModel))
	
	local TeamInfo = ShortcutsModule:GetPlayerTeamInfo(Player)
	
	if TeamInfo and TeamInfo["PickupWeapons"] == false then
		TouchingWeapon = nil
		
		if HudGuiModule then
			HudGuiModule:HudProcess("WeaponSwitch", "StopHint")
		end
		
		return nil
	end
	
	
	if not WeaponModel or WeaponModel == "nil" or typeof(WeaponModel) == "table" then
		TouchingWeapon = nil
		
		if HudGuiModule then
			HudGuiModule:HudProcess("WeaponSwitch", "StopHint")
		end
		
		--DeleteCache(WeaponModel)
		DeleteAllCache()
		
		return nil
	end
	
	if TouchingWeapon ~= WeaponModel then
		TouchingWeapon = nil
		if HudGuiModule then
			HudGuiModule:HudProcess("WeaponSwitch", "StopHint")
		end
		
		--DeleteCache(WeaponModel)
		DeleteAllCache()
	end
		
	----DebugModule:Print"Touched Weapon: ".. tostring(WeaponModel.Name))
	local CharacterWeapons = {Character:GetAttribute("Primary"), Character:GetAttribute("Secondary")}
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponModel.Name)
	
	if WeaponModel and WeaponModel:GetAttributes()["RestrictedToUser"] and WeaponModel:GetAttributes()["RestrictedToUser"] ~= "" and WeaponModel:GetAttributes()["RestrictedToUser"] ~= Player.Name then
		return nil
	end
	
	if WeaponModel and table.find(CharacterWeapons, WeaponModel.Name) ~= nil then
		local WeaponToCheck = GetWeaponModelFromCharacter(WeaponModel.Name)
		
		if WeaponToCheck and WeaponInfo["RoundType"] then
			if (--[[WeaponInfo["RoundType"] ~= "Plasma"]] table.find(RoundTypesInfoModule:GetTypesOfRound("Round"), WeaponInfo["RoundType"]) and WeaponToCheck:GetAttributes()["Rounds"] == (WeaponToCheck:GetAttributes()["MaxRoundsInMag"] * WeaponToCheck:GetAttributes()["MaxMags"])) then
				TouchingWeapon = nil
				return nil
			end
		end
		
				
		if --[[WeaponInfo["RoundType"] ~= "Plasma"]] table.find(RoundTypesInfoModule:GetTypesOfRound("Round"), WeaponInfo["RoundType"]) then
			CharacterProcessRemote:FireServer("PickupWeapon", WeaponModel)
		end
	else
		if (TouchingWeapon ~= WeaponModel --[[and WeaponInfo["RoundType"] ~= "Plasma"]]) and HudGuiModule and WeaponModel then
			--DebugModule:Print("Hinting to switch weapon: ".. tostring(WeaponModel.Name))
			HudGuiModule:HudProcess("WeaponSwitch", "AddHint", WeaponModel.Name)
			
			if not Billborads[WeaponModel] and SettingsModule:GetSettingValue("Game", "Hints", true) then
				Billborads[WeaponModel] = InterfacesModule:LoadBillboard(HintsFolder, "GunInteract", WeaponModel)
				Billborads[WeaponModel].AlwaysOnTop = true
				Billborads[WeaponModel].Adornee = WeaponModel
			end
		end
	end
	
	TouchingWeapon = WeaponModel
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
	TouchingWeapon = nil
	Connections = nil
	
end

local function End()
	-- Functions
	-- INIT
	if HudGuiModule then
		HudGuiModule:HudProcess("WeaponSwitch", "StopHint")
	end
	
	for i, Ui in pairs(HintsFolder:GetChildren()) do
		InterfacesModule:ClosePage(Ui)
	end
	
	UtilitiesModule:DisconnectConnections(Connections)
end

local function FireWeaponSwitch()
	-- Functions
	-- INIT
	local TeamInfo = ShortcutsModule:GetPlayerTeamInfo(Player)

	if TeamInfo and TeamInfo["PickupWeapons"] == false then
		DebugModule:Print(script.Name.. " | Cannot pickup weapon -> Team Pickup Restriction")
		
		TouchingWeapon = nil

		if HudGuiModule then
			HudGuiModule:HudProcess("WeaponSwitch", "StopHint")
		end

		return nil
	end
	
	if TouchingWeapon == nil or FPSHandlerModule:IsSwitchingWeapon() then
		--DebugModule:Print("FPSInteraction | Weapons | Not touching weapon!")
		DebugModule:Print(script.Name.. " | Cannot pickup weapon V")
		DebugModule:Print(script.Name.. " | TouchingWeapon: ".. tostring(TouchingWeapon))
		DebugModule:Print(script.Name.. " | IsSwitchingWeapon: ".. tostring(FPSHandlerModule:IsSwitchingWeapon()))
		
		return nil
	end

	--DebugModule:Print("FPSInteraction | Weapons | Firing Server pickup weapon!")
	CharacterProcessRemote:FireServer("PickupWeapon", TouchingWeapon)
	if HudGuiModule then
		HudGuiModule:HudProcess("WeaponSwitch", "StopHint")
	end

	--DeleteCache(TouchingWeapon)
	DeleteAllCache()
end

-- DIRECT
function WeaponsModule.Initialise(NilParam, Child)
	if not Child then
		--DebugModule:Print("FPSInteraction | Weapons | Touched | Dropping nil")
		return nil
	end
	
	Initialise(Child)
end

function WeaponsModule.SetTouching(NilParam, NewValue) --SetTouchingWeapon(NilParam, NewValue)
	TouchingWeapon = NewValue
	
	if NewValue == nil then
		if HudGuiModule then
			HudGuiModule:HudProcess("WeaponSwitch", "StopHint")
		end
		
		--DeleteCache(TouchingWeapon)
		DeleteAllCache()
	end
end

function WeaponsModule.GarbageCollect()
	GarbageCollect()
end

function WeaponsModule.GetTouching()
	return TouchingWeapon
end

function WeaponsModule.Switch()
	return FireWeaponSwitch()
end

function WeaponsModule.End()
	End()
end

-- INIT
local Connection2 = InterfaceRemote.Event:Connect(function(ActionName)
	if ActionName == "WeaponSwitch" then
		return FireWeaponSwitch()
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

return WeaponsModule