local ForceEquipGunModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedPartsWeaponsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]

-- Info Modules
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])

-- Modules
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local PhysicsModule = require(SharedModulesFolder["Physics"])
local SoundsModule = require(SharedModulesFolder["Sounds"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DamageModule = require(ServerModulesFolder["Damage"])
local DebugModule = require(SharedModulesFolder["Debug"])
local ObjectsModule = require(SharedModulesFolder["Objects"])

-- Functions
-- MECHANICS
local function EquipPlayerGun(CharacterActionsModule, Player, WeaponModel)
	--DebugModule:Print"Server Equip Check 1")
	
	local Character = UtilitiesModule:GetCharacter(Player)
	local GunModel = WeaponModel --GetGunModel(WeaponName)
	
	if not GunModel then
		DebugModule:Print("CharacterActions | ".. script.Name.. " | No Gun Model! | Player: ".. tostring(Player))
		return nil
	end
	
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(GunModel.Name)
	
	--DebugModule:Print"Server Equip Check 3")
	
	--if not GunModel then
	--	--DebugModule:Print("Cannot find server weapon model for Equipping!")
	--	return nil
	--end

	-- Elements
	-- PARTS
	local BarrelPart = GunModel:FindFirstChild("Barrel") --GunModel.PrimaryPart
	
	if not BarrelPart then
		DebugModule:Print("CharacterActions | ".. script.Name.. " | No BarrelPart | Player: ".. tostring(Player))
		return nil
	end
	
	-- Functions
	-- INIT
	--DebugModule:Print"Server Equip Check 4")
	
	if not Character or not GunModel then
		DebugModule:Print("CharacterActions | No Character | Player: ".. tostring(Player))
		return nil
	end
	
	--local ReplacementHandWeld = nil
	local GunModelHandWeld = UtilitiesModule:WaitForChildTimed(GunModel, "HandWeld")
	local Part0Value = UtilitiesModule:WaitForChildTimed(GunModelHandWeld, "Part0")
	local RightHand = Character:FindFirstChild("_RightHand") or Character:FindFirstChild("RightHand") --UtilitiesModule:WaitForChildTimed(Character, "RightHand")
	
	--DebugModule:Print"Server Equip Check 5")
	
	local PlayerArmourVariant = ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "Variant").Value
	local FoundSharedGunModel = SharedPartsWeaponsFolder:FindFirstChild(WeaponModel.Name)

	--[[if FoundSharedGunModel then
		local HandWeldsFolder = FoundSharedGunModel:FindFirstChild("HandWelds")

		if HandWeldsFolder then
			local FoundSpecificHandWeld = HandWeldsFolder:FindFirstChild(PlayerArmourVariant)
			ReplacementHandWeld = FoundSpecificHandWeld:Clone()
			ReplacementHandWeld.Parent = GunModelHandWeld.Parent
		end
	end]]
	
	if not GunModelHandWeld or not RightHand then
		DebugModule:Print("CharacterActions | ".. script.Name.. " | No GunModelHandWeld or no RightHand | Player: ".. tostring(Player).. " | VVVV")
		DebugModule:Print("CharacterActions | ".. script.Name.. " | GunModelHandWeld: ".. tostring(GunModelHandWeld))
		DebugModule:Print("CharacterActions | ".. script.Name.. " | RightHand: ".. tostring(RightHand))
		return nil
	end
	
	--DebugModule:Print("Force equipping weapon: ".. tostring(WeaponModel))
	
	--[[if ReplacementHandWeld then
		Part0Value = ReplacementHandWeld:WaitForChild("Part0")

		Part0Value.Value = GunModelHandWeld:WaitForChild("Part0").Value
		ReplacementHandWeld.Name = "HandWeld"

		GunModelHandWeld:Destroy()
		GunModelHandWeld = ReplacementHandWeld
	end]]
	
	if Part0Value and Part0Value.Value then
		GunModelHandWeld.Part0 = Part0Value.Value
	end
	
	GunModelHandWeld.Part1 = RightHand
	--GunModel.Parent = Character
	
	pcall(function()
		ObjectsModule:ObjectProcess("NoneRaycastable", GunModel)
		ObjectsModule:ObjectProcess("SetCollisionGroup", GunModel, tostring(Player:GetAttributes()["CollisionGroup"]).. "Characters")
		PhysicsModule:ServerRequest("CanCollide", GunModel, false)
		PhysicsModule:ServerRequest("Anchored", GunModel, false)
	end)
	
	GunModel.Parent = Character
	
	pcall(function()
		SoundsModule:PlaySoundEffectById(WeaponInfo["ToggleSound"], nil, BarrelPart, nil)
	end)
	
	return GunModel
end

-- DIRECT
function ForceEquipGunModule.Initialise(NilParam, ...)
	return EquipPlayerGun(...)
end

return ForceEquipGunModule