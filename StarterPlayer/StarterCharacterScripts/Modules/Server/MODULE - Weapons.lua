local WeaponsModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent

-- EXT
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedWeaponsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local ServerWeaponsModule = require(ServerModulesFolder["Weapons"])
local CharacterActionsModule = require(ServerModulesFolder["CharacterActions"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- Functions
-- MECHANICS
local function GetWeaponModel(WeaponName)
	-- Functions
	-- INIT
	if not WeaponName or WeaponName == "" then
		return nil
	end
	
	--if WeaponName ~= "Random" then
		return UtilitiesModule:WaitForChildTimed(SharedWeaponsFolder, WeaponName):Clone()
	--else
	--	return SharedWeaponsFolder:GetChildren()[math.random(1, #SharedWeaponsFolder:GetChildren())]:Clone()
	--end
end

local function Initialise()
	-- CORE
	local Player = game.Players:GetPlayerFromCharacter(Character)
	
	-- Functions
	-- INIT
	--[[repeat
		task.wait()
	until not Player or (Player.Character and Player.Character.Parent == workspace)
	
	task.wait()]]
	
	repeat
		task.wait()
	until (not table.find({nil, ""}, Character:GetAttributes()["Primary"]) and not table.find({nil, ""}, Character:GetAttributes()["Secondary"]) and Character.Parent == workspace)
	
	local PrimaryWeaponModel = GetWeaponModel(Character:GetAttribute("Primary"))
	local SecondaryWeaponModel = GetWeaponModel(Character:GetAttribute("Secondary"))
	
	if not Player then
		return nil
	end
	
	if PrimaryWeaponModel then
		local Success, Error = pcall(function()
			ServerWeaponsModule:InitialiseWeapon(PrimaryWeaponModel, Player)
		end)
		
		if not Success then
			DebugModule:Print("Character | ".. script.Name.. " | PrimaryWeaponModel: ".. tostring(PrimaryWeaponModel).. " | Error: ".. tostring(Error))
		end
		
		PrimaryWeaponModel.Parent = Player:WaitForChild("Backpack")
		--Character:SetAttribute("Primary", PrimaryWeaponModel.Name)
	end
	
	if SecondaryWeaponModel then
		local Success, Error = pcall(function()
			DebugModule:Print("Character | ".. script.Name.. " | SecondaryWeaponModel | Initialising Weapon: ".. tostring(SecondaryWeaponModel))
			ServerWeaponsModule:InitialiseWeapon(SecondaryWeaponModel, Player)
			DebugModule:Print("Character | ".. script.Name.. " | SecondaryWeaponModel | Finished Initialising Weapon: ".. tostring(SecondaryWeaponModel))
		end)
		
		if not Success then
			DebugModule:Print("Character | ".. script.Name.. " | SecondaryWeaponModel: ".. tostring(SecondaryWeaponModel).. " | Error: ".. tostring(Error))
		end
		
		SecondaryWeaponModel.Parent = Player:WaitForChild("Backpack")
		--Character:SetAttribute("Secondary", SecondaryWeaponModel.Name)
		CharacterActionsModule:ClientRequest(Player, "UnequipGun", SecondaryWeaponModel)
	end
end

local function GarbageCollect()
	-- Functions
	-- INIT
	Character = nil
	--
	ServerModulesFolder = nil
	SharedModulesFolder = nil
	SharedWeaponsFolder = nil
	--
	UtilitiesModule = nil
	ServerWeaponsModule = nil
	
end

-- DIRECT
function WeaponsModule.Initialise()
	-- Functions
	-- INIT
	Initialise()
end

function WeaponsModule.GarbageCollect()
	GarbageCollect()
end

return WeaponsModule