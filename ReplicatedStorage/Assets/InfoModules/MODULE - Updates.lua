local UpdatesInfoModule = {}

-- CORE
local UpdatesInfo = 
{
	["Contents"] = 
	{
		[1] = {Type = "+", Description = "Gameplay enhancements"},
		[2] = {Type = "+", Description = "Better Hit Marker"},
		[3] = {Type = "+", Description = "Faster bullet registration"},
		[4] = {Type = "+", Description = "Removed excess modes"},
		[5] = {Type = "+", Description = "More effects!"},
		[6] = {Type = "+", Description = "Improved Melee"}
	}	
}

-- Functions
-- DIRECT
function UpdatesInfoModule.GetUpdatesInfo(NilParam, SettingName)
	return UpdatesInfo[SettingName]
end

function UpdatesInfoModule.GetAllUpdatesInfo()
	return UpdatesInfo
end

return UpdatesInfoModule