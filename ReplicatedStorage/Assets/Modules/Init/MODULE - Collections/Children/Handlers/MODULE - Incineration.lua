local TagModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local EffectsHandlerModule = require(SharedModulesFolder["EffectsHandler"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebrisModule = require(SharedModulesFolder["Debris"])

-- CORE
local Cache = {}

-- Functions
-- MECHANICS
local function Initialise(Character)
	-- Functions
	-- INIT
	local FireObject = EffectsHandlerModule:LoadParticleEmitter(Character.PrimaryPart, "Fire", nil, true)
	EffectsHandlerModule:ToggleParticleEmitters(FireObject, true, nil)
	Cache[Character] = FireObject
end

local function End(Character)
	-- Functions
	-- INIT
	if Cache[Character] then
		EffectsHandlerModule:ToggleParticleEmitters(Cache[Character], false, nil)
		DebrisModule:AddItem(Cache[Character], 3)		
	end
end

-- DIRECT
function TagModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function TagModule.End(NilParam, ...)
	return End(...)
end

return TagModule