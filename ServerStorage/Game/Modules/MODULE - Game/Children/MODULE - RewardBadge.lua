local RewardBadgeModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Info Modules
--local KillstreaksInfoModule = require(SharedInfoModulesFolder["KillStreaks"])

-- Modules
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local Queued = false

-- Functions
-- MECHANICS
local function RewardBadge(ServerGameModule, Player, BadgeType, BadgeName)
	-- CORE
	local PlayerBadgesValue = ShortcutsModule:GetPlayerStatisticValue(Player, "General", "BadgesEarned")
	local CharacterProcessRemote = nil
	
	if UtilitiesModule:GetCharacter(Player, true) then
		CharacterProcessRemote = UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess")
	end
	
	-- Functions
	-- INIT
	PlayerBadgesValue.Value += 1
	
	if CharacterProcessRemote then
		CharacterProcessRemote:FireClient(Player, "Badge", BadgeType, BadgeName)
	end
end

-- DIRECT
function RewardBadgeModule.Initialise(NilParam, ServerGameModule, Player, BadgeType, BadgeName)
	return RewardBadge(ServerGameModule, Player, BadgeType, BadgeName)
end

function RewardBadgeModule.GetQueued()
	return Queued
end

return RewardBadgeModule