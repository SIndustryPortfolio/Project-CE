local PerkDrinksInfoModule = {}

-- CORE
local PerkDrinksInfo = 
{
	["Juggernog"] = {Image = {Id = "rbxassetid://11845232602"}, LiquidColour = BrickColor.new("Really red")},
	["Double Tap"] = {Image = {Id = "rbxassetid://11855871306"}, LiquidColour = BrickColor.new("Bright orange")},
	["Deadshot Daiquiri"] = {Image = {Id = "rbxassetid://11861739597"}, LiquidColour = BrickColor.new("Smoky grey")},
	["Electric Cherry"] = {Image = {Id = "rbxassetid://11870852792"}, LiquidColour = BrickColor.new("Crimson")},
	["Speed Cola"] = {Image = {Id = "rbxassetid://11879358203"}, LiquidColour = BrickColor.new("Slime green")},
	["Stamin Up"] = {Image = {Id = "rbxassetid://11881252774"}, LiquidColour = BrickColor.new("Neon orange")},
	["PHD Flopper"] = {Image = {Id = "rbxassetid://11889033707"}, LiquidColour = BrickColor.new("Pastel violet")},
	["Thumper Pumper"] = {Image = {Id = "rbxassetid://11910202221"}, LiquidColour = BrickColor.new("Medium red")},
	["Full Metal Jacket"] = {Image = {Id = "rbxassetid://12223083824"}, LiquidColour = BrickColor.new("Neon orange")}
}

-- Functions
-- DIRECT
function PerkDrinksInfoModule.GetPerkDrinkInfo(NilParam, SettingName)
	return PerkDrinksInfo[SettingName]
end

function PerkDrinksInfoModule.GetAllPerkDrinksInfo()
	return PerkDrinksInfo
end

return PerkDrinksInfoModule