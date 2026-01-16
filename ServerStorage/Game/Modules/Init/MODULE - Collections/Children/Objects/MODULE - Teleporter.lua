local TagModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Info Modules
local CollectionsInfoModule = require(SharedInfoModulesFolder["Collections"])
local ObjectsInfoModule = require(SharedInfoModulesFolder["Objects"])

-- Modules
local ServerObjectsModule = require(ServerModulesFolder["Objects"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local DebugModule = require(SharedModulesFolder["Debug"])

local Connections = {}
local DebounceCache = {}

-- Services
--local DebrisService = game:GetService("Debris")

-- Functions
-- MECHANICS
local function AddToCache(Model, _Connections)
	-- Functions
	-- INIT
	if Connections[Model] == nil then
		Connections[Model] = {}
	end

	for i, Connection in pairs(_Connections) do
		table.insert(Connections[Model], Connection)
	end
end

local function RemoveFromCache(Model)
	-- Functions
	-- INIT
	if not Connections[Model] then
		return nil
	end

	UtilitiesModule:DisconnectConnections(Connections[Model])
	Connections[Model] = nil
end

local function Initialise(Teleporter)
	
end

local function Teleport(Player, Teleporter)
	--print("TELEPORTING PLAYER: ".. tostring(Player))
	
	if DebounceCache[Player] then
		return nil
	end
	
	DebounceCache[Player] = true
	
	-- CORE
	local ObjectInfo = ObjectsInfoModule:GetObjectInfo(Teleporter.Name)
	
	-- Functions
	-- INIT
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if not Character then
		DebounceCache[Player] = nil
		return nil
	end
	
	-- Elements
	-- PARTS
	local HumanoidRootPart = Character.PrimaryPart
	local TeleporterPrimaryPart = UtilitiesModule:GetPartToShift(Teleporter)
	
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	-- CONFIGS
	local CoreConfig = UtilitiesModule:WaitForChildTimed(Teleporter, "Core")
	
	-- VALUES
	local ReceiverValue = UtilitiesModule:WaitForChildTimed(CoreConfig, "Receiver")
	
	if not ReceiverValue then
		DebounceCache[Player] = nil
		--DebugModule:Print"Teleporter has no receiver value instance: ".. tostring(Teleporter))
		return nil
	elseif not ReceiverValue.Value then
		DebounceCache[Player] = nil
		--DebugModule:Print"Teleporter has no receiver value: ".. tostring(Teleporter))
		return nil
	end
	
	-- PARTS
	local BasePart = UtilitiesModule:WaitForChildTimed(ReceiverValue.Value, "Base")
	
	-- INIT	
	local Distance = (HumanoidRootPart.Position - TeleporterPrimaryPart.Position).Magnitude
	local CharacterProcessRemote = UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess")
	
	if Distance <= ObjectInfo["DistanceToTeleport"] then
		--HumanoidRootPart.Position = (BasePart.CFrame.p --[[* CFrame.Angles(0, math.rad(90), 0))]] + Vector3.new(0, Humanoid.HipHeight * 1.5, 0))
		Character:SetPrimaryPartCFrame(CFrame.new((BasePart.CFrame.p --[[* CFrame.Angles(0, math.rad(90), 0))]] + Vector3.new(0, Humanoid.HipHeight * 1.5, 0))))
		Humanoid.Jump = true
		
		if CharacterProcessRemote then
			CharacterProcessRemote:FireClient(Player, "Teleported")
		end
	else
		----DebugModule:Print"Teleporter too far!")
	end	
	
	coroutine.wrap(function()
		task.wait(.3)
		DebounceCache[Player] = nil
	end)()
end

local function End(Teleporter)	
	-- Functions
	-- INIT
	RemoveFromCache(Teleporter)
end

-- DIRECT
local ClientRequests = 
{
	["Teleport"] = 	Teleport
}

-- DIRECT
function TagModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

function TagModule.Initialise(NilParam, Teleporter)
	return Initialise(Teleporter)
end

function TagModule.End(NilParam, Teleporter)
	return End(Teleporter)
end

return TagModule