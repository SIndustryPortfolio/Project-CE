local MeleeSmokeModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local SoundsModule = require(ModulesFolder["Sounds"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebrisModule = require(ModulesFolder["Debris"])

-- Services
--local DebrisService = game:GetService("Debris")

-- Functions
-- MECHANICS
local function MeleeSmokeEffect(EffectsHandlerModule, raycastResult)
	-- Functions
	-- INIT
	if not raycastResult then
		return nil
	end
	
	if not raycastResult.Instance or not raycastResult.Position then
		return nil
	end
	
	local Attachment = EffectsHandlerModule:LoadParticleEmitter(raycastResult.Position, "SmokeDustExplosion")
	Attachment.CFrame = CFrame.new(raycastResult.Position, raycastResult.Position + raycastResult.Normal)
	UtilitiesModule:WeldParts(Attachment, raycastResult.Instance)
	SoundsModule:PlaySoundEffectByName("CharacterActions", "MeleeThud", nil, Attachment)
	EffectsHandlerModule:ToggleParticleEmitters(Attachment, true, nil)
	task.wait(0.6)
	EffectsHandlerModule:ToggleParticleEmitters(Attachment, false, nil)
	--DebrisService:AddItem(Attachment, 1)
	DebrisModule:AddItem(Attachment, 1)
end

-- DIRECT
function MeleeSmokeModule.Initialise(NilParam, EffectsHandlerModule, raycastResult)
	return MeleeSmokeEffect(EffectsHandlerModule, raycastResult)
end

return MeleeSmokeModule