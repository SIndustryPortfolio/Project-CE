local UnequipGunModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Info Modules
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])

-- Modules
local DebrisModule = require(SharedModulesFolder["Debris"])
local DamageModule = require(ServerModulesFolder["Damage"])
local SoundsModule = require(SharedModulesFolder["Sounds"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function WeldToCharacter(WeldFolder, Character)
	-- Functions
	-- INIT
	for i, Folder in pairs(WeldFolder:GetChildren()) do
		local Part1Name = Folder.Name
		
		for x, Weld in pairs(Folder:GetChildren()) do
			Weld.Part1 = Character:FindFirstChild("_".. Part1Name) or Character:FindFirstChild(Part1Name)
		end
	end
end

local function RemoveUnequipGun(Player)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	-- Functions
	-- INIT
	if not Character then
		return nil
	end
	
	for i, Model in pairs(Character:GetChildren()) do
		if Model.Name == "UnequipWeapon" then
			DebrisModule:AddItem(Model)
		end
	end
	
	--[[local UnequipGun = Character:FindFirstChild("UnequipWeapon")
	
	if UnequipGun then
		return UnequipGun:Destroy()
	end]]
end

local function CreateUnequipGun(Player, BackpackWeaponModel)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if not Character then
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | No character found")
		return nil
	end
	
	local WeaponModelClone = BackpackWeaponModel:Clone()
	
	-- Functions
	-- INIT
	RemoveUnequipGun(Player)
	
	WeaponModelClone.Name = "UnequipWeapon"
	WeaponModelClone:SetAttribute("Weapon", BackpackWeaponModel.Name)
	WeaponModelClone.Parent = Character
	
	-- Elements
	-- WELDS
	local FoundHandWeld = WeaponModelClone:FindFirstChild("HandWeld")
	
	if FoundHandWeld then
		FoundHandWeld:Destroy()
	end
	
	-- FOLDERS
	local UnequipWeldFolder = UtilitiesModule:WaitForChildTimed(WeaponModelClone, "UnequipWeld")
	
	-- INIT
	return WeldToCharacter(UnequipWeldFolder, Character)
end

local function UnequipGun(CharacterActionsModule, Player, WeaponName)
	if not WeaponName then
		DebugModule:Print(script.Parent.Name..  " | ".. script.Name.. " | No weapon name!")
		return nil
	end

	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if not Character then
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | No Character! | Player: ".. tostring(Player).. " | WeaponName: ".. tostring(WeaponName))
		return nil
	end	
	
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	local GunModel = Character:FindFirstChild(tostring(WeaponName)) --UtilitiesModule:WaitForChildTimed(Character, WeaponName)
	
	if not Character or DamageModule:IsPlayerDead(Player) then
		DebugModule:Print("UnequipGun | No character or character is dead | Player: ".. tostring(Player))
		return nil
	end
	
	Humanoid:SetAttribute("Reload", false)
	
	local WeaponInfo = nil
	
	if typeof(WeaponName) == "Instance" then
		DebugModule:Print("CharacterActions | ".. script.Name.. " | Creating unequip gun | Player: ".. tostring(Player).. " | Gun: ".. tostring(WeaponName))
		WeaponName.Parent = Player:WaitForChild("Backpack")
		return CreateUnequipGun(Player, WeaponName)
	end
	
	--DebugModule:Print("Server unequipping: ".. tostring(WeaponName))
	
	if GunModel then
		WeaponInfo = WeaponsInfoModule:GetWeaponInfo(GunModel.Name)
	end

	-- Elements
	-- PARTS
	local BarrelPart = nil

	if GunModel then
		BarrelPart = GunModel:FindFirstChild("Barrel") --GunModel.PrimaryPart
	end

	-- Functions
	-- INIT
	if GunModel then
		SoundsModule:PlaySoundEffectById(WeaponInfo["ToggleSound"], nil, BarrelPart, nil)	
	end
	
	DebugModule:Print("CharacterActions | ".. script.Name.. " | Checking has unequipped")
	UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess"):FireClient(Player, "UnequipGun")
	CharacterActionsModule:GetPlayerCharacterSignal(Player, "GunRequest"):InvokeClient(Player, "HasUnequipped", WeaponName)
	DebugModule:Print("CharacterActions | ".. script.Name.. " | Finished checking has unequipped")
	
	if GunModel and --[[GunModel:IsDescendantOf(Character)]] GunModel.Parent == Character then
		--GunModel:Destroy()
		DebugModule:Print(script.Name.. " | Storing weapon: ".. tostring(GunModel).. " | Player: ".. tostring(Player.Name))
		GunModel.Parent = Player:WaitForChild("Backpack")
		CreateUnequipGun(Player, GunModel)
	else
		pcall(function()
			DebugModule:Print("UnequipGun | Gun Model doesn't exist or isn't descendant of character V")
			DebugModule:Print(script.Name.. " | GunModel: ".. tostring(GunModel))
			DebugModule:Print(script.Name.. " | GunModel Parent: ".. tostring(GunModel.Parent))
		end)
	end
end

-- DIRECT
function UnequipGunModule.Initialise(NilParam, ...)
	return UnequipGun(...)
end

return UnequipGunModule