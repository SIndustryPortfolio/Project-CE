local ExplosionModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local DumpFolder = workspace:WaitForChild("Dump")

-- Info Modules
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])
local RoundTypesInfoModule = require(SharedInfoModulesFolder["RoundTypes"])
local SoundsInfoModule = require(SharedInfoModulesFolder["Sounds"])
local ObjectsInfoModule = require(SharedInfoModulesFolder["Objects"])

-- Modules
local SoundsModule = require(SharedModulesFolder["Sounds"])
local ParticlesModule = require(SharedModulesFolder["Particles"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local SettingsModule = require(SharedModulesFolder["Settings"])
--local EffectsHandlerModule = require(SharedModulesFolder["EffectsHandler"])

-- Services
--local DebrisService = game:GetService("Debris")

-- Functions


local function HandleExplosion(EffectsHandlerModule, Position, ExplosionType)
	-- CORE
	local ObjectInfoModule = ObjectsInfoModule:GetObjectInfo(ExplosionType)
	
	-- Functions
	-- INIT
	ParticlesModule:ParticleEffect("Explosion", Position, ObjectInfoModule:GetInfo("ExplosionTrailColour"))
	ObjectsModule:ObjectProcess("Explosion", {["Name"] = ExplosionType, ["Position"] = Position})
	
end

-- DIRECT
function ExplosionModule.Initialise(NilParam, ...)
	return HandleExplosion(...)
end

return ExplosionModule