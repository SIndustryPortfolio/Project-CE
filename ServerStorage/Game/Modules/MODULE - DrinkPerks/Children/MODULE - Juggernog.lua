local DrinkModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]

-- Info Modules
local CharacterInfoModule = require(ServerInfoModulesFolder["Character"])	

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function Initialise(Player)
	-- CORE
	local CharacterInfo = CharacterInfoModule:GetCharacterInfo("Default")
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	-- Functions
	-- INIT
	if not Character then
		return nil
	end
	
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	--Humanoid:SetAttribute("MaxShield", Humanoid:GetAttribute("MaxShield") * 2)
	Humanoid:SetAttribute("MaxShield", CharacterInfo["Humanoid"]["MaxShield"] * 2)
	--Humanoid.MaxHealth *= 2
	Humanoid.MaxHealth = CharacterInfo["Humanoid"]["MaxHealth"] * 2
	
	Humanoid:SetAttribute("Shield", Humanoid:GetAttribute("MaxShield"))
	Humanoid.Health = Humanoid.MaxHealth	
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