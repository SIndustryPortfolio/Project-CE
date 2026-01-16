local FusionCoilInfoModule = {}

-- CORE
local FusionCoilInfo = 
{
	["Properties"] = 
	{
		["Humanoid"] = 
		{
			["MaxHealth"] = 30,
			["Health"] = 30
		}
	},
		
	["Hint"] = {Name = "Explosive", StudsOffset = Vector3.new(0, 5, 0)},

	["OriginNeonColour"] = Color3.fromRGB(245, 205, 48),
	["EmergencyNeonColour"] = Color3.fromRGB(255, 0, 0),
		
	["ExplosionTrailColour"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 170, 0)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 170, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 170, 0))
	}
}

-- Functions
-- DIRECT
function FusionCoilInfoModule.GetInfo(NilParam, SettingName)
	return FusionCoilInfo[SettingName]
end

function FusionCoilInfoModule.GetAllInfo()
	return FusionCoilInfo
end

return FusionCoilInfoModule