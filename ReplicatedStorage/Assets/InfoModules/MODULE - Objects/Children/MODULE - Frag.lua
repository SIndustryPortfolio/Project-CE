-- CORE
local ObjectInfo = 
{
	["ExplosionTrailColour"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 170, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 170, 0))
	},
	--
	["ExplosionRadius"] = 35,
	["ExplosionDamage"] = 280,
	["ExplosionDropOffIncrement"] = 6, -- Studs of 5 for damage drop off
	["ExplosionDropOffMultiplier"] = 0.5,
	["ExplosionPushBackForce"] = 5,
	["ExplosionUpThrust"] = 5,
	["ExplosionSound"] = "rbxassetid://180302005",

	["RespawnTime"] = 10
}

-- Functions
-- INIT

return ObjectInfo