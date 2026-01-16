local TagModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Modules
local DamageModule = require(ServerModulesFolder["Damage"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local Cache = {}
local FireDamage = 15

-- Functions
-- MECHANICS
local function Initialise(Character)
	if not Character then
		return nil
	end
	
	-- CORE
	local CustomConnection = UtilitiesModule:CreateCustomConnection()
	
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	-- Functions
	-- INIT
	Cache[Character] = {CustomConnection}
	
	coroutine.wrap(function()
		while task.wait(1) and Character and CustomConnection and CustomConnection.Value do
			DamageModule:TakeDamage(Humanoid, FireDamage, nil, nil, Character.PrimaryPart.Position)
		end
	end)()
end

local function End(Character)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectCustomConnections(Cache[Character])
end

-- DIRECT
function TagModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function TagModule.End(NilParam, ...)
	return End(...)
end

return TagModule