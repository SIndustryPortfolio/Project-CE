local SwitchWeaponModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Info Modules
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])

-- Modules
local SoundsModule = require(SharedModulesFolder["Sounds"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DamageModule = require(ServerModulesFolder["Damage"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function SwitchWeapon(CharacterActionsModule, Player, WeaponType, Force)
	-- CORE
	local ValidWeaponTypes = {"Primary", "Secondary"}
	local Character = UtilitiesModule:GetCharacter(Player, true)

	-- Functions
	-- INIT
	--DebugModule:Print("SwitchWeapon | Server switching weapon for: ".. tostring(Player).. " | WeaponType: ".. tostring(WeaponType).. " | Force: ".. tostring(Force))
	
	--DebugModule:Print"Switiching Weapon Check 1")
	
	if not table.find(ValidWeaponTypes, WeaponType) or not Character or DamageModule:IsPlayerDead(Player) then
		return nil
	end
	
	--DebugModule:Print"Switiching Weapon waiting for Character to load")
	
	if Character:GetAttributes()["EquippedWeapon"] == nil or Character:GetAttributes()[Character:GetAttribute("EquippedWeapon")] == nil then
		DebugModule:Print("CharacterActions | ".. script.Name.. " | Waiting for Character attributes | Player: ".. tostring(Player))
		repeat
			task.wait()
		until Character:GetAttributes()["EquippedWeapon"] ~= nil and Character:GetAttributes()[Character:GetAttribute("EquippedWeapon")] ~= nil or not Character or not Player
	end
	
	--DebugModule:Print"Switiching Weapon Check 2")
	
	if (Character:GetAttribute("EquippedWeapon") ~= WeaponType and not Force) or Force then
		CharacterActionsModule:ClientRequest(Player, "UnequipGun", Character:GetAttribute(Character:GetAttribute("EquippedWeapon")))
		--CharacterActionsModule:UnequipGun(Player, Character:GetAttribute(Character:GetAttribute("EquippedWeapon")))
		Character:SetAttribute("EquippedWeapon", WeaponType)
		--CharacterActionsModule:EquipPlayerGun(Player, Character:GetAttribute(WeaponType))
		CharacterActionsModule:ClientRequest(Player, "EquipGun", Character:GetAttribute(WeaponType))
	else
		DebugModule:Print("SwitchWeapon | CANNOT SWITCH WEAPON | Equipped Weapon Type: ".. tostring(Character:GetAttribute("EquippedWeapon")).. " | Requested Weapon Type: ".. tostring(WeaponType))
	end	
end

-- DIRECT
function SwitchWeaponModule.Initialise(NilParam, ...)
	return SwitchWeapon(...)
end

return SwitchWeaponModule