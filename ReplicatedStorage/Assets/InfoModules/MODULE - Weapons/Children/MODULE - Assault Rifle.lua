-- CORE
local GunInfo = 
{
	["Technology"] = "UNSC",
	["ProjectileType"] = "Raycast",
	["Type"] = "Automatic",
	--
	["FireRate"] = 15,
	["RoundWidth"] = 0.25,
	["MaxRoundsInMag"] = 36,
	["RoundsInMag"] = 36,
	["Mags"] = 6,
	["MaxMags"] = 8,
	["Spread"] = 1,
	["ReloadType"] = "Static",
	["ReloadSpeed"] = 1,
	--
	["AdsZoom"] = 1,
	["AdsSize"] = UDim2.new(1, 18, 1, 0),
	["AdsAspectRatio"] = 2.79,
	--
	["ShakeIntensity"] = 0.4,
	["ShakeDuration"] = 0.1,
	--
	["Damage"] = 10,
	["HeadshotDamageMultiplier"] = 0.5,
	--
	["GunIcon"] = "rbxassetid://7040648553",
	["CursorIcon"] = "rbxassetid://7040657279",
	["AdsIcon"] = "rbxassetid://8736126265",	
	["CursorSize"] = UDim2.new(0.075, 0,0.075, 0),
	["RoundType"] = "Light",
	--
	["FireSound"] = "rbxassetid://6150719521",
	["ReloadSound"] = "rbxassetid://6648991885",
	["MeleeSound"] = "rbxassetid://1306070008",
	["EmptyMagSound"] = "rbxassetid://240785604",
	["ToggleSound"] = "rbxassetid://7405483764"
}

-- Functions
-- INIT
GunInfo["Rounds"] = (GunInfo["MaxRoundsInMag"] * GunInfo["Mags"]) - GunInfo["RoundsInMag"]

return GunInfo