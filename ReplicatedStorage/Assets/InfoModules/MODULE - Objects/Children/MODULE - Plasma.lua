-- CORE
local ObjectInfo = 
{
	["ExplosionTrailColour"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 170, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255))
	},
	--
	["ExplosionRadius"] = 35,
	["ExplosionDamage"] = 280,
	["ExplosionDropOffIncrement"] = 6, -- Studs of 5 for damage drop off
	["ExplosionDropOffMultiplier"] = 0.5,
	["ExplosionPushBackForce"] = 5,
	["ExplosionUpThrust"] = 5,
	["ExplosionSound"] = "",

	["RespawnTime"] = 10
}

-- Functions
-- INIT

return ObjectInfo