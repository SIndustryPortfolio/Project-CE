local ThumperPumperModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local SoundsModule = require(ModulesFolder["Sounds"])
local DebrisModule = require(ModulesFolder["Debris"])

-- CORE
local TweenDict = {}
local EffectInfo = 
{
	["Duration"] = .5,
	["Style"] = Enum.EasingStyle.Cubic,
	["Direction"] = Enum.EasingDirection.InOut		
}

-- Services
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
local function Initialise(EffectsHandlerModule, RaycastResult)
	-- Functions
	-- INIT
	local _CFrame = CFrame.new(RaycastResult.Position, RaycastResult.Position + (RaycastResult.Normal or Vector3.new(0, 0, 0))) * CFrame.Angles(math.rad(90), 0, 0)

	local HollowCircle = EffectsHandlerModule:LoadParticleEmitter(_CFrame, "HollowCircle", nil, nil)
	EffectsHandlerModule:ToggleParticleEmitters(HollowCircle, true)

	HollowCircle.CanCollide = false

	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])

	local tweeningInfo = {}
	tweeningInfo.Transparency = 1
	tweeningInfo.Size = Vector3.new(HollowCircle.Size.X * 2, HollowCircle.Size.Y, HollowCircle.Size.Z * 2)
	
	HollowCircle.Size = Vector3.new()

	UtilitiesModule:CancelTween(HollowCircle, TweenDict)
	TweenDict[HollowCircle] = TweenService:Create(HollowCircle, tweenInfo, tweeningInfo)

	SoundsModule:PlaySoundEffectById("rbxassetid://8588542238", nil, HollowCircle)

	TweenDict[HollowCircle]:Play()
	UtilitiesModule:CompleteTween(HollowCircle, TweenDict)

	DebrisModule:AddItem(HollowCircle, EffectInfo["Duration"])
end

--[[local function Initialise(EffectsHandlerModule, Character)
	-- CORE
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	local HumanoidRootPart = Character.PrimaryPart
	
	-- Functions
	-- INIT
	local HollowCircle = EffectsHandlerModule:LoadParticleEmitter(HumanoidRootPart.CFrame * CFrame.new(0, -((Humanoid.HipHeight / 2)), 0), "HollowCircle", CFrame.new(0, -((Humanoid.HipHeight / 2)), 0), HumanoidRootPart)
	EffectsHandlerModule:ToggleParticleEmitters(HollowCircle, true)
	
	HollowCircle.CanCollide = false
	
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	local tweeningInfo = {}
	tweeningInfo.Transparency = 1
	tweeningInfo.Size = Vector3.new(HollowCircle.Size.X * 2, HollowCircle.Size.Y, HollowCircle.Size.Z * 2)
	
	UtilitiesModule:CancelTween(HollowCircle, TweenDict)
	TweenDict[HollowCircle] = TweenService:Create(HollowCircle, tweenInfo, tweeningInfo)
	
	SoundsModule:PlaySoundEffectById("rbxassetid://8588542238", nil, HollowCircle)
	
	TweenDict[HollowCircle]:Play()
	UtilitiesModule:CompleteTween(HollowCircle, TweenDict)
	
	DebrisModule:AddItem(HollowCircle, EffectInfo["Duration"])
end]]

-- DIRECT
function ThumperPumperModule.Initialise(NilParam, ...)
	return Initialise(...)
end

return ThumperPumperModule