local AdminInfoModule = {}

-- CORE
local AdminInfo = 
{
	["Prefix"] = "!",
	["Tiers"] = 
	{
		["Owner"] = 4	
	},
	["Owner"] = 
	{
		[4418504571] = "BDCharva",
		[25091159] = "shayan7863", 
		[99186689] = "DevAlexs",
		[32163212] = "co_rny",
		[0] = "Test",
		[-1] = "Test",
		[-2] = "Test"
	}	
}

-- Functions
-- DIRECT
function AdminInfoModule.GetAllAdminInfo()
	return AdminInfo
end

function AdminInfoModule.GetAdminInfo(NilParam, SettingName)
	return AdminInfo[SettingName]
end

return AdminInfoModule