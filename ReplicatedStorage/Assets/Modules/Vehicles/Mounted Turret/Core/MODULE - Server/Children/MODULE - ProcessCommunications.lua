local VehicleProcessCommunicationsModule = {}

-- Dirs
local ModelRoot = script.Parent.Parent.Parent

-- EXT
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local Connections = {}

-- Elements
-- FOLDERS
local RemotesFolder = UtilitiesModule:WaitForChildTimed(ModelRoot, "Remotes")
local ClientServerRemotesFolder = RemotesFolder["ClientServer"]["Remotes"]
local ClientServerSignalsFolder = RemotesFolder["ClientServer"]["Signals"]

-- Modules

-- SIGNALS
local VehicleRequestSignal = ClientServerSignalsFolder["VehicleRequest"]

-- REMOTES
local VehicleProcessRemote = ClientServerRemotesFolder["VehicleProcess"]

-- Functions
-- MECHANICS
local function PlayerAuthorised(Player)
	-- Functions
	-- INIT
	if Player.Name == ModelRoot:GetAttributes()["Occupant"] then
		return true
	end
end

local function Initialise(ServerModule)
	-- Functions
	-- DIRECT
	local Connection1 = VehicleProcessRemote.OnServerEvent:Connect(function(Player, ...)
		if PlayerAuthorised(Player) then
			return ServerModule:ClientRequest(Player, ...)
		end
	end)
	
	VehicleRequestSignal.OnServerInvoke = function(Player, ...)
		if PlayerAuthorised(Player) then
			return ServerModule:ClientRequest(Player, ...)
		end
	end
	
	-- CONNECTIONS
	table.insert(Connections, Connection1)
end

local function End()
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections)
end

-- DIRECT
function VehicleProcessCommunicationsModule.Initialise(NilParam, ServerModule)
	return Initialise(ServerModule)
end

function VehicleProcessCommunicationsModule.End()
	return End()
end

return VehicleProcessCommunicationsModule