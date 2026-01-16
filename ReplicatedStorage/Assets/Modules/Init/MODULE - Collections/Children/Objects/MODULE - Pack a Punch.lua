local TagModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedServerWeaponsPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]

-- Client
local Player = game.Players.LocalPlayer

-- Info Modules
local CollectionsInfoModule = require(InfoModulesFolder["Collections"])

-- Modules
local SharedObjectsModule = require(ModulesFolder["Objects"])
local PhysicsModule = require(ModulesFolder["Physics"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local SoundsModule = require(ModulesFolder["Sounds"])
local DebrisModule = require(ModulesFolder["Debris"])

-- CORE
local TweenDict = {}
local Cache = {}

local EffectInfo = 
{
	["Duration"] = 1,
	["Style"] = Enum.EasingStyle.Bounce,
	["Direction"] = Enum.EasingDirection.Out		
}

-- Services
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
local function Initialise(Model)
	-- CORE
	local CustomConnection = UtilitiesModule:CreateCustomConnection()
	
	-- Elements
	-- PARTS
	local RollingSoftPart = UtilitiesModule:WaitForChildTimed(Model, "RollingSoft")
	
	-- Functions
	-- DIRECT
	
	-- INIT
	coroutine.wrap(function()
		while task.wait() and CustomConnection and CustomConnection.Value do
			RollingSoftPart.CFrame *= CFrame.Angles(math.rad(1), 0, 0)
		end
	end)()
	
	Cache[Model] = {Connections = {}, CustomConnections = {CustomConnection}}
end

local function End(Model)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Cache[Model]["CustomConnections"])
	
	Cache[Model] = nil
end

-- DIRECT
function TagModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function TagModule.End(NilParam, ...)
	return End(...)
end

return TagModule