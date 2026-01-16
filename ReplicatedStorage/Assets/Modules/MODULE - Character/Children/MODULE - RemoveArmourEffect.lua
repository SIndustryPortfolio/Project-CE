local RemoveArmourEffectModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function RemoveArmourEffect(Character)
	-- Functions
	-- INIT
	for i, Part in pairs(Character:GetChildren()) do
		for x, Effect in pairs(Part:GetChildren()) do
			if Effect.Name == "ArmourEffect" then
				Effect:Destroy()
			end
		end
	end
end

-- DIRECT
function RemoveArmourEffectModule.Initialise(NilParam, CharacterModule, Character)
	return RemoveArmourEffect(Character)
end

return RemoveArmourEffectModule