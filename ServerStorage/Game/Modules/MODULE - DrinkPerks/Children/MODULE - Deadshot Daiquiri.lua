local DrinkModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function Initialise(Player)
	
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