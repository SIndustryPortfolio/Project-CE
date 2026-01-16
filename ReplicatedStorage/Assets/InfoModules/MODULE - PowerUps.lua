local PowerUpsInfoModule = {}

-- CORE
local PowerUpsInfo = 
{
	["Custom Power Up"] = {Duration = 30, WalkSpeed = --[[35]] 42, Icon = {Id = "rbxassetid://9012179533"}},
	["Invisibility Power Up"] = {Duration = 30, Icon = {Id = "rbxassetid://9012179227"}}	
}

-- Functions
-- DIRECT
function PowerUpsInfoModule.GetPowerUpInfo(NilParam, SettingName)
	return PowerUpsInfo[SettingName]
end

function PowerUpsInfoModule.GetAllPowerUpInfo()
	return PowerUpsInfo
end

return PowerUpsInfoModule