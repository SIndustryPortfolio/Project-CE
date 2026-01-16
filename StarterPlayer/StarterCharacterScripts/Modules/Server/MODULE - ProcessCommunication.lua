local CharacterProcessCommunicationsModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent
local CharacterClientServerRemotesFolder = Character:WaitForChild("Remotes")["ClientServer"]["Remotes"]
local CharacterClientServerSignalsFolder = Character:WaitForChild("Remotes")["ClientServer"]["Signals"]
local CharacterServerModulesFolder = Character:WaitForChild("Modules")["Server"]

-- EXT
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerInitModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]["Init"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Elements
-- SIGNALS
local CharacterRequestSignal = CharacterClientServerSignalsFolder["CharacterRequest"]

-- REMOTES
local CharacterProcessRemote = CharacterClientServerRemotesFolder["CharacterProcess"]
local CharacterPhysicsProcessRemote = CharacterClientServerRemotesFolder["CharacterPhysicsProcess"]

-- Modules
local CharacterActionsModule = require(ServerModulesFolder["CharacterActions"])
local WeaponsModule = require(ServerModulesFolder["Weapons"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local CollectionsInitModule = require(ServerInitModulesFolder["Collections"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local Connections = {}

local ActionsBeingPerfomed = {}

local ActionOverwrites = {"SwitchWeapon"}

-- Functions
-- MECHANICS
local function IsActionBeingPerformed(ActionName)
	-- Functions
	-- INIT
	if table.find(ActionsBeingPerfomed, ActionName) ~= nil then
		return true
	end
end

local function PerformAction(Player, ActionName, ...)
	-- Functions
	-- INIT
	if IsActionBeingPerformed(ActionName) and not table.find(ActionOverwrites, ActionName) then
		--DebugModule:Print"Dropping Action | Action Name: ".. tostring(ActionName).. " | Paramaters: ".. tostring({...}))
		return nil
	end
	
	table.insert(ActionsBeingPerfomed, ActionName)
	local Response = CharacterActionsModule:ClientRequest(Player, ActionName, ...)
	
	table.remove(ActionsBeingPerfomed, table.find(ActionsBeingPerfomed, ActionName))
	
	return Response
end

-- CORE FUNCTIONS
local Processes = 
{
	["Collections"] = function(Player, ...)
		return CollectionsInitModule:ClientRequest(Player, ...)
	end,
	["PickupPowerUp"] = function(Player, ...)
		return PerformAction(Player, "PickupPowerUp", ...)	
	end,
	["PickupGrenade"] = function(Player, ...)
		return PerformAction(Player, "PickupGrenade", ...)	
	end,
	["PickupWeapon"] = function(Player, ...)
		return PerformAction(Player, "PickupWeapon", ...) --CharacterActionsModule:ClientRequest(Player, "PickupWeapon", ...)		
	end,
	["EquipWeapon"] = function(Player, ...)
		return PerformAction(Player, "EquipGun", ...) --CharacterActionsModule:ClientRequest(Player, "EquipGun", ...) --CharacterActionsModule:EquipWeapon(Player, ...)
	end,
	["SwitchGrenade"] = function(Player, ...)
		return PerformAction(Player, "SwitchGrenade", ...)		
	end,
	["UnequipVehicle"] = function(Player, ...)
		return PerformAction(Player, "UnequipVehicle", ...)
	end,
	["SwitchVehicle"] = function(Player, ...)
		return PerformAction(Player, "SwitchVehicle", ...)	
	end,
	["SwitchWeapon"] = function(Player, ...)
		return PerformAction(Player, "SwitchWeapon", ...) --CharacterActionsModule:ClientRequest(Player, "SwitchWeapon", ...) --CharacterActionsModule:SwitchWeapon(Player, ...)
	end,
	["ThrowGrenade"] = function(Player, ...)
		return PerformAction(Player, "ThrowGrenade", ...)
	end,
	["Melee"] = function(Player, ...)
		return PerformAction(Player, "Melee", ...) --CharacterActionsModule:ClientRequest(Player, "Melee", ...) --CharacterActionsModule:Melee(Player, ...)
	end,
	["Reload"] = function(Player, ...)
		return PerformAction(Player, "Reload", ...) --CharacterActionsModule:ClientRequest(Player, "Reload", ...) --CharacterActionsModule:Reload(Player, ...)
	end,
	["ReloadIncrement"] = function(Player, ...)
		return PerformAction(Player, "ReloadIncrement", ...)
	end,
	["ProjectileHit"] = function(Player, ...)
		return WeaponsModule:ProjectileRegistered(Player, ...)		
	end,
	["Fire"] = function(Player, ...)
		return WeaponsModule:FireWeapon(Player, ...)
	end,
	["Crouch"] = function(Player, ...)
		return PerformAction(Player, "Crouch", ...)
	end,
	["StopCrouch"] = function(Player, ...)
		return PerformAction(Player, "StopCrouch", ...)
	end,
}

-- MECHANICS
local function AuthenticatePlayer(Player)
	-- Functions
	-- INIT
	if game.Players:GetPlayerFromCharacter(Character) == Player then
		return true
	end
end

local function OnCharacterProcessRemoteFired(Player, FunctionName, ...)
	--DebugModule:Print"CharacterProcessRemote | Fired Server! | Player: ".. tostring(Player.Name).. " | Function: ".. tostring(FunctionName).. " | Parameters: ".. tostring({...}))
	
	if AuthenticatePlayer(Player) then
		return Processes[FunctionName](Player, ...)
	end
end

-- DIRECT
function CharacterProcessCommunicationsModule.Initialise()
	-- Functions
	-- DIRECT
	local Connection1 = CharacterProcessRemote.OnServerEvent:Connect(OnCharacterProcessRemoteFired)
	CharacterRequestSignal.OnServerInvoke = OnCharacterProcessRemoteFired
	
	
	-- CONNECTIONS
	table.insert(Connections, Connection1)
end

function CharacterProcessCommunicationsModule.GarbageCollect()
	-- Functions
	-- INIT
	Processes = nil
	--
	Character = nil
	CharacterClientServerRemotesFolder = nil
	CharacterServerModulesFolder = nil
	--
	SharedModulesFolder = nil
	ServerInitModulesFolder = nil
	ServerModulesFolder = nil
	--
	CharacterProcessRemote = nil
	CharacterPhysicsProcessRemote = nil
	--
	CharacterActionsModule = nil
	WeaponsModule = nil
	UtilitiesModule = nil
	CollectionsInitModule = nil
	DebugModule = nil
	--
	Connections = nil
	ActionsBeingPerfomed = nil
	ActionOverwrites = nil
	
end

function CharacterProcessCommunicationsModule.End()
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections)
end

return CharacterProcessCommunicationsModule