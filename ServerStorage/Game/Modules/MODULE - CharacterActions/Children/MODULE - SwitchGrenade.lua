local SwitchGrenadeModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Info Modules
local GrenadesInfoModule = require(SharedInfoModulesFolder["Grenades"])

-- Modules
local SoundsModule = require(SharedModulesFolder["Sounds"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DamageModule = require(ServerModulesFolder["Damage"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function SwitchGrenade(CharacterActionsModule, Player, GrenadeVariant)
	-- Functions
	-- INIT
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if not Character then
		return nil
	end
	
	if not table.find(GrenadesInfoModule:GetGrenadeSetting("GrenadeOrder"), GrenadeVariant) then
		return nil
	end
	
	Character:SetAttribute("EquippedGrenade", GrenadeVariant)
end

-- DIRECT
function SwitchGrenadeModule.Initialise(NilParam, ...)
	return SwitchGrenade(...)
end

return SwitchGrenadeModule