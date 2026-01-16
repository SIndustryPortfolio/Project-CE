local ShieldHitModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local DumpFolder = workspace:WaitForChild("Dump")

-- Modules
local ObjectsModule = require(SharedModulesFolder["Objects"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])
local SoundsModule = require(SharedModulesFolder["Sounds"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local ParticlesModule = require(SharedModulesFolder["Particles"])
local SettingsModule = require(SharedModulesFolder["Settings"])
--local EffectsHandlerModule = require(SharedModulesFolder["EffectsHandler"])

-- Client
local Player = game.Players.LocalPlayer

-- Functions
-- MECHANICS
local function HandleShieldHit(EffectsHandlerModule, Character, raycastResult)
	-- CORE
	local LocalCharacter = UtilitiesModule:GetCharacter(Player)

	-- Functions
	-- INIT
	if LocalCharacter == Character then
		return nil
	end

	if not raycastResult or not raycastResult.Position then
		DebugModule:Print(script.Name.. " HandleShieldHit | No raycast result or no position V")
		DebugModule:Print(script.Name.. " HandleShieldHit | raycastResult: ".. tostring(raycastResult))
		DebugModule:Print(script.Name.. " HandleShieldHit | position: ".. tostring(raycastResult.Position))
		--DebugModule:Print"Returning nil | Effects Handler Module: ".. tostring(EffectsHandlerModule).. " | Character: ".. tostring(Character).. " | raycastResult: ".. tostring(raycastResult))
		return nil
	end
	
	if not raycastResult.Normal then
		raycastResult.Normal = Vector3.new()
	end
	
	if not raycastResult._Origin then
		raycastResult._Origin = raycastResult.Position
	end
	
	local ShieldHit = EffectsHandlerModule:LoadParticleEmitter(CFrame.new(raycastResult.Position + raycastResult.Normal, raycastResult._Origin), "ShieldHit", nil, raycastResult._Instance)
	EffectsHandlerModule:ToggleParticleEmitters(ShieldHit, true)
	task.wait(.5)
	EffectsHandlerModule:ToggleParticleEmitters(ShieldHit, false)
	DebrisModule:AddItem(ShieldHit, .5)
	--ParticlesModule:ParticleEffect("Blood", raycastResult.Position + raycastResult.Normal)
	--ParticlesModule:ParticleEffect("Explosion", raycastResult.Position + raycastResult.Normal, ShieldHitColour, 0.5)
end

-- DIRECT
function ShieldHitModule.Initialise(NilParam, EffectsHandlerModule, Character, raycastResult)
	return HandleShieldHit(EffectsHandlerModule, Character, raycastResult)
end

return ShieldHitModule