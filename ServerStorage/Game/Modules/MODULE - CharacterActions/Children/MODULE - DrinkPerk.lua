local DrinkPerkModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local PartsBottlesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Bottles"]

-- Elements
-- REMOTES
local EffectProcessRemote = ClientServerRemotesFolder["EffectProcess"]

-- Info Modules
local GrenadesInfoModule = require(SharedInfoModulesFolder["Grenades"])
local PerkDrinksInfoModule = require(SharedInfoModulesFolder["PerkDrinks"])
--local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])
local CharacterActionsInfoModule = require(ServerInfoModulesFolder["CharacterActions"])

-- Modules
local SoundsModule = require(SharedModulesFolder["Sounds"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ServerObjectsModule = require(ServerModulesFolder["Objects"])
local ServerLobbyModule = require(ServerModulesFolder["Lobby"])
local ServerGameModule = require(ServerModulesFolder["Game"])
local DamageModule = require(ServerModulesFolder["Damage"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local ServerDrinkPerksModule = require(ServerModulesFolder["DrinkPerks"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local DrinkPerkActionCooldownCache = {}

-- Services
local PhysicsService = game:GetService("PhysicsService")
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function DrinkPerk(CharacterActionsModule, Player, DrinkMachine)
	-- Elements
	local PlayerCharacterProcessRemote = UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess")
	
	-- CORE	
	local Character = UtilitiesModule:GetCharacter(Player, true)
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	local HumanoidRootPart = Character.PrimaryPart
	
	if table.find(DrinkPerkActionCooldownCache, Player) ~= nil then
		return nil
	end
	
	if not DrinkMachine or not Character or DamageModule:IsPlayerDead(Player) or not table.find(CollectionService:GetTags(Character), "Drinking") or Humanoid:GetAttributes()["Drink"] then
		return nil
	end
	
	Humanoid:SetAttribute("Drink", true)
	
	local FoundDrinksFolder = Character:FindFirstChild("Drinks")
	
	if not FoundDrinksFolder then
		Humanoid:SetAttribute("Drink", false)
		return nil
	end
	
	table.insert(DrinkPerkActionCooldownCache, Player)
	
	-- CORE
	
	-- Functions
	-- INIT	
	local FoundBottleModel = PartsBottlesFolder:FindFirstChild("Bottle"):Clone()
	
	ObjectsModule:ObjectProcess("ApplyBottleSkin", FoundBottleModel, DrinkMachine.Name)
	
	local HandWeld = FoundBottleModel:FindFirstChild("HandWeld")
	HandWeld.Part1 = Character["RightHand"]
	FoundBottleModel.Parent = Character
	
	
	CharacterActionsModule:GetPlayerCharacterSignal(Player, "GunRequest"):InvokeClient(Player, "DrinkPerk", DrinkMachine.Name)
	
	DebrisModule:AddItem(FoundBottleModel)
	
	if not Character or not Humanoid or Humanoid.Health <= 0 then
		return nil
	end
	
	--[[HandWeld.Part1 = nil
	HandWeld.Part0 = nil
	HandWeld:Destroy()]]
	
	ServerDrinkPerksModule:Drink(DrinkMachine.Name, Player)
	
	CollectionService:RemoveTag(Character, "Drinking")
	
	local FoundIndex = table.find(DrinkPerkActionCooldownCache, Player)
	
	if FoundIndex then
		table.remove(DrinkPerkActionCooldownCache, FoundIndex)
	end
	
	Humanoid:SetAttribute("Drink", false)
end

-- DIRECT
function DrinkPerkModule.Initialise(NilParam, ...)
	return DrinkPerk(...)
end


return DrinkPerkModule