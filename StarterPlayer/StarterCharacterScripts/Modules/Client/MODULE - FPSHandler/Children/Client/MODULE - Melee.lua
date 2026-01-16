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
local FpsInfoModule = require(InfoModulesFolder["Fps"])
local GameModesInfoModule = require(InfoModulesFolder["GameModes"])
local CharacterInfoModule = require(InfoModulesFolder["Character"])

-- Modules
local InterfacesModule = require(SharedModulesFolder["Interfaces"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])
local SoundsModule = require(SharedModulesFolder["Sounds"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])

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

-- PARTS
local HumanoidRootPart = Character.PrimaryPart

-- CORE
local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
local CharacterDrinksFolder = UtilitiesModule:WaitForChildTimed(Character, "Drinks")

-- Services
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
local function MeleeProcedure(ParentModule)
	-- CORE
	local EquippedWeaponModel = ParentModule:GetEquippedWeaponModel()
	local EquippedServerWeaponModel = ParentModule:GetEquippedServerWeaponModel()
	local ServerGunClientModule = ParentModule:GetServerGunClientModule()
	local GunClientModule = ParentModule:GetGunClientModule()
	local TweenDict = ParentModule:GetTweenDict()
	
	if not EquippedServerWeaponModel or not EquippedWeaponModel then
		return nil
	end

	-- CORE
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(SharedGameFolder:GetAttribute("GameMode"))
	local PackagedResult = ParentModule:FireRaycastProcedure()
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedWeaponModel.name)
	local MeleeConnections = {}
	local CancelledBudge = false
	local HasBudged = false

	-- Functions
	-- INIT
	if WeaponInfo and WeaponInfo["Type"] == "Melee" then
		if PackagedResult and PackagedResult.Instance then
			local TargetHumanoid = UtilitiesModule:GetHumanoidFromHit(PackagedResult.Instance)

			if TargetHumanoid and TargetHumanoid.Health > 0 then
				local TargetCharacter = TargetHumanoid.Parent
				local TargetHumanoidRootPart = UtilitiesModule:GetPartToShift(TargetHumanoid.Parent)

				local TargetPlayer = ShortcutsModule:GetPlayerFromCharacter(TargetCharacter) --game.Players:GetPlayerFromCharacter(TargetCharacter)

				local Distance = (HumanoidRootPart.Position - TargetHumanoidRootPart.Position).Magnitude

				if TargetHumanoidRootPart and (Distance <= (CharacterInfoModule:GetCharacterInfo("MeleeDistance") + (WeaponInfo["BudgeDistance"] or 0)) and Distance > 10) and TargetPlayer and (not GameModeInfo["Teams"] or TargetPlayer.Team ~= Player.Team) then

					UtilitiesModule:CancelTween(HumanoidRootPart, TweenDict)

					local EffectInfo = FpsInfoModule:GetFpsInfo("MeleeBudgeEffectInfo")

					local Direction = (TargetHumanoidRootPart.Position - HumanoidRootPart.Position).Unit * FpsInfoModule:GetFpsInfo("RayLength")
					local Origin = HumanoidRootPart.Position

					local raycastParams = RaycastParams.new()
					raycastParams.FilterDescendantsInstances = {TargetHumanoidRootPart, TargetCharacter:FindFirstChild("UpperTorso"), TargetCharacter:FindFirstChild("LowerTorso"), TargetCharacter:FindFirstChild("Neon")}
					raycastParams.FilterType = Enum.RaycastFilterType.Include --Enum.RaycastFilterType.Whitelist

					local raycastResult = workspace:Raycast(Origin, Direction, raycastParams)

					if raycastResult and raycastResult.Instance and (Origin - raycastResult.Position).Magnitude <= 25 then

						--ControlsModule:Disable()

						local Connection1 = Humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
							return UtilitiesModule:CancelTween(HumanoidRootPart, TweenDict)
						end)

						local Connection2 = Humanoid:GetAttributeChangedSignal("Crouch"):Connect(function()
							return UtilitiesModule:CancelTween(HumanoidRootPart, TweenDict)
						end)

						local Connection3 = Humanoid:GetAttributeChangedSignal("Melee"):Connect(function()
							if not Humanoid:GetAttributes()["Melee"] then
								return UtilitiesModule:CancelTween(HumanoidRootPart, TweenDict)
							end
						end)

						-- CONNECTIONS
						table.insert(MeleeConnections, Connection1)
						table.insert(MeleeConnections, Connection2)
						table.insert(MeleeConnections, Connection3)
						--
						table.insert(ParentModule:GetConnections(), Connection1)
						table.insert(ParentModule:GetConnections(), Connection2)
						table.insert(ParentModule:GetConnections(), Connection3)

						local EndPosition = raycastResult.Position + raycastResult.Normal

						if EndPosition.Y < TargetCharacter.PrimaryPart.Position.Y then
							EndPosition = Vector3.new(EndPosition.X, EndPosition.Y, EndPosition.Z)
						end

						local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
						local tweeningInfo = {}
						tweeningInfo.CFrame = CFrame.new(EndPosition --[[raycastResult.Position + raycastResult.Normal]], HumanoidRootPart.CFrame.lookVector * 10)

						HumanoidRootPart.Anchored = true
						HasBudged = true


						UtilitiesModule:CancelTween(HumanoidRootPart, TweenDict)
						TweenDict[HumanoidRootPart] = TweenService:Create(HumanoidRootPart, tweenInfo, tweeningInfo)
						TweenDict[HumanoidRootPart]:Play()
						UtilitiesModule:CompleteTween(HumanoidRootPart, TweenDict)

						coroutine.wrap(function()
							if TweenDict[HumanoidRootPart] then
								TweenDict[HumanoidRootPart].Completed:Wait()
							end

							UtilitiesModule:DisconnectConnections(MeleeConnections)
							MeleeConnections = nil

							ParentModule:ResetCharacterVelocity()
							--ControlsModule:Enable()
							HumanoidRootPart.Anchored = false
						end)()
					end

					--HumanoidRootPart.Position = HumanoidRootPart.Position:Lerp(TargetHumanoidRootPart.Position, 0.3)
				end
			end
		end
	end

	return PackagedResult, HasBudged
end



local function _MeleeProcedure(ParentModule)
	local Success, Error = pcall(function()
		return MeleeProcedure(ParentModule)
	end)

	if Success then
		return Error
	else
		DebugModule:Print("Error | Melee Procedure: ".. tostring(Error))
	end
end

local function Melee(ParentModule)
	-- Functions
	-- INIT
	if --[[not]] --[[Humanoid:GetAttribute("Melee")]] ParentModule:IsPerformingPhysicalAction() then
		return nil
	end
	
	local EquippedWeaponModel = ParentModule:GetEquippedWeaponModel()
	local EquippedServerWeaponModel = ParentModule:GetEquippedServerWeaponModel()
	local ServerGunClientModule = ParentModule:GetServerGunClientModule()
	local GunClientModule = ParentModule:GetGunClientModule()	

	local HasSpeedCola = CharacterDrinksFolder:FindFirstChild("Speed Cola")

	if EquippedServerWeaponModel and GunClientModule then
		local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedServerWeaponModel.Name)
		local SoundProperties = {}

		if HasSpeedCola then
			SoundProperties["PlaybackSpeed"] = 2
		end

		ParentModule:SetIsShooting(false)
		Humanoid:SetAttribute("Melee", true)
		GunClientModule:StopFiring()
		ParentModule:CancelReload()
		--MeleeProcedure()
		local RaycastResult, DidBudge = _MeleeProcedure(ParentModule) --FPSHandlerModule:MeleeProcedure()

		CharacterProcessRemote:FireServer("Melee", EquippedServerWeaponModel, RaycastResult, DidBudge)
		coroutine.wrap(function()
			if not WeaponInfo["MeleeSound"] then
				SoundsModule:PlaySoundEffectByName("CharacterActions", "MeleeSwing", nil, nil, nil, SoundProperties)
			else
				SoundsModule:PlaySoundEffectById(WeaponInfo["MeleeSound"], nil, nil, nil, SoundProperties)
			end
			ParentModule:GetRequestFunctions()["Melee"]()
		end)()

		if HasSpeedCola then
			GunClientModule:Melee(2)		
		else
			GunClientModule:Melee()		
		end		
	end
end

-- DIRECT
function ActionModule.Initialise(Nilparam, ...)
	return Melee(...)
end

return ActionModule




