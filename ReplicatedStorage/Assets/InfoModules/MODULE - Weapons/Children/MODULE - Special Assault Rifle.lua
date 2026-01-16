-- CORE
local GunInfo = 
{
	["Technology"] = "UNSC",
	["ProjectileType"] = "Projectile",
	["Type"] = "Automatic",
	--
	["FireRate"] = 30,
	["RoundWidth"] = 0.25,
	["MaxRoundsInMag"] = 180,
	["RoundsInMag"] = 180,
	["Mags"] = 50,
	["MaxMags"] = 50,
	["Spread"] = 1,
	["ReloadType"] = "Static",
	["ReloadSpeed"] = 2,
	["ProjectileSpeed"] = 600, -- Studs Per Second
	--
	["AdsZoom"] = 1,
	["AdsSize"] = UDim2.new(1, 18, 1, 0),
	["AdsAspectRatio"] = 2.79,
	--
	["ShakeIntensity"] = 0.0,
	["ShakeDuration"] = 0.0,
	--
	["Damage"] = 20,
	["HeadshotDamageMultiplier"] = 0.5,
	--
	["GunIcon"] = "rbxassetid://7040648553",
	["CursorIcon"] = "rbxassetid://7040657279",
	["AdsIcon"] = "rbxassetid://8736126265",	
	["CursorSize"] = UDim2.new(0.075, 0,0.075, 0),
	["RoundType"] = "Light",
	["HudRows"] = 4,
	--
	["ShootEffectOverwrite"] = "UNSCProjectileRainbowLight",
	--
	["FireSound"] = "rbxassetid://1898322396",
	["ReloadSound"] = "rbxassetid://6648991885",
	["MeleeSound"] = "rbxassetid://1306070008",
	["EmptyMagSound"] = "rbxassetid://240785604",
	["ToggleSound"] = "rbxassetid://7405483764",
	--
	["ExplosiveRounds"] = {["Type"] = "Frag"},
	["DevOnly"] = true	
}

-- Functions
-- INIT
GunInfo["Rounds"] = (GunInfo["MaxRoundsInMag"] * GunInfo["Mags"]) - GunInfo["RoundsInMag"]

return GunInfo