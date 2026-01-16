local ClientCoreInfoModule = {}

-- CORE
local ClientCoreInfo = 
{
	["UiTypes"] = {"Custom", "Main", "Pages"}	
}

-- Functions
-- DIRECT
function ClientCoreInfoModule.GetClientCoreInfo(NilParam, SettingName)
	return ClientCoreInfo[SettingName]
end

function ClientCoreInfoModule.GetAllClientCoreInfo()
	return ClientCoreInfo
end

return ClientCoreInfoModule