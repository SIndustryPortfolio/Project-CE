local AdminModule = {}

-- Dirs
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Info Modules
local AdminInfoModule = require(ServerInfoModulesFolder["Admin"])

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local RequiredModules = {}

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functiosn
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end

local function GetAdminTier(AdminType)
	return AdminInfoModule:GetAdminInfo("Tiers")[AdminType]
end

local function GetPlayerAdminLevel(Player)
	-- Functions
	-- INIT
	local AdminName, AdminTier = nil, nil
	
	for _AdminName, _Tier in pairs(AdminInfoModule:GetAdminInfo("Tiers")) do		
		if table.find(UtilitiesModule:GetDictKeys(AdminInfoModule:GetAdminInfo(_AdminName)), Player.UserId) then
			AdminName = _AdminName
			AdminTier = _Tier
			break
		end
	end
	
	return AdminName, AdminTier
end

local function GetCommandModule(CommandName)
	for ModuleName, Module in pairs(RequiredModules) do
		if string.lower(ModuleName) == CommandName then
			return Module
		end
	end
end

local function CanPlayerExecuteCommand(Player, CommandName)
	-- CORE
	local PlayerAdminType, PlayerAdminTier = GetPlayerAdminLevel(Player)
	
	if not PlayerAdminType then
		DebugModule:Print("Admin | Player is not admin | Player: ".. tostring(Player).. " | CommandName: ".. tostring(CommandName))
		return false
	end
	
	local CommandModule = GetCommandModule(CommandName)
	local CommandRequiredAdminType = CommandModule:GetAdminType()
	local CommandRequiredAdminTier = AdminInfoModule:GetAdminInfo("Tiers")[CommandRequiredAdminType]
	
	-- Functions
	-- INIT
	if CommandRequiredAdminTier > PlayerAdminTier then
		return false
	else
		return true
	end
end

local function ExecuteCommand(Player, CommandName, Args)
	-- Functions
	-- INIT
	local FoundCommandModule = GetCommandModule(CommandName)
	
	if not FoundCommandModule then
		DebugModule:Print("Admin | Cannot find command module! | CommandName: ".. tostring(CommandName))
		return nil
	end
	
	if CanPlayerExecuteCommand(Player, CommandName) then
		local Success, Error = pcall(function()
			return FoundCommandModule:Initialise(AdminModule, Player, Args)
		end)
		
		if not Success then
			DebugModule:Print("Admin | Execute Command | Command: ".. tostring(CommandName).. " | CommandModule: ".. tostring(FoundCommandModule).. " | Args: ".. tostring(Args).. " | Error: ".. tostring(Error))
		end
	else
		DebugModule:Print("Admin | Player: ".. tostring(Player).. " cannot execute command: ".. tostring(CommandName))
	end
end

local function HandleChat(Player, Message)
	-- Functions
	-- INIT
	Message = string.lower(Message)
	
	local Prefix = string.sub(Message, 1, string.len(AdminInfoModule:GetAdminInfo("Prefix")))
	
	if Prefix ~= AdminInfoModule:GetAdminInfo("Prefix") then
		return nil
	end
	
	Message = string.sub(Message, string.len(Prefix) + 1, string.len(Message))
	
	local CommandChunks = string.split(Message, " ")
	
	if not CommandChunks or #CommandChunks < 1 then
		return nil
	end
	
	local CommandName = CommandChunks[1]
	local CommandArgs = {}
	
	for i = 2, #CommandChunks do
		table.insert(CommandArgs, CommandChunks[i])
	end
	
	return ExecuteCommand(Player, CommandName, CommandArgs)
end

local function PlayerAdded(Player)
	-- Functions
	-- DIRECT
	local Connection1 = Player.Chatted:Connect(function(Message)
		HandleChat(Player, Message)
	end)
	
	return {Connection1}
end

local function GetPlayerFromAbbreviation(Abbreviation)
	-- Functions
	-- INIT
	for i, Player in pairs(game.Players:GetChildren()) do
		local PlayerName = string.lower(Player.Name)
		
		if string.sub(PlayerName, 1, string.len(Abbreviation)) == Abbreviation then
			return Player
		end
	end
end

local function GetRecipientsFromString(Player, String)
	-- CORE
	local Recipients = {}
	
	-- Functions	
	-- INIT
	local Abbreviations = nil
	
	if String and typeof(String) == "string" then
		Abbreviations = string.split(string.lower(String), ",")
	end
	
	if not Abbreviations then
		Abbreviations = {String}
	end
	
	--print(Abbreviations)
	
	for i, Abbreviation in pairs(Abbreviations) do
		if Abbreviation == "me" then
			table.insert(Recipients, Player)
		elseif Abbreviation == "all" then
			for i, _Player in pairs(game.Players:GetPlayers()) do
				table.insert(Recipients, _Player)
			end
		elseif Abbreviation == "others" then
			for i, _Player in pairs(game.Players:GetChildren()) do
				if _Player == Player then
					continue
				end
				
				table.insert(Recipients, _Player)
			end
		else
			local _Player = GetPlayerFromAbbreviation(Abbreviation)
			
			if _Player then
				table.insert(Recipients, _Player)
			end
		end
	end
	
	return Recipients
end

local function GetMessageFromArgs(MessageStringChunks, StartIndex)
	-- Functions
	-- INIT
	local String = ""
	
	for i = StartIndex, #MessageStringChunks do
		String = String.. tostring(MessageStringChunks[i])
		
		if i ~= #MessageStringChunks then
			String = String.. " "
		end
	end
	
	return String
end

-- DIRECT
function AdminModule.PlayerAdded(NilParam, Player)
	return PlayerAdded(Player)
end

function AdminModule.GetRecipientsFromString(NilParam, Player, String)
	return GetRecipientsFromString(Player, String)
end

function AdminModule.GetMessageFromArgs(NilParam, MessageStringChunks, StartIndex)
	return GetMessageFromArgs(MessageStringChunks, StartIndex)
end

-- INIT
RunSubModules()

return AdminModule