local TeamsInfoModule = {}

-- CORE
local TeamsInfo = 
{
	["Really red"] = {LayoutOrder = 1},
	["Really blue"] = {LayoutOrder = 2}
}

-- Functions
-- DIRECT
function TeamsInfoModule.GetTeamInfo(NilParam, SettingName)
	return TeamsInfo[SettingName]
end

function TeamsInfoModule.GetAllTeamsInfo()
	return TeamsInfo
end

return TeamsInfoModule