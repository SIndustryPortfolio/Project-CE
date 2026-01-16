local EffectHandlerModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ParticlesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Particles"]
local DumpFolder = workspace:WaitForChild("Dump")

-- Client
local Player = game.Players.LocalPlayer

-- Info Modules
local ObjectsInfoModule = require(InfoModulesFolder["Objects"])
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])

-- Modules
local SoundsModule = require(ModulesFolder["Sounds"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local ObjectsModule = require(ModulesFolder["Objects"])
local DebugModule = require(ModulesFolder["Debug"])
--local FPSEffectsModule = require(UtilitiesModule:WaitForChildTimed(script, "FPSEffects"))
local ParticlesModule = require(ModulesFolder["Particles"])

-- Core
local Player = game.Players.LocalPlayer
local RequiredModules = {}

-- Functions
-- INIT
pcall(function()
	Player = game.Players.LocalPlayer
end)

-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	for i, Module in pairs(script:GetChildren()) do
		coroutine.wrap(function()
			DebugModule:Print("EffectsHandler | Running Module: ".. tostring(Module))
			
			local Success, RequiredModule = pcall(function()
				return require(Module)
			end)
			
			if Success then
				RequiredModules[Module.Name] = RequiredModule
			else
				DebugModule:Print(script.Name.. " | RunSubModules | Error: ".. tostring(RequiredModule))
			end
			
			DebugModule:Print("EffectsHandler | Finished running Module: ".. tostring(Module))
		end)()
	end
end

--[[local function GetCharacter(Player)
	return Player.Character or Player:GetPropertyChangedSignal("Character"):Wait() --Player.CharacterAdded:Wait()
end]]

local function GetParticle(ParticleName)
	-- Functions
	-- INIT
	local ParticleBlock = UtilitiesModule:WaitForChildTimed(ParticlesFolder, ParticleName):Clone()
	
	local CoreFolder = ParticleBlock:FindFirstChild("Core")
	local ActivateModule = nil
	
	if CoreFolder then
		ActivateModule = CoreFolder:FindFirstChild("Activate")
	end
	
	--[[local FoundInnerAttachment = ParticleBlock:FindFirstChildOfClass("Attachment") or ParticleBlock
	
	if FoundInnerAttachment then
		return FoundInnerAttachment:Clone() 
	end]]
	
	return ParticleBlock, ActivateModule
end

local function LoadParticleEmitterIntoPart(Part, ParticleEmitterName, CFrameMultiplier, WeldTo)
	-- Functions
	-- INIT
	local Particle, ActivateModule = GetParticle(ParticleEmitterName)
	
	if Particle:IsA("BasePart") then
		if typeof(Part) == "Instance" and Part:IsA("BasePart") then
			Particle.CFrame = Part.CFrame
		elseif typeof(Part) == "Vector3" then
			Particle.Position = Part		
		elseif typeof(Part) == "CFrame" then
			Particle.CFrame = Part
		end
		
		Particle.Parent = UtilitiesModule:WaitForChildTimed(DumpFolder, "Misc") --UtilitiesModule:WaitForChildTimed(workspace, "Dump")
	else
		Particle.Parent = Part	
	end
	
	if CFrameMultiplier then
		Particle.CFrame *= CFrameMultiplier
	end
	
	if WeldTo then
		if typeof(WeldTo) == "Instance" then
			UtilitiesModule:WeldParts(Particle, WeldTo)
		else
			UtilitiesModule:WeldParts(Particle, Part)
		end	
	end
	
	return Particle, ActivateModule
end

local function ToggleParticleEmitters(Attachment, ToggleValue, PlayerToIgnore)
	-- Functions
	-- INIT
	if not Attachment then
		return nil
	end
	
	if Attachment:IsA("BasePart") and not Attachment:FindFirstChildOfClass("ParticleEmitter") then
		Attachment = Attachment:FindFirstChildOfClass("Attachment")
	end
	
	if PlayerToIgnore then
		if PlayerToIgnore == Player then
			return nil
		end
	end
	
	if Attachment:IsA("ParticleEmitter") then
		Attachment.Enabled = ToggleValue
	end
	
	for i, Effect in pairs(Attachment:GetChildren()) do
		if Effect:IsA("ParticleEmitter") then
			Effect.Enabled = ToggleValue
		end
	end
end

local function ChangeTransparencyOfModel(Model)
	-- Functions
	-- INIT
	for i, _Instance in pairs(Model:GetDescendants()) do -- For Decals, Textures, Parts
		pcall(function()
			_Instance.Transparency = 1
		end)
	end
end

local function HandleMelee(_Player, raycastResult)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(_Player)
	
	-- Elements
	-- FOLDERS
	local ClientModulesFolder = UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(Character, "Modules"), "Client")

	-- Modules
	--local FPSEffectsModule = require(ClientModulesFolder["FPSHandler"]["FPSEffects"])

	-- Functions
	-- INIT
	RequiredModules["FPSEffects"]:ClientMeleeEffect(EffectHandlerModule, raycastResult)
	--FPSEffectsModule:ClientMeleeEffect(EffectHandlerModule, raycastResult)
end

local function HandleFire(_Player, WeaponModel, raycastParams, WeaponName, Charge, ResultInfo)
	--[[if Player == _Player then
		return nil
	end]]
	
	-- CORE
	--local Character = UtilitiesModule:GetCharacter(_Player, true) --GetCharacter(_Player)
	
	--[[if not Character then
		return nil
	end]]
	
	-- Elements
	-- FOLDERS
	--local ClientModulesFolder = UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(Character, "Modules"), "Client")
	
	-- Modules
	--local FPSEffectsModule = require(ClientModulesFolder["FPSHandler"]["FPSEffects"])
	
	-- Functions
	-- INIT
	
	--FPSEffectsModule:ClientFireEffect(EffectHandlerModule, WeaponModel, raycastParams)
	if Player ~= _Player then
		RequiredModules["FPSEffects"]:ClientFireEffect(EffectHandlerModule, WeaponModel, raycastParams, WeaponName, Charge, ResultInfo)
	else
		if ResultInfo then
			local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponName or WeaponModel.Name)
			
			for i, _ResultInfo in pairs(ResultInfo) do	
				if _ResultInfo["Explosions"] then					
					coroutine.wrap(function()
						local ObjectInfo= ObjectsInfoModule:GetObjectInfo(WeaponInfo["ExplosiveRounds"]["Type"])

						for i, ExplosionLocation in pairs(_ResultInfo["Explosions"]) do
							ParticlesModule:ParticleEffect("Explosion", ExplosionLocation, ObjectInfo["ExplosionTrailColour"])
							ObjectsModule:ObjectProcess("Explosion", {Name = WeaponInfo["ExplosiveRounds"]["Type"], Position = ExplosionLocation})
							SoundsModule:PlaySoundEffectById(ObjectInfo["ExplosionSound"], nil, ExplosionLocation)
						end
					end)()
				end
					
				
				if _ResultInfo["Damage"] and  _ResultInfo["Damage"]["Effect"] then
					coroutine.wrap(function()
						return RequiredModules["FPSEffects"]:EffectProcess(EffectHandlerModule, _ResultInfo["Damage"]["Effect"]["Name"],  _ResultInfo["Damage"]["Effect"]["Character"],  _ResultInfo["Damage"]["Effect"]["Result"])
					end)()		
				end	
			end
		end
	end
end

local function EffectProcess(FunctionName, ...)
	-- Functions
	-- INIT
	--[[local Success, RequiredModule = pcall(function()
		return require(UtilitiesModule:WaitForChildTimed(script, FunctionName))
	end)]]
	
	local RequiredModule = RequiredModules[FunctionName]
	
	--[[if not Success then
		--DebugModule:PrintRequiredModule, "Error")
		return nil
	end]]
	
	return RequiredModule:ClientRequest(EffectHandlerModule, ...)
end

-- CORE FUNCTIONS
local ServerRequests = 
{
	["EffectProcess"] = EffectProcess,
	["ToggleParticleEmitters"] = function(Attachment, ToggleValue, PlayerToIgnore)
		return ToggleParticleEmitters(Attachment, ToggleValue, PlayerToIgnore)
	end,
	["LoadParticleEmitter"] = function(Part, ParticleEmitterName, CFrameMultiplier)
		return LoadParticleEmitterIntoPart(Part, ParticleEmitterName, CFrameMultiplier)
	end,
	["ChangeTransparency"] = function(Model, Transparency)
		return ChangeTransparencyOfModel(Model, Transparency)
	end,
	["Fire"] = function(_Player, WeaponModel, raycastParams, WeaponName, ...)
		return HandleFire(_Player, WeaponModel, raycastParams, WeaponName, ...)
	end,
	["Melee"] = function(_Player, raycastParams)
		return HandleMelee(_Player, raycastParams)
	end,
}

-- DIRECT
function EffectHandlerModule.FPSEffectProcess(Nilparam, ...)
	return RequiredModules["FPSEffects"]:EffectProcess(EffectHandlerModule, ...) --FPSEffectsModule:EffectProcess(EffectHandlerModule, ...)
end

function EffectHandlerModule.ToggleParticleEmitters(NilParam, Attachment, ToggleValue, PlayerToIgnore)
	return ToggleParticleEmitters(Attachment, ToggleValue, PlayerToIgnore)
end

function EffectHandlerModule.LoadParticleEmitter(NilParam, Part, ParticleEmitterName, CFrameMultiplier, WeldTo)
	return LoadParticleEmitterIntoPart(Part, ParticleEmitterName, CFrameMultiplier, WeldTo)
end

function EffectHandlerModule.ChangeTransparency(NilParam, Model, Transparency)
	return ChangeTransparencyOfModel(Model, Transparency)
end

function EffectHandlerModule.ServerRequest(NilParam, FunctionName, ...)
	return ServerRequests[FunctionName](...)
end

-- INIT
RunSubModules()

return EffectHandlerModule