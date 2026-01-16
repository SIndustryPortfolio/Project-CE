local MarketplaceManagementModule = {}

-- Dirs
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local ServerModulesInitFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]["Init"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Info Modules
local AdminInfoModule = require(ServerInfoModulesFolder["Admin"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local PurchaseableModule = require(SharedModulesFolder["Purchaseable"])
local MarketplaceInitModule = require(ServerModulesInitFolder["Marketplace"])

-- Functions
-- MECHANICS
local function PlayerAdded(Player)
	-- Functions
	-- INIT
	local UserOwnedGamepasses = MarketplaceInitModule:GetUserPurchasedGamepasses(Player)
	
	if table.find(UserOwnedGamepasses, "CECrew") or table.find(UserOwnedGamepasses, "DeprecatedCECrew") or table.find(UtilitiesModule:GetDictKeys(AdminInfoModule:GetAdminInfo("Owner")), Player.UserId) then
		Player:SetAttribute("Crew", true)
	else
		Player:SetAttribute("Crew", false)
	end
end

-- DIRECT
function MarketplaceManagementModule.PlayerAdded(NilParam, PlayerManagementModule, Player)
	return PlayerAdded(Player)
end

return MarketplaceManagementModule