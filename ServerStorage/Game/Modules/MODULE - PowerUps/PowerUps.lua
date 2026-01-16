local PowerUpsModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Core
local RequiredModules = {}

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

local function ApplyPowerUp(Character, PowerUpName)
	-- Functions
	-- INIT
	CollectionService:AddTag(Character, PowerUpName)
	return RequiredModules[PowerUpName]:Initialise(Character)
end

local function EndPowerUp(Character, PowerUpName)
	-- Functions
	-- INIT
	CollectionService:RemoveTag(Character, PowerUpName)
	return RequiredModules[PowerUpName]:End(Character)
end

-- DIRECT
function PowerUpsModule.ApplyPowerUp(NilParam, Character, PowerUpName)
	return ApplyPowerUp(Character, PowerUpName)
end

function PowerUpsModule.EndPowerUp(NilParam, Character, PowerUpName)
	return EndPowerUp(Character, PowerUpName)
end

-- INIT
RunSubModules()

return PowerUpsModule