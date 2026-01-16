local ShieldDamageModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
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
local function Initialise(EffectsHandlerModule, Character)
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildTimed(Character, "Humanoid")
	
	-- PARTS
	local HumanoidRootPart = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")
	
	-- Functions
	-- INIT
	local ShieldRegenObject = EffectsHandlerModule:LoadParticleEmitter(HumanoidRootPart, "ShieldRegen" --[[, CFrame.Angles(math.rad(180), 0, 0)]])
	
	UtilitiesModule:WeldParts(ShieldRegenObject, HumanoidRootPart)
	
	coroutine.wrap(function()
		EffectsHandlerModule:ToggleParticleEmitters(ShieldRegenObject, true, nil)
		task.wait(0.3)
		EffectsHandlerModule:ToggleParticleEmitters(ShieldRegenObject, false, nil)

		--DebrisService:AddItem(ShieldRegenObject, 3)
		DebrisModule:AddItem(ShieldRegenObject, 3)
	end)()
end

-- DIRECT
function ShieldDamageModule.Initialise(NilParam, EffectsHandlerModule, Character)
	return Initialise(EffectsHandlerModule, Character)
end

return ShieldDamageModule