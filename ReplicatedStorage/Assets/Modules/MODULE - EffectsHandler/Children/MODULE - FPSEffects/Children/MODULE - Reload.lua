local ReloadModule = {}

-- Dirs
--local Character = nil --script.Parent.Parent.Parent.Parent.Parent

-- Client
local LocalPlayer = game.Players.LocalPlayer

-- EXT
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local SoundsModule = require(ModulesFolder["Sounds"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local Connections = {}

-- Functions
-- MECHANICS
local function Reload(Character, WeaponModel)
	-- CORE
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponModel.Name)
	local Player = game.Players:GetPlayerFromCharacter(Character)
	
	-- Functions
	-- INIT
	if Player == LocalPlayer then
		return nil
	end
	local ReloadSoundProperty = nil
	
	if Character["Drinks"]:FindFirstChild("Speed Cola") then
		ReloadSoundProperty = {["PlaybackSpeed"] = 2}
	end
	
	SoundsModule:PlaySoundEffectById(WeaponInfo["ReloadSound"], nil, UtilitiesModule:GetPartToShift(WeaponModel), nil, ReloadSoundProperty)
end

-- DIRECT
function ReloadModule.Initialise(NilParam, EffectsHandlerModule, Character, WeaponModel)
	return Reload(Character, WeaponModel)
end

function ReloadModule.End()
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections)
end

return ReloadModule