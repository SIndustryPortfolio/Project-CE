local RedeemCodesModule = {}

-- Dirs
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ServerAPIsFolder = game:GetService("ServerStorage"):WaitForChild("Game")["APIs"]

-- Info Modules
local RedeemCodesInfoModule = require(ServerInfoModulesFolder["RedeemCodes"])

-- Modules
local ServerRewardsModule = require(ServerModulesFolder["Rewards"])

-- APIs
local DataStore2Module = require(ServerAPIsFolder["DataStore2"])

-- Functions
-- MECHANICS
local function UnpackAllData(Data)
	-- CORE
	local UnpackedTable = {}
	
	-- Functions
	-- INIT
	for i, Id in pairs(Data) do
		table.insert(UnpackedTable, RedeemCodesInfoModule:UnpackId(Id))
	end
	
	return UnpackedTable
end

local function Redeem(Player, Code)
	-- Functions
	-- INIT
	if not Code or Code == "" then
		return nil
	end
	
	local Datastore = DataStore2Module("RedeemCodes", Player)
	local Data = Datastore:Get({})
	local UnpackedData = UnpackAllData(Data)
	
	if table.find(UnpackedData, Code) then
		return nil
	end
	
	local RedeemCodeInfo = RedeemCodesInfoModule:GetRedeemCodeInfo(Code)
	
	if not RedeemCodeInfo then
		return nil
	end
	
	ServerRewardsModule:RewardPlayer(Player, RedeemCodeInfo["Rewards"])
	
	table.insert(Data, RedeemCodeInfo["Id"])
	Datastore:Set(Data)
end

-- DIRECT
function RedeemCodesModule.ClientRequest(NilParam, Player, Code)
	return Redeem(Player, Code)
end

return RedeemCodesModule