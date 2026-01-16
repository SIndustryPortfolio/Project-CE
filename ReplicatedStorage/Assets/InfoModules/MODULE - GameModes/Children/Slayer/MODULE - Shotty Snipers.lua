-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local GameModeInfo = 
{
	["Icon"] = "rbxassetid://10304114167",
	["Description"] = "Eliminate all others!",
	["ScoreTo"] = 25,
	["RoundTime"] = UtilitiesModule:MinutesToSeconds(10),
	["XpPerScore"] = 5,
	--["WinXpMultiplier"] = 2,
	["Lose"] = 
	{
		["CECoins"] = 5		
	},
	["Win"] = 
	{
		["XpMultiplier"] = 2,
		["CECoins"] = 15
	},
	["Teams"] = nil,
	["StartWeapons"] = 
	{
		["Primary"] = "Sniper",
		["Secondary"] = "Shotgun"	
	},
	["StartGrenades"] = 
	{
		["Frag"] = 4,
		["Plasma"] = 4
	},
	["MinimumPlayers"] = 1,
	["Lives"] = math.huge,
	["FriendlyFire"] = true,
	["MapWeapons"] = false,
	["MapVehicles"] = false,
	["MapGrenades"] = true,
	["Radar"] = true,
	["RestrictedMaps"] = false
}

return GameModeInfo