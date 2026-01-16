local PickupPowerUpModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Elements
-- REMOTES
local EffectProcess = ClientServerRemotesFolder["EffectProcess"]

-- Info Modules
local PowerUpsInfoModule = require(InfoModulesFolder["PowerUps"])
local ObjectsInfoModule = require(InfoModulesFolder["Objects"])

-- Modules
local ObjectsModule = require(ServerModulesFolder["Objects"])
local DamageModule = require(ServerModulesFolder["Damage"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])
local DebrisModule = require(ModulesFolder["Debris"])
local SoundsModule = require(ModulesFolder["Sounds"])
local PowerUpsModule = require(ServerModulesFolder["PowerUps"])

-- CORE
local PowerUpsBeingPickedUp = {}

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function PickupPowerUp(CharacterActionsModule, Player, PowerUpModel)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player)
	
	if not Character or not PowerUpModel or DamageModule:IsPlayerDead(Player) or table.find(PowerUpsBeingPickedUp, PowerUpModel) or typeof(PowerUpModel) ~= "Instance" then
		return nil
	end
	
	table.insert(PowerUpsBeingPickedUp, PowerUpModel)
	
	local ObjectInfo = ObjectsInfoModule:GetObjectInfo("Power Up")
	
	-- Functions
	-- INIT
	local PowerUpName = PowerUpModel.Name
	EffectProcess:FireAllClients("ToggleParticleEmitters", PowerUpModel, false)
	ObjectsModule:ObjectProcess("Respawn", PowerUpModel, "Power Up")
	CollectionService:AddTag(PowerUpModel, "PowerUpCollected")
	--
	if ObjectInfo and ObjectInfo["CollectSound"] ~= nil then
		----DebugModule:Print"Playing pickup sound")
		SoundsModule:PlaySoundEffectById(ObjectInfo["CollectSound"], nil, UtilitiesModule:GetPartToShift(PowerUpModel), nil, nil, "Power Up Collected", nil, nil)
	end
	--
	DebrisModule:AddItem(PowerUpModel, 1)
	UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess"):FireClient(Player, "Console", "Core", nil, "Picked up ".. tostring(PowerUpModel.Name).. "!")

	PowerUpsModule:ApplyPowerUp(Character, PowerUpName)
	
	coroutine.wrap(function()
		task.wait(PowerUpsInfoModule:GetPowerUpInfo(PowerUpName)["Duration"])
		
		PowerUpsModule:EndPowerUp(Character, PowerUpName)
		
		table.remove(PowerUpsBeingPickedUp, table.find(PowerUpsBeingPickedUp, PowerUpModel))
	end)()
end

-- DIRECT
function PickupPowerUpModule.Initialise(NilParam, ...)
	return PickupPowerUp(...)
end

function PickupPowerUpModule.End()
	-- Function
	-- INIT
	PowerUpsBeingPickedUp = {}
end

return PickupPowerUpModule