-- CORE
local GunInfo = 
{
	["Technology"] = "UNSC",
	["ProjectileType"] = "Raycast",
	["Type"] = "Burst",
	--
	["FireRate"] = 5,
	["RoundWidth"] = 0.25,
	["MaxRoundsInMag"] = 36,
	["RoundsInMag"] = 36,
	["Mags"] = 6,
	["MaxMags"] = 8,
	["Spread"] = 0.125,
	["ReloadType"] = "Static",
	["ReloadSpeed"] = 1,
	--
	["AdsZoom"] = 1.5,
	["AdsSize"] = UDim2.new(.75, 18, .75, 0),
	["AdsAspectRatio"] = 1,
	--
	["ShakeIntensity"] = 0.5,
	["ShakeDuration"] = 0.1,
	--
	["Damage"] = 75,
	["HeadshotDamageMultiplier"] = 2,
	--
	["GunIcon"] = "rbxassetid://10007952888",
	["CursorIcon"] = "rbxassetid://10008136209",
	["AdsIcon"] = "rbxassetid://8711942086",	
	["CursorSize"] = UDim2.new(0.05, 0,0.05, 0),
	["RoundType"] = "Light",
	--
	["FireSound"] = "rbxassetid://1044434118",
	["ReloadSound"] = "rbxassetid://6808977427",
	["MeleeSound"] = "rbxassetid://1306070008",
	["EmptyMagSound"] = "rbxassetid://240785604",
	["ToggleSound"] = "rbxassetid://7405483764",
	--
	["DevOnly"] = true	
}

-- Functions
-- INIT
GunInfo["Rounds"] = (GunInfo["MaxRoundsInMag"] * GunInfo["Mags"]) - GunInfo["RoundsInMag"]

return GunInfo