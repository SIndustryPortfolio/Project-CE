local CharacterCoreModule = {}

-- Dirs
local ServerModulesInitFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]["Init"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerRemotesFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Remotes"]
local ServerSignalsFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Signals"]


local GameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")

-- Info Modules
local GameModesInfoModule = require(SharedInfoModulesFolder["GameModes"])
local VisorColoursInfoModule = require(SharedInfoModulesFolder["VisorColours"])
local CharacterInfoModule = require(ServerInfoModulesFolder["Character"])

-- Modules
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])
local SoundsModule = require(SharedModulesFolder["Sounds"])
local MainLoopModule = require(ServerModulesInitFolder["MainLoop"])
local CharacterModule = require(SharedModulesFolder["Character"])
local LobbyModule = require(ServerModulesFolder["Lobby"])
local DamageModule = require(ServerModulesFolder["Damage"])
local GameModule = require(ServerModulesFolder["Game"])
local CharacterActionsModule = require(ServerModulesFolder["CharacterActions"])
local TeamsModule = require(ServerModulesFolder["Teams"])
local DebrisModule = require(SharedModulesFolder["Debris"])

-- Elements
-- SIGNALS
local CharacterCoreSignal = ServerSignalsFolder["CharacterCore"]

-- REMOTES
local MainRemote = ServerRemotesFolder["Main"]

-- Functions
-- MECHANICS
local function HandleCharacterModules(Character, End)
	if not Character then
		return nil
	end
	
	-- Elements
	-- FOLDERS
	local CharacterModulesFolder = Character:WaitForChild("Modules")["Server"] --UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(Character, "Modules"), "Server")
	
	--[[if not CharacterModulesFolder then
		while not CharacterModulesFolder and Character and task.wait(.1) do
			CharacterModulesFolder = UtilitiesModule:WaitForChildTimed(UtilitiesModule:WaitForChildTimed(Character, "Modules"), "Server")
			
			if not Character or not game.Players:GetPlayerFromCharacter(Character) then
				break
			end
		end
	end]]
		
	-- CORE
	local LoadedModules = 0
	local ModulesToLoad = #CharacterModulesFolder:GetChildren()
	
	-- Functions
	-- MECHANICS
	local function RunCharacterModule(ModuleInstance)
		-- Functions
		-- INIT
		coroutine.wrap(function()
			local Success, Error = pcall(function()
				--DebugModule:Print"Requiring: ".. tostring(ModuleInstance))
				local RequiredModule = require(ModuleInstance)

				if End then
					if RequiredModule.End ~= nil then
						return RequiredModule:End()
					end
				else
					if RequiredModule.Initialise ~= nil then
						return RequiredModule:Initialise()
					end	
				end
			end)
			
			--[[if ModuleInstance then
				--DebugModule:Print"Finished Loading Server Character Module: ".. tostring(ModuleInstance.Name))
			end]]
			
			LoadedModules += 1
			
			if not Success then
				--print("Error: ".. tostring(Error))
				--DebugModule:PrintError, "Error")
				DebugModule:Print(script.Name.. " | RunCharacterModule | Module: ".. tostring(ModuleInstance).. " | Error: ".. tostring(Error))
			else
				return Error
			end
		end)()
	end

	-- INIT
	if CharacterModulesFolder then
		for i, ModuleInstance in pairs(CharacterModulesFolder:GetChildren()) do
			RunCharacterModule(ModuleInstance)
		end
	end
	
	if not End then
		coroutine.wrap(function()
			repeat
				task.wait()
			until LoadedModules >= ModulesToLoad or not Character
			Character:SetAttribute("ServerLoaded", true)
		end)()
	end
end

local function HandleCharacterProperties(Player, Character)
	-- CORE
	local PlayerTeam = nil 
	
	if Player then
		PlayerTeam = Player.Team
	end
	
	local TeamInfo = nil
	
	if PlayerTeam then
		TeamInfo = TeamsModule:GetTeamInfo(PlayerTeam)
	else
		local CharacterTeam = Character:GetAttributes()["Team"]
		
		if CharacterTeam ~= nil and CharacterTeam ~= "" then
			TeamInfo = TeamsModule:GetTeamInfo(CharacterTeam)
		end
	end
	
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	-- PARTS
	local HumanoidRootPart = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")
	local Neck = UtilitiesModule:WaitForChildTimed(Character:WaitForChild("UpperTorso"), "Neck")
	local Waist = UtilitiesModule:WaitForChildTimed(Character:WaitForChild("LowerTorso"), "Waist")
	
	-- Functions
	-- INSTANCING
	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.Parent = HumanoidRootPart
	
	-- INIT
	if not Character then
		DebugModule:Print(script.Name.." | HandleCharacterProperties | No Character!")
		return nil
	end

	Character.Archivable = true
	
	for PropertyName, PropertyValue in pairs(CharacterInfoModule:GetCharacterInfo("BodyVelocity")) do
		BodyVelocity[PropertyName] = PropertyValue
	end
	
	Character.PrimaryPart.Velocity = Vector3.new(0, 0, 0)
	Character.PrimaryPart.RotVelocity = Vector3.new(0, 0, 0)
	
	--[[for i, Part in pairs(Character:GetDescendants()) do
		if not Part:IsA("BasePart") then
			continue
		end

		Part.Velocity = Vector3.new()
	end]]
	
	local function ProcessProperties(Dict)
		
		if Neck then
			Character:SetAttribute("NeckAnglePosition", Neck.C0.Position)
			Character:SetAttribute("NeckAngleLookVector", -Neck.C0.LookVector)
		end
		
		if Waist then
			Character:SetAttribute("WaistAnglePosition", Waist.C0.Position)
			Character:SetAttribute("WaistAngleLookVector", -Waist.C0.LookVector)
		end
		
		for InstanceName, Properties in pairs(Dict) do
			local Element = nil

			if InstanceName == "Root" then
				Element = Character
			else
				Element = UtilitiesModule:WaitForChildTimed(Character, InstanceName)
			end

			if not Element then
				continue
			end
			
			local ToSkip = {}
			
			for PropertyName, PropertyValue in pairs(Properties) do
				local Lowercase = string.lower(PropertyName)
				
				if not string.find(Lowercase, "max") then
					continue
				end
				
				local Success, Error = pcall(function()
					Element[PropertyName] = PropertyValue
				end)

				if not Success then
					Element:SetAttribute(PropertyName, PropertyValue)
				end
				
				table.insert(ToSkip, PropertyName)
			end

			for PropertyName, PropertyValue in pairs(Properties) do
				if table.find(ToSkip, PropertyName) then
					continue
				end
				
				local Success, Error = pcall(function()
					Element[PropertyName] = PropertyValue
				end)

				if not Success then
					Element:SetAttribute(PropertyName, PropertyValue)
				end
			end
		end
	end
	
	-- INIT
	ProcessProperties(CharacterInfoModule:GetCharacterInfo("Default"))
	
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(GameFolder:GetAttribute("GameMode"))
	
	if GameModeInfo then
		if GameModeInfo["Character"] then
			ProcessProperties(GameModeInfo["Character"])
		end
	end
	
	if TeamInfo and TeamInfo["Character"] then
		ProcessProperties(TeamInfo["Character"])
	end
	
	if Player and PlayerTeam then
		Character:SetAttribute("Team", PlayerTeam.Name)
	end
	
	return true
end

local function OnCharacterDied(Player, Character)
	-- CORE
	local VehicleValue = ShortcutsModule:GetCharacterCoreValueInstance(Player, "Vehicle")
	local DeathSounds = {"Death", "Death2", "Death3"}
	local PlayerDeathsValue = ShortcutsModule:GetPlayerStatisticValue(Player, "General", "Deaths")
	
	-- Elements
	-- PARTS
	local HumanoidRootPart = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")

	-- Functions
	-- INIT
	
	if VehicleValue and VehicleValue.Value then
		CharacterActionsModule:ClientRequest(Player, "UnequipVehicle")
	end
	
	SoundsModule:PlaySoundEffectByName("CharacterActions", DeathSounds[math.random(1, #DeathSounds)], nil, HumanoidRootPart)
	LobbyModule:IncrementValue(Player, "Deaths")
	LobbyModule:DecrementValue(Player, "Lives")
	PlayerDeathsValue.Value += 1	
	GameModule:CustomGameProcess("Kill", "ResetPlayer", Player)
	HandleCharacterModules(Character, true)
	
	MainRemote:Fire("PlayerDied", Player)
	
	ShortcutsModule:Ragdollify(Character)
	DebrisModule:AddItem(Character, 6, {["Parent"] = Character.Parent})
	
	coroutine.wrap(function()
		task.wait(1)
		pcall(function()
			Character:SetAttribute("ServerLoaded", nil)
		end)
		DamageModule:RemoveAssistTable(Character)
	end)()
end

local function OnCharacterAdded(Player, Character)
	--DebugModule:Print"Character Added | Player: ".. tostring(Player).. " | Character: ".. tostring(Character))
	--print("Character Added | Player: ".. tostring(Player).. " | Character: ".. tostring(Character))

	if not Character then
		DebugModule:Print(script.Name.. " | OnCharacterAdded | No Character | Player: ".. tostring(Player))
		return nil
	end

	-- Elements
	-- VALUES
	local VisorColourName = ShortcutsModule:GetPlayerInventoryFolder(Player, "VisorColours"):GetAttributes()["Equipped"]
	local ArmourEffectName = ShortcutsModule:GetPlayerInventoryFolder(Player, "ArmourEffects"):GetAttributes()["Equipped"]
	local HelmetName = ShortcutsModule:GetPlayerInventoryFolder(Player, "Helmets"):GetAttributes()["Equipped"]
	
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	-- PARTS
	local HumanoidRootPart = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPart")
	
	-- FORCE FIELDS
	--local ForceField = UtilitiesModule:WaitForChildOfClass(Character, "ForceField")

	-- Functions
	-- Properties
	Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None

	-- INIT
	if not Humanoid:FindFirstChildOfClass("Animator") then
		Instance.new("Animator", Humanoid)
	end
	
	local Success, Error = pcall(function()
		HandleCharacterProperties(Player, Character)
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | onCharacterAdded | HandleCharacterProperties | Error: ".. tostring(Error).. " | Player: ".. tostring(Player))
	end
	
	if MainLoopModule.CharacterAdded ~= nil then
		MainLoopModule:CharacterAdded(Player, Character)
	end
	
	local Success, Error = pcall(function()
		HandleCharacterModules(Character)
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | onCharacterAdded | HandleCharacterModules | Error: ".. tostring(Error).. " | Player: ".. tostring(Player))
	end

	if Character.Parent ~= workspace then
		DebugModule:Print(script.Name.. " | OnCharacterAdded | Waiting for Character Parent to be workspace | Player: ".. tostring(Player))
		repeat
			task.wait()
		until Character.Parent == workspace
		DebugModule:Print(script.Name.. " | OnCharacterAdded | Finished waiting for Character Parent to be workspace | Player: ".. tostring(Player))
	end

	-- DIRECT
	local Connection1 

	Connection1 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health <= 0 then
			UtilitiesModule:DisconnectConnections({Connection1})
			OnCharacterDied(Player, Character)
		end
	end)

	-- INIT
	local VisorColourInfo = VisorColoursInfoModule:GetInfo(VisorColourName) --VisorColoursInfoModule:GetVisorColourInfo(VisorColourName)
	local VisorColour = nil
	
	if VisorColourInfo then
		VisorColour = VisorColourInfo["Colour"]
	else
		VisorColour = BrickColor.new("Bright yellow")
	end
	
	--HumanoidRootPart.Anchored = true
	local Team = Player.Team
	local TeamInfo = nil
	
	if Team then
		TeamInfo = TeamsModule:GetTeamInfo(Team)
	end
	
	if HelmetName then
		CharacterModule:CharacterProcess("ApplyHelmet", Character, HelmetName)
	end
	
	if Team and TeamInfo and TeamInfo["Colour"] then
		Character:SetAttribute("ColourOverwrite", TeamInfo["Colour"])
		CharacterModule:SetCharacterAppearance(Character, TeamInfo["Colour"].Name, ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "SecondaryColour").Value, VisorColour)
	else
		CharacterModule:SetCharacterAppearance(Character, ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "Colour").Value, ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "SecondaryColour").Value, VisorColour)
	end
	
	if ArmourEffectName then
		CharacterModule:CharacterProcess("ApplyArmourEffect", Character, ArmourEffectName)
	end
	
	coroutine.wrap(function()
		local ForceField = UtilitiesModule:WaitForChildTimed(Character, "ForceField")

		if ForceField then
			ForceField:Destroy()
		end
	end)()
end

local function OnPlayerLeft(Player, Character)
	-- Functions
	-- INIT
	if Character then
		DamageModule:RemoveAssistTable(Character)
	end
end

-- CORE FUNCTIONS
local CoreFunctions = 
{
	["HandleCharacterProperties"] = HandleCharacterProperties
}

-- MECHANICS
local function OnCharacterCoreSignalInvoked(FunctionName, ...)
	-- Functions
	-- INIT
	--DebugModule:Print("FunctionName: ".. tostring(FunctionName))
	return CoreFunctions[FunctionName](...)
end

-- DIRECT
function CharacterCoreModule.HandleCharacterProperties(NilParam, Character)
	return HandleCharacterProperties(nil, Character)
end

function CharacterCoreModule.Initialise(NilParam, Player, Character)
	return OnCharacterAdded(Player, Character)
end

function CharacterCoreModule.End(NilParam, Player, Character)
	return OnPlayerLeft(Player, Character)
end

-- INIT
CharacterCoreSignal.OnInvoke = OnCharacterCoreSignalInvoked

return CharacterCoreModule