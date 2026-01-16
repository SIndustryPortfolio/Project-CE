local IntroInfoModule = {}

-- CORE
local IntroInfo = 
{
	["EffectInfo"] = 
	{
		["Duration"] = 1,
		["Style"] = Enum.EasingStyle.Cubic,	
		["Direction"] = Enum.EasingDirection.InOut
	},
	["LoadDelayPerService"] = 0.05	
}

-- Functions
-- DIRECT
function IntroInfoModule.GetIntroInfo(NilParam, SettingName)
	return IntroInfo[SettingName]
end

function IntroInfoModule.GetAllIntroInfo()
	return IntroInfo
end

return IntroInfoModule