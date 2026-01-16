local ApplyArmourEffectModule = {}

-- Dirs
local ArmourEffectsPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Armours"]["ArmourEffects"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function ApplyArmourEffect(Character, EffectName)
	-- CORE
	local FoundEffectFolder = UtilitiesModule:WaitForChildTimed(ArmourEffectsPartsFolder, EffectName)
	
	-- Functions
	-- INIT
	for i, PartNameFolder in pairs(FoundEffectFolder:GetChildren()) do
		for x, EffectInstance in pairs(PartNameFolder:GetChildren()) do
			local EffectClone = EffectInstance:Clone()
			EffectClone.Name = "ArmourEffect"
			EffectClone.Parent = Character:FindFirstChild(PartNameFolder.Name)
		end
	end
end

-- DIRECT
function ApplyArmourEffectModule.Initialise(NilParam, CharacterModule, Character, EffectName)
	return ApplyArmourEffect(Character, EffectName)
end

return ApplyArmourEffectModule