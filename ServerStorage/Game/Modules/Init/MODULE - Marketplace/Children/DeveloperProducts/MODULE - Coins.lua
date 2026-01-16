local CoinsModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilititesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function Initialise(Player, AmountToReward)
	-- Elements
	-- FOLDERS
	local StatisticsFolder = UtilititesModule:WaitForChildTimed(Player, "Statistics")
	local CurrencyFolder = UtilititesModule:WaitForChildTimed(StatisticsFolder, "Currency")
	
	-- VALUES
	local CoinsValue = UtilititesModule:WaitForChildTimed(CurrencyFolder, "Coins")
	
	-- Functions
	-- INIT
	CoinsValue.Value += AmountToReward
end

-- DIRECT
function CoinsModule.Initialise(NilParam, Player, AmountToReward)
	return Initialise(Player, AmountToReward)
end

return CoinsModule