local TagModule = {}

-- Dirs
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- CORE
local DebounceCache = {}

-- Functions
-- MECHANICS
local function Dead(Player)
	-- Functions
	-- INIT
	if DebounceCache[Player] then
		return nil
	end
	
	DebounceCache[Player] = true
	
	GameProcessRemote:FireAllClients("Game", "LogConsole", "Core", nil, Player.Name.. " was killed by the guardians!")
	
	task.wait(1)
	DebounceCache[Player] = nil
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Dead"] = Dead	
}

-- DIRECT
function TagModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

function TagModule.Initialise()
	
end

function TagModule.End()
	
end

return TagModule