local CrewModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerAPIsFolder = game:GetService("ServerStorage"):WaitForChild("Game")["APIs"]

-- APIs
local DataStore2Module = require(ServerAPIsFolder["DataStore2"])

-- Info Modules
local CrewInfoModule = require(SharedInfoModulesFolder["Crew"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local ServerInventoryModule = require(ServerModulesFolder["Inventory"])
local ServerGameModule = require(ServerModulesFolder["Game"])
local DebugModule = require(SharedModulesFolder["Debug"])
local DatastoreModule = require(ServerModulesFolder["Datastore"])
local ServerRewardsModule = require(ServerModulesFolder["Rewards"])

-- CORE
--[[local RewardConversion = 
{
	["Camo"] = "Camos",
	["ArmourEffect"] = "ArmourEffects",
	["VisorColour"] = "VisorColours"
}]]

-- Functions
-- MECHANICS
local function DoesPlayerHaveRewards(Player, SlotIndex)
	-- Functions
	-- INIT
	local HasReward = false
	
	local SlotInfo = CrewInfoModule:GetTierInfo(SlotIndex)
	
	if not SlotInfo then
		DebugModule:Print("Crew | No slot info for index: ".. tostring(SlotIndex))
		return nil
	end
	
	--local Rewards = SlotInfo["Rewards"]
	
	local RewardTables = {SlotInfo["Crew"]["Rewards"], SlotInfo["Free"]["Rewards"]}
	
	for x, Rewards in pairs(RewardTables) do
		for i, Reward in pairs(Rewards) do
			if Reward["Type"] == "Xp" or Reward["Type"] == "CECoins" then
				continue
			end
			
			if ShortcutsModule:GetPlayerInventoryValue(Player, Reward["Type"], Reward["Name"]) then  --RewardConversion[Reward["Type"]], Reward["Name"]) then
				HasReward = true
				break
			end
		end
	end
	
	if not HasReward then
		local ClaimedTiersStore = DataStore2Module("ClaimedTiers", Player)
		
		if table.find(ClaimedTiersStore:Get({}), SlotIndex) then
			HasReward = true
		end
	end
	
	return HasReward
end

--[[local function RewardCoins(Player, Amount)
	-- Functions
	-- INIT
	local CoinsValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Currency", "Coins")
	
	CoinsValue.Value += Amount
end]]

local function RewardPlayer(Player, SlotIndex)
	-- Functions
	-- INIT
	local SlotInfo = CrewInfoModule:GetTierInfo(SlotIndex)
	local Store = DataStore2Module("ClaimedTiers", Player)
	local CurrentClaimed = Store:Get({})
	
	ServerRewardsModule:RewardPlayer(Player, SlotInfo["Rewards"])
	
	--[[for i, Reward in pairs(SlotInfo["Rewards"]) do
		if Reward["Type"] == "Xp" then
			ServerGameModule:GameProcess("AddXp", Player, Reward["Value"])
		elseif Reward["Type"] == "CECoins" then
			RewardCoins(Player, Reward["Value"])
		else
			ServerInventoryModule:AddItem(Player, --[[RewardConversion[Reward["Type"]]-- Reward["Type"], Reward["Name"])
		--end
	--end
	
	table.insert(CurrentClaimed, SlotIndex)
	Store:Set(CurrentClaimed)
end

local function GetSlotFromXp(Xp)
	-- Functions
	-- INIT
	for Index, SlotInfo in pairs(CrewInfoModule:GetAllTiers()) do
		local NextTierInfo = CrewInfoModule:GetAllTiers()[Index + 1]
		
		if not NextTierInfo then
			continue
		end
		
		if Xp >= SlotInfo["RequiredXp"] and Xp < NextTierInfo["RequiredXp"] then
			return Index
		end
	end
end

local function GetSlotFromTier(Tier)
	-- Functions
	-- INI
	return Tier
end

local function PlayerTieredUp(Player)
	-- Functions
	-- INIT
	if not Player:GetAttributes()["Crew"] then
		return nil
	end
	
	local PlayerCrewXpValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Crew", "CrewXp")
	local PlayerCrewTierValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Crew", "CrewTier")
	
	local SlotIndex = GetSlotFromTier(PlayerCrewTierValue.Value) --GetSlotFromXp(PlayerCrewXpValue.Value)
	
	if not SlotIndex then
		DebugModule:Print("Crew | No slot info for Xp: ".. tostring(PlayerCrewXpValue.Value).. " | Player: ".. tostring(Player))
		return nil
	end
	
	if DoesPlayerHaveRewards(Player, SlotIndex) then
		DebugModule:Print("Crew | Player: ".. tostring(Player).. " already has rewards!")
		return nil
	end
	
	return RewardPlayer(Player, SlotIndex)
end

local function PlayerAdded(Player)
	-- CORE
	local PlayerCrewTierValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Crew", "CrewTier")
	local PlayerCrewXpValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Crew", "CrewXp")
	
	-- Functions
	-- INIT
	if not Player:GetAttribute("Crew") then
		return nil
	end
	
	for Index, SlotInfo in pairs(CrewInfoModule:GetAllTiers()) do
		if SlotInfo["RequiredXp"] <= PlayerCrewXpValue.Value then
			if not DoesPlayerHaveRewards(Player, Index) then
				RewardPlayer(Player, Index)
			end
		end
	end
end

local function CrewMemberAdded(Player)
	-- Functions
	-- INIT
	Player:SetAttribute("Crew", true)
	
	local PlayerCrewTierValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Crew", "CrewTier")
	local PlayerCrewXpValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Crew", "CrewXp")

	
	if not PlayerCrewTierValue then
		return nil
	end
	
	for Index, SlotInfo in pairs(CrewInfoModule:GetAllTiers()) do
		if SlotInfo["RequiredXp"] <= PlayerCrewXpValue.Value then
			if not DoesPlayerHaveRewards(Player, Index) then
				RewardPlayer(Player, Index)
			end
		end
	end
end

local function PurchaseNextTier(Player)
	-- CORE
	local PlayerCoinsValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Currency", "Coins")
	local NextTierPrice = CrewInfoModule:GetCrewInfo("Purchaseable")["NextTier"]
	
	-- Functions
	-- INIT
	if PlayerCoinsValue.Value < NextTierPrice then
		DebugModule:Print("Crew | PurchaseNextTier | Player lacking funds to purchase Next Tier | Player: ".. tostring(Player))
		return nil
	end
	
	local PlayerCrewTierValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Crew", "CrewTier")
	local PlayerCrewXpValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Crew", "CrewXp")
	
	local NextTierInfo = CrewInfoModule:GetAllTiers()[PlayerCrewTierValue.Value + 1]
	
	if not NextTierInfo then
		DebugModule:Print("Crew | PurchaseNextTier | No NextTierInfo | Player: ".. tostring(Player).. " | Crew Tier: ".. tostring(PlayerCrewTierValue.Value))
		return nil	
	end
	
	local XpToAdd = NextTierInfo["RequiredXp"] - PlayerCrewXpValue.Value
	PlayerCrewXpValue.Value += XpToAdd
	PlayerCoinsValue.Value -= NextTierPrice
end

local function PurchaseAllTiers(Player)
	-- CORE
	local PlayerCoinsValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Currency", "Coins")
	local AllTiersPrice = CrewInfoModule:GetCrewInfo("Purchaseable")["AllTiers"]

	-- Functions
	-- INIT
	if PlayerCoinsValue.Value < AllTiersPrice then
		DebugModule:Print("Crew | Player lacking funds to purchase All Tiers | Player: ".. tostring(Player))
		return nil
	end
	
	local PlayerCrewXpValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Crew", "CrewXp")
	local PlayerCrewTierValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Crew", "CrewTier")
	
	local LastTierInfo = CrewInfoModule:GetAllTiers()[UtilitiesModule:GetSizeOfDict(CrewInfoModule:GetAllTiers())]
	PlayerCrewXpValue.Value = LastTierInfo["RequiredXp"]	
	PlayerCoinsValue.Value -= AllTiersPrice
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["PurchaseNextTier"] = PurchaseNextTier,
	["PurchaseAllTiers"] = PurchaseAllTiers
}

-- DIRECT
function CrewModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

function CrewModule.CrewMemberAdded(NilParam, Player)
	return CrewMemberAdded(Player)
end

function CrewModule.PlayerTieredUp(NilParam, Player)
	return PlayerTieredUp(Player)
end

function CrewModule.PlayerAdded(NilParam, Player)
	return PlayerAdded(Player)
end

return CrewModule