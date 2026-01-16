local MainLoopModule = {}

-- Dirs
local SharedServerWeaponsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ServerInitModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]["Init"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedSpartansFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Spartans"]
local ServerRemotesFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Remotes"]
local ServerSignalsFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Signals"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")

-- Elements
-- Remotes
local CoreRemote = ServerRemotesFolder["Core"]
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]
local MainRemote = ServerRemotesFolder["Main"]

-- Signals
local CoreSignal = ServerSignalsFolder["Core"]

-- FOLDERS
local SharedGameLobbyFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Lobby"]
local SharedGameScoresFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Scores"]
local SharedGameDeployedFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Deployed"]

-- InfoModules
local GameModesInfoModule = require(SharedInfoModulesFolder["GameModes"])
local GameInfoModule = require(ServerInfoModulesFolder["Game"])

-- Modules
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local GameModule = require(UtilitiesModule:WaitForChildTimed(ServerModulesFolder, "Game"))
local LobbyModule = require(UtilitiesModule:WaitForChildTimed(ServerModulesFolder, "Lobby"))
local TeamsModule = require(UtilitiesModule:WaitForChildTimed(ServerModulesFolder, "Teams"))
local MapsModule = require(UtilitiesModule:WaitForChildTimed(ServerModulesFolder, "Maps"))
local CharacterActionsModule = require(UtilitiesModule:WaitForChildTimed(ServerModulesFolder, "CharacterActions"))
local DebugModule = require(UtilitiesModule:WaitForChildTimed(SharedModulesFolder, "Debug"))
local NotificationsModule = require(UtilitiesModule:WaitForChildTimed(ServerModulesFolder, "Notifications"))
local DebrisModule = require(SharedModulesFolder["Debris"])

-- CORE
local Connections = {}
local CustomConnections = {}

local ClientsCanSwitchMap = {} -- Developer Product Linked
local ClientsCanSwitchMode = {} -- Developer Product Linked

local RequiredModules = {}

----
local PlayerToDeployTime = {}
local SelectedMaps = {}
local SelectedModes = {}

---------
local RoundTimeStarted = nil
local RoundRunning = false
local CurrentLoopStage = 0
---------
local NextClientSelectedMap = nil
local NextClientSelectedGameMode = nil

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

--[[local function PlayerLeft(Player)
	-- Functions
	-- INIT
	for ModuleName, Module in pairs(RequiredModules) do
		Module:PlayerLeft(Player)
	end
end]]

local function CreateCustomConnection()
	-- Functions
	-- INIT
	local CustomConnection = Instance.new("BoolValue")
	CustomConnection.Value = true
	
	return CustomConnection
end

local function WaitForEnoughPlayers()
	-- Functions
	-- INIT
	DebugModule:Print(script.Name.. " | Waiting for enough players first")
	repeat
		local PlayersNeeded = GameInfoModule:GetGameInfo("MinimumPlayers") - LobbyModule:GetNumberOfPlayersInLobby()
		
		LobbyModule:SetLobbyHintText("Waiting for at least ".. PlayersNeeded.. " more players!")
		task.wait()
	until LobbyModule:GetNumberOfPlayersInLobby() >= GameInfoModule:GetGameInfo("MinimumPlayers")
	DebugModule:Print(script.Name.. " | Got enough players!")
end

local function Intermission(CustomConnection)
	-- Functions
	-- INIT
	GameModule:ClearTotalScores()
	LobbyModule:SetLobbyHintText("Intermission. Hang tight!")
	UtilitiesModule:BetterCountdown(GameInfoModule:GetGameInfo("IntermissionTime"), CustomConnection)
end

local function GetPlayableGameModes(AllGameModes)
	-- CORE
	local Playable = {}
	local MembersInLobby = #SharedGameLobbyFolder:GetChildren()
	
	-- Functions
	-- INIT
	for GameModeName, GameModeInfo in pairs(AllGameModes) do
		local RequiredNumberOfPlayers = 0
		
		if GameModeInfo["Teams"] then
			for Index, TeamInfo in pairs(GameModeInfo["Teams"]) do
				RequiredNumberOfPlayers += TeamInfo["StartMembers"] or 1
			end
		else
			RequiredNumberOfPlayers += GameModeInfo["MinimumPlayers"] or 1
		end
		
		if MembersInLobby >= RequiredNumberOfPlayers then
			--Playable[GameModeName] = GameModeInfo
			table.insert(Playable, GameModeName)
		end
	end
	
	return Playable
end

local function SelectGameMode(CustomConnection, RecursiveCount)
	-- CORE
	RecursiveCount = RecursiveCount or 1
	local GameModes = GetPlayableGameModes(GameModesInfoModule:GetAllGameModesInfo()) --GetPlayableGameModes(UtilitiesModule:GetDictKeys(GameModesInfoModule:GetAllGameModesInfo()))
	
	local SelectedModeName = NextClientSelectedGameMode or ""
	
	-- Functions
	-- INIT
	LobbyModule:SetLobbyHintText("Selecting game mode!")
	
	UtilitiesModule:BetterCountdown(3, CustomConnection)
	
	if SelectedModeName == "" then
		if not GameModes or #GameModes <= 0 then
			DisconnectRoundLoop()
		end
		
		local PlayableInCategory  ={}
		
		for i, GameModeName in pairs(SelectedModes) do
			if table.find(GameModes, GameModeName) then
				table.insert(PlayableInCategory, GameModeName)
			end
		end
		
		--[[if #SelectedModes >= #GameModes then
			SelectedModes = {}
		end]]
		
		if #SelectedModes >= #PlayableInCategory then
			SelectedModes = {}
		end
		
		repeat
			task.wait()
			local Success, Error = pcall(function()
				SelectedModeName = GameModes[math.random(1, #GameModes)]
			end)
			
			if not Success then
				DebugModule:Print(script.Name.. " | SelectGameMode | Error: ".. tostring(Error))
				return SelectGameMode(CustomConnection, RecursiveCount)
			end
		until not table.find(SelectedModes, SelectedModeName) or not CustomConnection or not CustomConnection.Value
	end

	table.insert(SelectedModes, SelectedModeName)
	
	GameModule:SetGameMode(SelectedModeName)
	--GameModule:SetGameMode(NextClientSelectedGameMode or GameModes[math.random(1, #GameModes)])
	
	if not NextClientSelectedGameMode and RecursiveCount < 2 and CustomConnection and CustomConnection.Value and #GameModes > 1 then
		local Veto = Veto(CustomConnection, "Game Mode")
		
		if Veto then
			return SelectGameMode(CustomConnection, RecursiveCount + 1)
		end
	else
		if GameModule:GetGameMode() == NextClientSelectedGameMode then
			NextClientSelectedGameMode = nil
		end
		
		GameModule:SetupTotalScores()
	end
end

function Veto(CustomConnection, Type)
	-- CORE
	local VetoVotes = 0
	local VotesNeeded = math.ceil(LobbyModule:GetNumberOfPlayersInLobby() / 2)
	local VetoedPlayers = {}
	local InnerCustomConnection = UtilitiesModule:CreateCustomConnection(CustomConnections)
	
	-- Functions
	-- MECHANICS
	local function Update()
		-- Functions
		-- INIT
		LobbyModule:SetLobbyHintText("Veto (skip) votes needed to change '".. tostring(Type).. "': ".. tostring(VotesNeeded - VetoVotes))
		
		if VetoVotes >= VotesNeeded then
			UtilitiesModule:DisconnectCustomConnections({InnerCustomConnection})
		end
	end
	
	-- DIRECT
	ClientRequests["Veto"] = function(Player)
		if not table.find(VetoedPlayers, Player) then
			VetoVotes += 1
			table.insert(VetoedPlayers, Player)
			Update()
		end
	end
	
	-- INIT
	Update()
	
	coroutine.wrap(function()
		local TimeNow = tick()
		
		repeat
			if not CustomConnection or not CustomConnection.Value then
				UtilitiesModule:DisconnectCustomConnections({InnerCustomConnection})
				break
			end
			
			task.wait(.05)
		until (tick() - TimeNow) >= GameInfoModule:GetGameInfo("VetoTime") 
	end)()
	
	UtilitiesModule:BetterCountdown(GameInfoModule:GetGameInfo("VetoTime"), InnerCustomConnection)
	
	if VetoVotes >= VotesNeeded then
		return true
	else
		return false
	end
end

local function SelectMap(CustomConnection, RecursiveCount)
	-- CORE
	RecursiveCount = RecursiveCount or 1
	local MapNames = MapsModule:GetAllMapNames(SharedGameFolder:GetAttribute("GameMode"))
	local SelectedMapName = NextClientSelectedMap 
	
	if not SelectedMapName then
		SelectedMapName = ""
	end
	
	-- Functions
	-- INIT
	
	if SelectedMapName == "" then
		if #SelectedMaps >= #MapNames then
			SelectedMaps = {}
		end
		
		repeat
			task.wait()
			SelectedMapName = MapNames[math.random(1, #MapNames)]
		until not table.find(SelectedMaps, SelectedMapName)
	end
	
	table.insert(SelectedMaps, SelectedMapName)
	LobbyModule:SetLobbyHintText("Selecting map!")
	UtilitiesModule:BetterCountdown(3, CustomConnection)
	
	if NextClientSelectedMap then
		SelectedMapName = NextClientSelectedMap
	end
	
	GameModule:SetMap(SelectedMapName)
	
	
	if not NextClientSelectedMap and RecursiveCount < 2 and #MapsModule:GetAllMapNames(SharedGameFolder:GetAttribute("GameMode")) > 1 then
		local VetoResult = Veto(CustomConnection, "Map")
		
		if VetoResult and RecursiveCount < 2 and CustomConnection and CustomConnection.Value then
			return SelectMap(CustomConnection, RecursiveCount + 1)
		end
	else
		if GameModule:GetMap() == NextClientSelectedMap then
			NextClientSelectedMap = nil
		end
	end
end

local function SplitTeams(CustomConnection)
	-- CORE
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(SharedGameFolder:GetAttribute("GameMode"))
	local TeamsInfo = GameModesInfoModule:GetGameModeInfo(GameModule:GetGameMode())["Teams"]
	local NumberOfPlayersInLobby = LobbyModule:GetNumberOfPlayersInLobby()
	local NumberOfTeams = 0
	
	local PlayerLeftToTeam = {}
	
	if TeamsInfo then
		NumberOfTeams = UtilitiesModule:GetSizeOfDict(TeamsInfo) or 0
	end
	
	-- Functions
	-- MECHANICS
	local function CheckIfTeamsExist()
		-- Functions
		-- INIT
		if not GameModeInfo["Teams"] then
			return nil
		end
		
		for TeamIndex, TeamInfo in pairs(GameModeInfo["Teams"]) do
			local FoundTeam = game.Teams:FindFirstChild(TeamInfo["Name"])
			
			if not FoundTeam and (TeamInfo and TeamInfo["StartMembers"] and TeamInfo["StartMembers"] ~= 0) then
				return false
			end
			
			if FoundTeam and #FoundTeam:GetPlayers() <= 0 then
				if TeamInfo["StartMembers"] ~= 0 then
					return false
				end
			end
		end
		
		return true
	end
	
	local function GetLowestMemberTeam()
		-- CORE
		local NumberOfMembers, TeamName, TeamIndex = math.huge, nil, nil
		
		-- Functions
		-- INIT
		for i = 1, NumberOfTeams do
			local NumberOfPlayersOnTeam = TeamsModule:GetNumberOfMembersOnTeam(TeamsInfo[i]["Name"]) 
			
			if NumberOfPlayersOnTeam == nil then
				NumberOfPlayersOnTeam = 0
			end
			
			if NumberOfPlayersOnTeam <= NumberOfMembers and ((TeamsModule:GetTeamInfo(TeamsInfo[i]["Name"])["StartMembers"] and NumberOfPlayersOnTeam < TeamsModule:GetTeamInfo(TeamsInfo[i]["Name"])["StartMembers"]) or not TeamsModule:GetTeamInfo(TeamsInfo[i]["Name"])["StartMembers"]) then
				NumberOfMembers = NumberOfPlayersOnTeam
				TeamName = TeamsInfo[i]["Name"]
				TeamIndex = i
			end
		end
		
		return TeamName, TeamIndex
	end
	
	-- DIRECT
	function MainLoopModule.AddToLobby(NilParam, Player)
		-- Functions
		-- INIT
		if not CustomConnection or not CustomConnection.Value then
			return nil
		end
		
		if TeamsInfo then
			local SwitchToName = nil
			
			if PlayerLeftToTeam[Player.Name] then			
				SwitchToName = PlayerLeftToTeam[Player.Name]
			else
				local TeamName, TeamIndex = GetLowestMemberTeam()
				SwitchToName = TeamName	
			end
			
			if SwitchToName then
				TeamsModule:SwitchTeam(Player, SwitchToName, TeamsModule:GetTeamInfo(SwitchToName)) --[[TeamsInfo[TeamIndex]["Name"], TeamsInfo[TeamIndex])]]
			end
			
			PlayerLeftToTeam[Player.Name] = nil
		end
		
		if RoundRunning then
			if MainLoopModule.PlayerAddedRound ~= nil then
				MainLoopModule:PlayerAddedRound(Player)
			end
			
			local GameModeModule = RequiredModules[GameModule:GetGameMode()]
			
			if GameModeModule then
				return GameModeModule:PlayerAdded(Player)
			end
		end
	end
	
	function MainLoopModule.RemoveFromLobby(NilParam, Player)
		-- Functions
		-- INIT
		local PlayerTeam = Player.Team
		
		if PlayerTeam and not PlayerLeftToTeam[Player.Name] then
			PlayerLeftToTeam[Player.Name] = PlayerTeam.Name
		end
		
		local GameModeModule = RequiredModules[GameModule:GetGameMode()]
		
		if GameModeModule then
			GameModeModule:PlayerLeft(Player)
		end
		
		if MainLoopModule.PlayerLeftRound ~= nil then
			MainLoopModule:PlayerLeftRound(Player)
		end
	
		if Player and UtilitiesModule:HasProperty(Player, "Team") and Player.Team then
			Player.Neutral = true
		end
		
		if CheckIfTeamsExist() == false then
			DisconnectRoundLoop()
			--UtilitiesModule:DisconnectCustomConnections({CustomConnection})
		end

		
		if not CustomConnection or not CustomConnection.Value then
			return nil
		end
	end
	
	-- INIT
	LobbyModule:SetLobbyHintText("Splitting Teams. Please wait!")
	
	local PlayersInLobby = LobbyModule:GetPlayersInLobby()
	
	
	local function PickRandomFromLobby()
		-- Functions
		-- INIT
		local Index = math.random(1, #PlayersInLobby)
		
		return PlayersInLobby[Index], Index
	end
	
	
	local TeamToMembers = {}
	
	if TeamsInfo then
		for i, TeamInfo in pairs(TeamsInfo or {}) do
			if not TeamInfo["StartMembers"] then
				continue
			end
			
			local Members = {}
			
			if TeamInfo["StartMembers"] > #PlayersInLobby then
				DisconnectRoundLoop()
				--UtilitiesModule:DisconnectCustomConnections({CustomConnection})
				break
			end
			
			for x = 1, TeamInfo["StartMembers"] do
				local Player, Index = PickRandomFromLobby()
				TeamsModule:SwitchTeam(Player, TeamsInfo[i].Name, TeamsInfo[i])
				table.remove(PlayersInLobby, Index)
			end
			
			TeamToMembers[i] = Members
		end
	end
	
	--NumberOfTeams = NumberOfTeams - UtilitiesModule:GetSizeOfDict(TeamToMembers)
	
	if not CustomConnection or not CustomConnection.Value then
		return nil
	end
	
	local NumberOfPlayersOnSingleTeam = math.ceil(#PlayersInLobby / (NumberOfTeams - UtilitiesModule:GetSizeOfDict(TeamToMembers))) -- Even Split
	
	local Index = 1
	
	for x = 1, NumberOfTeams do
		if TeamToMembers[x] ~= nil then
			continue
		end
		
		for i = 1, NumberOfPlayersOnSingleTeam do
			if PlayersInLobby[Index] and TeamsInfo then
				TeamsModule:SwitchTeam(PlayersInLobby[Index], TeamsInfo[x].Name, TeamsInfo[x])
			end
			
			Index += 1
		end
	end
end

local function LoadMap(CustomConnection)
	-- Functions
	-- INIT
	LobbyModule:SetLobbyHintText("Loading Map. Please wait!")
	
	MapsModule:LoadMap(GameModule:GetMap(), GameModule:GetGameMode())
	
	UtilitiesModule:BetterCountdown(GameInfoModule:GetGameInfo("StaticMapLoadingTime"), CustomConnection)
end

local function GameStarting(CustomConnection)
	-- Functions
	-- INIT
	LobbyModule:SetLobbyHintText("Game Starting. Please wait!")
	
	UtilitiesModule:BetterCountdown(GameInfoModule:GetGameInfo("GameStartingTime"), CustomConnection)
end

local function RoundStart(CustomConnection)
	-- CORE
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(GameModule:GetGameMode())
	local RoundConnections = {}
	--local PlayersDeployed = {} -- GAME
	local GameModeModule = RequiredModules[GameModule:GetGameMode()]
	
	--local PlayerLeftToTeam = {}
	
	local PlayerToAttributes = {}
	
	-- 
	local PlayersDeploying = {} -- DEBOUNCE
	local PlayersRespawning = {}
	
	-- Functions
	-- MECHANICS
	local function AreAllPlayersNoLives()
		-- CORE
		local Teams = GameModeInfo["Teams"]
		local AllDead = true
		
		-- Functions
	 	-- INIT		
		if not Teams then
			Teams = {}
			AllDead = false
		end
		
		for i, TeamInfo in pairs(Teams) do
			local FoundTeamInstance = game:GetService("Teams"):FindFirstChild(TeamInfo["Name"])
			
			if not FoundTeamInstance or (TeamInfo["StartMembers"] and TeamInfo["StartMembers"] == 0) then
				continue
			end
			
			for i, DeployedPlayerValue in pairs(SharedGameDeployedFolder:GetChildren()) do
				local Player = game.Players:FindFirstChild(DeployedPlayerValue.Name)
				
				if not Player or Player.Team ~= FoundTeamInstance then
					continue
				end

				local FoundLobbyValue = SharedGameLobbyFolder:FindFirstChild(Player.Name)

				if FoundLobbyValue and (FoundLobbyValue:GetAttributes()["Lives"] or 0) > 0 then
					AllDead = false
					break
				end
			end
			
			--[[for i, Player in pairs(FoundTeamInstance:GetPlayers()) do
				if not Player or Player.Team ~= FoundTeamInstance then
					continue
				end
				
				local FoundLobbyValue = SharedGameLobbyFolder:FindFirstChild(Player.Name)

				if FoundLobbyValue and (FoundLobbyValue:GetAttributes()["Lives"] or 0) > 0 then
					AllDead = false
					break
				end
			end]]
		end
		
		return AllDead
	end
	
	-- DIRECT
	function MainLoopModule.PlayerDied(NilParam, ...)
		-- Functions
		-- INIT
		if AreAllPlayersNoLives() then
			DisconnectRoundLoop()
			--UtilitiesModule:DisconnectCustomConnections({CustomConnection})
		end
		
		task.wait(1.5)
		
		if GameModeModule.PlayerDied ~= nil then
			return GameModeModule:PlayerDied(...)
		end
	end
	
	function MainLoopModule.PlayerShotRegistered(NilParam, ...)
		-- Functions
		-- INIT
		
		if GameModeModule.PlayerShotRegistered ~= nil then
			return GameModeModule:PlayerShotRegistered(...)
		end
	end
	
	function MainLoopModule.PlayerKilled(NilParam, ...)
		-- Functions
		-- INIT
		
		if GameModeModule.PlayerKilled ~= nil then
			return GameModeModule:PlayerKilled(...)
		end
	end
	
	function MainLoopModule.CharacterAdded(NilParam, Player, Character)
		
		-- Functions
		-- MECHANICS
		local function GetWeaponNameFromProperty(Property, Ignore)
			-- Functions
			-- INIT
			if Property and Property == "Random" then
				local AllWeaponNames = ShortcutsModule:GetAllNoneDevWeaponNames() --UtilitiesModule:GetChildrenNames(SharedServerWeaponsFolder)
				
				local WeaponName = AllWeaponNames[math.random(1, #AllWeaponNames)]
				
				while WeaponName == Ignore and task.wait() do
					WeaponName = AllWeaponNames[math.random(1, #AllWeaponNames)]
				end
				
				return WeaponName
			else
				return Property or ""
			end
		end
		
		-- INIT
		if not Character then
			return nil
		end
		
		local PlayerTeam = Player.Team
		
		pcall(function()
			if not GameModeInfo["Teams"] or (PlayerTeam and not TeamsModule:GetTeamInfo(PlayerTeam)["Weapons"] --[[GameModeInfo["Teams"][PlayerTeam.Name]["Weapons"]--]]) then
				local Primary = GetWeaponNameFromProperty(GameModeInfo["StartWeapons"]["Primary"])
				Character:SetAttribute("Primary", Primary --[[GameModeInfo["StartWeapons"]["Primary"] or ""]])
				Character:SetAttribute("Secondary", GetWeaponNameFromProperty(GameModeInfo["StartWeapons"]["Secondary"], Primary) --[[GameModeInfo["StartWeapons"]["Secondary"] or ""]])
			else
				local TeamInfo = TeamsModule:GetTeamInfo(PlayerTeam) --GameModeInfo["Teams"][PlayerTeam.Name]
				local Primary = GetWeaponNameFromProperty(TeamInfo["Weapons"]["Primary"])

				Character:SetAttribute("Primary", Primary --[[or ""]])
				Character:SetAttribute("Secondary", GetWeaponNameFromProperty(TeamInfo["Weapons"]["Secondary"], Primary) --[[or ""]])		
			end
		end)
		
		for GrenadeName, GrenadeAmount in pairs(GameModeInfo["StartGrenades"]) do
			Character:SetAttribute(tostring(GrenadeName).. "Grenades", tonumber(GrenadeAmount))
		end
	end
	
	function MainLoopModule.PlayerAddedRound(NilParam, Player)
		-- Functions
		-- INIT
		local PlayerLobbyValue = SharedGameLobbyFolder:FindFirstChild(Player.Name)

		if not PlayerLobbyValue then
			DebugModule:Print(script.Name.. " | PlayerAddedRound | Cannnot find PlayerLobbyValue")
			return nil
		end
		
		if GameModeInfo and not GameModeInfo["Teams"] then	
			local Connection1 = PlayerLobbyValue:GetAttributeChangedSignal("Score"):Connect(function()
				if PlayerLobbyValue:GetAttribute("Score") >= GameModeInfo["ScoreTo"] then
					--UtilitiesModule:DisconnectCustomConnections({CustomConnection})
					DisconnectRoundLoop()
				end
			end)
			
			-- Connections
			table.insert(RoundConnections, Connection1)
		end
		
		local PlayerTeam = Player.Team
		local TeamInfo = nil
		
		if PlayerTeam then
			TeamInfo = TeamsModule:GetTeamInfo(PlayerTeam)
			
			if TeamInfo and TeamInfo["Lives"] then
				PlayerLobbyValue:SetAttribute("Lives", TeamInfo["Lives"] or GameModeInfo["Lives"])
			else
				PlayerLobbyValue:SetAttribute("Lives", GameModeInfo["Lives"] or math.huge)
			end
		else
			PlayerLobbyValue:SetAttribute("Lives", GameModeInfo["Lives"] or math.huge)
		end
		
		if PlayerToAttributes[Player] then
			for AttributeName, AttributeValue in pairs(PlayerToAttributes) do
				PlayerLobbyValue:SetAttribute(AttributeName, AttributeValue)
			end
		end
	end
	
	function MainLoopModule.PlayerLeftRound(NilParam, Player)
		-- Functions
		-- INIT
		
		--if PlayersDeployed then
		--local FoundIndex = table.find(PlayersDeployed, Player)
		--[[local PlayerTeam = Player.Team
		
		if PlayerTeam then
			PlayerLeftToTeam[Player.Name] = PlayerTeam.Name
		end]]
		
		
		local Success, Error = pcall(function()
			local FoundPlayerLobbyValue = SharedGameLobbyFolder:FindFirstChild(Player.Name)	
			
			if FoundPlayerLobbyValue then
				PlayerToAttributes[Player] = FoundPlayerLobbyValue:GetAttributes()
			end
		end)
		
		local FoundPlayerDeployedValue = SharedGameDeployedFolder:FindFirstChild(Player.Name)
		
		if FoundPlayerDeployedValue then
			DebrisModule:AddItem(FoundPlayerDeployedValue)
			--FoundPlayer:Destroy()
		end		
		
		if AreAllPlayersNoLives() then
			DisconnectRoundLoop()
			--UtilitiesModule:DisconnectCustomConnections({CustomConnection}) nil
		end
		
			--if FoundIndex then
				--table.remove(PlayersDeployed, FoundIndex)
				--GameModule:SetPlayersDeployed(math.clamp(GameModule:GetPlayersDeployed() - 1, 0, math.huge))
			--end
			--[[if FoundPlayer then
				GameModule:SetPlayersDeployed(#SharedGameDeployedFolder:GetChildren() --[[math.clamp(GameModule:GetPlayersDeployed() - 1, 0, math.huge)]]--)
			--end
		--end
	end
	
	ClientRequests["Respawn"] = function(Player, SkipTimer)
		if not CustomConnection or not CustomConnection.Value or not RoundRunning or not PlayersRespawning then
			return nil
		end
				
		if PlayersRespawning[Player] then
			return nil
		end
		
		local PlayerLobbyValue = SharedGameLobbyFolder:FindFirstChild(Player.Name)
		
		PlayersRespawning[Player] = true
		
		local RespawnTime = GameInfoModule:GetGameInfo("RespawnTime")
		
		coroutine.wrap(function()
			if not SkipTimer then
				task.wait(RespawnTime)
			end
			
			if not CustomConnection or not CustomConnection.Value or not RoundRunning then
				return nil
			end
			
			if ClientRequests and ClientRequests["Deploy"] then
				local Response = ClientRequests["Deploy"](Player, true)
				
				if Response == "No Lives" or (PlayerLobbyValue and PlayerLobbyValue:GetAttributes()["Lives"] <= 0) then
					pcall(function()
						local Character = Player.Character
						
						Player.Character = nil
						
						DebrisModule:AddItem(Character)
					end)
					GameProcessRemote:FireClient(Player, "Game", "Spectate")
				end
			end
			
			if PlayersRespawning and PlayersRespawning[Player] then
				PlayersRespawning[Player] = nil
			end
		end)()
		
		return RespawnTime
	end
	
	ClientRequests["Undeploy"] = function(Player)
		if not CustomConnection or not CustomConnection.Value or not PlayersDeploying then
			return nil
		end
		
		if PlayersDeploying[Player] ~= nil then
			return nil
		end
		
		local Character = UtilitiesModule:GetCharacter(Player, true)
		
		if Character then
			local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
			
			Humanoid.Health = 0
			DebrisModule:AddItem(Character)
			--Character:Destroy()
		end
		
		--[[local FoundIndex = table.find(PlayersDeployed, Player)
		
		if FoundIndex then
			table.remove(PlayersDeployed, FoundIndex)
		end]]
		
		local FoundPlayerDeployedValue = SharedGameDeployedFolder:FindFirstChild(Player.Name)
		
		if FoundPlayerDeployedValue then
			FoundPlayerDeployedValue:Destroy()
		end
		
		--GameModule:SetPlayersDeployed( #SharedGameDeployedFolder:GetChildren() --[[#PlayersDeployed]] --[[GameModule:GetPlayersDeployed() + 1]])
		
		if AreAllPlayersNoLives() then
			DisconnectRoundLoop()
		end
		
		PlayersDeploying[Player] = nil
		PlayersRespawning[Player] = nil
	end
	
	ClientRequests["Deploy"] = function(Player, Respawn)
		if not CustomConnection or not CustomConnection.Value or not RoundRunning or not PlayersDeploying then
			return nil
		end
		
		if PlayersDeploying[Player] ~= nil then
			return nil
		end
		
		local PlayerLobbyValue = SharedGameLobbyFolder:FindFirstChild(Player.Name)
		
		if PlayerLobbyValue and PlayerLobbyValue:GetAttributes()["Lives"] <= 0 then
			PlayersDeploying[Player] = nil
			return "No Lives"
		end
		
		PlayersDeploying[Player] = true
		
		DebugModule:Print("MainLoop | Deploying: ".. tostring(Player).. " | Respawn: ".. tostring(Respawn))
		
		PlayerToDeployTime[Player] = tick()
		
		pcall(function()
			if PlayerLobbyValue then
				PlayerLobbyValue:SetAttribute("Deploy", (PlayerLobbyValue:GetAttributes()["Deploy"] or 0) + 1)
			end
		end)
		
		local Response = GameModule:GameProcess("SpawnCharacter", Player, Respawn)
		
		if not Response then
			while not Response and RoundRunning and task.wait() and Player do
				Response = GameModule:GameProcess("SpawnCharacter", Player, Respawn)
			end
		end
		
		coroutine.wrap(function()
			task.wait(1)
			
			if Player and PlayersDeploying then
				PlayersDeploying[Player] = nil
			end
		end)()
		
		return true
	end
	
	-- INIT	
	
	if GameModeInfo["Teams"] then
		local Connection1 = SharedGameScoresFolder.ChildAdded:Connect(function(TeamTotalScoreValue)
			local Connection2 = TeamTotalScoreValue:GetPropertyChangedSignal("Value"):Connect(function()
				if TeamTotalScoreValue.Value >= GameModeInfo["ScoreTo"] then
					DisconnectRoundLoop()
					--UtilitiesModule:DisconnectCustomConnections({CustomConnection})
				end
			end)

			-- Connections
			table.insert(RoundConnections, Connection2)
		end)

		-- Connections
		table.insert(RoundConnections, Connection1)
		
		-- INIT
		for i, TeamTotalScoreValue in pairs(SharedGameScoresFolder:GetChildren()) do
			local Connection1 = TeamTotalScoreValue:GetPropertyChangedSignal("Value"):Connect(function()
				if TeamTotalScoreValue.Value >= GameModeInfo["ScoreTo"] then
					DisconnectRoundLoop()
					--UtilitiesModule:DisconnectCustomConnections({CustomConnection})
				end
			end)

			-- Connections
			table.insert(RoundConnections, Connection1)
		end
	end
	
	for i, PlayerLobbyValue in pairs(SharedGameLobbyFolder:GetChildren()) do
		local FoundPlayer = game.Players:FindFirstChild(PlayerLobbyValue.Name)

		if FoundPlayer then
			MainLoopModule:PlayerAddedRound(FoundPlayer)
		end

			--[[local Connection1 = PlayerLobbyValue:GetAttributeChangedSignal("Score"):Connect(function()
				if PlayerLobbyValue:GetAttribute("Score") >= GameModeInfo["ScoreTo"] then
					UtilitiesModule:DisconnectCustomConnections({CustomConnection})
				end
			end)

			-- Connections
			table.insert(RoundConnections, Connection1)]]
	end	
	
	RoundRunning = true

	GameModeModule:Initialise(CustomConnection)
		
	GameProcessRemote:FireAllClients("Game", "RoundStarted")
	
	LobbyModule:SetLobbyHintText("Round Started. Deploy now Spartan!")
		
	RoundTimeStarted = tick()
	
	if not GameModeInfo["TimeRoundBased"] then
		UtilitiesModule:BetterCountdown(GameModeInfo["RoundTime"], CustomConnection, {Attribute = {Instance = SharedGameFolder, Name = "GameTime"}})
	else
		UtilitiesModule:BetterCountdown(math.huge, CustomConnection, {Attribute = {Instance = SharedGameFolder, Name = "GameTime"}})
	end
	
	UtilitiesModule:DisconnectConnections(RoundConnections)
	PlayersDeploying = nil
	--PlayersDeployed = nil
	PlayersRespawning = nil
	ClientRequests["Deploy"] = nil
	ClientRequests["Respawn"] = nil
	ClientRequests["Undeploy"] = nil
end

local function TickOver(Player)
	-- Functions
	-- INIT
	if not Player then
		return nil
	end
	
	local TimeNow = tick()
	
	local TimePlayedValue = ShortcutsModule:GetPlayerStatisticValue(Player, "General", "TimePlayed")
	local PlayerDeployedTime = PlayerToDeployTime[Player]
	
	if not PlayerDeployedTime then
		return nil
	end
	
	TimePlayedValue.Value += (TimeNow - PlayerDeployedTime)
	
	PlayerToDeployTime[Player] = nil
end

local function TickOverAllPlayers()
	-- Functions
	-- INIT
	for Player, _ in pairs(PlayerToDeployTime) do
		if not Player then
			continue
		end
		
		TickOver(Player)
	end
end

local function RewardRestOfPlayers(CustomConnection, WinningPlayers)
	-- Functions
	-- INIT
	local GameModeInfo = nil
	
	local Success, Error = pcall(function()
		GameModeInfo = GameModesInfoModule:GetGameModeInfo(GameModule:GetGameMode())
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | RewardRestOfPlayers | Error: ".. tostring(Error))
		return nil
	end
	
	for i, PlayerLobbyValue in pairs(SharedGameLobbyFolder:GetChildren()) do
		local FoundPlayer = game.Players:FindFirstChild(PlayerLobbyValue.Name)
		
		if not FoundPlayer then
			continue
		end
		
		if WinningPlayers and typeof(WinningPlayers) == "table" and table.find(WinningPlayers, FoundPlayer) then
			continue
		end
		
		if GameModeInfo then
			local Success, Error = pcall(function()
				
				local RoundTimeSeconds = 0
				
				local Success, Error = pcall(function()
					RoundTimeSeconds = math.floor(tick() - RoundTimeStarted)
				end)
				
				if not Success then
					RoundTimeSeconds = 0
				end

				GameModule:GameProcess("AddXp", FoundPlayer, "RoundScore", {["Xp"] = ((PlayerLobbyValue:GetAttributes()["Score"] or 0) * GameModeInfo["XpPerScore"])})
				--GameModule:GameProcess("AddXp", FoundPlayer, "RoundFinished", {["Xp"] = UtilitiesModule:SecondsToMinutes(GameModeInfo["RoundTime"] * GameInfoModule:GetGameInfo("RoundTimeXpMultiplier"))})
				GameModule:GameProcess("AddXp", FoundPlayer, "RoundFinished", {["Xp"] = UtilitiesModule:SecondsToMinutes(RoundTimeSeconds * GameInfoModule:GetGameInfo("RoundTimeXpMultiplier"))})
			end)
			
			local PlayerCECoinsValue = ShortcutsModule:GetPlayerStatisticValue(FoundPlayer, "Currency", "Coins")
			PlayerCECoinsValue.Value += GameModeInfo["Lose"]["CECoins"]
			
			if not Success then
				DebugModule:Print(script.Name.. " | RewardRestOfPlayers | Error: ".. tostring(Error))
			end
		end
	end
end

local function RewardWinningTeam(CustomConnection)
	-- Functions
	-- INIT
	--if not CustomConnection or not CustomConnection.Value then
	--	return nil
	--end
	
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(GameModule:GetGameMode())
	
	if GameModeInfo then
		DebugModule:Print(script.Name.. " | GameModeInfo: ".. tostring(GameModeInfo))
		DebugModule:Print(script.Name.. " | XpPerScore: ".. tostring(GameModeInfo["XpPerScore"]))
		DebugModule:Print(script.Name.. " | WinXpMultiplier: ".. tostring(--[[GameModeInfo["WinXpMultiplier"]] GameModeInfo["Win"]["XpMultiplier"]))
	end
	
	local WinningTeam = GameModule:GetWinningTeam()
	--local WinningTeam = UtilitiesModule:WaitForChildTimed(game.Teams, WinningTeamName)
	
	--DebugModule:Print("MainLoop | Winning Team: ".. tostring(WinningTeam))
	
	local WinningPlayers = {}
	
	if WinningTeam then
		local LoopThrough = nil
		
		if WinningTeam:IsA("Team") then
			LoopThrough = WinningTeam:GetPlayers()
		else
			LoopThrough = {WinningTeam}
		end
		
		for i, Player in pairs(LoopThrough) do
			if not Player then
				continue
			end
			
			local PlayerLobbyValue = SharedGameLobbyFolder:FindFirstChild(Player.Name)
			
			if not PlayerLobbyValue then
				continue
			end
			
			if GameModeInfo then
				local Success, Error = pcall(function()
					GameModule:GameProcess("AddXp", Player, "RoundScore", {["Xp"] = (PlayerLobbyValue:GetAttributes()["Score"] * GameModeInfo["XpPerScore"] * --[[GameModeInfo["WinXpMultiplier"]] GameModeInfo["Win"]["XpMultiplier"])})
										
					local RoundTimeSeconds = 0

					local Success, Error = pcall(function()
						RoundTimeSeconds = math.floor(tick() - RoundTimeStarted)
					end)

					if not Success then
						RoundTimeSeconds = 0
					end
					
					GameModule:GameProcess("AddXp", Player, "RoundFinished", {["Xp"] = UtilitiesModule:SecondsToMinutes(RoundTimeSeconds * GameInfoModule:GetGameInfo("RoundTimeXpMultiplier") * --[[GameModeInfo["WinXpMultiplier"]] GameModeInfo["Win"]["XpMultiplier"])})
				end)
				
				local PlayerCECoinsValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Currency", "Coins")
				PlayerCECoinsValue.Value += GameModeInfo["Win"]["CECoins"]
				
				if not Success then
					DebugModule:Print(script.Name.. " | RewardWinningTeam | Error: ".. tostring(Error))
				end	
			end
			
			local PlayerWinsValue = ShortcutsModule:GetPlayerStatisticValue(Player, "General", "GamesWon")
			
			if PlayerWinsValue then
				PlayerWinsValue.Value += 1
			end
			
			table.insert(WinningPlayers, Player)
		end
	end
	
	return WinningPlayers
end

local function RoundEnd(CustomConnection)
	-- Functions
	-- INIT
	RoundRunning = false
	
	MainLoopModule.AddToLobby = nil
	MainLoopModule.RemoveFromLobby = nil	
	MainLoopModule.PlayerLeftRound = nil
	MainLoopModule.PlayerAddedRound = nil
	
	local GameModeModule = RequiredModules[GameModule:GetGameMode()]
	local WinningTeam = GameModule:GetWinningTeam()
	
	if GameModeModule then
		local Success, Error = pcall(function()
			return GameModeModule:End()
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | RoundEnd | Error: ".. tostring(Error))
		end
	end
	
	local ScoreboardParams = nil
	
	if WinningTeam then
		if WinningTeam:IsA("Team") then
			ScoreboardParams = {Type = "Team", Name = WinningTeam.Name}
		else
			ScoreboardParams = {Type = "Player", Name = WinningTeam.Name}
		end
		
		GameProcessRemote:FireAllClients("Game", "LogConsole", "Core", nil, WinningTeam.Name.. " team wins!")
	end
	
	GameProcessRemote:FireAllClients("Game", "RoundOver", ScoreboardParams)
	LobbyModule:SetLobbyHintText("Round Ended.")
	
	if --[[GameModule:GetPlayersDeployed() > 0]] #SharedGameDeployedFolder:GetChildren() > 0 then
		UtilitiesModule:BetterCountdown(GameInfoModule:GetGameInfo("GameEndingTime"))
	else
		task.wait(1)
		DebugModule:Print("MainLoop | No one has deployed! -> No round end count down")
	end
end

local function RemoveTeams()
	-- Functions
	-- INIT
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(GameModule:GetGameMode())
	
	if not GameModeInfo then
		return nil
	end
	
	if GameModeInfo["Teams"] then
		for i, TeamName in pairs(GameModeInfo["Teams"]) do
			TeamsModule:RemoveTeam(TeamName)
		end
	end
	
	for i, PlayerLobbyValue in pairs(LobbyModule:GetPlayersInLobby()) do
		local Player = game.Players:FindFirstChild(PlayerLobbyValue.Name)
		Player.Neutral = true
		Player.Team = nil
	end
end

local function ResetLobbyValues()
	-- Functions
	-- INIT
	LobbyModule:ResetLobby()
end

local function ResetGameValues()
	-- Functrions
	-- INIT
	local FoundGameModeFolder = SharedGameFolder:FindFirstChild("GameMode")
	
	if FoundGameModeFolder then
		FoundGameModeFolder:Destroy()
	end
	
	GameModule:SetGameMode("")
	GameModule:SetMap("")
	--GameModule:SetPlayersDeployed(0)
	GameModule:SetGameTime(0)
	GameModule:EndGameProcess("Kill")
	CharacterActionsModule:End("PickupWeapon")
	CharacterActionsModule:End("PickupPowerUp")
end

local function UnloadMap(CustomConnection)
	-- Functions
	-- INIT
	ClientRequests["Deploy"] = function(Player)
		-- OVER WRITTEN
	end
	
	ClientRequests["Respawn"] = function(Player)
		-- OVER WRITTEN
	end
	
	ClientRequests["Undeploy"] = function(Player)
		-- OVER WRITTEN
	end
	
	MapsModule:UnloadMap(GameModule:GetMap())
end

local function UnloadCharacters(CustomConnection)
	-- Functions
	-- INIT
	for i, Character--[[Player]] in pairs(--[[game.Players:GetPlayers()]] UtilitiesModule:GetCharacters()) do
		--local Character = UtilitiesModule:GetCharacter(Player, true)
		
		--print("Player character: ".. tostring(Character))
		coroutine.wrap(function()
			if Character then
				-- Elements
				-- HUMANOIDS
				local Humanoid = UtilitiesModule:WaitForChildTimed(Character, "Humanoid")
				
				if not Humanoid then
					return nil
				end
				
				coroutine.wrap(function()
					Humanoid.Health = 0
					DebrisModule:AddItem(Character, 1)
					--task.wait(1)
					--Character:Destroy()
				end)()
			end
		end)()
	end
	
	for i, Model in pairs(workspace:GetChildren()) do
		if not Model:IsA("Model") then
			continue
		end
		
		Model:Destroy()
	end
end

local function ReturnPlayersToLobby(CustomConnection)
	-- Functions
	-- INIT
	SharedGameDeployedFolder:ClearAllChildren()
	
	return GameProcessRemote:FireAllClients("Game", "ReturnToLobby")
end

local function CanPerformVitalAction(Player)
	-- Functions
	-- INIT
	local IsOwner = GameInfoModule:GetGameInfo("Admins")[Player.UserId]
	
	if IsOwner ~= nil then
		return true
	end
	
	if UtilitiesModule:IsPrivateServer() and game.PrivateServerOwnerId == Player.UserId then
		return true
	end
end

function DisconnectRoundLoop()
	-- Functions
	-- INIT
	if MainLoopModule.DisconnectRoundLoop ~= nil then
		MainLoopModule:DisconnectRoundLoop()
	end
end

local function PlayerLeft(Player)
	-- Functions
	-- INIT
	TickOver(Player)
end

local function SwitchGameMode(GameModeName)
	-- Functions
	-- INIT
	NextClientSelectedGameMode = GameModeName
	--DebugModule:Print("Switched Game Mode: ".. tostring(GameModeName))
	if CurrentLoopStage > 3 then
		DisconnectRoundLoop()
	end
end

local function SwitchMap(MapName)
	-- Functions
	-- INIT
	NextClientSelectedMap = MapName
	--DebugModule:Print("Switched Map: ".. tostring(MapName))
	if CurrentLoopStage > 4 then
		DisconnectRoundLoop()
	end
end

local function ClientSwitchMap(Player, MapName)
	-- CORE
	local UserType = "Owner"
	local FoundPlayerIndex = table.find(ClientsCanSwitchMap, Player.UserId)
	
	-- Functions
	-- INIT
	if not CanPerformVitalAction(Player) and not FoundPlayerIndex then
		return nil
	elseif FoundPlayerIndex and not CanPerformVitalAction(Player) then
		UserType = "Purchase"
		
		if RoundRunning then
			return nil
		end
		
		table.remove(ClientsCanSwitchMap, FoundPlayerIndex)
	end
	
	SwitchMap(MapName)

	NotificationsModule:SendAllNotification("Important", tostring(UserType).. " | Changing map to: ".. tostring(MapName))

	--UtilitiesModule:DisconnectCustomConnections(CustomConnections)
end

local function ClientSwitchGameMode(Player, GameModeName)
	-- CORE
	local UserType = "Owner"
	local FoundPlayerIndex = table.find(ClientsCanSwitchMode, Player.UserId)
	
	-- Functions
	-- INIT
	if not CanPerformVitalAction(Player) and not FoundPlayerIndex then
		return nil
	elseif FoundPlayerIndex and not CanPerformVitalAction(Player) then
		UserType = "Purchase"

		if RoundRunning then
			return nil
		end

		table.remove(ClientsCanSwitchMode, FoundPlayerIndex)
	end
	
	SwitchGameMode(GameModeName)

	NotificationsModule:SendAllNotification("Important", tostring(UserType).. " | Changing game mode to: ".. tostring(GameModeName))
end

local function AddClientModeChange(Player, AmountToGive)
	-- Functions
	-- INIT
	--DebugModule:Print("MainLoop | Adding Client Mode Changes!")
	
	for i = 1, AmountToGive do
		table.insert(ClientsCanSwitchMode, Player.UserId)
	end
end

local function AddClientMapChange(Player, AmountToGive) -- RewardDevProduct
	-- Functions
	-- INIT
	--DebugModule:Print("MainLoop | Adding Client Map Changes!")e
	
	for i = 1, AmountToGive do
		table.insert(ClientsCanSwitchMap, Player.UserId)
	end
end

-- CORE FUNCTIONS
ClientRequests = 
{
	["Undeploy"] = function(Player)
		-- OVER WRITTEN	
	end,
	["Deploy"] = function(Player)
		-- OVER WRITTEN
	end,
	["Respawn"] = function(Player)
		-- OVER WRITTEN
	end,
	--
	["SwitchMap"] = function(Player, MapName)
		return ClientSwitchMap(Player, MapName)
	end,
	["SwitchGameMode"] = function(Player, GameModeName)
		return ClientSwitchGameMode(Player, GameModeName)
	end,
}

ServerRequests = 
{
	["GetRoundRunning"] = function()
		return RoundRunning
	end,	
}

ServerProcesses = 
{
	["ForceMapChange"] = function(MapName)
		return SwitchMap(MapName)		
	end,
	["ForceGameModeChange"] = function(GameModeName)
		return SwitchGameMode(GameModeName)		
	end,
	["MapChange"] = function(Player, AmountToGive)
		return AddClientMapChange(Player, AmountToGive)
	end,
	["ModeChange"] = function(Player, AmountToGive)
		return AddClientModeChange(Player, AmountToGive)
	end,
	["PlayerRespawn"] = function(Player)
		return ClientRequests["Respawn"](Player, true)	
	end,
	["PlayerDied"] = function(...)
		return MainLoopModule:PlayerDied(...)		
	end,
	["PlayerKilled"] = function(...)
		return MainLoopModule:PlayerKilled(...)
	end,
	["PlayerShotRegistered"] = function(...)
		return MainLoopModule:PlayerShotRegistered(...)
	end,
	["DisconnectRoundLoop"] = function(...)
		return MainLoopModule:DisconnectRoundLoop()		
	end,
}

-- DIRECT
local Connection1 = SharedGameLobbyFolder.ChildAdded:Connect(function(Child)
	if MainLoopModule.AddToLobby ~= nil then
		MainLoopModule:AddToLobby(game.Players:FindFirstChild(Child.Name))
	end
end)

local Connection2 = SharedGameLobbyFolder.ChildRemoved:Connect(function(Child)
	if MainLoopModule.RemoveFromLobby ~= nil then
		MainLoopModule:RemoveFromLobby(game.Players:FindFirstChild(Child.Name))
	end
end)

local Connection3 = MainRemote.Event:Connect(function(FunctionName, ...)
	return ServerProcesses[FunctionName](...)
end)

CoreSignal.OnInvoke = function(FunctionName, ...)
	return ServerRequests[FunctionName](...)
end

--
function MainLoopModule.ServerProcess(NilParam, FunctionName, ...)
	return ServerProcesses[FunctionName](...)
end

function MainLoopModule.GetClientsCanSwitchMap()
	return ClientsCanSwitchMap
end

function MainLoopModule.PlayerLeft(NilParam, Player)
	return PlayerLeft(Player)
end

function MainLoopModule.GetRoundRunning()
	return RoundRunning
end

function MainLoopModule.ClientRequest(NilParam, Player, FunctionName, ...)
	if ClientRequests[FunctionName] then
		return ClientRequests[FunctionName](Player, ...)
	else
		DebugModule:Print("MainLoop | Client Request doesn't exist | Player: ".. tostring(Player).. " | FunctionName: ".. tostring(FunctionName).. " | Args: ".. tostring({...}))
	end
end

-- INIT
RunSubModules()

coroutine.wrap(function()
	local OperationStartOrder = 
	{
		[2] = WaitForEnoughPlayers,
		[1] = ResetLobbyValues,
		[3] = Intermission,
		[4] = SelectGameMode,
		[5] = SelectMap,
		[6] = SplitTeams,
		[7] = LoadMap,
		[8] = GameStarting,
		[9] = RoundStart
		-----
	}

	local OperationEndOrder = 
	{
		[1] = TickOverAllPlayers,
		[2] = RewardWinningTeam,
		[3] = RewardRestOfPlayers,
		[4] = RoundEnd,
		[5] = UnloadCharacters,
		[6] = ReturnPlayersToLobby,
		[7] = UnloadMap,
		[8] = RemoveTeams,
		[9] = ResetGameValues,
	}
	
	coroutine.wrap(function()
		return GameModule:SetServerRegion(UtilitiesModule:GetServerRegion())
	end)()
	
	GameModule:SetServerVersion(game.PlaceVersion / 100)
	
	while true do
		CurrentLoopStage = 0
		
		-- Instancing
		local CustomConnection = CreateCustomConnection(CustomConnections)
		
		-- FUNCTIONS
		-- DIRECT
		function MainLoopModule.DisconnectRoundLoop()
			return UtilitiesModule:DisconnectCustomConnections({CustomConnection})
		end
		
		-- PROCESS
		--local Success, Error = pcall(function()
			local _Success, _Error = pcall(function()
				local ReturnedParam = nil
				
				for i, Process in pairs(OperationStartOrder) do
					CurrentLoopStage = i
					ReturnedParam = Process(CustomConnection, ReturnedParam)
					
					if not CustomConnection or not CustomConnection.Value then
						--DebugModule:Print("Breaking loop | OperationStartOrder: ".. tostring(i))
						DebugModule:Print("Breaking loop | OperationStartOrder: ".. tostring(i))
						break -- BREAK GAME LOOP
					end
				end
			end)
			
			if not _Success then
				--DebugModule:Print("FATAL ERROR | START OPERATION | CurrentLoopStage: ".. tostring(CurrentLoopStage).. " | ".. tostring(_Error))
				print("FATAL ERROR | START OPERATION | CurrentLoopStage: ".. tostring(CurrentLoopStage).. " | ".. tostring(_Error))
			end
			
			local _Success, _Error = pcall(function()
				local ReturnedParam = nil
				
				for i, Process in pairs(OperationEndOrder) do
					DebugModule:Print("END STAGE | ".. tostring(i).. " | Time: ".. tostring(tick()))

					CurrentLoopStage = UtilitiesModule:GetSizeOfDict(OperationStartOrder) + i
					ReturnedParam = Process(CustomConnection, ReturnedParam)
				end
			end)
			
			if not _Success then
				--DebugModule:Print("FATAL ERROR | END OPERATION | CurrentLoopStage: ".. tostring(CurrentLoopStage).. " | ".. tostring(_Error))
				print("FATAL ERROR | END OPERATION | CurrentLoopStage: ".. tostring(CurrentLoopStage).. " | ".. tostring(_Error))
			end
			
			--[[ResetLobbyValues()
			WaitForEnoughPlayers()
			Intermission(CustomConnection)
			SelectMap(CustomConnection)
			SelectGameMode(CustomConnection)
			SplitTeams(CustomConnection)
			LoadMap(CustomConnection)
			GameStarting(CustomConnection)
			RoundStart(CustomConnection)
			
			RoundEnd(CustomConnection)
			UnloadCharacters(CustomConnection)
			UnloadMap(CustomConnection)
			RemoveTeams()
			ResetGameValues()
			ReturnPlayersToLobby(CustomConnection)]]
		--end)
		
		local Success, Error = pcall(function()
			UtilitiesModule:DisconnectCustomConnections({CustomConnection})
			UtilitiesModule:DisconnectCustomConnections(CustomConnections)
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | Error: ".. tostring(Error))
		end
		
		--if not Success then
			--DebugModule:Print("FATAL ERROR | ".. tostring(Error))
		--	print("FATAL ERROR | ".. tostring(Error))
		--end
	end
end)()


return MainLoopModule