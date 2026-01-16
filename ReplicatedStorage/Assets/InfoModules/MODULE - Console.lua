local ConsoleInfoModule = {}

-- CORE
local ConsoleInfo = 
{
	["Fonts"] = 
	{
		["Core"] = {Colour = Color3.fromRGB(131, 145, 192), Duration = 5},
		["Donation"] = {Colour = Color3.fromRGB(170, 85, 255), Duration = 10},
		["Purchase"] = {Colour = Color3.fromRGB(198, 198, 0), Duration = 5},
		["Normal"] = {Colour = Color3.fromRGB(131, 145, 192)},
		["System"] = {Colour = Color3.fromRGB(255, 255, 0)},
		["Debug"] = {Colour = Color3.fromRGB(255, 85, 127)}
	}
}

-- Functions
-- DIRECT
function ConsoleInfoModule.GetConsoleInfo(NilParam, SettingName)
	return ConsoleInfo[SettingName]
end

function ConsoleInfoModule.GetAllConsoleInfo()
	return ConsoleInfo
end

return ConsoleInfoModule