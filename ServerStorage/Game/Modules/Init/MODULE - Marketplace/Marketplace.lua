local MarketplaceModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Info Modules
local GamepassesInfoModule = require(InfoModulesFolder["Gamepasses"])
local DeveloperProductsInfoModule = require(InfoModulesFolder["DeveloperProducts"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local ShopModule = require(ServerModulesFolder["Shop"])
local DebugModule = require(ModulesFolder["Debug"])

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- CORE
local PlayerToPurchased = {}
local SubModules = {}

-- Services
local MarketplaceService = game:GetService("MarketplaceService")

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	for x, Folder in pairs(script:GetChildren()) do
		SubModules[Folder.Name] = UtilitiesModule:RunSubModules(Folder, true)
	end
end

local function GetUserPurchasedGamepasses(Player)
	-- CORE
	local OwnedPasses = {}
	
	-- Functions
	-- INIT
	if not PlayerToPurchased[Player] then
		for GamepassName, GamepassInfo in pairs(GamepassesInfoModule:GetAllGamepassesInfo()) do
			local Success, DoesUserOwn = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassInfo["Id"])
			end)
			
			if not Success then
				DebugModule:Print(script.Name.. " | GetUserPurchasedGamepasses | Error: ".. tostring(DoesUserOwn))
			else
				if DoesUserOwn then
					table.insert(OwnedPasses, GamepassName)
				end
			end
			
			--[[if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassInfo["Id"]) then
				table.insert(OwnedPasses, GamepassName)
			end]]
		end
		
		PlayerToPurchased[Player] = OwnedPasses
	else
		OwnedPasses = PlayerToPurchased[Player]
	end
	
	return OwnedPasses
end

local function GamepassPurchasedFinished(Player, gamePassId, wasPurchased)
	-- Functions
	-- INIT
	if not wasPurchased then
		DebugModule:Print("Marketplace | User didn't purchase gamepass | Player: ".. tostring(Player).. " | Gamepass: ".. tostring(gamePassId))
		return nil
	end
	
	local GamepassName = GamepassesInfoModule:GetGamepassFromId(gamePassId)
	local GamepassInfo = GamepassesInfoModule:GetGamepassProductInfo(GamepassName)
	
	DebugModule:Print("Marketplace | Gamepass purchased | Player: ".. tostring(Player).. " | Gamepass: ".. tostring(GamepassName))
	
	if GamepassName then
		if GamepassInfo and GamepassInfo["Rewards"] then
			for i, Reward in pairs(GamepassInfo["Rewards"]) do
				--print(Reward)
				local SubModule = SubModules["Gamepasses"][Reward["Type"]]
				
				if SubModule then
					SubModule:Initialise(Player, Reward["Folder"], Reward["Name"])
				end
			end
		end
		
		if PlayerToPurchased[Player] ~= nil then
			table.insert(PlayerToPurchased[Player], GamepassName)
		end
	end
end

local function ProcessReceipt(ReceiptInfo)
	-- Functions
	-- INIT
	local Player = game.Players:GetPlayerByUserId(ReceiptInfo["PlayerId"])
	local DeveloperProductName = DeveloperProductsInfoModule:GetDeveloperProductFromId(ReceiptInfo["ProductId"])
	
	local DeveloperProductInfo = DeveloperProductsInfoModule:GetDeveloperProductInfo(DeveloperProductName)
	
	if DeveloperProductInfo["Rewards"] then
		for i, Reward in pairs(DeveloperProductInfo["Rewards"]) do
			for RewardName, RewardValue in pairs(Reward) do
				SubModules["DeveloperProducts"][RewardName]:Initialise(Player, RewardValue)
			end
		end
		
		GameProcessRemote:FireClient(Player, "Marketplace", "PurchaseComplete", DeveloperProductInfo["Name"], ReceiptInfo["PurchaseId"])
		
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end
	
	
	return Enum.ProductPurchaseDecision.NotProcessedYet
end

local function PlayerAdded(Player)
	-- Functions
	-- INIT
	local GamepassNames = GetUserPurchasedGamepasses(Player)
	
	for GamepassName, GamepassInfo in pairs(GamepassesInfoModule:GetAllGamepassesInfo()) do
		if not table.find(GamepassNames, GamepassName) then
			continue
		end
		
		GamepassPurchasedFinished(Player, GamepassInfo["Id"], true)
	end
end

local function PlayerLeft(Player)
	-- Functions
	-- INIT
	PlayerToPurchased[Player] = nil
end

-- DIRECT
local Connection1 = MarketplaceService.PromptGamePassPurchaseFinished:Connect(GamepassPurchasedFinished)

function MarketplaceModule.GetUserPurchasedGamepasses(NilParam, Player)
	return GetUserPurchasedGamepasses(Player)
end

function MarketplaceModule.PlayerAdded(NilParam, Player)
	return PlayerAdded(Player)
end

function MarketplaceModule.PlayerLeft(NilParam, Player)
	return PlayerLeft(Player)
end

-- CONNECTIONS
MarketplaceService.ProcessReceipt = ProcessReceipt

-- INIT
ShopModule:Initialise()
RunSubModules()

return MarketplaceModule