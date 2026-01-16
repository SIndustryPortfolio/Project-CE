-- CORE
local GunInfo = 
{
	["Technology"] = "UNSC",
	["ProjectileType"] = "Raycast",
	["Type"] = "Automatic",
	--
	["FireRate"] = 20,
	["RoundWidth"] = 0.25,
	["MaxRoundsInMag"] = 300,
	["RoundsInMag"] = 300,
	["Mags"] = 6,
	["MaxMags"] = 8,
	["Spread"] = .75,
	["ReloadType"] = "Static",
	["ReloadSpeed"] = 1,
	--
	["AdsZoom"] = 1,
	["AdsSize"] = UDim2.new(.5, 18, .5, 0),
	["AdsAspectRatio"] = 2.79,
	--
	["ShakeIntensity"] = 0.5,
	["ShakeDuration"] = 0.1,
	--
	["Damage"] = 12,
	["HeadshotDamageMultiplier"] = 0.5,
	--
	["GunIcon"] = "rbxassetid://11241372932",
	["CursorIcon"] = "rbxassetid://11252996531",
	["AdsIcon"] = "rbxassetid://8736126265",	
	["CursorSize"] = UDim2.new(0.075, 0,0.075, 0),
	["RoundType"] = "Light",
	["HudRows"] = 3,
	--
	["FireSound"] = "rbxassetid://341294413",
	["ReloadSound"] = "rbxassetid://5293680865",
	["MeleeSound"] = "rbxassetid://1306070008",
	["EmptyMagSound"] = "rbxassetid://240785604",
	["ToggleSound"] = "rbxassetid://5509331917"
}

-- Functions
-- INIT
GunInfo["Rounds"] = (GunInfo["MaxRoundsInMag"] * GunInfo["Mags"]) - GunInfo["RoundsInMag"]

return GunInfo