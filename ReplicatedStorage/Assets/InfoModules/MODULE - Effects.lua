local EffectsInfoModule = {}

-- CORE
local EffectInfo = 
{
	["UNSCRaycast"] = 
	{
		["Style"] = Enum.EasingStyle.Linear,
		["Direction"] = Enum.EasingDirection.InOut,
		["Duration"] = 0.15
	},
	["UNSCProjectile"] = 
	{
		["Style"] = Enum.EasingStyle.Linear,
		["Direction"] = Enum.EasingDirection.InOut,
		["Duration"] = 1	
	},
	["CovenantProjectile"] = 
	{
		["Style"] = Enum.EasingStyle.Linear,
		["Direction"] = Enum.EasingDirection.InOut,
		["Duration"] = 1	
	}
}

-- Functions
-- DIRECT
function EffectsInfoModule.GetEffectInfo(NilParam, SettingName)
	return EffectInfo[SettingName]
end

function EffectsInfoModule.GetAllEffectInfo()
	return EffectInfo
end

return EffectsInfoModule