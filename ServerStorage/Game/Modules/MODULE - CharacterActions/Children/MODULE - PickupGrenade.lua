local PickupWeaponModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Info Modules
local CharacterInfoModule = require(InfoModulesFolder["Character"])
local GrenadesInfoModule = require(InfoModulesFolder["Grenades"])

-- Modules
local DamageModule = require(ServerModulesFolder["Damage"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])
local SoundsModule = require(ModulesFolder["Sounds"])
local WeaponsModule = require(ServerModulesFolder["Weapons"])
local DebrisModule = require(ModulesFolder["Debris"])

-- CORE
local GrenadesBeingPickedUp = {}
--local CharactersPickingUpGrenades = {}

-- Functions
-- MECHANICS
local function RemoveFromTable(Table, Element)
	-- INIT
	local Pass = true
	
	repeat
		Pass = true
		for i, _Instance in pairs(Table) do
			if _Instance == Element then
				Pass = false
				table.remove(Table, i)
				break
			end
		end
	until Pass
end

local function PassCheck(Table)
	-- INIT
	if not Table then
		return nil
	end
	
	local Pass = true

	repeat
		Pass = true

		for i, _Instance in pairs(Table) do
			if not _Instance then
				Pass = false
				table.remove(Table, i)
				break
			end
		end
	until Pass
end

local function RefreshTables()
	-- Functions
	-- INIT
	PassCheck(GrenadesBeingPickedUp)
	--PassCheck(CharactersPickingUpGrenades)
end

local function PickupWeapon(CharacterActionsModule, Player, GrenadeModel)
	-- CORE
	--DebugModule:Print("PickupWeapon | Picking up weapon: ".. tostring(WeaponModel))
	
	local Character = UtilitiesModule:GetCharacter(Player)	
	local CharacterRequestRemote = UtilitiesModule:GetPlayerCharacterSignal(Player, "CharacterRequest")
	
	if not Character or not GrenadeModel or DamageModule:IsPlayerDead(Player) or table.find(GrenadesBeingPickedUp, GrenadeModel) --[[or table.find(CharactersPickingUpGrenades, Character)]] then
		DebugModule:Print("PickupGrenade | Unable to pickup Grenade V")
		
		DebugModule:Print("Character: ".. tostring(Character))
		DebugModule:Print("GrenadeModel: ".. tostring(GrenadeModel))
		DebugModule:Print("IsPlayerDead: ".. tostring(DamageModule:IsPlayerDead(Player)))
		DebugModule:Print("GrenadeBeingPickedUp: ".. tostring(table.find(GrenadesBeingPickedUp, GrenadeModel)))
		--DebugModule:Print("CharacterPickingUpGrenade: ".. tostring(table.find(CharactersPickingUpGrenades, Character)))
		
		return nil
	end
	
	local PrimaryPart = UtilitiesModule:GetPartToShift(GrenadeModel)
	
	if not PrimaryPart then
		return nil
	end
	
	local PickupDistance = (Character.PrimaryPart.Position - PrimaryPart.Position).Magnitude

	if PickupDistance > CharacterInfoModule:GetCharacterInfo("PickupDistance") then
		DebugModule:Print("PickupWeapon | Grenade too far! | Player: ".. tostring(Player).. " | Grenade: ".. tostring(GrenadeModel))
		return nil
	end
	
	if not table.find(GrenadesBeingPickedUp, GrenadeModel) then
		table.insert(GrenadesBeingPickedUp, GrenadeModel)
	end
	
	--[[if not table.find(CharactersPickingUpGrenades, Character) then
		table.insert(CharactersPickingUpGrenades, Character)
	end]]
	
	local PlaceToEquipTo = tostring(GrenadeModel.Name).. "Grenades" --Character:GetAttribute("EquippedWeapon")
	
	-- Elements
	-- PARTS		
	--local PrimaryWeaponName = Character:GetAttribute("Primary")
	--local SecondaryWeaponName = Character:GetAttribute("Secondary")
	
	--local ArsenalWeaponNames = {PrimaryWeaponName, SecondaryWeaponName}
	
	-- Elements
	-- PARTS
	local HumanoidRootPart = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")
	
	-- Functions
	-- INIT
	local ToDestroy = false
	
	local AmountOfGrenades = Character:GetAttribute(PlaceToEquipTo)
	local MaxAmountOfGrenades = GrenadesInfoModule:GetGrenadeSetting("MaxGrenades")
	
	local GrenadesLeft = MaxAmountOfGrenades - AmountOfGrenades
	
	if GrenadesLeft >= 1 then
		--GrenadeModel:Destroy()
		ToDestroy = true
		SoundsModule:PlaySoundEffectByName("CharacterActions", "PickupGrenade", nil, HumanoidRootPart)
		--Character:SetAttribute(PlaceToEquipTo, AmountOfGrenades + 1)
		WeaponsModule:WeaponProcess("AddGrenades", Character, GrenadeModel.Name, 1)
	end
	
	--DebugModule:Print("PickupWeapon | Clearing debounce tables!")
	
	local FoundGrenadeModelIndex = table.find(GrenadesBeingPickedUp, GrenadeModel)
	
	if FoundGrenadeModelIndex then
		--table.remove(WeaponsBeingPickedUp, FoundWeaponModelIndex)
		RemoveFromTable(GrenadesBeingPickedUp, GrenadeModel)
	end
	
	--[[local FoundCharacterIndex = table.find(CharactersPickingUpGrenades, Character)
	
	if FoundCharacterIndex then
		--table.remove(CharactersPickingUpWeapons, FoundCharacterIndex)
		RemoveFromTable(CharactersPickingUpGrenades, Character)
	end]]
	
	if ToDestroy then
		--GrenadeModel:Destroy()
		DebrisModule:AddItem(GrenadeModel)
	end
	
	RefreshTables()
	
	--table.remove(WeaponsBeingPickedUp, table.find(WeaponsBeingPickedUp, WeaponModel))
	--table.remove(CharactersPickingUpWeapons, table.find(CharactersPickingUpWeapons, Character))
end

-- DIRECT
function PickupWeaponModule.Initialise(NilParam, ...)
	return PickupWeapon(...)
end

function PickupWeaponModule.End()
	-- Function
	-- INIT
	GrenadesBeingPickedUp = {}
	--CharactersPickingUpGrenades = {}
end

return PickupWeaponModule