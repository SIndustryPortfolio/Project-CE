-- CORE
local GunInfo = 
{
	["Technology"] = "Covenant",
	["ProjectileType"] = "Projectile",
	["Type"] = "Semi Automatic",
	--
	["FireRate"] = 6,
	["MaxEnergy"] = 100,
	["Energy"] = 100,
	["MaxCharge"] = 10,
	["MinimumEnergyConsumption"] = 1,
	["CurrentEnergyUsage"] = 0,
	["Spread"] = 0.125,
	["ReloadType"] = "Static",
	["ReloadSpeed"] = 1,
	["ProjectileSpeed"] = 300, -- Studs Per Second
	--
	["AdsZoom"] = 2,
	["AdsSize"] = UDim2.new(0.187, 18, 0.4, 0),
	["AdsAspectRatio"] = 1,
	--
	["ShakeIntensity"] = 0.5,
	["ShakeDuration"] = 0.1,
	--
	["ChargeShot"] = true,
	["ChargeTime"] = .3,
	["ChargeDamage"] = 50,
	["Damage"] = 20,
	["HeadshotDamageMultiplier"] = 0.5,
	--
	["GunIcon"] = "rbxassetid://10147556137",
	["CursorIcon"] = "rbxassetid://10147643679",
	["AdsIcon"] = "rbxassetid://8711942086",
	["CursorSize"] = UDim2.new(0.04, 0,0.04, 0),
	["RoundType"] = "Plasma",		
	--
	["ShootEffectOverwrite"] = "CovenantProjectileGreen",
	--
	["FireSound"] = "rbxassetid://1145252063",
	["ReloadSound"] = "rbxassetid://7432098524",
	--["ReloadSound"] = "rbxassetid://10821837193",
	["MeleeSound"] = "rbxassetid://1306070008",
	["EmptyMagSound"] = "rbxassetid://1903570867",
	["ToggleSound"] = "rbxassetid://4458750270"
}

-- Functions
-- INIT
--GunInfo["Rounds"] = (GunInfo["MaxRoundsInMag"] * GunInfo["Mags"]) - GunInfo["RoundsInMag"]
GunInfo["ShakeDuration"] = 1 / GunInfo["FireRate"]

return GunInfo