local GetAllShieldEffectsModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function GetAllShieldEffects()
	-- CORE
	local ShieldEffects = {}
	
	-- Functions
	-- INIT
	for i, Player in pairs(game.Players:GetChildren()) do
		local Character = UtilitiesModule:GetCharacter(Player, true)
		
		if not Character then
			continue
		end
		
		
		table.insert(ShieldEffects, Character:FindFirstChild("ShieldEffect"))
	end
	
	return ShieldEffects
end

-- DIRECT
function GetAllShieldEffectsModule.Initialise(NilParam, CharacterModule)
	return GetAllShieldEffects()
end

return GetAllShieldEffectsModule