local GameModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local SharedGameLobbyFolder = SharedGameFolder["Lobby"]
local SharedGameScoresFolder = SharedGameFolder["Scores"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local GameModesInfoModule = require(SharedInfoModulesFolder["GameModes"])

-- Modules
local SharedGameModule = require(SharedModulesFolder["Game"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local RequiredModules = {}
local RunningFunctions = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	if UtilitiesModule:GetSizeOfDict(RequiredModules) > 0 then
		return nil
	end
	
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

local function ClearTotalScores()
	-- Functions
	-- INIT
	for i, ScoreValue in pairs(SharedGameScoresFolder:GetChildren()) do
		ScoreValue:Destroy()
	end
end

local function GetWinningTeam()
	-- Functions
	-- INIT
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(SharedGameFolder:GetAttribute("GameMode"))
	
	if not GameModeInfo then
		return nil
	end
	
	--local HighestTeam, CurrentHighestScore = "", 0
	
	return SharedGameModule:GameProcess("GetOrderedTeamScore")["OrderedTeamScores"][1]
end

local function SetupTotalScores()
	-- Functions
	-- INIT
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(GameModule:GetGameMode())
	
	if not GameModeInfo["Teams"] then
		return nil
	end
	
	for i, TeamInfo in pairs(GameModeInfo.Teams) do
		local TotalScoreValue = Instance.new("IntValue")
		TotalScoreValue.Name = TeamInfo["Name"]
		TotalScoreValue.Parent = SharedGameScoresFolder
	end
	
	--[[for i, TeamName in pairs(GameModeInfo.Teams) do
		local TotalScoreValue = Instance.new("IntValue")
		TotalScoreValue.Name = TeamName
		TotalScoreValue.Parent = SharedGameScoresFolder
	end]]
end

local function UpdateTotalScore(Team)
	-- Functions
	-- INIT
	local RunningTotal = 0
	local TeamTotalScoreValue = SharedGameScoresFolder:FindFirstChild(Team.Name)
	
	if not TeamTotalScoreValue then
		return nil
	end
	
	for i, PlayerLobbyValue in pairs(SharedGameLobbyFolder:GetChildren()) do
		local Player = game.Players:FindFirstChild(PlayerLobbyValue.Name)
		
		if not Player or Player.Team ~= Team then
			continue
		end
		
		RunningTotal += PlayerLobbyValue:GetAttribute("Score")
	end
	
	TeamTotalScoreValue.Value = RunningTotal
end

local function CustomGameProcess(ModuleName, FunctionName, ...)
	-- Functions
	-- INIT
	local Response =  RequiredModules[ModuleName][FunctionName](nil, GameModule, ...)
	
	return Response
end

local function GameProcess(RunType, FunctionName, ...)
	-- Functions
	-- INIT
	if RunType then
		local ProcessKey = {Name = FunctionName, Params = {...}}
		
		if RequiredModules[FunctionName]:GetQueued() then
			if RunningFunctions[ProcessKey] then
				repeat
					task.wait()
				until not RequiredModules[ProcessKey]
			end
		end
		
		RunningFunctions[ProcessKey] = true
		
		local Response =  RequiredModules[FunctionName]:Initialise(GameModule, ...)
		
		RunningFunctions[ProcessKey] = nil
		
		return Response
	else
		return RequiredModules[FunctionName]:End(GameModule, ...)
	end
end

-- DIRECT
function GameModule.GetWinningTeam()
	return GetWinningTeam()
end

function GameModule.EndGameProcess(NilParam, FunctionName, ...)
	return GameProcess(false, FunctionName, ...)
end

function GameModule.CustomGameProcess(NilParam, ModuleName, FunctionName, ...)
	return CustomGameProcess(ModuleName, FunctionName, ...)
end

function GameModule.GameProcess(NilParam, FunctionName, ...)
	return GameProcess(true, FunctionName, ...)
end

function GameModule.UpdateTotalScore(NilParam, Team)
	return UpdateTotalScore(Team)
end

function GameModule.ClearTotalScores()
	return ClearTotalScores()
end

function GameModule.SetupTotalScores()
	return SetupTotalScores()
end

function GameModule.GetServerRegion()
	return SharedGameFolder:GetAttribute("Region")
end

function GameModule.GetServerVersion()
	return SharedGameLobbyFolder:GetAttribute("Version")
end

function GameModule.SetServerVersion(NilParam, ServerVersion)
	SharedGameFolder:SetAttribute("Version", ServerVersion)
end

function GameModule.SetServerRegion(NilParam, Country)
	SharedGameFolder:SetAttribute("Region", Country)
end

function GameModule.SetMap(NilParam, MapName)
	SharedGameFolder:SetAttribute("Map", MapName)
end

function GameModule.GetMap(NilParam)
	return SharedGameFolder:GetAttribute("Map")
end

function GameModule:SetGameTime(NilParam, GameTime)
	return SharedGameFolder:SetAttribute("GameTime", GameTime)
end

function GameModule.GetGameTime()
	return SharedGameFolder:GetAttribute("GameTime")
end

function GameModule.GetGameMode(NilParam)
	return SharedGameFolder:GetAttribute("GameMode")
end

function GameModule.SetGameMode(NilParam, GameMode)
	SharedGameFolder:SetAttribute("GameMode", GameMode)
end

function GameModule.SetPlayersDeployed(NilParam, PlayersDeployed)
	SharedGameFolder:SetAttribute("PlayersDeployed", PlayersDeployed)
end

--[[function GameModule.GetPlayersDeployed(NilParam)
	return SharedGameFolder:GetAttribute("PlayersDeployed")
end]]

-- INIT
RunSubModules()

return GameModule