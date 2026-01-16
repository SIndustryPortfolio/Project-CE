local CharacterActionsModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local SharedPartsWeaponsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]
local ServerStarterCharacterFolder = game:GetService("ServerStorage"):WaitForChild("Game")["StarterCharacter"]
local StarterCharacterScripts = game:GetService("StarterPlayer"):WaitForChild("StarterCharacterScripts")

local ServerSignalsFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Signals"]

-- InfoModules
local CharacterActionsInfoModule = require(ServerInfoModulesFolder["CharacterActions"])
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])

-- Modules
local SoundsModule = require(SharedModulesFolder["Sounds"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- Elements
-- SIGNALS
local CharacterActionsSignal = ServerSignalsFolder["CharacterActions"]

-- CORE
local RequiredModules = {}

-- Functions
-- MECHANICS
local function RubSubModules()
	-- Functions
	-- INIT
	for i, Module in pairs(script:GetChildren()) do
		local Success, RequiredModule = pcall(function()
			return require(Module)
		end)
		
		if not Success then
			--DebugModule:PrintRequiredModule, "Error")
		else
			RequiredModules[Module.Name] = RequiredModule
		end
	end
end

--[[local function GetGunModel(WeaponName)
	return UtilitiesModule:WaitForChildTimed(SharedPartsWeaponsFolder, WeaponName):Clone()
end]]

local function GetPlayerGunModel(Player, WeaponName)
	return UtilitiesModule:WaitForChildTimed(Player:WaitForChild("Backpack"), WeaponName)
end

--[[local function GetCharacter(Player)
	return Player.Character or Player.CharacterAdded:Wait()
end]]

local function GetPlayerCharacterSignal(Player, SignalName)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if not Character then
		return nil
	end
	
	-- Elements
	-- FOLDERS
	local CharacterClientServerSignalsFolder = UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(Character, "Remotes"), "ClientServer"), "Signals")
	
	-- Functions
	-- INIT
	return UtilitiesModule:WaitForChildTimed(CharacterClientServerSignalsFolder, SignalName)
end

local function CharacterAction(ActionName, Player, ...)
	-- Functions
	-- INIT
	--DebugModule:Print("CharacterActions | Character Action | Action: ".. tostring(ActionName).. " | Player: ".. tostring(Player).. " | Args: ".. tostring({...}))
	
	local Args = {...}
	
	DebugModule:Print("Character Action | ActionName: ".. tostring(ActionName).. " | Player: ".. tostring(Player).. " | Args: ".. tostring(Args))
	
	local Success, Error = pcall(function()
		
		--local RequiredModule = require(UtilitiesModule:WaitForChildTimed(script, ActionName))
		local RequiredModule = RequiredModules[ActionName]
		
		if RequiredModule and RequiredModule.Initialise ~= nil then
			return RequiredModule:Initialise(CharacterActionsModule, Player, unpack(Args))
		end
	end)
	
	if Success then
		return Error
	else
		DebugModule:Print(script.Name.. " | CharacterAction | Error: ".. tostring(Error))
		--DebugModule:PrintError, "Error")
	end
end

local function End(FunctionName, ...)
	-- Functions
	-- INIT
	RequiredModules[FunctionName]:End(...)
end

local function InitialiseCharacter(Character)
	-- Functions
	-- INIT
	for i, _Instance in pairs(StarterCharacterScripts:GetChildren()) do
		if not Character:FindFirstChild(_Instance.Name) then
			local InstanceClone = _Instance:Clone()
			InstanceClone.Parent = Character
		end
	end
	
	--[[for i, Part in pairs(Character:GetChildren()) do
		if not Part:IsA("BasePart") then
			continue
		end
		
		local ArmourEffectFolder = Instance.new("Folder")
		ArmourEffectFolder.Name = "ArmourEffect"
		ArmourEffectFolder.Parent = Part
	end]]
end

local function CharacterSpawned(Character)
	-- Functions
	-- INIT
	for i, _Instance in pairs(ServerStarterCharacterFolder:GetChildren()) do
		if not Character:FindFirstChild(_Instance.Name) then
			local InstanceClone = _Instance:Clone()
			InstanceClone.Parent = Character
		end
	end
end

local function onCharacterActionRequest(Type, ...)
	-- Functions
	-- INIT
	
	if Type == "CharacterAction" then
		return CharacterAction(...)
	elseif Type == "InitialiseCharacter" then
		return CharacterActionsModule:InitialiseCharacter(...)
	elseif Type == "CharacterSpawned" then
		return CharacterActionsModule:CharacterSpawned(...)
	end
end

local function Initialise()
	-- Functions
	-- INIT
	CharacterActionsSignal.OnInvoke = onCharacterActionRequest
end

-- DIRECT
function CharacterActionsModule.GetPlayerCharacterSignal(NilParam, Player, SignalName)
	return GetPlayerCharacterSignal(Player, SignalName)
end

function CharacterActionsModule.GetPlayerGunModel(NilParam, Player, WeaponName)
	return GetPlayerGunModel(Player, WeaponName)
end

function CharacterActionsModule.CharacterSpawned(NilParam, Character)
	return CharacterSpawned(Character)
end

function CharacterActionsModule.InitialiseCharacter(NilParam, Character)
	return InitialiseCharacter(Character)
end

-- CALLS
function CharacterActionsModule.End(NilParam, FunctionName, ...)
	return End(FunctionName, ...)
end

function CharacterActionsModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return CharacterAction(FunctionName, Player, ...)
end

--[[function CharacterActionsModule.Reload(NilParam, Player)
	return Reload(Player)
end

function CharacterActionsModule.Melee(NilParam, Player, raycastResult)
	return Melee(Player, raycastResult)
end

function CharacterActionsModule.SwitchWeapon(NilParam, Player, WeaponType)
	return SwitchWeapon(Player, WeaponType)
end

function CharacterActionsModule.EquipWeapon(NilParam, Player, WeaponName)
	return EquipPlayerGun(Player, WeaponName)
end]]

-- INIT
Initialise()
RubSubModules()

return CharacterActionsModule