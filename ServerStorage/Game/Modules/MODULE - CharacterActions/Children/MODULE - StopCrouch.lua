local StopCrouchModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Info Modules
local GameModesInfoModule = require(InfoModulesFolder["GameModes"])
local CharacterInfoModule = require(InfoModulesFolder["Character"])
local ServerCharacterInfoModule = require(ServerInfoModulesFolder["Character"])
local PowerUpsInfoModule = require(InfoModulesFolder["PowerUps"])

-- Modules
local TeamsModule = require(ServerModulesFolder["Teams"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function Crouch(CharacterActionsModule, Player)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player)
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(SharedGameFolder:GetAttribute("GameMode"))

	if not Character then
		return nil
	end

	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")

	-- Functions
	-- INIT
	local DefaultWalkSpeed = ServerCharacterInfoModule:GetCharacterInfo("Default")["Humanoid"]["WalkSpeed"]

	if GameModeInfo and GameModeInfo["Teams"] then
		local PlayerTeam = Player.Team

		if PlayerTeam then
			local TeamInfo = TeamsModule:GetTeamInfo(PlayerTeam)

			if TeamInfo and TeamInfo["Character"] and TeamInfo["Character"]["Humanoid"] and TeamInfo["Character"]["Humanoid"]["WalkSpeed"] then
				DefaultWalkSpeed = TeamInfo["Character"]["Humanoid"]["WalkSpeed"]
			end
		end
	end
	
	if Humanoid:GetAttributes()["BaseSpeed"] then
		DefaultWalkSpeed = Humanoid:GetAttribute("BaseSpeed")
	end
	
	if table.find(CollectionService:GetTags(Character), "Custom Power Up") then
		Humanoid.WalkSpeed = PowerUpsInfoModule:GetPowerUpInfo("Custom Power Up")["WalkSpeed"]
	else
		Humanoid.WalkSpeed = DefaultWalkSpeed 
	end

	--Humanoid.WalkSpeed = Humanoid.WalkSpeed * CharacterInfoModule:GetCharacterInfo("CrouchSpeedMultiplier")
	Humanoid:SetAttribute("Crouch", false)
end

local function End()

end

-- DIRECT
function StopCrouchModule.Initialise(NilParam, ...)
	return Crouch(...)
end

function StopCrouchModule.End()
	return End()
end

return StopCrouchModule