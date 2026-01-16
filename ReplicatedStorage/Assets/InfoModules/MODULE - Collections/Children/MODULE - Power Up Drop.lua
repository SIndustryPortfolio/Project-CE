local PowerUpDropInfoModule = {}

-- CORE
local PowerUpInfo = 
{	
	["TouchOnly"] =  true
}

-- Functions
-- DIRECT
function PowerUpDropInfoModule.GetInfo(NilParam, SettingName)
	return PowerUpInfo[SettingName]
end

function PowerUpDropInfoModule.GetAllInfo()
	return PowerUpInfo
end

return PowerUpDropInfoModule