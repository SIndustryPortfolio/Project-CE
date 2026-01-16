local GetOrderedTeamScoreModule = {}

-- Dirs
local GameLobbyFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Lobby"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local SharedGameDeployedFolder = SharedGameFolder["Deployed"]

-- Info Modules
local GameModesInfoModule = require(InfoModulesFolder["GameModes"])

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function GetAllTeamScores()
	-- CORE
	local TeamScores = {}
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(SharedGameFolder:GetAttribute("GameMode"))
	
	-- Functions
	-- INIT
	for i, Player in pairs(game.Players:GetPlayers()) do
		local LobbyPlayerValue = GameLobbyFolder:FindFirstChild(Player.Name)
		
		if not LobbyPlayerValue or not SharedGameDeployedFolder:FindFirstChild(Player.Name) then
			continue
		end
		
		if GameModeInfo["Teams"] and not GameModeInfo["NeutralDisplay"] then
			if not TeamScores[Player.Team] then
				TeamScores[Player.Team] = 0
			end
			
			TeamScores[Player.Team] += LobbyPlayerValue:GetAttribute("Score")
		else
			if not TeamScores[Player] then
				TeamScores[Player] = 0
			end
			
			TeamScores[Player] += LobbyPlayerValue:GetAttribute("Score")
		end
	end
	
	
	return TeamScores
end

local function Initialise()
	-- CORE
	local _AllTeamScores = GetAllTeamScores()
	
	local _OrderedTeamScores = UtilitiesModule:GetDictKeys(_AllTeamScores)
	
	-- Functions
	-- INIT
	local Changed = false
	
	repeat
		Changed = false
		
		for i, TeamInstance in pairs(_OrderedTeamScores) do
			if i == #_OrderedTeamScores then
				continue
			end
			
			local _TeamInstance = TeamInstance
			local TeamScore = _AllTeamScores[TeamInstance]
				
			local NextTeamPosition = i + 1
			local NextTeamInstance = _OrderedTeamScores[NextTeamPosition]
			local NextTeamScore = _AllTeamScores[NextTeamInstance]
				
			if NextTeamScore > TeamScore then
				Changed = true
				table.remove(_OrderedTeamScores, i)
				table.remove(_OrderedTeamScores, i)
				table.insert(_OrderedTeamScores, i, NextTeamInstance)
				table.insert(_OrderedTeamScores, NextTeamPosition, _TeamInstance)
			end
		end
	until not Changed
	
	--[[for TeamInstance, ScoreValue in pairs(_AllTeamScores) do
		local Position = 1
		
		for i, OrderedTeamInstance in pairs(_OrderedTeamScores) do
			if ScoreValue < _AllTeamScores[OrderedTeamInstance] then
				Position = i
			end
		end
		
		table.insert(_OrderedTeamScores, Position, TeamInstance)
	end]]
	
	----DebugModule:Print"Highest Score Team: ".. tostring(_OrderedTeamScores[1].Name))
	
	return {OrderedTeamScores = _OrderedTeamScores, AllTeamScores = _AllTeamScores}
end

-- DIRECT
function GetOrderedTeamScoreModule.Initialise()
	return Initialise()
end

return GetOrderedTeamScoreModule