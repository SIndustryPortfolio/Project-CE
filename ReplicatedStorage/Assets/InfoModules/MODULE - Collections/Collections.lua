local CollectionsInfoModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- InfoModules
local PowerUpsInfoModule = require(InfoModulesFolder["PowerUps"])

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local CollectionsInfo = 
{
	["CollectionsOnStart"] = {"Fusion Coil", "Plasma Battery", "Wooden Pallet", "Window", "Death Zone", "SafeDeathZone", "Sentinel", "Weapons", "Grenades", "AnimatedWeaponCamo", "ThrowGrenade", "MachineGunTurret", "LastManStanding"}		
}

local RequiredModules = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

-- DIRECT
function CollectionsInfoModule.GetAllCollectionItemsInfo()
	return RequiredModules
end

function CollectionsInfoModule.GetCollectionItemInfo(NilParam, ItemName)
	--[[local ItemInfoModule = script:FindFirstChild(ItemName)
	
	if ItemInfoModule then
		return require(ItemInfoModule)	
	end]]
	
	return RequiredModules[ItemName]
end

function CollectionsInfoModule.GetCollectionInfo(NilParam, SettingName)
	return CollectionsInfo[SettingName]	
end

function CollectionsInfoModule.GetCollectionsInfo()
	return CollectionsInfo
end

-- INIT
RunSubModules()

for i, PowerUpName in pairs(UtilitiesModule:GetDictKeys(PowerUpsInfoModule:GetAllPowerUpInfo())) do
	table.insert(CollectionsInfo["CollectionsOnStart"], PowerUpName)
end

return CollectionsInfoModule