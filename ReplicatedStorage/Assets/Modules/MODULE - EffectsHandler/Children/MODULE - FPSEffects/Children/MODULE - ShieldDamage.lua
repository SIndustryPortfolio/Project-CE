local ShieldDamageModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local ParticlesModule = require(ModulesFolder["Particles"])
--local EffectsHandlerModule = require(ModulesFolder["EffectsHandler"])
local DebrisModule = require(ModulesFolder["Debris"])

-- CORE
local TweenDict = {}

local EffectInfo = 
{
	["Duration"] = 0.3,
	["Style"] = Enum.EasingStyle.Cubic,
	["Direction"] = Enum.EasingDirection.InOut
}

-- Services
local TweenService = game:GetService("TweenService")
--local DebrisService = game:GetService("Debris")

-- Functions
-- MECHANICS

local function UpdateShield(EffectsHandlerModule, Character)
	-- CORE
	local ShieldEffectModel = Character:FindFirstChild("ShieldEffect") --UtilitiesModule:WaitForChildTimed(Character, "ShieldEffect")
	
	-- Elements
	-- Humanoids
	local Humanoid = UtilitiesModule:WaitForChildTimed(Character, "Humanoid")
	
	-- PARTS
	--local HumanoidRootPart = UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")
	
	-- Functions
	-- INIT
	if not ShieldEffectModel then
		return nil
	end
	
	local TransparencyToTweenTo = 1
	
	if Humanoid:GetAttribute("Shield") == 0  or Humanoid:GetAttribute("Shield") >= Humanoid:GetAttribute("MaxShield") or Humanoid.Health <= 0 then
		--ShieldEffectModel:Destroy()
	else
		TransparencyToTweenTo = math.clamp(Humanoid:GetAttribute("MaxShield") / Humanoid:GetAttribute("Shield"), 0.5, 0.9)
	end
	
	for i, Part in pairs(ShieldEffectModel:GetChildren()) do
		if not Part:IsA("BasePart") then
			continue
		end
		
		Part.Transparency = TransparencyToTweenTo
		
		--[[local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
		local tweeningInfo = {}
		tweeningInfo.Transparency = TransparencyToTweenTo --math.clamp(Humanoid:GetAttribute("MaxShield") / Humanoid:GetAttribute("Shield"), 0.5, 0.9)

		UtilitiesModule:CancelTween(Part, TweenDict)
		TweenDict[Part] = TweenService:Create(Part, tweenInfo, tweeningInfo)
		TweenDict[Part]:Play()
		UtilitiesModule:CompleteTween(Part, TweenDict)]]
	end
end

local function SetupCrackedShield(EffectsHandlerModule, Character)
	-- Functions
	-- INIT
	for i, Part in pairs(Character:GetChildren()) do
		if not Part:IsA("BasePart") or Part == Character.PrimaryPart then
			continue
		end
		
		if Part:FindFirstChild("ShieldBroken") then
			continue
		end
		
		EffectsHandlerModule:LoadParticleEmitter(Part, "ShieldBroken")
	end
end

local function RemoveCrackedShield(EffectsHandlerModule, Character)
	for i, Part in pairs(Character:GetChildren()) do
		if not Part:IsA("BasePart") or Part == Character.PrimaryPart then
			continue
		end

		local FoundParticle = Part:FindFirstChild("ShieldBroken")
		
		if FoundParticle then
			EffectsHandlerModule:ToggleParticleEmitters(FoundParticle, false)
			DebrisModule:AddItem(FoundParticle)
		end
	end
end

local function Initialise(EffectsHandlerModule, Character)
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildTimed(Character, "Humanoid")
	
	-- Functions
	-- INIT
	--[[if not Character:FindFirstChild("ShieldEffect") --[[and Humanoid:GetAttribute("Shield") > 0 and Humanoid.Health > 0]] --then
		--SetupFilterCharacter(Character)
	--end
	
	if Humanoid:GetAttribute("Shield") <= 0 and Humanoid.Health > 0 then
		SetupCrackedShield(EffectsHandlerModule, Character)
	else
		RemoveCrackedShield(EffectsHandlerModule, Character)
	end
	
	return UpdateShield(EffectsHandlerModule, Character)
end

-- DIRECT
function ShieldDamageModule.Initialise(NilParam, EffectsHandlerModule, Character)
	return Initialise(EffectsHandlerModule, Character)
end

return ShieldDamageModule