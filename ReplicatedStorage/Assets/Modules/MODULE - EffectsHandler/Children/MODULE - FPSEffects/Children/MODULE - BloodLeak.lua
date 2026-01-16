local BloodLeakModule = {}

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
-- Client
local Player = game.Players.LocalPlayer

-- CORE
local BloodLeakColour = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(170, 0, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 0, 0))
}

-- Services
--local DebrisService = game:GetService("Debris")

-- Functions
-- MECHANICS
local function HandleLeak(EffectsHandlerModule, Character, raycastResult)
	-- CORE
	local LocalCharacter = UtilitiesModule:GetCharacter(Player)
	
	-- Functions
	-- INIT
	if LocalCharacter == Character then
		return nil
	end
	
	if not raycastResult or not raycastResult.Position then
		--DebugModule:Print"Returning nil | Effects Handler Module: ".. tostring(EffectsHandlerModule).. " | Character: ".. tostring(Character).. " | raycastResult: ".. tostring(raycastResult))
		return nil
	end
	
	if not raycastResult._Origin then
		raycastResult._Origin = raycastResult.Position
	end
	
	if SettingsModule:GetSettingValue("Video", "Blood", true) and raycastResult and raycastResult.Position and raycastResult.Normal and raycastResult._Origin and raycastResult._Instance then
		local Blood = EffectsHandlerModule:LoadParticleEmitter(CFrame.new(raycastResult.Position + raycastResult.Normal, raycastResult._Origin), "Blood", nil, raycastResult._Instance)
		
		if SettingsModule:GetSettingValue("Video", "BloodSpecular", true) then
			ParticlesModule:ParticleEffect("Explosion", raycastResult.Position + raycastResult.Normal, BloodLeakColour, 0.5, true)
		end
		
		--[[if SettingsModule:GetSettingValue("Video", "RenderQuality") == "ULTRA HIGH" then
			ParticlesModule:ParticleEffect("Explosion", raycastResult.Position + raycastResult.Normal, BloodLeakColour, 0.5)
		end]]
		
		EffectsHandlerModule:ToggleParticleEmitters(Blood, true)
		task.wait(1)
		EffectsHandlerModule:ToggleParticleEmitters(Blood, false)
		DebrisModule:AddItem(Blood, 1)
		--ParticlesModule:ParticleEffect("Blood", raycastResult.Position + raycastResult.Normal)
		--ParticlesModule:ParticleEffect("Explosion", raycastResult.Position + raycastResult.Normal, BloodLeakColour, 0.5)
	end
end

-- DIRECT
function BloodLeakModule.Initialise(NilParam, EffectsHandlerModule, Character, raycastResult)
	return HandleLeak(EffectsHandlerModule, Character, raycastResult)
end

return BloodLeakModule