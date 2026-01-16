local HealModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Info Modules
local ObjectsInfoModule = require(SharedInfoModulesFolder["Objects"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DamageModule = require(ServerModulesFolder["Damage"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function Initialise(Player, HealthModel)
	--DebugModule:Print"Healing Player : ".. tostring(Player).. " | Health Model: ".. tostring(HealthModel))
	
	if typeof(HealthModel) == "table" then
		for i, v in pairs(HealthModel) do
			--DebugModule:Print"i: ".. tostring(i).. " | v: ".. tostring(v))
		end
		
		return nil
	end
	
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	local ObjectInfo = ObjectsInfoModule:GetObjectInfo(HealthModel.Name)
	
	if not Character or not ObjectInfo then
		return nil
	end
	
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	-- Functions
	-- INIT
	
	if Humanoid.Health ~= Humanoid.MaxHealth or (Humanoid:GetAttribute("Shield") <= 0 and Humanoid:GetAttribute("MaxShield") > 0) then
		Humanoid.Health = Humanoid.Health + (Humanoid.MaxHealth * ObjectInfo["HealthUpPercentage"])
		DamageModule:RemoveAssistTable(Character)
		
		--UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess"):FireClient(Player, "Heal")
		local CharacterHealthModule = require(UtilitiesModule:GetPlayerCharacterModule(Player, "Server", "Health"))
		
		if CharacterHealthModule then
			CharacterHealthModule:ForceHeal()
			
			UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess"):FireClient(Player, "Console", "Core", nil, "Picked up Health Pack!")
		end
		
		return true
	end
	
	return false
end

-- DIRECT
function HealModule.Initialise(NilParam, ObjectsModule, Player, HealthModel)
	return Initialise(Player, HealthModel)
end

function HealModule.End()
	
end

return HealModule