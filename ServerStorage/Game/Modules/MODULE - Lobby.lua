local LobbyModule = {}

-- Dirs
local SharedGameLobbyFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Lobby"]

-- Functions
-- MECHANICS
local function ResetLobbyPlayer(PlayerInLobbyValue)
	-- Functions
	-- INIT
	PlayerInLobbyValue:SetAttribute("Deaths", 0)
	PlayerInLobbyValue:SetAttribute("Kills", 0)
	PlayerInLobbyValue:SetAttribute("Assists", 0)
	PlayerInLobbyValue:SetAttribute("Score", 0)
	PlayerInLobbyValue:SetAttribute("Lives", 0)
end

local function GetNumberOfPlayersInLobby()
	-- Functions
	-- INIT
	return #SharedGameLobbyFolder:GetChildren()
end

local function GetPlayersInLobby()
	-- CORE
	local Players = {}
	
	-- Functions
	-- INIT
	for i, PlayerInstance in pairs(SharedGameLobbyFolder:GetChildren()) do
		table.insert(Players, game.Players:FindFirstChild(PlayerInstance.Name))
	end
	
	return Players
end

local function IsPlayerInLobby(Player)
	-- Functions
	-- INIT
	return SharedGameLobbyFolder:FindFirstChild(Player.Name)
end

local function CreatePlayerInstance(Player)
	-- Instancing
	local PlayerInstance = Instance.new("BoolValue")
	PlayerInstance.Name = Player.Name
	
	ResetLobbyPlayer(PlayerInstance)
	
	return PlayerInstance
end

local function PlayerJoinedLobby(Player)
	-- Functions
	-- INIT
	if IsPlayerInLobby(Player) then
		return nil
	end
	
	CreatePlayerInstance(Player).Parent = SharedGameLobbyFolder
end

local function PlayerLeftLobby(Player)
	-- Functions
	-- INIT
	local PlayerInLobby = IsPlayerInLobby(Player)
	
	if PlayerInLobby then
		PlayerInLobby:Destroy()
	end
end

local function DecrementValue(Player, ValueName, Decrement)
	-- Function
	-- INIT
	local PlayerInLobbyValue = SharedGameLobbyFolder:FindFirstChild(Player.Name)

	if not PlayerInLobbyValue then
		return nil
	end

	if Decrement then
		return PlayerInLobbyValue:SetAttribute(ValueName, PlayerInLobbyValue:GetAttribute(ValueName) - Decrement)
	else
		return PlayerInLobbyValue:SetAttribute(ValueName, PlayerInLobbyValue:GetAttribute(ValueName) - 1)
	end
end

local function IncrementValue(Player, ValueName, Increment)
	-- Function
	-- INIT
	local PlayerInLobbyValue = SharedGameLobbyFolder:FindFirstChild(Player.Name)
	
	if not PlayerInLobbyValue then
		return nil
	end
	
	if Increment then
		return PlayerInLobbyValue:SetAttribute(ValueName, (PlayerInLobbyValue:GetAttributes()[ValueName] or 0) + Increment)
	else
		return PlayerInLobbyValue:SetAttribute(ValueName, (PlayerInLobbyValue:GetAttributes()[ValueName] or 0) + 1)
	end
end

local function ResetLobby()
	-- Functions
	-- INIT
	for i, PlayerInLobbyValue in pairs(SharedGameLobbyFolder:GetChildren()) do
		ResetLobbyPlayer(PlayerInLobbyValue)
	end
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Joined"] = function(Player)
		return PlayerJoinedLobby(Player)	
	end,
	["Left"] = function(Player)
		return PlayerLeftLobby(Player)
	end,
}

-- DIRECT
function LobbyModule.ResetLobby()
	return ResetLobby()
end

function LobbyModule.DecrementValue(NilParam, Player, ValueName, Decrement)
	return DecrementValue(Player, ValueName, Decrement)
end

function LobbyModule.IncrementValue(NilParam, Player, ValueName, Increment)
	return IncrementValue(Player, ValueName, Increment)
end

function LobbyModule.SetLobbyHintText(NilParam, HintText)
	SharedGameLobbyFolder:SetAttribute("HintText", HintText)
end

function LobbyModule.GetLobbyHintText()
	return SharedGameLobbyFolder:GetAttribute("HintText")
end

function LobbyModule.GetPlayersInLobby()
	return GetPlayersInLobby()
end

function LobbyModule.GetNumberOfPlayersInLobby()
	return GetNumberOfPlayersInLobby()
end

function LobbyModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

function LobbyModule.PlayerLeft(NilParam, Player)
	return PlayerLeftLobby(Player)
end

return LobbyModule