local CommandModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedWeaponsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]
local ServerDrinkPerksModuleInstance = ServerModulesFolder["DrinkPerks"]
local SharedDropsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Drops"]

-- Modules
local DrinkPerksModule = require(ServerModulesFolder["DrinkPerks"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
local PhysicsModule = require(SharedModulesFolder["Physics"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local AdminType = "Owner"

local MaxRandomBounds = 3

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function FindMatchingChild(Directory, String)
	-- CORE
	local ToReturn = {}
	
	-- Functions
	-- INIT
	for i, Model in pairs(Directory:GetChildren()) do
		if string.lower(String) ~= "all" then
			if string.lower(string.sub(Model.Name, 1, #String)) == string.lower(String) then
				table.insert(ToReturn, Model)
				--return Model
			end
		else
			table.insert(ToReturn, Model)
		end
	end
	
	return ToReturn
end

local function SpawnPowerUpDrop(Player, Character, PowerUpDropName)
	-- Functions
	-- INIT
	local PowerUpDropModels = FindMatchingChild(SharedDropsFolder, PowerUpDropName)
	
	for i, PowerUpDropModel in pairs(PowerUpDropModels) do
		if not PowerUpDropModel then
			DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | Cannot find drop name!")
			return nil
		end
		
		local RandomX = math.random(-(MaxRandomBounds * 100), MaxRandomBounds * 100) / 100
		local RandomZ = math.random(-(MaxRandomBounds * 100), MaxRandomBounds * 100) / 100

		local PowerUpDropModel = PowerUpDropModel:Clone()
		
		local PartToShift = UtilitiesModule:GetPartToShift(PowerUpDropModel)
		
		PartToShift.CFrame = (Character.PrimaryPart.CFrame * CFrame.new(RandomX, 0, RandomZ))

		PhysicsModule:ServerRequest("CanCollide", PowerUpDropModel, false)

		CollectionService:AddTag(PowerUpDropModel, "Power Up Drop")

		PowerUpDropModel.Parent = workspace:WaitForChild("Dump")["Power Up Drops"]
	end
end

local function SpawnDrink(Player, Character, DrinkName)
	-- Functions
	-- INIT
	local Drinks = FindMatchingChild(ServerDrinkPerksModuleInstance, DrinkName)
	
	local CharacterDrinksFolder = Character:FindFirstChild("Drinks")
	
	for i, Drink in pairs(Drinks) do
		if CharacterDrinksFolder and CharacterDrinksFolder:FindFirstChild(Drink.Name) then
			continue
		end
				
		DrinkPerksModule:Drink(Drink.Name, Player)
	end
end

local function SpawnWeapon(Player, Character, WeaponName)
	-- Functions
	-- INIT
	local WeaponModels = FindMatchingChild(SharedWeaponsFolder, WeaponName)
	
	for i, WeaponModel in pairs(WeaponModels) do
		if not WeaponModel then
			DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | Cannot find weapon name!")
			return nil
		end
		
		local RandomX = math.random(-(MaxRandomBounds * 100), MaxRandomBounds * 100) / 100
		local RandomZ = math.random(-(MaxRandomBounds * 100), MaxRandomBounds * 100) / 100

		
		local WeaponModelClone = WeaponModel:Clone()
		WeaponModelClone:SetAttribute("NoneRespawnable", true)
		
		WeaponModelClone:SetPrimaryPartCFrame(Character.PrimaryPart.CFrame * CFrame.new(RandomX, 0, RandomZ))
		
		PhysicsModule:ServerRequest("CanCollide", WeaponModelClone, true)
		ObjectsModule:ObjectProcess("Raycastable", WeaponModel)
		
		CollectionService:AddTag(WeaponModelClone, "Weapons")
			
		WeaponModelClone.Parent = workspace:WaitForChild("Dump")["Weapons"]
	end
end

-- CORE FUNCTIONS
local TypeToFunctions = 
{
	["drink"] = SpawnDrink,
	["weapon"] = SpawnWeapon,
	["powerupdrop"] = SpawnPowerUpDrop		
}

local function Initialise(AdminModule, Player, Args)
	-- Functions
	-- INIT
	local Recipients = AdminModule:GetRecipientsFromString(Player, Args[1])
	local Type = string.lower(Args[2])
	local ItemName = string.lower(AdminModule:GetMessageFromArgs(Args, 3))


	for i, Recipient in pairs(Recipients) do
		local RecipientCharacter = UtilitiesModule:GetCharacter(Recipient, true)

		if not RecipientCharacter then
			continue
		end

		TypeToFunctions[Type](Recipient, RecipientCharacter, ItemName)
	end
end

-- DIRECT
function CommandModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function CommandModule.GetAdminType()
	return AdminType
end

return CommandModule