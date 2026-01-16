local PowerSwitchInfoModule = {}

-- CORE
local PowerSwitchInfo = 
{	
	["Hint"] = {Name = "Power Switch"},
	["Icon"] = {Id = "rbxassetid://11896961147"},
	["SwitchSound"] = {Id = "rbxassetid://7057058465"},
	["HoldToInteract"] = true,
}

-- Functions
-- DIRECT
function PowerSwitchInfoModule.GetInfo(NilParam, SettingName)
	return PowerSwitchInfo[SettingName]
end

function PowerSwitchInfoModule.GetAllInfo()
	return PowerSwitchInfo
end

return PowerSwitchInfoModule