local EquipGunModule = {}

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

-- CORE
local CharactersEquippingWeapons = {}

-- Services
--local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function RemoveCharacterFromCache(Character)
	-- Functions
	-- INIT
	--[[local FoundIndex = table.find(CharactersEquippingWeapons, Character)
	
	if FoundIndex then
		table.remove(CharactersEquippingWeapons, FoundIndex)
	end]]
	
	CharactersEquippingWeapons[Character] = nil
end

local function EquipPlayerGun(CharacterActionsModule, Player, WeaponName, Force)
	--DebugModule:Print"Server Equip Check 1")
	
	if not WeaponName then
		DebugModule:Print("CharacterActions | ".. script.Name.. " | No weapon name | Player: ".. tostring(Player))
		--DebugModule:Print("No weapon name to equip!")
		return nil
	end
	
	-- CORE
	--DebugModule:Print"Server Equip Character Yield")

	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if table.find(CharactersEquippingWeapons, Character) ~= nil then
		DebugModule:Print("CharacterActions | ".. script.Name.. " | Character already equipping weapons | Player: ".. tostring(Player))
		return nil
	end
	
	--table.insert(CharactersEquippingWeapons, Character)
	
	CharactersEquippingWeapons[Character] = true
	
	local Success, GunModel = pcall(function()
		local PrimaryWeaponName = Character:GetAttribute("Primary")
		local SecondaryWeaponName = Character:GetAttribute("Secondary")
		
		local WeaponToFind = nil
		
		if WeaponName == PrimaryWeaponName then
			WeaponToFind = Character:FindFirstChild(SecondaryWeaponName)
			--CharacterActionsModule:ClientRequest("Unequip", Player, SecondaryWeaponName)
		else
			WeaponToFind = Character:FindFirstChild(PrimaryWeaponName)
			--CharacterActionsModule:ClientRequest("Unequip", Player, PrimaryWeaponName)
		end
		
		if WeaponToFind ~= nil or Force then
			CharacterActionsModule:ClientRequest(Player, "UnequipGun", WeaponToFind.Name)
		end
		
		local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponName)
		
		--DebugModule:Print"Server Equip Check 2")

		if not Character or (Character:FindFirstChild(WeaponName) and not Force) or DamageModule:IsPlayerDead(Player) then
			DebugModule:Print("Returning nil on server equip first check V")
			DebugModule:Print("EquipGun | Weapon In Character: ".. tostring(Character:FindFirstChild(WeaponName)))
			DebugModule:Print("EquipGun | Force: ".. tostring(Force))
			DebugModule:Print("EquipGun | IsPlayerDead: ".. tostring(DamageModule:IsPlayerDead(Player)))
			RemoveCharacterFromCache(Character)
			return nil
		end

		local GunModel = CharacterActionsModule:GetPlayerGunModel(Player, WeaponName)--GetGunModel(WeaponName)
		
		--DebugModule:Print"Server Equip Check 3")
		
		if not GunModel then
			--DebugModule:Print("Cannot find server weapon model for Equipping!")
			DebugModule:Print("CharacterActions | ".. script.Name.. " | Gun Model not found | Player: ".. tostring(Player))
			RemoveCharacterFromCache(Character)
			return nil
		end

		-- Elements
		-- PARTS
		local BarrelPart = GunModel:FindFirstChild("Barrel") --GunModel.PrimaryPart
		
		if not BarrelPart then
			DebugModule:Print("CharacterActions | ".. script.Name.. " | Barrel Part not found | Player: ".. tostring(Player))
			RemoveCharacterFromCache(Character)
			return nil
		end
		-- Functions
		-- INIT
		--DebugModule:Print"Server Equip Check 4")
		
		if not Character or not GunModel then
			DebugModule:Print("CharacterActions | ".. script.Name.. " | No Character or Gun Model | Player: ".. tostring(Player).. " | VVVV")
			DebugModule:Print("CharacterActions | ".. script.Name.. " | Character: ".. tostring(Character))
			DebugModule:Print("CharacterActions | ".. script.Name.. " | GunModel: ".. tostring(GunModel))
			RemoveCharacterFromCache(Character)
			return nil
		end
		
		--local ReplacementHandWeld = nil
		local GunModelHandWeld = UtilitiesModule:WaitForChildTimed(GunModel, "HandWeld")
		local Part0Value = UtilitiesModule:WaitForChildTimed(GunModelHandWeld, "Part0")
		local RightHand = Character:FindFirstChild("_RightHand") or Character:FindFirstChild("RightHand") --UtilitiesModule:WaitForChildTimed(Character, "RightHand")
		
		local PlayerArmourVariant = ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "Variant").Value
		local FoundSharedGunModel = SharedPartsWeaponsFolder:FindFirstChild(WeaponName)
		
		--[[if FoundSharedGunModel then
			local HandWeldsFolder = FoundSharedGunModel:FindFirstChild("HandWelds")
			
			if HandWeldsFolder then
				local FoundSpecificHandWeld = HandWeldsFolder:FindFirstChild(PlayerArmourVariant)
				ReplacementHandWeld = FoundSpecificHandWeld:Clone()
				ReplacementHandWeld.Parent = GunModelHandWeld.Parent
			end
		end]]
		
		--DebugModule:Print"Server Equip Check 5")
		
		if not GunModelHandWeld or not RightHand then
			DebugModule:Print("CharacterActions | ".. script.Name.. " | Not found GunModelHandWeld or RightHand | Player: ".. tostring(Player).. " | VVVV")
			DebugModule:Print("CharacterActions | ".. script.Name.. " | RightHand: ".. tostring(RightHand))
			DebugModule:Print("CharacterActions | ".. script.Name.. " | GunModelHandWeld: ".. tostring(GunModelHandWeld))
			--[[if ReplacementHandWeld then
				ReplacementHandWeld:Destroy()
			end]]
			RemoveCharacterFromCache(Character)
			return nil
		end
		
		--DebugModule:Print("Server Equipping weapon: ".. tostring(WeaponName))
		
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
		GunModel.Parent = Character
		
		pcall(function()
			ObjectsModule:ObjectProcess("NoneRaycastable", GunModel)
			ObjectsModule:ObjectProcess("SetCollisionGroup", GunModel, tostring(Player:GetAttributes()["CollisionGroup"]).. "Characters")
			PhysicsModule:ServerRequest("CanCollide", GunModel, false)
			PhysicsModule:ServerRequest("Anchored", GunModel, false)
		end)
			
		pcall(function()
			SoundsModule:PlaySoundEffectById(WeaponInfo["ToggleSound"], nil, BarrelPart, nil)
		end)
		
		return GunModel
	end)
	
	if not Success then
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | EquipPlayerGun | Error: ".. tostring(GunModel))
	end
	
	RemoveCharacterFromCache(Character)
	
	return GunModel
end

-- DIRECT
function EquipGunModule.Initialise(NilParam, ...)
	return EquipPlayerGun(...)
end

return EquipGunModule