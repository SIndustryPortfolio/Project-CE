-- CORE
local GunInfo = 
{
	["Technology"] = "Covenant",
	["ProjectileType"] = "Projectile",
	["Type"] = "Melee",
	--
	["FireRate"] = 6,
	["MaxEnergy"] = 100,
	["Energy"] = 100,
	["MinimumEnergyConsumption"] = 10,
	["CurrentEnergyUsage"] = 0,
	["Spread"] = 0.125,
	["BudgeDistance"] = 10,
	--
	["AdsZoom"] = 1,
	["AdsSize"] = UDim2.new(1, 18, 1, 0),
	["AdsAspectRatio"] = 2.79,
	--
	["ShakeIntensity"] = 0.5,
	["ShakeDuration"] = 0.1,
	--
	["Damage"] = 300,
	["HeadshotDamageMultiplier"] = 0.5,
	--
	["GunIcon"] = "rbxassetid://12266525264",
	["CursorIcon"] = "rbxassetid://12204244287",
	["AdsIcon"] = "rbxassetid://8736126265",	
	["CursorSize"] = UDim2.new(0.1, 0,0.1, 0),
	["RoundType"] = "Plasma",	
	--
	["FireSound"] = "rbxassetid://7267474210",
	["ReloadSound"] = "rbxassetid://7432098524",
	--["ReloadSound"] = "rbxassetid://10821837193",
	--["MeleeSound"] = "rbxassetid://7267474210",
	["MeleeSound"] = "rbxassetid://7601865567",
	["EmptyMagSound"] = "rbxassetid://1903570867",
	["ToggleSound"] = "rbxassetid://5508953366",
	--
	["DevOnly"] = true	
}

-- Functions
-- INIT
--GunInfo["Rounds"] = (GunInfo["MaxRoundsInMag"] * GunInfo["Mags"]) - GunInfo["RoundsInMag"]
GunInfo["ShakeDuration"] = 1 / GunInfo["FireRate"]

return GunInfo