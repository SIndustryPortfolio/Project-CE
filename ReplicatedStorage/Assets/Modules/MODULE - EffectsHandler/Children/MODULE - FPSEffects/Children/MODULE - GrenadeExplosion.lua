local GrenadeExplosionModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Info Modules
local GrenadesInfoModule = require(InfoModulesFolder["Grenades"])
local ObjectsInfoModule = require(InfoModulesFolder["Objects"])

-- Modules
local DebrisModule = require(ModulesFolder["Debris"])
local ObjectsModule = require(ModulesFolder["Objects"])
local ParticlesModule = require(ModulesFolder["Particles"])
local SoundsModule = require(ModulesFolder["Sounds"])

-- Functions
-- MECHANICS
local function Initialise(EffectsHandlerModule, GrenadeModel)
	-- CORE
	local GrenadeInfo = GrenadesInfoModule:GetGrenadeInfo(GrenadeModel.Name)
	local ObjectInfoModule = ObjectsInfoModule:GetObjectInfo(GrenadeModel.Name)
	
	local Attachment = EffectsHandlerModule:LoadParticleEmitter(GrenadeModel.PrimaryPart.Position, GrenadeModel.Name)
	EffectsHandlerModule:ToggleParticleEmitters(Attachment, true, nil)
	ParticlesModule:ParticleEffect("Explosion", GrenadeModel.PrimaryPart, ObjectInfoModule["ExplosionTrailColour"])
	ObjectsModule:ObjectProcess("Explosion", GrenadeModel)
	
	if not ObjectInfoModule["ExplosionSound"] or ObjectInfoModule["ExplosionSound"] == "" then
		SoundsModule:PlaySoundEffectByName("Objects", "Explosion", nil, Attachment, {["RollOffMaxDistance"] = 500--[[, ["RollOffMinDistance"] = 30--[[, ["Volume"] = 5]]})
	else
		SoundsModule:PlaySoundEffectById(ObjectInfoModule["ExplosionSound"], nil, Attachment, nil, {["RollOffMaxDistance"] = 500--[[, ["RollOffMinDistance"] = 30--[[, ["Volume"] = 5]]})
	end
	
	task.wait(.4)
	DebrisModule:AddItem(Attachment, 2)
	EffectsHandlerModule:ToggleParticleEmitters(Attachment, false, nil)
	
end

-- DIRECT
function GrenadeExplosionModule.Initialise(NilParam, EffectsHandlerModule, GrenadeModel)
	return Initialise(EffectsHandlerModule, GrenadeModel)
end

function GrenadeExplosionModule.End()
	return nil
end

return GrenadeExplosionModule