local DrinkModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function Initialise(Player)
	-- Functions
	-- INIT
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if not Character then
		return nil
	end
	
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	Humanoid:SetAttribute("BaseSpeed", Humanoid:GetAttribute("BaseSpeed") * 1.20)
	
	Humanoid.WalkSpeed = Humanoid:GetAttribute("BaseSpeed")
end

local function End(Player)
	
end

-- DIRECT
function DrinkModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function DrinkModule.End(NilParam, ...)
	return End(...)
end

return DrinkModule