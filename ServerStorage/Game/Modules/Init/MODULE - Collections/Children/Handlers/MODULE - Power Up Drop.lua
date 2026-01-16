local TagModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerRemotesFolder = game:GetService("ServerStorage")["Remotes"]["Server"]["Remotes"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebrisModule = require(SharedModulesFolder["Debris"])

-- CORE
local PickedUp = {}

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]
local PowerUpsRemote = ServerRemotesFolder["PowerUps"]

-- Functions
-- MECHANICS
local function Initialise(DropModel)
	-- Functions
	-- INIT
	DebrisModule:AddItem(DropModel, 30)
end

local function PickUp(Player, DropModel)
	-- Functions
	-- INIT
	if not DropModel or PickedUp[DropModel] then
		return nil
	end
	
	PickedUp[DropModel] = true
	
	if (UtilitiesModule:GetPartToShift(DropModel).Position - UtilitiesModule:GetCharacter(Player, true).PrimaryPart.Position).Magnitude > 10 then
		PickedUp[DropModel] = nil
		return nil
	end
	
	PowerUpsRemote:Fire("Activate", DropModel.Name, Player)
	
	DebrisModule:AddItem(DropModel)
	
	GameProcessRemote:FireAllClients("Game", "PowerUpDrop", DropModel.Name)
	
	task.wait(3)
	PickedUp[DropModel] = nil
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["PickUp"] = PickUp
}

-- DIRECT
function TagModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

function TagModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function TagModule.End()
	
end

return TagModule