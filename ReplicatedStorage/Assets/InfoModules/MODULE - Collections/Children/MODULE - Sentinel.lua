local WindowInfoModule = {}

-- CORE
local WindowInfo = 
{
	["Properties"] = 
	{
		["Humanoid"] = 
		{
			["MaxHealth"] = 30,
			["Health"] = 30
		}
	}
}

-- Functions
-- DIRECT
function WindowInfoModule.GetInfo(NilParam, SettingName)
	return WindowInfo[SettingName]
end

function WindowInfoModule.GetAllInfo()
	return WindowInfo
end

return WindowInfoModule