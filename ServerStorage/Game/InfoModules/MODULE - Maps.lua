local MapsInfoModule = {}

-- Core
local MapsInfo = 
{
	["SpawnOffset"] = 2
}

-- Functions
-- DIRECT
function MapsInfoModule.GetMapInfo(NilParam, SettingName)
	return MapsInfo[SettingName]
end

function MapsInfoModule.GetAllMapInfo()
	return MapsInfo
end

return MapsInfoModule