local GameInfoModule = {}

-- Services
local RunService = game:GetService("RunService")

-- CORE
local GameInfo = 
{
	["MinimumPlayers"] = 1,
	["IntermissionTime"] =  5, -- Seconds
	["StaticMapLoadingTime"] = 1, -- Seconds
	["GameStartingTime"] = 3, -- Seconds
	["GameEndingTime"] = 10, -- Seconds
	["VetoTime"] = 5, -- Seconds
	["RespawnTime"] = 5,
	--------------
	["RoundTimeXpMultiplier"] = 5,
	--------------
	["Admins"] = 
	{
		[25091159] = "shayan7863",
		[99186689] = "DevAlexs",
		[32163212] = "co_rny",
		[-1] = "Test1",
		[-2] = "Test2",
		[0] = "Test3",
		[1] = "Test4"
	}
}

-- Functions
-- DIRECT
function GameInfoModule.GetGameInfo(NilParam, SettingName)
	return GameInfo[SettingName]
end

function GameInfoModule.GetAllGameInfo()
	return GameInfo
end

-- INIT
--[[if RunService:IsStudio() then
	GameInfo["IntermissionTime"] = 1
	GameInfo["StaticMapLoadingTime"] = 1
	GameInfo["GameEndingTime"] = 1
	GameInfo["GameStartingTime"] = 1
end]]

return GameInfoModule