-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local GameModeInfo = 
{
	["Icon"] = "rbxassetid://10270984345",
	["Description"] = "Die to zombies and you shall join their ranks",
	["ScoreTo"] = math.huge,
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
	["NeutralDisplay"] = true,
	["Teams"] =
	{
			[1] = {Name = "Infected", Colour = BrickColor.new("Sea green"), SpawnSound = {Id = "rbxassetid://11887148554"}, KillSound = {Id = "rbxassetid://11887148688"}, Weapons = {["Primary"] = --[["Skull"]] "Energy Sword"}, Character = {["Humanoid"] = {["MaxShield"] = 0, ["Shield"] = 0, ["WalkSpeed"] = 45, ["BaseSpeed"] = 45, ["JumpPower"] = 70}}, PickupWeapons = false, Lives = math.huge, StartMembers = 1},
		[2] = {Name = "Survivor", Colour = BrickColor.new("Institutional white"), Lives = math.huge}
	},
	["StartWeapons"] = -- GLOBAL -> For teams without weapons
	{
		["Primary"] = "Shotgun",
		["Secondary"] = "Pistol"	
	},
	["StartGrenades"] = 
	{
		["Frag"] = 0
	},
	["MinimumPlayers"] = 2,
	["FriendlyFire"] = false,
	["MapWeapons"] = false,
	["MapVehicles"] = false,	
	["MapGrenades"] = false,
	["Radar"] = false,
	["RestrictedMaps"] = false
}

return GameModeInfo