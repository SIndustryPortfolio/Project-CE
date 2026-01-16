local ShortcutsModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local GameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local SharedPartsServerWeaponsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]


-- Client
local Player = nil

pcall(function()
	Player = game.Players.LocalPlayer
end)

-- Info Modules
local RanksInfoModule = require(InfoModulesFolder["Ranks"])
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])
local GameModesInfoModule = require(InfoModulesFolder["GameModes"])
local AdsInfoModule = require(InfoModulesFolder["Ads"])
local KeybindsInfoModule = require(InfoModulesFolder["Keybinds"])
local VisorColoursInfoModule = require(InfoModulesFolder["VisorColours"])
local InputsInfoModule = require(InfoModulesFolder["Inputs"])

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local InterfacesModule = nil

if Player then
	InterfacesModule = require(ModulesFolder["Interfaces"])
end

-- Functions
-- MECHANICS
local function GetDeviceSpecificKey(PlayerDeviceName, KeybindName)
	-- Functions
	-- INIT
	--local PlayerDeviceName = Player:GetAttributes()["Device"]

	if PlayerDeviceName == "Mobile" then
		return {Name = "Touch / Tap"}
	elseif PlayerDeviceName ~= "Computer" then
		for i, KeyCode in pairs(KeybindsInfoModule:GetKeybindInfo("Interact")) do
			if table.find(InputsInfoModule:GetInputInfo(PlayerDeviceName), KeyCode) then
				return KeyCode
			end
		end
	else
		for i, KeyCode in pairs(KeybindsInfoModule:GetKeybindInfo("Interact")) do
			local Found = false
			for DeviceName, InputSet in pairs(InputsInfoModule:GetAllInputInfo()) do
				if table.find(InputSet, KeyCode) then
					Found = true
				end
			end

			if not Found then
				return KeyCode
			end
		end
	end
end

local function IsMenuOpen()
	-- CORE
	local ExtraUis = {"DonationPrompt", "Donations", "MOTD", "Intro"}
	local Open = false
	
	-- Functions
	-- INIT
	if InterfacesModule:IsPageOpen("Main", "Menu") then
		local MenuModule = InterfacesModule:GetUiModuleFromType("Main", "Menu")

		if MenuModule then
			if MenuModule:GetState() == "Show" then
				Open = true
			end
		end
	end
	
	for i, UiName in pairs(ExtraUis) do
		if InterfacesModule:IsPageOpen("Custom", UiName) then
			Open = true
		end
	end	
	
	return Open
end


local function GetAllDeadAi()
	-- CORE
	local Dead = {}

	-- Functions
	-- INIT
	for i, AI in pairs(workspace["Temporary"]["AI"]:GetChildren()) do
		local Humanoid = AI:FindFirstChildOfClass("Humanoid")

		if not Humanoid or Humanoid.Health <= 0 then
			table.insert(Dead, AI)
		end
	end

	return Dead
end

local function GetBaseFieldOfView()
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)

	if not Character then
		return 70
	end
	
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	
	if not Humanoid then
		return 70
	end
	
	local Success, FOV = pcall(function()
		if not Character:GetAttributes()["EquippedWeapon"] then
			return 70
		end
		
		local WeaponName = Character:GetAttribute(Character:GetAttribute("EquippedWeapon"))
		
		if not WeaponName then
			return 70
		end
		
		-- Functions
		-- INIT
		if Humanoid:GetAttribute("Ads") then
			return AdsInfoModule:GetAdsInfo(WeaponsInfoModule:GetWeaponInfo(WeaponName)["AdsZoom"])["FieldOfView"]
		else
			return 70
		end
	end)
	
	if not Success then
		return 70
	else
		return FOV
	end
end

local function Ragdollify(Model)
	-- Functions
	-- INIT
	for i, Motor in pairs(Model:GetDescendants()) do
		if not Motor:IsA("Motor6D") then
			continue
		end
		
		local Attachment0, Attachment1 = Instance.new("Attachment"), Instance.new("Attachment")
		Attachment0.CFrame = Motor.C0
		Attachment1.CFrame = Motor.C1
		Attachment0.Parent = Motor.Part0
		Attachment1.Parent = Motor.Part1
		
		local Constraint = Instance.new("BallSocketConstraint")
		Constraint.Radius /= 2
		Constraint.Attachment0 = Attachment0
		Constraint.Attachment1 = Attachment1
		Constraint.LimitsEnabled = true
		Constraint.TwistLimitsEnabled = true
		Constraint.Parent = Motor.Part0
		Motor.Enabled = false
	end
end

local function GetPlayerVisorColour(Player)
	-- CORE
	local EquippedVisorColour = nil
	
	-- Functions
	-- INIT
	local VisorColourFolder = ShortcutsModule:GetPlayerInventoryFolder(Player, "VisorColours")

	if VisorColourFolder:GetAttributes()["Equipped"] and VisorColourFolder:GetAttributes()["Equipped"] ~= "" then
		--EquippedVisorColour = VisorColoursInfoModule:GetVisorColourInfo(VisorColourFolder:GetAttribute("Equipped"))["Colour"]
		EquippedVisorColour = VisorColoursInfoModule:GetInfo(VisorColourFolder:GetAttribute("Equipped"))["Colour"]	
	else
		EquippedVisorColour = BrickColor.new("Bright yellow")
		--EquippedVisorColour = VisorColoursInfoModule:GetVisorColourInfo(VisorColourFolder:GetAttributes()["Equipped"])["Colour"]
		--[[else
			EquippedVisorColour = BrickColor.new("Bright yellow")]]
	end
	
	return EquippedVisorColour
end

local function GetPlayerStatisticValue(Player, Category, Name)
	-- Functions
	-- INIT
	local PlayerStatisticsFolder = UtilitiesModule:WaitForChildTimed(Player, "Statistics")
	local CategoryFolder = UtilitiesModule:WaitForChildTimed(PlayerStatisticsFolder, Category)
	
	return UtilitiesModule:WaitForChildTimed(CategoryFolder, Name)
end

local function GetPlayerRankInfo(Player)
	-- Elements
	-- VALUES
	local RankValue = GetPlayerStatisticValue(Player, "General", "Rank")
	
	-- Functions
	-- INIT
	if RankValue then
		return RanksInfoModule:GetRankInfo(RankValue.Value)
	end
end

local function GetPlayerInventoryFolder(Player, FolderName)
	-- Functions
	-- INIT
	local InventoryFolder = UtilitiesModule:WaitForChildTimed(Player, "Inventory")
	
	return InventoryFolder:FindFirstChild(FolderName)
end

local function GetPlayerInventoryValue(Player, FolderType, ItemName)
	-- Functions
	-- INIT
	local InventoryFolder = GetPlayerInventoryFolder(Player, FolderType)
	
	return InventoryFolder:FindFirstChild(ItemName)
end

local function GetCharacterCoreValueInstance(Player, ValueName)
	-- Functions
	-- INIT
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if not Character then
		return nil
	end
	
	return UtilitiesModule:WaitForChildTimed(Character, "Core")[ValueName]
end

local function GetVehicleModule(VehicleModel, ModuleName)
	-- Elements
	-- FOLDERS
	local VehicleCoreFolder = UtilitiesModule:WaitForChildTimed(VehicleModel, "Core")
	
	return require(UtilitiesModule:WaitForChildTimed(VehicleCoreFolder, ModuleName))
end

local function IsPlayerInLeaderboard(Player, LeaderboardFolder)
	-- Functions
	-- INIT
	for i, IndexFolder in pairs(LeaderboardFolder:GetChildren()) do
		local FoundNumberValue = IndexFolder:FindFirstChildOfClass("NumberValue")
		
		if not FoundNumberValue then
			continue
		end
		
		local UserId = string.sub(FoundNumberValue.Name, string.len("PCESave-") + 1, string.len(FoundNumberValue.Name))
		
		--DebugModule:Print(script.Name.. " | UserId: ".. tostring(UserId).. " | Player User Id: ".. tostring(Player.UserId))
		
		if tostring(UserId) == tostring(Player.UserId) then
			return IndexFolder
		end
	end
end

local function GetPlayerTeamInfo(Player)
	-- Functions
	-- INIT
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(GameFolder:GetAttributes()["GameMode"])
	
	if not GameModeInfo then
		return nil
	end
	
	if not Player then
		return nil
	end
	
	local PlayerTeam = Player.Team
	
	if not PlayerTeam then
		return nil
	end
	
	for i, TeamInfo in pairs(GameModeInfo["Teams"] or {}) do
		if TeamInfo["Name"] == PlayerTeam.Name then
			return TeamInfo
		end
	end
end

local function GetAllDeadCharacters()
	-- CORE
	local DeadCharacters = {}
	
	-- Functions
	-- INIT
	for i, Character in pairs(UtilitiesModule:CombineTables(UtilitiesModule:GetCharacters(), workspace["Temporary"]:GetChildren())) do
		local FoundHumanoid = Character:FindFirstChildOfClass("Humanoid")
		
		if FoundHumanoid and FoundHumanoid.Health <= 0 then
			table.insert(DeadCharacters, Character)
		end
	end
	
	return DeadCharacters
end

local function GetPlayerFromCharacter(TargetCharacter)
	-- Functions
	-- INIT
	local TargetPlayer = game.Players:GetPlayerFromCharacter(TargetCharacter)

	if not TargetPlayer and TargetCharacter.Parent == workspace["Temporary"]["AI"] then
		TargetPlayer = {["Character"] = TargetCharacter, Name = TargetCharacter.Name, Team = {Name = TargetCharacter:GetAttributes()["Team"]}, ["AI"] = true}
	end
	
	return TargetPlayer
end

local function GetAllNoneDevWeaponNames()
	-- Functions
	-- MECHANICS
	local function GetAllNoneBoxWeaponNames()
		-- CORE
		local NoneBoxWeaponNames = {}

		-- Functions
		-- INIT
		for WeaponName, WeaponInfo in pairs(WeaponsInfoModule:GetAllWeaponInfos()) do
			if WeaponInfo and WeaponInfo["DevOnly"] then
				table.insert(NoneBoxWeaponNames, WeaponName)
			end
		end

		return NoneBoxWeaponNames
	end

	-- INIT
	local AllWeaponNames = UtilitiesModule:GetChildrenNames(SharedPartsServerWeaponsFolder)

	for i, WeaponName in pairs(GetAllNoneBoxWeaponNames()) do
		if table.find(AllWeaponNames, WeaponName) then
			table.remove(AllWeaponNames, table.find(AllWeaponNames, WeaponName))
		end
	end
	
	return AllWeaponNames
end

function GetCamera()
	-- Functions
	-- INIT
	return workspace.CurrentCamera
end

-- DIRECT
function ShortcutsModule.GetCamera()
	return GetCamera()
end

function ShortcutsModule.GetAllDeadAi()
	return GetAllDeadAi()
end

function ShortcutsModule.GetAllNoneDevWeaponNames()
	return GetAllNoneDevWeaponNames()
end

function ShortcutsModule.GetPlayerVisorColour(NilParam, ...)
	return GetPlayerVisorColour(...)
end

function ShortcutsModule.GetPlayerFromCharacter(NilParam, ...)
	return GetPlayerFromCharacter(...)
end

function ShortcutsModule.GetDeviceSpecificKey(NilParam, ...)
	return GetDeviceSpecificKey(...)
end

function ShortcutsModule.GetAllDeadCharacters()
	return GetAllDeadCharacters()
end

function ShortcutsModule.GetPlayerTeamInfo(NilParam, Player)
	return GetPlayerTeamInfo(Player)
end

function ShortcutsModule.IsPlayerInLeaderboard(NilParam, Player, LeaderboardFolder)
	return IsPlayerInLeaderboard(Player, LeaderboardFolder)
end

function ShortcutsModule.GetVehicleModule(NilParam, VehicleModel, ModuleName)
	return GetVehicleModule(VehicleModel, ModuleName)
end

function ShortcutsModule.GetCharacterCoreValueInstance(NilParam, Player, ValueName)
	return GetCharacterCoreValueInstance(Player, ValueName)
end

function ShortcutsModule.GetPlayerInventoryValue(NilParam, Player, Type, Name)
	return GetPlayerInventoryValue(Player, Type, Name)
end

function ShortcutsModule.GetPlayerInventoryFolder(NilParam, Player, Type)
	return GetPlayerInventoryFolder(Player, Type)
end

function ShortcutsModule.GetPlayerStatisticValue(NilParam, Player, Category, Name)
	return GetPlayerStatisticValue(Player, Category, Name)
end

function ShortcutsModule.GetPlayerRankInfo(NilParam, Player)
	return GetPlayerRankInfo(Player)
end

function ShortcutsModule.Ragdollify(NilParam, Model)
	return Ragdollify(Model)
end
	
function ShortcutsModule.GetBaseFieldOfView()
	return GetBaseFieldOfView()
end

function ShortcutsModule.IsMenuOpen()
	return IsMenuOpen()
end

return ShortcutsModule