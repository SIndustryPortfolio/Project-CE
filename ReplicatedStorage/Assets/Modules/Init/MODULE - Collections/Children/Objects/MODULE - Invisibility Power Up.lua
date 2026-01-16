local TagModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Client
local Player = game.Players.LocalPlayer

-- Modules
local SoundsModule = require(ModulesFolder["Sounds"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- Functions
-- MECHANICS
local function Initialise(Character)	
	-- CORE
	if Character ~= UtilitiesModule:GetCharacter(Player) then
		return nil
	end
	
	local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	-- Functions
	-- INIT
	if not HudGuiModule then
		return nil
	end
	
	HudGuiModule:HudProcess("PowerUps", "Add", script.Name)
end

function End(Character)
	-- CORE
	local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	-- Functions
	-- INIT
	if not HudGuiModule then
		return nil
	end
	
	HudGuiModule:HudProcess("PowerUps", "Remove", script.Name)
end

-- DIRECT
function TagModule.Initialise(NilParam, Character)
	return Initialise(Character)
end

function TagModule.End(NilParam, Character)
	return End(Character)
end

return TagModule