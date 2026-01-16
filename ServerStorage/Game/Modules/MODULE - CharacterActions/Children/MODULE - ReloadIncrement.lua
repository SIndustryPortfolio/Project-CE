local ReloadIncrementModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Elements
-- REMOTES
local EffectProcessRemote = ClientServerRemotesFolder["EffectProcess"]

-- Info Modules
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])

-- Modules
local DamageModule = require(ServerModulesFolder["Damage"])
local SoundsModule = require(SharedModulesFolder["Sounds"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function ReloadIncrement(CharacterActionsModule, Player, WeaponName)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player)
	local EquippedWeapon = Character:GetAttribute(Character:GetAttribute("EquippedWeapon"))
	EquippedWeapon = UtilitiesModule:WaitForChildTimed(Character, tostring(EquippedWeapon))
	
	if not EquippedWeapon or not Character or DamageModule:IsPlayerDead(Player) then
		return nil
	end

	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(EquippedWeapon.Name)

	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")

	-- PARTS
	local BarrelPart = EquippedWeapon:FindFirstChild("Barrel") --EquippedWeapon.PrimaryPart
	
	if not BarrelPart then
		return nil
	end
	
	-- Functions
	-- INIT
	--DebugModule:Print("ReloadIncrement | Incrementing Reload!")
	
	if EquippedWeapon:GetAttribute("Rounds") <= 0 then
		--DebugModule:Print("ReloadIncrement | Weapon has no rounds!")
		return nil
	end

	--SoundsModule:PlaySoundEffectById(WeaponInfo["ReloadSound"], nil, BarrelPart, nil, nil)
	
	coroutine.wrap(function()
		local AmountToStoreInMag = WeaponInfo["ReloadIncrement"]
		
		if not AmountToStoreInMag then
			DebugModule:Print("ReloadIncrement | No reload increment was found in weapon: ".. tostring(EquippedWeapon))
			
			return CharacterActionsModule:ClientRequest(Player, "Reload", WeaponName)			
		end
		
		local RoundsAvailable = EquippedWeapon:GetAttribute("Rounds")
		local MaxRoundsInMag = EquippedWeapon:GetAttribute("MaxRoundsInMag")
		
		if AmountToStoreInMag > RoundsAvailable then
			AmountToStoreInMag = RoundsAvailable
		end
		
		if (MaxRoundsInMag - EquippedWeapon:GetAttribute("RoundsInMag")) >= AmountToStoreInMag then
			EquippedWeapon:SetAttribute("RoundsInMag", EquippedWeapon:GetAttribute("RoundsInMag") + AmountToStoreInMag)
			EquippedWeapon:SetAttribute("Rounds", EquippedWeapon:GetAttribute("Rounds") - AmountToStoreInMag)
		else
			AmountToStoreInMag = (MaxRoundsInMag - EquippedWeapon:GetAttribute("RoundsInMag"))
			
			if AmountToStoreInMag <= RoundsAvailable then
				EquippedWeapon:SetAttribute("RoundsInMag", EquippedWeapon:GetAttribute("RoundsInMag") + AmountToStoreInMag)
				EquippedWeapon:SetAttribute("Rounds", EquippedWeapon:GetAttribute("Rounds") - AmountToStoreInMag)
			end
		end
	end)()

	--coroutine.wrap(function()
		--ReloadActionCooldownCache[Player] = nil
	--end)()

end
-- DIRECT
function ReloadIncrementModule.Initialise(NilParam, ...)
	return ReloadIncrement(...)
end

return ReloadIncrementModule