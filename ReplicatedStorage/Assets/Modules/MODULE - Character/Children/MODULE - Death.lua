local DeathModule = {}

-- Functions
-- MECHANICS
local function UnCanCollideCharacter(CharacterModel)
	-- Functions
	-- INIT
	for i, Part in pairs(CharacterModel:GetDescendants()) do
		if not Part:IsA("BasePart") then
			continue
		end
		
		if Part ~= CharacterModel.PrimaryPart then
			Part.CanCollide = false
		end
	end
end

local function Initialise(CharacterModel)
	-- Functions
	-- INIT
	UnCanCollideCharacter(CharacterModel)
end

-- DIRECT
function DeathModule.Initialise(NilParam, CharacterModule, CharacterModel)
	return Initialise(CharacterModel)
end

return DeathModule