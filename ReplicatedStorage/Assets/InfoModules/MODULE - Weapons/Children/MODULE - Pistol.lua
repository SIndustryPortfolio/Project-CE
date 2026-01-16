-- CORE
local GunInfo = 
{
	["Technology"] = "UNSC",
	["ProjectileType"] = "Raycast",
	["Type"] = "Semi Automatic",
	--
	["FireRate"] = 6,
	["RoundWidth"] = 0.25,
	["MaxRoundsInMag"] = 12,
	["RoundsInMag"] = 12,
	["Mags"] = 6,
	["MaxMags"] = 8,
	["Spread"] = 0.125,
	["ReloadType"] = "Static",
	["ReloadSpeed"] = 1,
	--
	["AdsZoom"] = 2,
	["AdsSize"] = UDim2.new(0.187, 18, 0.4, 0),
	["AdsAspectRatio"] = 1,
	--
	["ShakeIntensity"] = 0.5,
	["ShakeDuration"] = 0.1,
	--
	["Damage"] = 20,
	["HeadshotDamageMultiplier"] = 1.5,
	--
	["GunIcon"] = "rbxassetid://7518249615",
	["CursorIcon"] = "rbxassetid://7518106699",
	["AdsIcon"] = "rbxassetid://8711942086",
	["CursorSize"] = UDim2.new(0.04, 0,0.04, 0),
	["RoundType"] = "Medium",
	--
	["FireSound"] = "rbxassetid://950065975",
	["ReloadSound"] = "rbxassetid://972980700",
	--["ReloadSound"] = "rbxassetid://10821837193",
	["MeleeSound"] = "rbxassetid://1306070008",
	["EmptyMagSound"] = "rbxassetid://1903570867",
	["ToggleSound"] = "rbxassetid://4458750270"
}

-- Functions
-- INIT
GunInfo["Rounds"] = (GunInfo["MaxRoundsInMag"] * GunInfo["Mags"]) - GunInfo["RoundsInMag"]
GunInfo["ShakeDuration"] = 1 / GunInfo["FireRate"]

return GunInfo