local KillModule = {}

-- Dirs
local ServerModulesInitFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]["Init"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]
local ServerRemotesFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Remotes"]
local ServerSignalsFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Signals"]
local GameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]
local MainRemote = ServerRemotesFolder["Main"]

-- Signals
local GameModeSignal = ServerSignalsFolder["GameMode"]
local CoreSignal = ServerSignalsFolder["Core"]

-- Info Modules
local KillStreaksInfoModule = require(SharedInfoModulesFolder["KillStreaks"])
local GameModesInfoModule = require(SharedInfoModulesFolder["GameModes"])

-- Modules
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ServerLobbyModule = require(ServerModulesFolder["Lobby"])
local ServerDamageModule = require(ServerModulesFolder["Damage"])
local DebugModule = require(SharedModulesFolder["Debug"])
--local MainLoopModule = require(ServerModulesInitFolder["MainLoop"])

-- CORE
--[[local KillStreakToName = 
{
	[5] = "Killing Spree",
	[10] = "Killing Frenzy",
	[15] = "Running Riot"	
}]]

local Queued = true

local RegisteringKill = {}

local RapidKillsTable = {}
local KillStreaksTable = {}

-- Functions
-- MECHANICS
local function UpdateKillStreaks(Player)
	-- Functions
	-- INIT
	if KillStreaksTable[Player] == nil then
		KillStreaksTable[Player] = 0
	end

	local NewValue = KillStreaksTable[Player] + 1

	KillStreaksTable[Player] = NewValue

	local KillStreakInfo = KillStreaksInfoModule:GetKillStreakInfo("Generic", NewValue)

	if KillStreakInfo ~= nil then
		GameProcessRemote:FireAllClients("Game", "LogConsole", "Core", nil, Player.Name.. " is on a ".. KillStreakInfo["Name"].. "!")
	end

	return NewValue
end

local function UpdateRapidKillStreak(Player)
	-- Functions
	-- INIT
	if RapidKillsTable[Player] == nil then
		RapidKillsTable[Player] = 0
	end

	local NewValue = RapidKillsTable[Player] + 1

	RapidKillsTable[Player] = NewValue

	coroutine.wrap(function()
		task.wait(5)
		if RapidKillsTable[Player] == NewValue then
			RapidKillsTable[Player] = nil
		end
	end)()

	return NewValue
end

local function HandleAssistTable(ServerGameModule, AssistTable)
	-- Functions
	-- INIT

	if not AssistTable then
		return nil
	end	

	for i, PlayerName in pairs(AssistTable) do
		local FoundPlayer = game.Players:FindFirstChild(PlayerName)

		if not FoundPlayer then
			continue
		end

		-- Elements
		-- REMOTES
		local CharacterProcessRemote = UtilitiesModule:GetPlayerCharacterRemote(FoundPlayer, "CharacterProcess")
		ServerLobbyModule:IncrementValue(FoundPlayer, "Assists", 1)

		--[[if CharacterProcessRemote then
			CharacterProcessRemote:FireClient(FoundPlayer, "Badge", "Generic", "Assist")
		end]]

		ServerGameModule:GameProcess("RewardBadge", FoundPlayer, "Generic", "Assist")
	end
end


local function StopRegisteringKill(KilledPlayer)
	-- Functions
	-- INIT
	if not KilledPlayer then
		return nil
	end

	RegisteringKill[tostring(KilledPlayer)] = nil
end

local function Initialise(ServerGameModule, Player, WeaponOfChoice, KilledPlayer, IsHeadShot, BadgeOverwrite, DontLogConsole, Distance)
	if not KilledPlayer or RegisteringKill[tostring(KilledPlayer)] then
		return nil
	end

	RegisteringKill[tostring(KilledPlayer)] = true
	
	DebugModule:Print(script.Name.. " | Invoking core signal")
	if not CoreSignal:Invoke("GetRoundRunning") then
		StopRegisteringKill(KilledPlayer)
		return nil
	end
	DebugModule:Print(script.Name.. " | Passed core signal check")

	-- CORE
	local PlayerKillsValue = ShortcutsModule:GetPlayerStatisticValue(Player, "General", "Kills")
	local KilledCharacter = UtilitiesModule:GetCharacter(KilledPlayer, true)
	local PlayerCharacter = UtilitiesModule:GetCharacter(Player, true)
	local AssistTable = ServerDamageModule:GetAssistTable(KilledCharacter)
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(GameFolder:GetAttribute("GameMode"))
	local CharacterProcessRemote = nil
	local MethodOfKill = " killed "
	local IsAi = false
	
	pcall(function()
		if KilledPlayer["AI"] then
			IsAi = true
		end
	end)
	
	-- Elements
	-- HUMANOIDS
	local PlayerCharacterHumanoid = UtilitiesModule:WaitForChildOfClass(PlayerCharacter, "Humanoid")
	
	-- Functions
	-- INIT
	
	--[[if AssistTable then
		--DebugModule:Print"ASSIST TABLE: ".. tostring(AssistTable).. " | SIZE: ".. tostring(#AssistTable))
	end]]

	if UtilitiesModule:GetCharacter(Player, true) then
		CharacterProcessRemote = UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess")
	end

	if GameModeInfo and GameModeInfo["Teams"] and Player.Team == KilledPlayer.Team and Player ~= KilledPlayer then
		GameProcessRemote:FireClient(KilledPlayer, "Betrayed")

		if CharacterProcessRemote then
			CharacterProcessRemote:FireClient(Player, "Sound", "Narrator", "Betrayed")
		end
		--

		MethodOfKill = " betrayed "

		ServerGameModule:GameProcess("AddXp", Player, "Betrayal", {Target = KilledPlayer})
	elseif Player == KilledPlayer then
		MethodOfKill = " suicide "
	else
		if WeaponOfChoice == "Melee" then
			--[[if CharacterProcessRemote then
				--CharacterProcessRemote:FireClient(Player, "Badge", "Generic", "Melee")
			end]]

			ServerGameModule:GameProcess("RewardBadge", Player, "Generic", "Melee")

			MethodOfKill = " pummeled "
		elseif WeaponOfChoice == "Explosion" then
			MethodOfKill = " exploded "

			if BadgeOverwrite and string.lower(BadgeOverwrite) == "stuck" then
				MethodOfKill = " stuck "
			end

			ServerGameModule:GameProcess("RewardBadge", Player, "Generic", "Explosion")
		end

		if PlayerCharacterHumanoid and PlayerCharacterHumanoid.Health <= 0 then
			ServerGameModule:GameProcess("RewardBadge", Player, "Generic", "FromTheGrave")
		end

		if KillStreaksTable[tostring(KilledPlayer)] and KillStreaksTable[tostring(KilledPlayer)] > 5 then
			--[[if CharacterProcessRemote then
				CharacterProcessRemote:FireClient(Player, "Badge", "Generic", "KillJoy")
			end]]

			ServerGameModule:GameProcess("RewardBadge", Player, "Generic", "KillJoy")
		end
	end


	if not table.find({" betrayed ", " suicide "}, MethodOfKill) then
		ServerLobbyModule:IncrementValue(Player, "Kills", 1)
		
		if not IsAi then
			PlayerKillsValue.Value += 1
			ServerGameModule:GameProcess("AddXp", Player, "Kill", {Target = KilledPlayer})
		end
		
		local NewValue = UpdateRapidKillStreak(Player)
		local GenericNewValue = UpdateKillStreaks(Player)

		--coroutine.wrap(function()
		if CharacterProcessRemote then
			if NewValue then
				local Success, Error = pcall(function()	
					local KillstreakInfo = KillStreaksInfoModule:GetKillStreakInfo("Rapid", NewValue)	

					--CharacterProcessRemote:FireClient(Player, "Badge", "Rapid", NewValue)
					if KillstreakInfo and KillstreakInfo["Xp"] then
						ServerGameModule:GameProcess("AddXp", Player, KillstreakInfo["Name"], {["Xp"] = KillstreakInfo["Xp"]})
					end
				end)

				ServerGameModule:GameProcess("RewardBadge", Player, "Rapid", NewValue)
			end

			if GenericNewValue then
				local Success, Error = pcall(function()
					local KillstreakInfo = KillStreaksInfoModule:GetKillStreakInfo("Generic", GenericNewValue)	

					if KillstreakInfo and KillstreakInfo["Xp"] then
						ServerGameModule:GameProcess("AddXp", Player, KillstreakInfo["Name"], {["Xp"] = KillstreakInfo["Xp"]})
					end
				end)

				--CharacterProcessRemote:FireClient(Player, "Badge", "Generic", GenericNewValue)
				ServerGameModule:GameProcess("RewardBadge", Player, "Generic", GenericNewValue)
			end

			if IsHeadShot then
				--CharacterProcessRemote:FireClient(Player, "Badge", "Generic", "HeadCase")
				ServerGameModule:GameProcess("RewardBadge", Player, "Generic", "HeadCase")
			end

			if BadgeOverwrite then
				ServerGameModule:GameProcess("RewardBadge", Player, "Generic", BadgeOverwrite)
			end
		end
		--end)()
		----
	end

	if BadgeOverwrite == "SniperHeadshot" then
		MethodOfKill = " sniped "
	end
	
	if MethodOfKill ~= " suicide " then
		local GameModeMethodOfKillOverwrite = GameModeSignal:Invoke("GetKillType", KilledPlayer, Player, MethodOfKill)
		
		if GameModeMethodOfKillOverwrite ~= nil then
			MethodOfKill = GameModeMethodOfKillOverwrite
		end
		
		if AssistTable then
			HandleAssistTable(ServerGameModule, AssistTable)
		end
		
		GameProcessRemote:FireClient(Player, "Game", "Kill")
		
		local DistanceInMeters = nil 
		
		local Success, Error = pcall(function()
			DistanceInMeters = Distance * 0.28 -- .28 meters is 1 stud
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | DistanceInMeters: ".. tostring(DistanceInMeters).. " | Error: ".. tostring(Error))
		end
		
		if not DontLogConsole then
			if Distance then
				GameProcessRemote:FireAllClients("Game", "LogConsole", "Core", nil, Player.Name.. MethodOfKill.. KilledPlayer.Name.. " [ ".. tostring(math.floor(--[[Distance]] DistanceInMeters)).. "m ]")
			else
				GameProcessRemote:FireAllClients("Game", "LogConsole", "Core", nil, Player.Name.. MethodOfKill.. KilledPlayer.Name)
			end
		end
	else
		if not DontLogConsole then
			GameProcessRemote:FireAllClients("Game", "LogConsole", "Core", nil, Player.Name.. " committed suicide!")
		end
	end
	
	MainRemote:Fire("PlayerKilled", KilledPlayer, Player)
	
	DebugModule:Print(script.Name.. " | Firing Client died signal | KilledPlayer: ".. tostring(KilledPlayer))
	
	if typeof(KilledPlayer) == "Instance" and KilledPlayer:IsDescendantOf(game.Players) then
		GameProcessRemote:FireClient(KilledPlayer, "Game", "Died", --[[{["Murderer"] = Player}]] Player)
	end
	--KilledPlayer:SetAttribute("KilledBy", Player.Name)
	--KilledPlayer:SetAttribute("KilledByTime", tick())
	
	--ServerDamageModule:RemoveAssistTable(UtilitiesModule:GetCharacter(KilledPlayer, true))
	RapidKillsTable[tostring(KilledPlayer)] = nil
	KillStreaksTable[tostring(KilledPlayer)] = nil

	coroutine.wrap(function()
		task.wait(1)
		StopRegisteringKill(KilledPlayer)
	end)()
end

local function End()
	-- Functions
	-- INIT
	RegisteringKill = {}
	KillStreaksTable = {}
	RapidKillsTable = {}
	ServerDamageModule:Reset()
end

local function ResetPlayer(Player)
	-- Functions
	-- INIT
	RapidKillsTable[Player] = nil
	KillStreaksTable[Player] = nil
end

-- DIRECT
function KillModule.GetQueued()
	return Queued
end

function KillModule.ResetPlayer(NilParam, GameModule, ...)
	return ResetPlayer(...)
end

function KillModule.Initialise(NilParam, GameModule, ...)
	return Initialise(GameModule, ...)
end

function KillModule.End(NilParam, GameModule, ...)
	return End(GameModule, ...)
end

return KillModule