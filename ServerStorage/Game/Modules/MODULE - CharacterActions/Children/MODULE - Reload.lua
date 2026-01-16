local ReloadModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]
local ParticlesPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Particles"]

-- Elements
-- REMOTES
local EffectProcessRemote = ClientServerRemotesFolder["EffectProcess"]

-- Info Modules
local RoundTypesInfoModule = require(SharedInfoModulesFolder["RoundTypes"])
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])

-- Modules
local EffectsHandlerModule = require(SharedModulesFolder["EffectsHandler"])
local DamageModule = require(ServerModulesFolder["Damage"])
local SoundsModule = require(SharedModulesFolder["Sounds"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ServerObjectsModule = require(ServerModulesFolder["Objects"])
local DebugModule = require(SharedModulesFolder["Debug"])
local DebrisModule = require(SharedModulesFolder["Debris"])

-- CORE
local ReloadActionCooldownCache = {}

-- Functions
-- MECHANICS
local function ElectricCherry(Player, Character)
	-- Functions
	-- INIT
	local Success, Returned = pcall(function()
		return ServerObjectsModule:ObjectProcess("KillAura", Character)
	end)
	
	if Success then
		--[[for i, Character in pairs(Returned) do
			pcall(function()
				local Particle = EffectsHandlerModule:LoadParticleEmitter(Character.PrimaryPart, "ElectricCherry", nil, true)
				EffectsHandlerModule:ToggleParticleEmitters(Particle, true)
			end)
		end]]
		
		EffectProcessRemote:FireAllClients("EffectProcess", "FPSEffects", "ElectricCherry", Returned)
	end
	
	EffectProcessRemote:FireAllClients("EffectProcess", "FPSEffects", "ElectricCherry", Character)
end

local function Reload(CharacterActionsModule, Player, WeaponName)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player)
	local EquippedWeapon = Character:GetAttribute(Character:GetAttribute("EquippedWeapon"))
	EquippedWeapon = UtilitiesModule:WaitForChildTimed(Character, tostring(EquippedWeapon))
	
	-- Elements
	-- FOLDERS
	local DrinksFolder = Character:FindFirstChild("Drinks")
	
	if EquippedWeapon and EquippedWeapon.Name ~= WeaponName then
		--DebugModule:Print"Force Equipping from Reload: ".. tostring(WeaponName))
		EquippedWeapon = CharacterActionsModule:ClientRequest(Player, "EquipGun", WeaponName)
		--DebugModule:Print"Finished Force Equipping from Reload: ".. tostring(WeaponName))
	end
	
	if not EquippedWeapon or not Character or DamageModule:IsPlayerDead(Player) or not Player then
		DebugModule:Print("Reload | Cannot reload first check v")
		DebugModule:Print("Reload | EquippedWeapon: ".. tostring(EquippedWeapon))
		DebugModule:Print("Reload | Character: ".. tostring(Character))
		DebugModule:Print("Reload | PlayerDead: ".. tostring(DamageModule:IsPlayerDead(Player)))
		DebugModule:Print("Reload | Player: ".. tostring(Player))
		return nil
	end

	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedWeapon.Name)

	-- Elements
	-- HUMANOIDS
	local Humanoid = Character:FindFirstChildOfClass("Humanoid") --UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	if not Humanoid or Humanoid.Health <= 0 then
		return nil
	end
	
	-- REMOTES
	local CharacterProcessRemote = UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess")
	
	-- PARTS
	local BarrelPart = EquippedWeapon:FindFirstChild("Barrel") --EquippedWeapon.PrimaryPart

	-- Functions
	-- INIT
	if --[[table.find(ReloadActionCooldownCache, Player)]] ReloadActionCooldownCache[Player] then
		DebugModule:Print("Reload | Player already reloading!")
		return nil
	end

	if (table.find(RoundTypesInfoModule:GetTypesOfRound("Round"), WeaponInfo["RoundType"]) and EquippedWeapon:GetAttribute("Rounds") <= 0) or (table.find(RoundTypesInfoModule:GetTypesOfRound("Energy"), WeaponInfo["RoundType"]) and EquippedWeapon:GetAttribute("Energy") <= 0) then
		DebugModule:Print("Reload | No rounds available to reload with!")
		Humanoid:SetAttribute("Reload", false)
		return nil
	end

	--SoundsModule:PlaySoundEffectById(WeaponInfo["ReloadSound"], nil, BarrelPart, nil, nil)
	coroutine.wrap(function()
		EffectProcessRemote:FireAllClients("EffectProcess", "FPSEffects", "Reload", Character, EquippedWeapon)
	end)()
	
	Humanoid:SetAttribute("Reload", true)

	coroutine.wrap(function()
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | Started yield from reload invoke | Player: ".. tostring(Player))
		
		local FoundElectricCherry = DrinksFolder:FindFirstChild("Electric Cherry")
		
		if FoundElectricCherry then
			ElectricCherry(Player, Character)
		end
		
		local Reloaded = CharacterActionsModule:GetPlayerCharacterSignal(Player, "GunRequest"):InvokeClient(Player, "Reload")
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | Finished yield from reload invoke | Player: ".. tostring(Player))
		
		if not Reloaded or not Humanoid:GetAttributes()["Reload"] then
			DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | Client returned not reloaded | Player: ".. tostring(Player))
			
			if Humanoid then
				Humanoid:SetAttribute("Reload", false)
			end
			
			ReloadActionCooldownCache[Player] = nil
			return nil
		end
		
		if not WeaponInfo["ReloadIncrement"] and table.find(RoundTypesInfoModule:GetTypesOfRound("Round"), WeaponInfo["RoundType"]) then
			local AmountToStoreInMag = EquippedWeapon:GetAttribute("MaxRoundsInMag")
			local SpareRounds = EquippedWeapon:GetAttribute("RoundsInMag")

			if EquippedWeapon:GetAttribute("Rounds") + SpareRounds < EquippedWeapon:GetAttribute("MaxRoundsInMag") then
				AmountToStoreInMag = EquippedWeapon:GetAttribute("Rounds")
				EquippedWeapon:SetAttribute("RoundsInMag", AmountToStoreInMag + SpareRounds)
				SpareRounds = 0
			else
				EquippedWeapon:SetAttribute("RoundsInMag", AmountToStoreInMag)
			end

			EquippedWeapon:SetAttribute("Rounds", (EquippedWeapon:GetAttribute("Rounds") - AmountToStoreInMag) + SpareRounds)
		elseif table.find(RoundTypesInfoModule:GetTypesOfRound("Energy"), WeaponInfo["RoundType"]) then
			CharacterProcessRemote:FireClient(Player, "FPSHandler", "ResetEnergyUsage")
		end
		
		if Humanoid then
			Humanoid:SetAttribute("Reload", false)
		end
		
		ReloadActionCooldownCache[Player] = nil

	end)()

	--coroutine.wrap(function()
		--ReloadActionCooldownCache[Player] = nil
	--end)()

end
-- DIRECT
function ReloadModule.Initialise(NilParam, ...)
	return Reload(...)
end

return ReloadModule