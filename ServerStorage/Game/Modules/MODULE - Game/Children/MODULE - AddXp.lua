local AddXpModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesInitFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]["Init"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local FeedInfoModule = require(InfoModulesFolder["Feed"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local MarketplaceModule = require(ServerModulesInitFolder["Marketplace"])
local ShortcutsModule = require(ModulesFolder["Shortcuts"])

-- CORE
local Queued = false

-- Functions
-- MECHANICS
local function HandleFeed(Player, Type, XpToGive, Args, ReturnWithoutFiringClient)
	-- Core
	if typeof(Type) == "number" then
		return nil
	end
	
	if not UtilitiesModule:GetCharacter(Player, true) then
		return nil
	end
	
	local CharacterProcessRemote = UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess")
	
	-- Functions
	-- INIT
	if CharacterProcessRemote then
		if ReturnWithoutFiringClient then
			return {
				["Type"] = Type,
				["XpToGive"] = XpToGive,
				["Args"] = Args
			}
		else
			CharacterProcessRemote:FireClient(Player, "Feed", Type, XpToGive, Args)
		end
	end
end

local function Add(GameModule, Player, Type, Args)
	if not Player then
		return nil
	end
	
	-- Elements
	-- VALUES
	local PlayerXpValue = ShortcutsModule:GetPlayerStatisticValue(Player, "General", "Xp")
	local PlayerCrewXpValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Crew", "CrewXp")
	
	-- Functions
	-- Init
	local XpToGive = nil
	
	if Type and typeof(Type) == "string" then
		local FeedInfo = FeedInfoModule:GetFeedInfo(Type)
		
		if FeedInfo and FeedInfo["Xp"] ~= nil then
			XpToGive = FeedInfo["Xp"]
		end
	elseif Type and typeof(Type) == "number" then
		XpToGive = Type
	end
	
	if Args and Args["Xp"] then
		XpToGive = Args["Xp"]
	end
	
	if table.find(MarketplaceModule:GetUserPurchasedGamepasses(Player), "DoubleXp") ~= nil then
		XpToGive *= 2
	end
	
	if Player:GetAttributes()["Crew"] then
		PlayerCrewXpValue.Value += XpToGive
	end
	
	PlayerXpValue.Value += XpToGive
	
	if Args and UtilitiesModule:GetCharacter(Player, true) then
		return HandleFeed(Player, Type, XpToGive, Args)
	end
end

-- DIRECT
function AddXpModule.Initialise(NilParam, GameModule, ...)
	return Add(GameModule, ...)
end

function AddXpModule.GetQueued()
	return Queued
end

return AddXpModule