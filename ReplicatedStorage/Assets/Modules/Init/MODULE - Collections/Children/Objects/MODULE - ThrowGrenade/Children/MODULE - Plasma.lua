local GrenadeModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function Initialise(GrenadeModel)
	-- Functions
	-- INIT
	UtilitiesModule:WaitForChildTimed(GrenadeModel, "Base")["Fire"].Enabled = true
end

-- DIRECT
function GrenadeModule.Initialise(NilParam, GrenadeModel)
	return Initialise(GrenadeModel)
end

return GrenadeModule