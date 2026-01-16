local PickupWeaponModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- InfoModules
local CharacterInfoModule = require(InfoModulesFolder["Character"])
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])
local RoundTypesInfoModule = require(InfoModulesFolder["RoundTypes"])

-- Modules
local DebrisModule = require(ModulesFolder["Debris"])
local DamageModule = require(ServerModulesFolder["Damage"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local WeaponsModule = require(ServerModulesFolder["Weapons"])
local DebugModule = require(ModulesFolder["Debug"])
local SoundsModule = require(ModulesFolder["Sounds"])
local WeaponsModule = require(ServerModulesFolder["Weapons"])
local TeamsModule = require(ServerModulesFolder["Teams"])

-- CORE
local WeaponsBeingPickedUp = {}
local CharactersPickingUpWeapons = {}

-- Functions
-- MECHANICS
--[[local function RemoveFromTable(Table, Element)
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
end]]

local function RefreshTables()
	-- Functions
	-- INIT
	--[[PassCheck(WeaponsBeingPickedUp)
	PassCheck(CharactersPickingUpWeapons)]]
end

local function PickupWeapon(CharacterActionsModule, Player, WeaponModel)
	-- CORE
	--DebugModule:Print("PickupWeapon | Picking up weapon: ".. tostring(WeaponModel))
	
	local PlayerTeam = Player.Team
	local TeamInfo = nil
	
	if PlayerTeam then
		TeamInfo = TeamsModule:GetTeamInfo(PlayerTeam)
		
		if TeamInfo and TeamInfo["PickupWeapons"] == false then
			return nil
		end
	end	
	
	local Character = UtilitiesModule:GetCharacter(Player, true)
	local CharacterRequestRemote = UtilitiesModule:GetPlayerCharacterSignal(Player, "CharacterRequest")
	
	
	local PartToShift = UtilitiesModule:GetPartToShift(WeaponModel)
	
	if not PartToShift then
		DebugModule:Print(script.Name.. " | PickupWeapon | Player: ".. tostring(Player)..  " | WeaponModel: ".. tostring(WeaponModel).. " | PartToShift: ".. tostring(PartToShift).. " | Error: No Part To Shift")
		return nil
	end
	
	local PickupDistance = (Character.PrimaryPart.Position - PartToShift.Position).Magnitude

	if PickupDistance > CharacterInfoModule:GetCharacterInfo("PickupDistance") then
		DebugModule:Print("PickupWeapon | Weapon too far! | Player: ".. tostring(Player).. " | Weapon: ".. tostring(WeaponModel))
		return nil
	end
	
	if not Character or not WeaponModel or DamageModule:IsPlayerDead(Player) or --[[table.find(WeaponsBeingPickedUp, WeaponModel)]] WeaponsBeingPickedUp[WeaponModel] or --[[table.find(CharactersPickingUpWeapons, Character)]] CharactersPickingUpWeapons[Character] then
		DebugModule:Print("PickupWeapon | Unable to pickup weapon V")
		
		DebugModule:Print("Character: ".. tostring(Character))
		DebugModule:Print("WeaponModel: ".. tostring(WeaponModel))
		DebugModule:Print("IsPlayerDead: ".. tostring(DamageModule:IsPlayerDead(Player)))
		DebugModule:Print("WeaponBeingPickedUp: ".. WeaponsBeingPickedUp[WeaponModel]) --tostring(table.find(WeaponsBeingPickedUp, WeaponModel)))
		DebugModule:Print("CharacterPickingUpWeapon: ".. CharactersPickingUpWeapons[WeaponModel]) --tostring(table.find(CharactersPickingUpWeapons, Character)))
		
		return nil
	end
	
	if WeaponModel:GetAttributes()["RestrictedToUser"] ~= nil and WeaponModel:GetAttributes()["RestrictedToUser"] ~= "" and WeaponModel:GetAttributes()["RestrictedToUser"] ~= Player.Name then
		DebugModule:Print(script.Name.. " | Weapon is restricted! | Restriction To: ".. tostring(WeaponModel:GetAttributes()["RestrictedToUser"]).. " | Player: ".. tostring(Player))
		return nil
	end
	
	--[[if not table.find(WeaponsBeingPickedUp, WeaponModel) then
		table.insert(WeaponsBeingPickedUp, WeaponModel)
	end]]
	
	if not WeaponsBeingPickedUp[WeaponModel] then
		WeaponsBeingPickedUp[WeaponModel] = true
	end
	
	--[[if not table.find(CharactersPickingUpWeapons, Character) then
		table.insert(CharactersPickingUpWeapons, Character)
	end]]
	
	if not CharactersPickingUpWeapons[Character] then
		CharactersPickingUpWeapons[Character] = true
	end
	
	local Success, Error = pcall(function()
		local PlaceToEquipTo = Character:GetAttribute("EquippedWeapon")
		
		-- Elements
		-- PARTS
		local HumanoidRootPart = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")
			
		local PrimaryWeaponName = Character:GetAttribute("Primary")
		local SecondaryWeaponName = Character:GetAttribute("Secondary")
		
		local ArsenalWeaponNames = {PrimaryWeaponName, SecondaryWeaponName}
		
		-- Elements
		-- PARTS
		local HumanoidRootPart = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")
		
		-- Functions
		-- INIT
		if table.find(ArsenalWeaponNames, WeaponModel.Name) ~= nil then
			for i, WeaponName in pairs(ArsenalWeaponNames) do
				if WeaponModel.Name ~= WeaponName or not WeaponModel then
					continue
				end
				
				local PlayerWeaponModel = WeaponsModule:GetPlayerWeaponFromName(Player, WeaponName)
				
				if not PlayerWeaponModel then
					continue
				end
				
				local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(PlayerWeaponModel.Name)
				
				--DebugModule:Print("PickupWeapon | Adding ammo to: ".. tostring(WeaponName))
				
				if not table.find(RoundTypesInfoModule:GetTypesOfRound("Round"), WeaponInfo["RoundType"]) then
					continue
				end
				
				if not WeaponModel:GetAttributes()["Rounds"]  and not WeaponModel:GetAttributes()["MysteryBox"] then
					WeaponsModule:InitialiseWeapon(WeaponModel, nil, nil, true)
				end
				
				local RemainingAmmo, HasAdded = WeaponsModule:WeaponProcess("AddAmmo", PlayerWeaponModel, WeaponModel:GetAttribute("Rounds"))
				
				if HasAdded then
					SoundsModule:PlaySoundEffectByName("CharacterActions", "PickupWeapon", nil, HumanoidRootPart)
				end
					
				if RemainingAmmo > 0 then
					WeaponModel:SetAttribute("Rounds", RemainingAmmo)
				else
					--DebugModule:Print("Destroying weapon 1")
					WeaponModel:Destroy()
				end
				
				if WeaponModel:GetAttribute("Rounds") <= 0 then
					--DebugModule:Print("Destroying weapon 2")
					WeaponModel:Destroy()
				end
			end
		else
			if CharacterRequestRemote:InvokeClient(Player, "IsSwitchingWeapon") == false then
				local PlayerWeaponModel = WeaponsModule:GetPlayerWeaponFromName(Player, Character:GetAttribute(PlaceToEquipTo))
				--CharacterActionsModule:ClientRequest(Player, "UnequipGun", WeaponModel)
				
				if not WeaponModel:GetAttributes()["DontDropNextWeapon"] then
					CharacterActionsModule:ClientRequest(Player, "DropWeapon")
				else
					DebrisModule:AddItem(PlayerWeaponModel)
				end
				--DebugModule:Print("PickupWeapon | Character: ".. tostring(Character))
				--DebugModule:Print("PickupWeapon | WeaponModel: ".. tostring(WeaponModel))
				
				WeaponModel.Parent = Character
				
				--DebugModule:Print("PickupWeapon | WeaponModel Parent: ".. tostring(WeaponModel.Parent))
				
				if not WeaponModel:GetAttributes()["Rounds"] then
					WeaponsModule:InitialiseWeapon(WeaponModel, Player, true)
				end
				
				Character:SetAttribute(PlaceToEquipTo, WeaponModel.Name)
				WeaponModel:SetAttribute("DontDropNextWeapon", nil)
				WeaponModel:SetAttribute("RestrictedToUser", nil)
				WeaponModel:SetAttribute("MysteryBox", nil)
				CharacterActionsModule:ClientRequest(Player, "ForceEquipGun", WeaponModel, true)
				--CharacterActionsModule:ClientRequest(Player, "SwitchWeapon", Character:GetAttribute("EquippedWeapon"), true)
			else
				DebugModule:Print("Character is switching weapon (Previous weapon still loading)!")
			end
		end
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | PickupWeapon | Error: ".. tostring(Error))
	end
	
	--DebugModule:Print("PickupWeapon | Clearing debounce tables!")
	
	--local FoundWeaponModelIndex = table.find(WeaponsBeingPickedUp, WeaponModel)
	
	--[[if FoundWeaponModelIndex then
		--table.remove(WeaponsBeingPickedUp, FoundWeaponModelIndex)
		RemoveFromTable(WeaponsBeingPickedUp, WeaponModel)
	end]]
	
	WeaponsBeingPickedUp[WeaponModel] = nil
	
	--[[local FoundCharacterIndex = table.find(CharactersPickingUpWeapons, Character)
	
	if FoundCharacterIndex then
		--table.remove(CharactersPickingUpWeapons, FoundCharacterIndex)
		RemoveFromTable(CharactersPickingUpWeapons, Character)
	end]]
	
	CharactersPickingUpWeapons[Character] = nil
	
	--RefreshTables()
	
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
	WeaponsBeingPickedUp = {}
	CharactersPickingUpWeapons = {}
end

return PickupWeaponModule