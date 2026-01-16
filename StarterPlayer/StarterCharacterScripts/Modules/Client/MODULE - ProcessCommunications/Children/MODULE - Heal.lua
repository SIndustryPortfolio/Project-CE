local HealModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- Functions
-- MECHANICS
local function Initialise()
	-- Functions
	-- INIT
	local HudModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	if not HudModule then
		return nil
	end
	
	HudModule:HudProcess("HealthBar", "Heal")
end

local function GarbageCollect()
	-- Functions
	-- INIT
	ModulesFolder = nil
	--
	InterfacesModule = nil
	
end

-- DIRECT
function HealModule.Initialise()
	Initialise()
end

function HealModule.GarbageCollect()
	GarbageCollect()
end

return HealModule