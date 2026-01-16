local DevicesInfoModule = {}

-- CORE
local DevicesInfo = 
{
	["Mobile"] = {Icon = {Id = "rbxassetid://10125065072"}},
	["Computer"] = {Icon = {Id = "rbxassetid://9084091854"}},
	["Console"] = {Icon = {Id = "rbxassetid://10125065278"}}	
}

-- Functions
-- DIRECT
function DevicesInfoModule.GetDeviceInfo(NilParam, SettingInfo)
	return DevicesInfo[SettingInfo]
end

function DevicesInfoModule.GetAllDevicesInfo()
	return DevicesInfo
end

return DevicesInfoModule