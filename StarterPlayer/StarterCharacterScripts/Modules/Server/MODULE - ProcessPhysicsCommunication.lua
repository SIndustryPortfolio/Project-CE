local CharacterPhysicsCommunicationModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent
local CharacterClientServerRemotesFolder = Character:WaitForChild("Remotes")["ClientServer"]["Remotes"]
local CharacterServerModulesFolder = Character:WaitForChild("Modules")["Server"]

-- EXT
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Elements
-- REMOTES
local CharacterPhysicsProcessRemote = CharacterClientServerRemotesFolder["CharacterPhysicsProcess"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local CharacterPhysicsModule = require(CharacterServerModulesFolder["CharacterPhysics"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local Connections = {}

-- Functions
-- MECHANICS
local function AuthenticatePlayer(Player)
	-- Functions
	-- INIT
	if game.Players:GetPlayerFromCharacter(Character) == Player then
		return true
	end
end

local function OnCharacterPhysicsProcessRemoteFired(Player, FunctionName, ...)
	----DebugModule:Print"CharacterPhysicsRemote | Fired Server! | Player: ".. tostring(Player.Name).. " | Function: ".. tostring(FunctionName).. " | Parameters: ".. tostring({...}))

	if AuthenticatePlayer(Player) then
		return CharacterPhysicsModule:ClientRequest(Player, FunctionName, ...)
	end
end

-- DIRECT
function CharacterPhysicsCommunicationModule.Initialise()
	-- Functions
	-- DIRECT
	local Connection2 = CharacterPhysicsProcessRemote.OnServerEvent:Connect(OnCharacterPhysicsProcessRemoteFired)
	
	-- CONNECTIONS
	table.insert(Connections, Connection2)
end

function CharacterPhysicsCommunicationModule.GarbageCollect()
	-- Functions
	-- INIT
	Character = nil
	CharacterClientServerRemotesFolder = nil
	CharacterServerModulesFolder = nil
	--
	SharedModulesFolder = nil
	ServerModulesFolder = nil
	--
	CharacterPhysicsProcessRemote = nil
	--
	UtilitiesModule = nil
	CharacterPhysicsModule = nil
	DebugModule = nil
	--
	Connections = nil
	
end

function CharacterPhysicsCommunicationModule.End()
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections)
end

return CharacterPhysicsCommunicationModule