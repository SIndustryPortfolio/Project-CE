local DrinkPerksModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local RequiredModules = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

local function Drink(ModuleName, Player, ...)
	-- Functions
	-- INIT
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if not Character then
		return nil
	end
	
	local DrinksFolder = Character:FindFirstChild("Drinks")
	
	if not DrinksFolder then
		return nil
	end
	
	local BoolValue = Instance.new("BoolValue")
	BoolValue.Name = ModuleName --DrinkMachine.Name
	BoolValue.Value = true
	BoolValue.Parent = DrinksFolder --FoundDrinksFolder
	
	RequiredModules[ModuleName]:Initialise(Player, ...)
end

-- DIRECT
function DrinkPerksModule.Drink(NilParam, ModuleName, Player, ...)
	return Drink(ModuleName, Player, ...)
end

-- INIT
RunSubModules()

return DrinkPerksModule