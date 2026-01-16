local TagModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local ObjectsModule = require(ModulesFolder["Objects"])

-- Functions
-- MECHANICS
local function Initialise(OneWayDoorModel)
	-- Functions
	-- INIT
	ObjectsModule:ObjectProcess("SetCollisionGroup", OneWayDoorModel, "OneWayDoors")
end

local function End()
	
end

-- DIRECT
function TagModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function TagModule.End(NilParam, ...)
	return End(...)
end

return TagModule