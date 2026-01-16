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
local EffectsHandlerModule = require(SharedModulesFolder["EffectsHandler"])
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
local function Dead(ParentModule)
	if ParentModule:GetDying() then
		return nil
	end

	ParentModule:SetDying(true)

	Humanoid:SetAttribute("Ads", false)
	ParentModule:UnbindFromRenderStepped()
	UtilitiesModule:CancelTween(ParentModule:GetCamera(), ParentModule:GetTweenDict())

	local RequiredModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")

	if RequiredModule and SharedGameFolder:GetAttribute("GameMode") ~= "" and SharedGameFolder:GetAttribute("Map") ~= "" and SharedGameFolder:GetAttribute("GameTime") > 0 then
		if not InterfacesModule:IsPageOpen("Custom", "Multiplayer") and not ParentModule:GetReturningToMenu() then
			RequiredModule:Death(GameRequestSignal:InvokeServer("Main", "Respawn"))
			--DebugModule:Print("Death Camera")
			EffectsHandlerModule:FPSEffectProcess("Death", Character)
		else
			InterfacesModule:LoadPage("Custom", "Loading", true)
			GameRequestSignal:InvokeServer("Main", "Undeploy")
		end
	end

	--FPSEffectsModule:EffectProcess("Death", EffectsHandlerModule)

	if Humanoid then
		return UtilitiesModule:UnloadAnimations(Humanoid:GetPlayingAnimationTracks())
	end
end

-- DIRECT
function ActionModule.Initialise(Nilparam, ...)
	return Dead(...)
end

return ActionModule