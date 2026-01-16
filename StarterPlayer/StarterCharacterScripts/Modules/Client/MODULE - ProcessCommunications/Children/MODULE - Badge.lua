local BadgeModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- Functions
-- MECHANICS
local function Initialise(Type, Name)
	-- Functions
	-- INIT
	local RequiredModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	if not RequiredModule then
		return nil
	end
	
	RequiredModule:HudProcess("Badges", "Add", Type, Name)
end

local function GarbageCollect()
	-- Functions
	-- INIT
	ModulesFolder = nil
	--
	UtilitiesModule = nil
	InterfacesModule = nil
	
end

-- DIRECT
function BadgeModule.Initialise(NilParam, Type, Name)
	Initialise(Type, Name)
end

function BadgeModule.GarbageCollect()
	GarbageCollect()
end

return BadgeModule