local HealthPackInfoModule = {}

-- CORE
local HealthPackInfo = 
{	
	["Hint"] = {Name = "Health"},
	["Icon"] = {Id = "rbxassetid://10051274186"}
}

-- Functions
-- DIRECT
function HealthPackInfoModule.GetInfo(NilParam, SettingName)
	return HealthPackInfo[SettingName]
end

function HealthPackInfoModule.GetAllInfo()
	return HealthPackInfo
end

return HealthPackInfoModule