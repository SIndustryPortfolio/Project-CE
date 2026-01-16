local PlasmaBatteryInfoModule = {}

-- CORE
local PlasmaBatteryInfo = 
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

	["OriginNeonColour"] = Color3.fromRGB(4, 175, 236),
	["EmergencyNeonColour"] = Color3.fromRGB(255, 0, 0),
		
	["ExplosionTrailColour"] = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 170, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255))
	}
}

-- Functions
-- DIRECT
function PlasmaBatteryInfoModule.GetInfo(NilParam, SettingName)
	return PlasmaBatteryInfo[SettingName]
end

function PlasmaBatteryInfoModule.GetAllInfo()
	return PlasmaBatteryInfo
end

return PlasmaBatteryInfoModule