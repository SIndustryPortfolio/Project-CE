local AmmoContainerInfoModule = {}

-- CORE
local AmmoContainerInfo = 
{	
	["Hint"] = {Name = "Ammo"},
	["Icon"] = {Id = "rbxassetid://10051274186"}
}

-- Functions
-- DIRECT
function AmmoContainerInfoModule.GetInfo(NilParam, SettingName)
	return AmmoContainerInfo[SettingName]
end

function AmmoContainerInfoModule.GetAllInfo()
	return AmmoContainerInfo
end

return AmmoContainerInfoModule