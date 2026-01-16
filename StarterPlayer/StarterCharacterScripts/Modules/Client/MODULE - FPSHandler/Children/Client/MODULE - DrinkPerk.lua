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

-- Modules
local InterfacesModule = require(SharedModulesFolder["Interfaces"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])
local SoundsModule = require(SharedModulesFolder["Sounds"])
local ObjectsModule = require(SharedModulesFolder["Objects"])

-- Elements
-- REMOTES
local ProcessCommunicationsEvent = UtilitiesModule:GetPlayerCharacterClientRemote(Player, "ProcessCommunications")
local MouseCameraEvent = UtilitiesModule:GetPlayerCharacterClientRemote(Player, "MouseCamera")
local CharacterProcessRemote = UtilitiesModule:WaitForChildTimed(CharacterClientServerRemotesFolder, "CharacterProcess")
local CharacterPhysicsProcessRemote = UtilitiesModule:WaitForChildTimed(CharacterClientServerRemotesFolder, "CharacterPhysicsProcess")
local InterfaceRemote = UtilitiesModule:WaitForChildTimed(ClientRemotesFolder, "Interface")

-- CORE
local PartsViewModelBottlesFolder = UtilitiesModule:WaitForChildTimed(PartsViewModelsFolder, "Bottles")

-- Functions
-- MECHANICS
local function DrinkPerk(ParentModule, PerkName)
	-- Functions
	-- INIT
	local EquippedWeaponModel = ParentModule:GetEquippedWeaponModel()
	local EquippedServerWeaponModel = ParentModule:GetEquippedServerWeaponModel()
	local ServerGunClientModule = ParentModule:GetServerGunClientModule()
	local GunClientModule = ParentModule:GetGunClientModule()
	
	coroutine.wrap(function()
		GunClientModule:StopFiring()

		local FinishedVMAnimation = false

		local FoundBottleModel = PartsViewModelBottlesFolder:FindFirstChild("Bottle"):Clone()
		ObjectsModule:ObjectProcess("ApplyBottleSkin", FoundBottleModel, PerkName)

		local HandWeld = FoundBottleModel:FindFirstChild("HandWeld")

		HandWeld.Part1 = EquippedWeaponModel["RightHand"]
		FoundBottleModel.Parent = EquippedWeaponModel
		
		ParentModule:SetDrinking(true)

		--end
		ParentModule:GetRequestFunctions()["Unequip"](EquippedWeaponModel.Name, EquippedWeaponModel, GunClientModule, ServerGunClientModule, true)
		--GunClientModule:Unequip(true)
		--SoundsModule:PlaySoundEffectById(GrenadeInfo["ThrowSound"].Id)
		--SoundsModule:PlaySoundEffectByName("Grenades", EquippedGrenade)
		coroutine.wrap(function()
			SoundsModule:PlaySoundEffectByName("CharacterActions", "Drink")
			GunClientModule:DrinkPerk(ParentModule:GetThirdPerson())
			FinishedVMAnimation = true
		end)()

		--task.wait(GunClientModule:GetAnimationToLoad()["ThrowGrenade"].Length)

		--[[coroutine.wrap(function()
			SoundsModule:PlaySoundEffectByName("Grenades", EquippedGrenade)
			RequestFunctions["ThrowGrenade"]()
		end)()]]

		repeat
			task.wait()
		until FinishedVMAnimation
		FoundBottleModel:Destroy()
		
		ParentModule:SetDrinking(false)
		GunClientModule:Equip(ParentModule:GetThirdPerson())
	end)()

	return ParentModule:GetFPSServerModule():Request("ServerDrinkPerk", ParentModule)
end


-- DIRECT
function ActionModule.Initialise(Nilparam, ...)
	return DrinkPerk(...)
end

return ActionModule


