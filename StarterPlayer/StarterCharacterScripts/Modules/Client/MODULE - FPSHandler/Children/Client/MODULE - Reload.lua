local ActionModule = {}

-- Client
local Player = game.Players.LocalPlayer

-- Dirs
local Character = script.Parent.Parent.Parent.Parent.Parent
local CharacterClientServerSignalsFolder = Character:WaitForChild("Remotes")["ClientServer"]["Signals"]
local CharacterClientServerRemotesFolder = Character:WaitForChild("Remotes")["ClientServer"]["Remotes"]
local ClientServerSignalsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Signals"]
local CharacterCoreFolder = Character:WaitForChild("Core")

-- EXT
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local PartsViewModelsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["ViewModels"]
local SharedFPSAPIsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["APIs"]["FPS"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local ClientRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["Client"]["Remotes"]

-- Info Modules
local RoundTypesInfoModule = require(InfoModulesFolder["RoundTypes"])
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])
local SoundsInfoModule = require(InfoModulesFolder["Sounds"])

-- Modules
local InterfacesModule = require(SharedModulesFolder["Interfaces"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])
local SoundsModule = require(SharedModulesFolder["Sounds"])

-- Elements
-- REMOTES
local ProcessCommunicationsEvent = UtilitiesModule:GetPlayerCharacterClientRemote(Player, "ProcessCommunications")
local MouseCameraEvent = UtilitiesModule:GetPlayerCharacterClientRemote(Player, "MouseCamera")
local CharacterProcessRemote = UtilitiesModule:WaitForChildTimed(CharacterClientServerRemotesFolder, "CharacterProcess")
local CharacterPhysicsProcessRemote = UtilitiesModule:WaitForChildTimed(CharacterClientServerRemotesFolder, "CharacterPhysicsProcess")
local InterfaceRemote = UtilitiesModule:WaitForChildTimed(ClientRemotesFolder, "Interface")

-- SIGNALS
local CharacterRequestSignal = UtilitiesModule:WaitForChildTimed(CharacterClientServerSignalsFolder, "CharacterRequest")
local GunRequestSignal = UtilitiesModule:WaitForChildTimed(CharacterClientServerSignalsFolder, "GunRequest")
local GameRequestSignal = UtilitiesModule:WaitForChildTimed(ClientServerSignalsFolder, "GameRequest")

-- CORE
local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
local CharacterDrinksFolder = UtilitiesModule:WaitForChildTimed(Character, "Drinks")


-- Functions
-- MECHANICS
local function Reload(ParentModule)
	-- CORE
	local EquippedWeaponModel = ParentModule:GetEquippedWeaponModel()
	local EquippedServerWeaponModel = ParentModule:GetEquippedServerWeaponModel()
	local ServerGunClientModule = ParentModule:GetServerGunClientModule()
	local GunClientModule = ParentModule:GetGunClientModule()
	
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedWeaponModel.Name)
	
	
	if not ServerGunClientModule then
		return nil
	end

	if ParentModule:GetFireCustomConnection() then
		UtilitiesModule:DisconnectCustomConnections({ParentModule:GetFireCustomConnection()})
	end

	local ServerGunClientAnimations = ServerGunClientModule:GetAnimationToLoad()
	local GunClientAnimations = GunClientModule:GetAnimationToLoad()

	local _ReloadConnections = {}

	local RoundTypeToAttribute = 
		{
			["Shell"] = "RoundsInMag",
			["Medium"] = "RoundsInMag",
			["Light"] = "RoundsInMag",
			["Heavy"] = "RoundsInMag",
			["Plasma"] = "Energy"		
		}

	ParentModule:SetLastReloadTime(tick())

	-- Functions
	-- DIRECT
	local Connection1 = ServerGunClientAnimations["Reload"]:GetMarkerReachedSignal("Increment"):Connect(function(ParamString)
		--DebugModule:Print("FPSHandler | ServerGunClient Reload Animation Marker Reached | ParamString: ".. tostring(ParamString))

		if SoundsInfoModule:GetSounds("Effects")["RoundReload"][WeaponInfo["RoundType"]] then
			SoundsModule:PlaySoundEffectByName("RoundReload", WeaponInfo["RoundType"])
		end

		--CurrentIncrementMarker = 
		return CharacterProcessRemote:FireServer("ReloadIncrement", EquippedWeaponModel.Name)
	end)

	local Connection2 = EquippedServerWeaponModel:GetAttributeChangedSignal(--[["RoundsInMag"]] RoundTypeToAttribute[WeaponInfo["RoundType"]]):Connect(function()
		if EquippedServerWeaponModel and (table.find(RoundTypesInfoModule:GetTypesOfRound("Round"), WeaponInfo["RoundType"]) and EquippedServerWeaponModel:GetAttribute("RoundsInMag") < EquippedServerWeaponModel:GetAttribute("MaxRoundsInMag")) then
			return nil
		end

		if ServerGunClientAnimations then
			ServerGunClientAnimations["Reload"]:Stop()
		end

		if GunClientAnimations then
			GunClientAnimations["Reload"]:Stop()
		end
	end)

	for MarkerName, _ in pairs(SoundsInfoModule:GetSounds("Effects")["RoundReload"]) do
		local Connection2 = ServerGunClientAnimations["Reload"]:GetMarkerReachedSignal(MarkerName):Connect(function()
			SoundsModule:PlaySoundEffectByName("RoundReload", MarkerName)
		end)

		-- Connections
		table.insert(_ReloadConnections, Connection2)
		table.insert(ParentModule:GetConnections(), Connection2)
	end

	-- Connections
	table.insert(_ReloadConnections, Connection1)
	table.insert(_ReloadConnections, Connection2)
	table.insert(ParentModule:GetConnections(), Connection1)
	table.insert(ParentModule:GetConnections(), Connection2)
	
	
	-- INIT
	--[[coroutine.wrap(function()
		while task.wait(.1) and Connection1 and Connection1.Connected and Humanoid and Humanoid.Health > 0 do
			if EquippedServerWeaponModel and EquippedServerWeaponModel:GetAttribute("RoundsInMag") == EquippedServerWeaponModel:GetAttribute("MaxRoundsInMag") or EquippedServerWeaponModel:GetAttribute("Rounds") <= 0 then
				ServerGunClientAnimations["Reload"]:Stop()
				GunClientAnimations["Reload"]:Stop()
			end
		end
	end)()]]

	if ParentModule:IsPerformingPhysicalAction() --[[Humanoid:GetAttribute("Reload")]] then
		return nil
	end

	ParentModule:SetIsShooting(false)

	local HasSpeedCola = CharacterDrinksFolder:FindFirstChild("Speed Cola")
	local ReloadSpeed = WeaponInfo["ReloadSpeed"] or 1

	local ReloadSoundProperty = nil

	if HasSpeedCola then
		ReloadSpeed *= 2
		--ReloadSoundProperty = {["PlaybackSpeed"] = ReloadSpeed * 2}
	end

	ReloadSoundProperty = {["PlaybackSpeed"] = ReloadSpeed}


	--[[if ServerGunClientModule then
		if HasSpeedCola then
			--ServerGunClientModule:GetAnimationToLoad()["Reload"]:AdjustSpeed(2)
			ServerGunClientModule:GetAnimationToLoad()["Reload"].Speed = 2.0
		end
	end]]

	if GunClientModule then
		GunClientModule:StopFiring()
		--
		ParentModule:CancelActionSound("Reload")

		ParentModule:GetActionToSound()["Reload"] = SoundsModule:PlaySoundEffectById(WeaponInfo["ReloadSound"], nil, nil, nil, ReloadSoundProperty)
		Humanoid:SetAttribute("Ads", false)

		--[[if HasSpeedCola then
			--GunClientModule:GetAnimationToLoad()["Reload"]:AdjustSpeed(2)
			--GunClientModule:GetAnimationToLoad()["Reload"].Speed = 2.0
		end]]

		Humanoid:SetAttribute("Reload", true)
		--ToggleAds(false, true)


		--[[coroutine.wrap(function()
			RequestFunctions["Reload"]()
		end)()]]

		coroutine.wrap(function()

			local HudInterfaceModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
			local ReloadTime = GunClientModule:GetAnimationToLoad()["Reload"].Length / (WeaponInfo["ReloadSpeed"] or 1)

			if HasSpeedCola then
				ReloadTime /= 2
			end

			if HudInterfaceModule then
				HudInterfaceModule:HudProcess("Cursor", "Reload", ReloadTime)
			end

			--[[if not HasSpeedCola then
				GunClientModule:Reload(ReloadSpeed)
			else
				GunClientModule:Reload(ReloadSpeed * 2)
			end]]

			GunClientModule:Reload(ReloadSpeed)

			if HudInterfaceModule then
				HudInterfaceModule:HudProcess("Cursor", "CancelReload")
			end

			UtilitiesModule:DisconnectConnections(_ReloadConnections)
		end)()
		CharacterProcessRemote:FireServer("Reload", tostring(EquippedWeaponModel.Name))
	end
end

-- DIRECT
function ActionModule.Initialise(Nilparam, ...)
	return Reload(...)
end

return ActionModule
