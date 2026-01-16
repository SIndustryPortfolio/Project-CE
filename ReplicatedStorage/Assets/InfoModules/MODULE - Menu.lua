local MenuInfoModule = {}

-- CORE
local MenuInfo = 
{
	["EffectInfo"] = 
	{
		["Duration"] = 1,
		["Style"] = Enum.EasingStyle.Cubic,	
		["Direction"] = Enum.EasingDirection.InOut
	},
	["TimeUpdateDelay"] = 1
}

-- Functions
-- DIRECT
function MenuInfoModule.GetMenuInfo(NilParam, SettingName)
	return MenuInfo[SettingName]
end

function MenuInfoModule.GetAllIntroInfo()
	return MenuInfo
end

return MenuInfoModule