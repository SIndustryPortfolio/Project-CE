local MeleeModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ServerRemotesFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Remotes"]

-- Elements
-- REMOTES
local MainRemote = ServerRemotesFolder["Main"]
local EffectProcessRemote = ClientServerRemotesFolder["EffectProcess"]

-- Info Modules
local RoundTypesInfoModule = require(SharedInfoModulesFolder["RoundTypes"])
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])
local CharacterInfoModule = require(SharedInfoModulesFolder["Character"])
local CharacterActionsInfoModule = require(ServerInfoModulesFolder["CharacterActions"])

-- Modules
local SoundsModule = require(SharedModulesFolder["Sounds"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ServerObjectsModule = require(ServerModulesFolder["Objects"])
local ServerLobbyModule = require(ServerModulesFolder["Lobby"])
local ServerGameModule = require(ServerModulesFolder["Game"])
local DamageModule = require(ServerModulesFolder["Damage"])
local DebugModule = require(SharedModulesFolder["Debug"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])

-- CORE
local MeleeActionCooldownCache = {}


-- Functions
-- MECHANICS
local function EndMelee(Player, Humanoid)
	-- CORE
	local MeleeInfo = CharacterActionsInfoModule:GetCharacterActionInfo("Melee")
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	-- Functions
	-- INIT
	if not Character or not Humanoid:GetAttributes()["Melee"] and not MeleeActionCooldownCache[Player] then
		return nil
	end
	
	local DrinksFolder = Character:FindFirstChild("Drinks")
	local HasSpeedCola = DrinksFolder:FindFirstChild("Speed Cola")
	
	coroutine.wrap(function()
		local Cooldown = MeleeInfo["Cooldown"]
		
		if HasSpeedCola then
			Cooldown /= 2
		end
		
		task.wait(Cooldown)
		if Humanoid then
			Humanoid:SetAttribute("Melee", false)
		end
		MeleeActionCooldownCache[Player] = nil
	end)()
end

local function ThumperPump(Player, Character, WeaponModel, raycastResult)
	if not raycastResult then
		return nil
	end
	
	-- CORE
	local MeleeInfo = CharacterActionsInfoModule:GetCharacterActionInfo("Melee")
	
	-- Functions
	-- INTI
	local RootModel = UtilitiesModule:GetRootModel(raycastResult.Instance)
	
	if not RootModel then
		return nil
	end	
	
	local RootModelHumanoid = RootModel:FindFirstChildOfClass("Humanoid")
	
	--[[if not RootModelHumanoid or RootModelHumanoid.Health <= 0 then
		return nil
	end]]
	
	EffectProcessRemote:FireAllClients("EffectProcess", "FPSEffects", "ThumperPumper", --[[Character]] raycastResult)

	ServerObjectsModule:ObjectProcess("Melee", UtilitiesModule:GetCharacter(Player, true), raycastResult, 50)
	
	for i, Zombie in pairs(workspace["Temporary"]["AI"]:GetChildren()) do
		local Success, Error = pcall(function()
			if not Zombie then
				return nil
			end
			
			local ZombieHumanoid = Zombie:FindFirstChildOfClass("Humanoid")
			
			if ZombieHumanoid.Health <= 0 then
				return nil
			end
			
			local Hrp = Zombie.PrimaryPart
			
			if (Hrp.Position - RootModel.PrimaryPart.Position).Magnitude > 30 then
				return nil
			end
			
			local Direction = (RootModel.PrimaryPart.Position - Hrp.Position).Unit * 30
			
			local BlackList = {Zombie}
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
			raycastParams.FilterDescendantsInstances = BlackList
			
			local result = workspace:Raycast(RootModel.PrimaryPart.Position, Direction, raycastParams)
			
			if not result then
				return nil
			end
			
			if not result.Instance:IsDescendantOf(RootModel) then
				return nil
			end
						
			ServerObjectsModule:ObjectProcess("Melee", UtilitiesModule:GetCharacter(Player, true), result, 50)
			local Success, Error = pcall(function()
				return Hurt(Player, Character, WeaponModel, ZombieHumanoid, true, result, nil, true)
			end)
			
			if not Success then
				DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | ThumperPump | Hurt | Error: ".. tostring(Error))
			end
		end)
		
		if not Success then
			DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | ThumperPump | Error: ".. tostring(Error))
		end
	end
	
	--Hurt(Player, Character, RootModelHumanoid, true, raycastResult, nil)
end

function Hurt(Player, Character, WeaponModel, TargetHumanoid, HasThumperPumper, raycastResult, BadgeOverwrite, Force)
	-- CORE
	local WeaponInfo = nil 
	
	if WeaponModel then
		pcall(function()
			WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponModel.Name)
		end)
	end
	
	local MeleeInfo = CharacterActionsInfoModule:GetCharacterActionInfo("Melee")
	local PlayerCharacterProcessRemote = UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess")

	-- Functions
	-- INIT	
	if not Force then
		if WeaponInfo and WeaponInfo["Type"] == "Melee" then	
			if WeaponInfo["Technology"] == "UNSC" then
				WeaponModel:SetAttribute("RoundsInMag", math.clamp(WeaponModel:GetAttribute("RoundsInMag") - 1, 0, math.huge))
			elseif WeaponInfo["Technology"] == "Covenant" then
				WeaponModel:SetAttribute("Energy", math.clamp(WeaponModel:GetAttribute("Energy") - --[[1]] WeaponInfo["MinimumEnergyConsumption"], 0, math.huge))
			end
		end
	end
	
	if TargetHumanoid and TargetHumanoid.Health > 0 then
		local TargetCharacter = TargetHumanoid.Parent
		local TargetPrimaryPart = UtilitiesModule:GetPartToShift(TargetCharacter) --TargetCharacter.PrimaryPart

		local ToDamage = MeleeInfo["Damage"]
		
		if WeaponInfo and WeaponInfo["Type"] == "Melee" and WeaponInfo["Damage"] then
			if (WeaponModel:GetAttributes()["Energy"] or 0) > 0 then
				ToDamage = WeaponInfo["Damage"]
			end			
		end
		
		if HasThumperPumper then
			ToDamage *= 3
		end

		local IsDead, DamagedHealth, DamageTaken = DamageModule:TakeDamage(TargetHumanoid, ToDamage, Player, nil, Character.PrimaryPart.Position)
		
		--[[local TargetPlayer = game.Players:GetPlayerFromCharacter(TargetCharacter)

		if not TargetPlayer and TargetCharacter.Parent == workspace["Temporary"]["AI"] then
			TargetPlayer = {["Character"] = TargetCharacter, Name = TargetCharacter.Name, Team = {Name = TargetCharacter:GetAttributes()["Team"]}, ["AI"] = true}
		end]]
		
		local TargetPlayer = ShortcutsModule:GetPlayerFromCharacter(TargetCharacter)
		
		local Distance = nil
		
		pcall(function()
			Distance = ((raycastResult.Origin or raycastResult._Origin or UtilitiesModule:GetCharacter(Player, true).PrimaryPart.Position) - raycastResult.Position).Magnitude
		end)
		
		if TargetPlayer and DamageTaken then
			MainRemote:Fire("PlayerShotRegistered", Player)
			if typeof(TargetPlayer) ~= "table" then
				ServerGameModule:GameProcess("AddXp", Player, "Melee", {Target = TargetCharacter})
			end
			
			if Player.Settings.Game.VisualDamage.Value == "ON" or Player.Settings.Game.HitMarker.Value == "ON" then
				PlayerCharacterProcessRemote:FireClient(Player, "Damage", Character, MeleeInfo["Damage"], true, DamagedHealth, raycastResult.Position)
			end
			
			if TargetHumanoid.Health <= 0  --[[and DeadPlayer.Team ~= Player.Team]] then
				--ServerLobbyModule:IncrementValue(Player, "Kills")
				local Success, Error = pcall(function()
					if typeof(TargetPlayer) == "table" then
						return ServerGameModule:GameProcess("Kill", Player, "Melee", TargetPlayer, nil, BadgeOverwrite, true, Distance)
					else
						return ServerGameModule:GameProcess("Kill", Player, "Melee", TargetPlayer, nil, BadgeOverwrite, nil, Distance)
					end
				end)
				
				
				if not Success then
					DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | GameProcess 'Kill' | Error: ".. tostring(Error))
				end
			end
		end
	end
end

local function Melee(CharacterActionsModule, Player, WeaponModel, raycastResult, DidBudge)
	-- Elements
	local PlayerCharacterProcessRemote = UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess")
	
	-- CORE	
	local Character = UtilitiesModule:GetCharacter(Player, true)
	local MeleeInfo = CharacterActionsInfoModule:GetCharacterActionInfo("Melee")
	local MeleeMaxDistance = CharacterInfoModule:GetCharacterInfo("MeleeDistance")
	local BadgeOverwrite = nil

	local EquippedWeapon = Character:GetAttribute(Character:GetAttribute("EquippedWeapon"))
	EquippedWeapon = UtilitiesModule:WaitForChildTimed(Character, tostring(EquippedWeapon))

	if not EquippedWeapon or not Character or DamageModule:IsPlayerDead(Player) then
		DebugModule:Print("CharacterActions | ".. script.Name.. " | Returning nil on first check V")
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | EquippedWeapon: ".. tostring(EquippedWeapon))
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | Character: ".. tostring(Character))
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | IsPlayerDead: ".. tostring(DamageModule:IsPlayerDead(Player)))
		return nil
	end
	
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	-- CORE
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedWeapon.Name)
	local CharacterDrinksFolder = Character:FindFirstChild("Drinks")
	
	local HasThumperPumper = false
	
	if CharacterDrinksFolder:FindFirstChild("Thumper Pumper") then
		HasThumperPumper = true
	end
	
	if WeaponInfo and WeaponInfo["BudgeDistance"] and DidBudge then
		MeleeMaxDistance += WeaponInfo["BudgeDistance"]
	end
	
	--[[pcall(function()
		TargetHumanoid = HitPart:FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid")

		if not TargetHumanoid then
			TargetHumanoid = HitPart:FindFirstAncestorOfClass("Model"):FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid")

			if not TargetHumanoid then
				TargetHumanoid = HitPart:FindFirstAncestorOfClass("Model"):FindFirstAncestorOfClass("Model"):FindFirstAncestorOfClass("Model"):FindFirstChildOfClass("Humanoid")
			end
		end
	end)]]

	-- PARTS
	local BarrelPart = EquippedWeapon:FindFirstChild("Barrel") --EquippedWeapon.PrimaryPart
	
	-- Functions
	-- INIT
	if MeleeActionCooldownCache[Player] or Humanoid:GetAttribute("Melee") or not BarrelPart then
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | Returning nil on second check V")
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | CooldownCache: ".. tostring(MeleeActionCooldownCache[Player]))
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | Humanoid Melee Attribute: ".. tostring(Humanoid:GetAttribute("Melee")))
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | BarrelPart: ".. tostring(BarrelPart))
		return nil
	end
		
	Humanoid:SetAttribute("Melee", true)

	if not raycastResult then
		EndMelee(Player, Humanoid)
		return nil
	end
	
	local HitPart = raycastResult.Instance

	if not HitPart then
		EndMelee(Player, Humanoid)
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | No melee hit | Player: ".. tostring(Player.Name))
		return nil
	end

	if HitPart.Name == "Back" then
		BadgeOverwrite = "Beatdown"
	end
	
	-- Elements
	-- Humanoids
	local TargetHumanoid = UtilitiesModule:GetHumanoidFromHit(HitPart)
	
	MeleeActionCooldownCache[Player] = true

	Humanoid:SetAttribute("Reload", false)
	--Humanoid:SetAttribute("Melee", true)
	
	coroutine.wrap(function()
		EffectProcessRemote:FireAllClients("EffectProcess", "FPSEffects", "Melee", Character, EquippedWeapon)
		--SoundsModule:PlaySoundEffectById(WeaponInfo["MeleeSound"], nil, BarrelPart, nil, nil)
		--CharacterActionsModule:GetPlayerCharacterSignal(Player, "GunRequest"):InvokeClient(Player, "Melee")
	end)()
	
	if (raycastResult.Position - Character.PrimaryPart.Position).Magnitude > (--[[MeleeInfo["MaxDistance"]] MeleeMaxDistance * 1.5) then
		return EndMelee(Player, Humanoid)
	end
	
	coroutine.wrap(function()
		local Success, Error = pcall(function()
			Hurt(Player, Character, WeaponModel, TargetHumanoid, HasThumperPumper, raycastResult, BadgeOverwrite)
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | Melee | Error: ".. tostring(Error))
		end
				--[[if TargetHumanoid:GetAttributes()["Shield"] ~= nil then
					if TargetHumanoid:GetAttribute("Shield") > 0 then
						local Result = TargetHumanoid:GetAttribute("Shield") - MeleeInfo["Damage"]

						if Result < 0 then
							TargetHumanoid:SetAttribute("Shield", 0)
							TargetHumanoid:TakeDamage(-Result)
						else
							TargetHumanoid:SetAttribute("Shield", TargetHumanoid:GetAttribute("Shield") - MeleeInfo["Damage"])
						end
					else
						TargetHumanoid:TakeDamage(MeleeInfo["Damage"])
					end

					SoundsModule:PlaySoundEffectByName("CharacterActions", "MeleeDamage", nil, Character.PrimaryPart)
				else
					TargetHumanoid:TakeDamage(MeleeInfo["Damage"])
				end]]
			--end
	end)()
	
	coroutine.wrap(function()
		if raycastResult and HitPart ~= nil and raycastResult.Position ~= nil then
			--if (raycastResult.Position - Character.PrimaryPart.Position).Magnitude <= (MeleeInfo["MaxDistance"] * 1.5) then
				--if raycastResult then
					EffectProcessRemote:FireAllClients("Melee", Player, raycastResult)
					if not HasThumperPumper then
						ServerObjectsModule:ObjectProcess("Melee", UtilitiesModule:GetCharacter(Player, true), raycastResult)
					else
				ThumperPump(Player, UtilitiesModule:GetCharacter(Player, true), WeaponModel, raycastResult)
					end
				--end
			--end
		end
	end)()
	
	EndMelee(Player, Humanoid)
end


-- DIRECT
function MeleeModule.Initialise(NilParam, ...)
	return Melee(...)
end

return MeleeModule