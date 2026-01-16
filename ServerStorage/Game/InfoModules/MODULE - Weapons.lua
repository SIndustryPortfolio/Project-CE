local WeaponsInfoModule = {}

-- CORE
local WeaponsInfo = 
{
	["HeadshotParts"] = {"Visor", "Head"}		
}

-- Functions
-- DIRECT
function WeaponsInfoModule.GetWeaponInfo(NilParam, SettingName)
	return WeaponsInfo[SettingName]
end

function WeaponsInfoModule.GetAllWeaponInfo()
	return WeaponsInfo
end

return WeaponsInfoModule