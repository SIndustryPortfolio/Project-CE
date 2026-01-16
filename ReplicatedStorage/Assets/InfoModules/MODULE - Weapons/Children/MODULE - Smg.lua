-- CORE
local GunInfo = 
{
	["Technology"] = "UNSC",
	["ProjectileType"] = "Raycast",
	["Type"] = "Automatic",
	--
	["FireRate"] = 20,
	["RoundWidth"] = 0.25,
	["MaxRoundsInMag"] = 60,
	["RoundsInMag"] = 60,
	["Mags"] = 6,
	["MaxMags"] = 8,
	["Spread"] = 1.5,
	["ReloadType"] = "Static",
	["ReloadSpeed"] = 1,
	--
	["AdsZoom"] = 1,
	["AdsSize"] = UDim2.new(1, 18, 1, 0),
	["AdsAspectRatio"] = 2.79,
	--
	["ShakeIntensity"] = 0.25,
	["ShakeDuration"] = 0.075,
	--
	["Damage"] = 8,
	["HeadshotDamageMultiplier"] = 0.5,
	--
	["GunIcon"] = "rbxassetid://10272080190",
	["CursorIcon"] = "rbxassetid://10272155822",
	["AdsIcon"] = "rbxassetid://8736126265",	
	["CursorSize"] = UDim2.new(0.1, 0,0.1, 0),
	["RoundType"] = "Light",
	["HudRows"] = 3,
	--
	["FireSound"] = "rbxassetid://5293762009",
	["ReloadSound"] = "rbxassetid://5293680865",
	["MeleeSound"] = "rbxassetid://1306070008",
	["EmptyMagSound"] = "rbxassetid://240785604",
	["ToggleSound"] = "rbxassetid://5509331917"
}

-- Functions
-- INIT
GunInfo["Rounds"] = (GunInfo["MaxRoundsInMag"] * GunInfo["Mags"]) - GunInfo["RoundsInMag"]

return GunInfo