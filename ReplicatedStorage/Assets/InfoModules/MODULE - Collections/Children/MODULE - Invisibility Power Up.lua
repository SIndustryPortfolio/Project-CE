local PowerUpInfoModule = {}

-- CORE
local PowerUpInfo = 
{	
	["Hint"] = {Name = "PowerUp"}
}

-- Functions
-- DIRECT
function PowerUpInfoModule.GetInfo(NilParam, SettingName)
	return PowerUpInfo[SettingName]
end

function PowerUpInfoModule.GetAllInfo()
	return PowerUpInfo
end

return PowerUpInfoModule