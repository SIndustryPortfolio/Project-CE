local RewardsModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local ServerGameModule = require(ServerModulesFolder["Game"])
local ServerInventoryModule = require(ServerModulesFolder["Inventory"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])

-- Functions
-- MECHANICS
local function RewardCoins(Player, Amount)
	-- Functions
	-- INIT
	local CoinsValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Currency", "Coins")

	CoinsValue.Value += Amount
end

local function RewardPlayer(Player, RewardInfo)
	-- Functions
	-- INIT
	if not RewardInfo then
		return nil
	end
	
	for i, Reward in pairs(RewardInfo or {}) do
		if Reward["Type"] == "Xp" then
			ServerGameModule:GameProcess("AddXp", Player, Reward["Value"])
		elseif Reward["Type"] == "CECoins" then
			RewardCoins(Player, Reward["Value"])
		else
			ServerInventoryModule:AddItem(Player, --[[RewardConversion[Reward["Type"]] Reward["Type"], Reward["Name"])
		end
	end
end

-- DIRECT
function RewardsModule.RewardPlayer(NilParam, Player, RewardInfo)
	return RewardPlayer(Player, RewardInfo)
end

return RewardsModule