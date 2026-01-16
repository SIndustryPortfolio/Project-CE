local IsCharacterDeadModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function IsCharacterDead(Character)
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	-- Functions
	-- INIT
	if Humanoid.Health <= 0 then
		return true
	else
		return false
	end
end

-- DIRECT
function IsCharacterDeadModule.Initialise(NilParam, CharacterModule, Character)
	return IsCharacterDead(Character)
end

return IsCharacterDeadModule