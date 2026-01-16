-- CORE
local GunInfo = 
{
	["Technology"] = "UNSC",
	["ProjectileType"] = "Raycast",
	["Type"] = "Semi Automatic",
	--
	["FireRate"] = 2,
	["RoundWidth"] = 0.25,
	["MaxRoundsInMag"] = 4,
	["RoundsInMag"] = 4,
	["Mags"] = 5,
	["MaxMags"] = 8,
	["Spread"] = 0,
	["ReloadType"] = "Static",
	--["ReloadSpeed"] = 1,
	--
	["AdsZoom"] = 4,
	["AdsSize"] = UDim2.new(0.55, 18, 0.55, 0),
	["AdsAspectRatio"] = 1.603,
	--
	["ShakeIntensity"] = 0.5,
	["ShakeDuration"] = 0.1,
	--
	["Damage"] = 50,
	["HeadshotDamageMultiplier"] = 3,
	["DamageDropOffMultiplier"] = 1,
	--
	["GunIcon"] = "rbxassetid://10303098526",
	["CursorIcon"] = "rbxassetid://9200028824",
	["AdsIcon"] = "rbxassetid://10303894414",	
	["CursorSize"] = UDim2.new(0.025, 0, 0.025, 0),
	["RoundType"] = "Heavy",
	["HudRows"] = 2,
	--
	["FireSound"] = "rbxassetid://4398166940",
	["ReloadSound"] = "rbxassetid://4250401854",
	["MeleeSound"] = "rbxassetid://1306070008",
	["EmptyMagSound"] = "rbxassetid://240785604",
	["ToggleSound"] = "rbxassetid://5508953366",
	--
	["AnimationSpeeds"] = 
	{
		["Equip"] = 1.5,
		["Unequip"] = 1.5	
	},
	--
	["ShootEffectOverwrite"] = "UNSCSniper",
	["BulletLinger"] = 
	{
		["Duration"] = 2,
		["Beam"] = "UNSCSniper",
		["BeamProperties"] = 
		{
			["TextureSpeed"] = 0,
			["TextureLength"] = 1,
			["Transparency"] = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(1, 0.5)},
		}
	}
	
}

-- Functions
-- INIT
GunInfo["Rounds"] = (GunInfo["MaxRoundsInMag"] * GunInfo["Mags"]) - GunInfo["RoundsInMag"]

return GunInfo