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
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])
local FpsInfoModule = require(InfoModulesFolder["Fps"])
local AdsInfoModule = require(InfoModulesFolder["Ads"])

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

-- Services
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
function ToggleAds(ParentModule, Toggle, Force)
	local EquippedWeaponModel = ParentModule:GetEquippedWeaponModel()
	local EquippedServerWeaponModel = ParentModule:GetEquippedServerWeaponModel()
	local ServerGunClientModule = ParentModule:GetServerGunClientModule()
	local GunClientModule = ParentModule:GetGunClientModule()
	local Camera = ParentModule:GetCamera()
	local TweenDict = ParentModule:GetTweenDict()
	
	if not EquippedWeaponModel --[[or ADSing]]--[[ or (Humanoid:GetAttribute("Reload") and not Force)]] then
		--DebugModule:Print("FPSHandler | Droppping Toggle Ads first check")
		return nil
	end

	--DebugModule:Print("FPSHandler | Toggling ADS: ".. tostring(Toggle).. " | Reload: ".. tostring(Humanoid:GetAttribute("Reload")).. " | Force: ".. tostring(Force))

	-- CORE
	local HudModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedWeaponModel.Name)
	local EffectInfo = FpsInfoModule:GetFpsInfo("AdsEffectInfo")

	if not WeaponInfo or not WeaponInfo["AdsZoom"] --[[or Humanoid:GetAttribute("Reload")]] then
		HudModule:HudProcess("Ads", "End")

		return nil
	end

	local AdsInfo = AdsInfoModule:GetAdsInfo(WeaponInfo["AdsZoom"])

	if not AdsInfo and not Force then
		--DebugModule:Print("FPSHandler | No ADS Info")
		return nil
	end

	-- Functions
	-- INIT	
	if not HudModule then
		--DebugModule:Print("FPSHandler | No Hud Module")
		return nil
	end

	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	local tweeningInfo = {}
	
	local GoalFOV = 70

	if Toggle and not --[[Humanoid:GetAttribute("Reload")]] ParentModule:IsPerformingPhysicalAction() then
		if GunClientModule then
			GunClientModule:Hide()
		end

		--tweeningInfo.FieldOfView = AdsInfo["FieldOfView"]

		--Camera.FieldOfView = AdsInfo["FieldOfView"]
		
		GoalFOV = AdsInfo["FieldOfView"]
		HudModule:HudProcess("Ads", "ZoomIn")
	else
		if GunClientModule and not ParentModule:GetThirdPerson() then
			GunClientModule:Show()
		end

		--tweeningInfo.FieldOfView = 70
		--Camera.FieldOfView = 70

		--DebugModule:Print("FPSHandler | Ending ADS")
		HudModule:HudProcess("Ads", "End")
	end
	
	
	tweeningInfo.FieldOfView = GoalFOV

	--DebugModule:Print("FPSHandler | Setting FOV to: ".. tostring(tweeningInfo.FieldOfView))

	UtilitiesModule:CancelTween(Camera, TweenDict)

	ParentModule:SetADSing(true)

	TweenDict[Camera] = TweenService:Create(Camera, tweenInfo, tweeningInfo)
	TweenDict[Camera]:Play()
	UtilitiesModule:CompleteTween(Camera, TweenDict)

	TweenDict[Camera].Completed:Wait()
	ParentModule:SetADSing(false)
end

-- DIRECT
function ActionModule.Initialise(Nilparam, ...)
	return ToggleAds(...)
end

return ActionModule


