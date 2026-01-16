-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local GameModeInfo = 
{
	["Icon"] = "rbxassetid://11806010837",
	["Description"] = "Destroy the waves of AI zombies. YOU HAVE 1 LIFE",
	["ScoreTo"] = math.huge,
	["TimeRoundBased"] = true,
	--["RoundTime"] = UtilitiesModule:MinutesToSeconds(10),
	["XpPerScore"] = 0,
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
	["NeutralDisplay"] = true,
	["Teams"] =
	{
		[1] = {Name = "Survivor", Colour = BrickColor.new("Institutional white"), Lives = 1},
		[2] = {Name = "Infected", Colour = BrickColor.new("Sea green"), Weapons = {["Primary"] = "Skull"}, Character = {["Humanoid"] = {["MaxShield"] = 5, ["Shield"] = 5, ["WalkSpeed"] = 25, ["BaseSpeed"] = 25, ["JumpPower"] = 70}}, PickupWeapons = false, Lives = math.huge, StartMembers = 0},
		[3] = {Name = "Boss", Colour = BrickColor.new("Crimson"), Weapons = {["Primary"] = "Energy Sword"}, Character = {["Humanoid"] = {["MaxShield"] = 5, ["Shield"] = 5, ["WalkSpeed"] = 20, ["BaseSpeed"] = 20, ["JumpPower"] = 70}}, PickupWeapons = false, Lives = math.huge, StartMembers = 0, SpawnWith = 2}	
	},
	["StartWeapons"] = -- GLOBAL -> For teams without weapons
	{
		["Primary"] = "Pistol",
		["Secondary"] = "Skull"	
	},
	["StartGrenades"] = 
	{
		["Frag"] = 4,
		["Plasma"] = 4
	},
	["FriendlyFire"] = false,
	["MapWeapons"] = false,
	["MapVehicles"] = true,
	["MapGrenades"] = false,
	["Radar"] = false,
	["RestrictedMaps"] = true,
	--
	["NoLivesHint"] = "RESPAWN NEXT ROUND",
	--
	["Hidden"] = false
}

return GameModeInfo