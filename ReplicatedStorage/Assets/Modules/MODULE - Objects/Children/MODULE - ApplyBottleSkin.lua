local ApplyBottleSkinModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local PerkDrinksInfoModule = require(InfoModulesFolder["PerkDrinks"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function Initialise(ObjectsModule, BottleModel, DrinkPerkName)
	-- CORE
	local PerkDrinkInfo = PerkDrinksInfoModule:GetPerkDrinkInfo(DrinkPerkName)
	
	-- Elements
	-- PARTS
	local LiquidPart = UtilitiesModule:WaitForChildTimed(BottleModel, "Liquid")
	local IconLeftPart = UtilitiesModule:WaitForChildTimed(BottleModel, "IconLeft")
	local IconRightPart = UtilitiesModule:WaitForChildTimed(BottleModel, "IconRight")
	
	-- CORE
	local Decals = {IconLeftPart:FindFirstChildOfClass("Decal"), IconRightPart:FindFirstChildOfClass("Decal")}
	
	-- Functions
	-- INIT
	for i, Decal in pairs(Decals) do
		Decal.Texture = PerkDrinkInfo["Image"]["Id"]
	end
	
	LiquidPart.BrickColor = PerkDrinkInfo["LiquidColour"]
end

-- DIRECT
function ApplyBottleSkinModule.Initialise(NilParam, ObjectsModule, BottleModel, DrinkPerkName)
	return Initialise(ObjectsModule, BottleModel, DrinkPerkName)
end

function ApplyBottleSkinModule.End()

end

return ApplyBottleSkinModule