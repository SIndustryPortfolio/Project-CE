local CustomPowerUpModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]

-- Info Modules
local CharacterInfoModule = require(SharedInfoModulesFolder["Character"])
local ServerCharacterInfoModule = require(ServerInfoModulesFolder["Character"])
local PowerUpsInfoModule = require(SharedInfoModulesFolder["PowerUps"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function Initialise(Character)
	-- Core
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	-- Functions
	-- INIT
	if Humanoid:GetAttribute("Crouch") then
		Humanoid.WalkSpeed = PowerUpsInfoModule:GetPowerUpInfo(script.Name)["WalkSpeed"] * CharacterInfoModule:GetCharacterInfo("CrouchSpeedMultiplier")
	else
		Humanoid.WalkSpeed = PowerUpsInfoModule:GetPowerUpInfo(script.Name)["WalkSpeed"]
	end
end

local function End(Character)
	-- Core
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")

	-- Functions
	-- INIT
	if Humanoid:GetAttribute("Crouch") then
		Humanoid.WalkSpeed = ServerCharacterInfoModule:GetCharacterInfo("Default")["Humanoid"]["WalkSpeed"] * CharacterInfoModule:GetCharacterInfo("CrouchSpeedMultiplier")
	else
		Humanoid.WalkSpeed = ServerCharacterInfoModule:GetCharacterInfo("Default")["Humanoid"]["WalkSpeed"]
	end
end

-- DIRECT
function CustomPowerUpModule.Initialise(NilParam, Character)
	return Initialise(Character)
end

function CustomPowerUpModule.End(NilParam, Character)
	return End(Character)
end

return CustomPowerUpModule