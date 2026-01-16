local TurretInfoModule = {}

-- CORE
local TurretInfo = 
{	
	["Hint"] = {Name = "Turret"},
	["Icon"] = {Id = "rbxassetid://10051274186"}
}

-- Functions
-- DIRECT
function TurretInfoModule.GetInfo(NilParam, SettingName)
	return TurretInfo[SettingName]
end

function TurretInfoModule.GetAllInfo()
	return TurretInfo
end

return TurretInfoModule