-- CORE
local GunInfo = 
{
	["Technology"] = "UNSC",
	["ProjectileType"] = "Raycast",
	--["Type"] = "ScatterShot",
	["Type"] = "ScatterShot",
	--
	["FireRate"] = 1.5,
	["RoundWidth"] = 0.25,
	["MaxRoundsInMag"] = 8,
	["RoundsInMag"] = 8,
	["Mags"] = 6,
	["MaxMags"] = 8,
	["Scatter"] = 8,
	["Spread"] = 2,
	["ReloadType"] = "Increment",
	["ReloadSpeed"] = 1,
	["ReloadIncrement"] = 2,
	--
	["AdsZoom"] = 1,
	["AdsSize"] = UDim2.new(1, 18, 1, 0),
	["AdsAspectRatio"] = 2.79,
	--
	["ShakeIntensity"] = 0.75,
	["ShakeDuration"] = 0.1,
	--
	["Damage"] = 30,
	["DamageDropOffMultiplier"] = 0.5,
	["HeadshotDamageMultiplier"] = 0.5,
	--
	["GunIcon"] = "rbxassetid://9200029504",
	["CursorIcon"] = "rbxassetid://9200028824",
	["AdsIcon"] = "rbxassetid://8736126265",	
	["CursorSize"] = UDim2.new(0.1, 0,0.1, 0),
	["RoundType"] = "Shell",
	--
	["FireSound"] = "rbxassetid://2001619675",
	["ReloadSound"] = "rbxassetid://5677987779",
	["MeleeSound"] = "rbxassetid://1306070008",
	["EmptyMagSound"] = "rbxassetid://240785604",
	["ToggleSound"] = "rbxassetid://4458750140"
}

-- Functions
-- INIT
GunInfo["Rounds"] = (GunInfo["MaxRoundsInMag"] * GunInfo["Mags"]) - GunInfo["RoundsInMag"]

return GunInfo