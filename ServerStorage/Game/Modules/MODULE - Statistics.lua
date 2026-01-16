local StatisticsModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Info Modules
local StatisticsInfoModule = require(InfoModulesFolder["Stats"])

-- Modules
local ShortcutsModule = require(ModulesFolder["Shortcuts"])
local DebugModule = require(ModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function CanPlayerChangeTo(StatisticType, StatisticName, NewValue)
	-- Functions
	-- INIT
	local StatInfo = StatisticsInfoModule:GetStatInfo(StatisticType, StatisticName)
	
	if StatInfo and StatInfo.AcceptedValues then
		if not table.find(StatInfo.AcceptedValues, NewValue) then
			return false
		end	
	end
	
	return true
end

local function ChangeStatistic(Player, StatisticType, StatisticName, NewValue)
	-- Functions
	-- INIT
	local StatisticValue = ShortcutsModule:GetPlayerStatisticValue(Player, StatisticType, StatisticName)
	
	if not CanPlayerChangeTo(StatisticType, StatisticName, NewValue) then
		return nil
	end
	
	if StatisticValue then
		StatisticValue.Value = NewValue
	end
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Change"] = ChangeStatistic
}

-- MECHANICS
local function ClientRequest(Player, FunctionName, ...)
	-- Functions
	-- INIT
	return ClientRequests[FunctionName](Player, ...)
end

-- DIRECT
function StatisticsModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequest(Player, FunctionName, ...)
end

return StatisticsModule