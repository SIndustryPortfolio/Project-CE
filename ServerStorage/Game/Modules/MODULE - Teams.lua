local TeamsModule = {}

-- DIRS
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- Info Modules
local GameModesInfoModule = require(SharedInfoModulesFolder["GameModes"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DamageModule = require(ServerModulesFolder["Damage"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local TeamToConnections = {}
local DebounceCache = {}

-- Services
local TeamsService = game:GetService("Teams")
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function GetCharacter(Player)
	return Player.Character or Player.CharacterAdded:Wait()
end

local function AddToDebounceCache(Player)
	-- Functions
	-- INIT
	DebounceCache[Player] = true	
end

local function RemoveFromDebounceCache(Player)
	DebounceCache[Player] = nil
end

local function InsertTeamIntoCache(Team, Connections)
	if TeamToConnections[Team] == nil then
		TeamToConnections[Team] = Connections
	end
	
	return TeamToConnections[Team]
end

--[[local function DisconnectConnections(Connections)
	for i, Connection in pairs(Connections) do
		Connection:Disconnect()
	end
	
	Connections = {}
end]]

local function RemoveTeamFromCache(Team)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(TeamToConnections[Team]) --DisconnectConnections(TeamToConnections[Team])
	TeamToConnections[Team] = nil
end

local function CreateTeam(TeamName, TeamInfo)
	-- CORE
	local TeamConnections = {}
	local TeamPlayerConnections = {}
	
	-- Instancing
	local Team = Instance.new("Team")
	
	-- PROPERTIES
	Team.Name = TeamName
	if TeamInfo then
		Team.TeamColor = TeamInfo["TeamColour"] or TeamInfo["Colour"] or BrickColor.new(TeamName)
	else
		Team.TeamColor = BrickColor.new(TeamName)
	end
	Team.AutoAssignable = false
	Team.Parent = TeamsService
	
	-- Functions
	-- MECHANICS
	local function CheckIfTeamNeedsToBeDestroyed()
		if not Team or not Team:IsDescendantOf(TeamsService) then
			return true
		end
		
		if #Team:GetPlayers() <= 0 then
			return true
		end
	end
	
	-- DIRECT
	local Connection1 = Team.PlayerRemoved:Connect(function(Player)
		-- Functions
		-- INIT
		local PlayerTeamConnection = TeamPlayerConnections[Player]
		
		if PlayerTeamConnection then
			PlayerTeamConnection:Disconnect()
			TeamPlayerConnections[Player] = nil
		end
		
		task.wait(1)
		
		local DestroyTeam = CheckIfTeamNeedsToBeDestroyed()
		
		if DestroyTeam then
			RemoveTeamFromCache(Team)
			
			if Team then
				Team:Destroy()
			end
		end
	end)
	
	local Connection2 = Team.PlayerAdded:Connect(function(Player)		
		-- Connections
		TeamPlayerConnections[Player] = nil
	end)
	
	-- Connections
	table.insert(TeamConnections, Connection1)
	table.insert(TeamConnections, Connection2)
	
	-- INIT
	InsertTeamIntoCache(Team, TeamConnections)
	
	return Team
end

local function SwitchTeam(Player, TeamName, TeamInfo)
	-- CORE
	local OriginalTeam = Player.Team
	local Character = Player.Character
	
	-- Functions
	-- INIT
	if not TeamName then
		DebugModule:Print("Teams | TeamName doesn't exist!")
		return nil
	end
	
	local FoundTeam = TeamsService:FindFirstChild(TeamName)
	if not FoundTeam then
		FoundTeam = CreateTeam(TeamName, TeamInfo)
		FoundTeam.Parent = TeamsService
	end
	
	-- Properties
	Player.Team = FoundTeam
	
	CollectionService:AddTag(Player, FoundTeam.Name)
end

local function GetNumberOfMembersOnTeam(TeamName)
	-- CORE
	local Team = TeamsService:FindFirstChild(TeamName)
	
	-- Functions
	-- INIT
	if Team then
		return #Team:GetPlayers()
	end
end

local function RemoveTeam(TeamName)
	-- Functions
	-- INIT
	local FoundTeam = UtilitiesModule:WaitForChildTimed(TeamsService, TeamName)
	
	if not FoundTeam then
		return nil
	end
	
	RemoveTeamFromCache(FoundTeam)
	FoundTeam:Destroy()
end

local function GetTeamInfoFromName(GameModeInfo, TeamName)
	-- Functions
	-- INIT
	for i, TeamInfo in pairs(GameModeInfo["Teams"]) do
		if TeamInfo["Name"] == TeamName then
			return TeamInfo
		end
	end
end

local function ClientSwitchTeam(Player, TeamName--[[, TeamInfo]])
	-- CORE
	local PlayerTeam = Player.Team
	local Character = UtilitiesModule:GetCharacter(Player, true)
	local GameModeInfo = nil
	
	if SharedGameFolder:GetAttribute("GameMode") ~= "" then
		GameModeInfo = GameModesInfoModule:GetGameModeInfo(SharedGameFolder:GetAttribute("GameMode"))
	end
	
	-- Functions
	-- INIT
	if PlayerTeam and PlayerTeam.Name == TeamName then
		return nil
	end
	
	if GameModeInfo then
		SwitchTeam(Player, TeamName, GetTeamInfoFromName(GameModeInfo, TeamName))
	else
		SwitchTeam(Player, TeamName, nil)
	end
	
	if Character then
		local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
		
		if Humanoid then
			DamageModule:TakeDamage(Humanoid, Humanoid.MaxHealth + Humanoid:GetAttribute("MaxShield"))
		end
	end
	
	GameProcessRemote:FireAllClients("Game", "LogConsole", "Core", nil, Player.Name.. " switched teams to: '".. tostring(TeamName).. "'")
	
	return true
end

local function GetTeamInfo(Team)
	-- Functions
	-- INIT
	local TempInstance = false
	
	if typeof(Team) == "string" then
		local TeamName = Team
		
		Team = Instance.new("BoolValue")
		Team.Name = TeamName
		TempInstance = true
	end
	
	local GameModeInfo
	
	if SharedGameFolder:GetAttribute("GameMode") ~= "" then
		GameModeInfo = GameModesInfoModule:GetGameModeInfo(SharedGameFolder:GetAttribute("GameMode"))
	end
	
	if not GameModeInfo then
		return nil
	end
	
	for i, TeamInfo in pairs(GameModeInfo["Teams"] or {}) do
		if TeamInfo["Name"] == Team.Name then
			if TempInstance then
				Team:Destroy()
			end
			return TeamInfo
		end
	end
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Switch"] = function(Player, TeamName)
		return ClientSwitchTeam(Player, TeamName)
	end,	
}

-- DIRECT
function TeamsModule.GetTeamInfo(NilParam, Team)
	return GetTeamInfo(Team)
end

function TeamsModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

function TeamsModule.GetNumberOfMembersOnTeam(NilParam, TeamName)
	return GetNumberOfMembersOnTeam(TeamName)
end

function TeamsModule.SwitchTeam(NilParam, Player, TeamName, TeamInfo)
	SwitchTeam(Player, TeamName, TeamInfo)
end

function TeamsModule.RemoveTeam(NilParam, TeamName)
	return RemoveTeam(TeamName)
end

return TeamsModule