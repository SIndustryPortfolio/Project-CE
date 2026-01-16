local TeleportedModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- Functions
-- MECHANICS
local function Initialise(SoundType, SoundName)
	-- Functions
	-- INIT
	local HudUiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	if HudUiModule then
		HudUiModule:HudProcess("Teleport", "Teleport")
	end
end

local function GarbageCollect()
	-- Functions
	-- INIT
	ModulesFolder = nil
	--
	InterfacesModule = nil
	
end

-- DIRECT
function TeleportedModule.Initialise()
	Initialise()
end

function TeleportedModule.GarbageCollect()
	GarbageCollect()
end

return TeleportedModule