local TeleporterInfoModule = {}

-- CORE
local TeleporterInfo = 
{	
	["TouchOnly"] = true
}

-- Functions
-- DIRECT
function TeleporterInfoModule.GetInfo(NilParam, SettingName)
	return TeleporterInfo[SettingName]
end

function TeleporterInfoModule.GetAllInfo()
	return TeleporterInfo
end

return TeleporterInfoModule