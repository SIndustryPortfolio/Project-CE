local TagModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Info Modules
local CollectionsInfoModule = require(SharedInfoModulesFolder["Collections"])

-- Modules
local ServerGameModule = require(ServerModulesFolder["Game"])
local ServerObjectsModule = require(ServerModulesFolder["Objects"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- CORE
local Connections = {}
local HumanoidsDying = {}

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

local function Initialise(DeathZone)
	-- Functions
	-- DIRECT
	--DebugModule:Print"Initialising Death Zone: ".. tostring(DeathZone))
	
	local Connection1 = DeathZone.Touched:Connect(function(HitPart)
		local Humanoid = UtilitiesModule:GetHumanoidFromHit(HitPart)
		
		
		if Humanoid and Humanoid.Health > 0 then
			if HumanoidsDying[Humanoid] then
				return nil
			end

			HumanoidsDying[Humanoid] = true
			
			Humanoid.Health = 0
			
			local AssociatedPlayer = game.Players:GetPlayerFromCharacter(Humanoid.Parent)
			  	
			if AssociatedPlayer and (not Humanoid:GetAttributes()["LastHit"] or Humanoid:GetAttributes()["LastHit"] == "") then
				GameProcessRemote:FireAllClients("Game", "LogConsole", "Core", nil, AssociatedPlayer.Name.. " fell to their death!")
			elseif Humanoid:GetAttributes()["LastHit"] ~= "" and Humanoid:GetAttributes()["LastHit"] ~= nil then
				local FoundLastHitPlayer = game.Players:FindFirstChild(Humanoid:GetAttributes()["LastHit"])
				
				if FoundLastHitPlayer then
					ServerGameModule:GameProcess("Kill", FoundLastHitPlayer, "Kill", AssociatedPlayer, nil)
				end
			end
			
			task.wait(5)
			HumanoidsDying[Humanoid] = nil
		else
			--DebugModule:Print"Touched! No humanoid. Part: ".. tostring(HitPart)) 
		end
	end)
	
	-- INIT
	AddToCache(DeathZone, {Connection1})
end

local function End(DeathZone)	
	-- Functions
	-- INIT
	RemoveFromCache(DeathZone)
end

-- DIRECT
function TagModule.Initialise(NilParam, DeathZone)
	return Initialise(DeathZone)
end

function TagModule.End(NilParam, DeathZone)
	return End(DeathZone)
end

return TagModule