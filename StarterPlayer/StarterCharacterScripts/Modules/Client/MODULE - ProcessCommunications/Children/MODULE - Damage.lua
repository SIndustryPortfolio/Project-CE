local DamageModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local InterfacesModule = require(ModulesFolder["Interfaces"])
local SettingsModule = require(ModulesFolder["Settings"])

-- Functions
-- MECHANICS
local function LogDamage(Character, Damage, IsHeadShot, DamagedHealth, Position)
	local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	if HudGuiModule and SettingsModule:GetSettingValue("Game", "HitMarker", true) then
		HudGuiModule:HudProcess("Cursor", "Hit")
	end
	
	if SettingsModule:GetSettingValue("Game", "VisualDamage", true) then
		return InterfacesModule:LoadBillboard(Position, "Damage", Damage, IsHeadShot, DamagedHealth)
	end
end

local function GarbageCollect()
	-- Functions
	-- INIT
	ModulesFolder = nil
	--
	InterfacesModule = nil
	SettingsModule = nil
	
end

-- DIRECT
function DamageModule.Initialise(NilParam, ...)
	return LogDamage(...)
end

function DamageModule.GarbageCollect()
	GarbageCollect()
end

return DamageModule