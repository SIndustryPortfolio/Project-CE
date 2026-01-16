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
local GrenadesInfoModule = require(InfoModulesFolder["Grenades"])

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
local PartsViewModelGrenadesFolder = UtilitiesModule:WaitForChildTimed(PartsViewModelsFolder, "Grenades")


-- Functions
-- MECHANICS
local function ThrowGrenade(ParentModule)
	if --[[Humanoid:GetAttribute("Grenade")]] ParentModule:IsPerformingPhysicalAction() then
		return nil
	end
	
	local EquippedWeaponModel = ParentModule:GetEquippedWeaponModel()
	local EquippedServerWeaponModel = ParentModule:GetEquippedServerWeaponModel()
	local ServerGunClientModule = ParentModule:GetServerGunClientModule()
	local GunClientModule = ParentModule:GetGunClientModule()
	local Camera = ParentModule:GetCamera()
	
	local EquippedGrenade = Character:GetAttribute("EquippedGrenade")
	local GrenadeInfo = GrenadesInfoModule:GetGrenadeInfo(EquippedGrenade)
	local HasSpeedCola = CharacterDrinksFolder:FindFirstChild("Speed Cola")
	local SoundProperties = {}

	if HasSpeedCola then
		SoundProperties["PlaybackSpeed"] = 2
	end

	if Character:GetAttributes()[tostring(EquippedGrenade).. "Grenades"] <= 0 then
		return nil
	end

	if GunClientModule then
		ParentModule:SetIsThrowing(true)

		Humanoid:SetAttribute("Grenade", true)
		ParentModule:CancelReload()		
		ParentModule:SetIsShooting(false)
		GunClientModule:StopFiring()
		
		local HasSpeedCola = CharacterDrinksFolder:FindFirstChild("Speed Cola")

		local FinishedVMAnimation = false

		local FoundGrenadeModel = PartsViewModelGrenadesFolder:FindFirstChild(EquippedGrenade):Clone()
		local HandWeld = FoundGrenadeModel:FindFirstChild("HandWeld")

		HandWeld.Part1 = EquippedWeaponModel["RightHand"]
		FoundGrenadeModel.Parent = EquippedWeaponModel

		--end
		ParentModule:GetRequestFunctions()["Unequip"](EquippedWeaponModel.Name, EquippedWeaponModel, GunClientModule, ServerGunClientModule, true)
		--GunClientModule:Unequip(true)
		SoundsModule:PlaySoundEffectById(GrenadeInfo["ThrowSound"].Id, nil, nil, nil, SoundProperties)
		--SoundsModule:PlaySoundEffectByName("Grenades", EquippedGrenade)
		coroutine.wrap(function()
			if not HasSpeedCola then
				GunClientModule:ThrowGrenade(ParentModule:GetThirdPerson())
			else
				GunClientModule:ThrowGrenade(ParentModule:GetThirdPerson(), 2)
			end
			FinishedVMAnimation = true
		end)()

		task.wait((GunClientModule:GetAnimationToLoad()["ThrowGrenade"].Length * (1 / GunClientModule:GetAnimationToLoad()["ThrowGrenade"].Speed)) / 2)

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {Character, EquippedWeaponModel, EquippedServerWeaponModel, FoundGrenadeModel}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude --Enum.RaycastFilterType.Blacklist
		local OriginPosition = Camera.CFrame.Position
		local Direction = Camera.CFrame.LookVector * GrenadesInfoModule:GetGrenadeSetting("ThrowRange") --600

		local RayResult = workspace:Raycast(OriginPosition, Direction, raycastParams)

		if not RayResult then
			RayResult = {["Position"] = (Camera.CFrame * CFrame.new(0, 0, GrenadesInfoModule:GetGrenadeSetting("ThrowRange"))).p, ["Direction"] = Direction, ["Distance"] = GrenadesInfoModule:GetGrenadeSetting("ThrowRange")}
			RayResult["Distance"] = (RayResult["Position"] - OriginPosition).Magnitude
		end

		--if not RayResult then
		DebugModule:Print("FPSHandler | Ray Result: ".. tostring(RayResult))

		CharacterProcessRemote:FireServer("ThrowGrenade", EquippedGrenade, {["Position"] = RayResult.Position, ["Normal"] = RayResult.Normal, ["Instance"] = RayResult.Instance, ["Material"] = RayResult.Material, ["Direction"] = Direction, ["Distance"] = RayResult.Distance})
		--[[coroutine.wrap(function()
			SoundsModule:PlaySoundEffectByName("Grenades", EquippedGrenade)
			RequestFunctions["ThrowGrenade"]()
		end)()]]


		FoundGrenadeModel:Destroy()

		repeat
			task.wait()
		until FinishedVMAnimation or Humanoid.Health <= 0

		GunClientModule:Equip(ParentModule:GetThirdPerson())
		ParentModule:SetIsThrowing(false)
	end
end


-- DIRECT
function ActionModule.Initialise(Nilparam, ...)
	return ThrowGrenade(...)
end

return ActionModule
