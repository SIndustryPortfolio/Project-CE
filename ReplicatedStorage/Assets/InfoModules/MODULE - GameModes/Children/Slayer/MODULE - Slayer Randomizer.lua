-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local GameModeInfo = 
{
	["Icon"] = "rbxassetid://12247606839",
	["Description"] = "Eliminate all others!",
	["ScoreTo"] = 25,
	["RoundTime"] = UtilitiesModule:MinutesToSeconds(10),
	["XpPerScore"] = 5,
	["Lose"] = 
	{
		["CECoins"] = 5		
	},
	["Win"] = 
	{
		["XpMultiplier"] = 2,
		["CECoins"] = 15
	},
	--["WinXpMultiplier"] = 2,
	["Teams"] = nil,
	["StartWeapons"] = 
	{
		["Primary"] = "Random",
		["Secondary"] = "Random"	
	},
	["StartGrenades"] = 
	{
		["Frag"] = 4,
		["Plasma"] = 4
	},
	["MinimumPlayers"] = 1,
	["Lives"] = math.huge,
	["FriendlyFire"] = true,
	["MapWeapons"] = true,
	["MapVehicles"] = false,
	["MapGrenades"] = true,
	["Radar"] = true,
	["RestrictedMaps"] = false
}

return GameModeInfo