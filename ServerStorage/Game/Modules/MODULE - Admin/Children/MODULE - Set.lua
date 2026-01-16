local CommandModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedLobbyFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Lobby"]

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local AdminType = "Owner"

-- Functions
-- MECHANICS
local function GetAttributeNameFromAbbreviation(_Instance, Abbreviation)
	-- Functions
	-- INIT
	for AttributeName, AttributeValue in pairs(_Instance:GetAttributes()) do
		if string.lower(string.sub(AttributeName, 1, string.len(Abbreviation))) == Abbreviation then
			return AttributeName
		end
	end
end

local function Initialise(AdminModule, Player, Args)
	-- Functions
	-- INIT
	local Recipients = AdminModule:GetRecipientsFromString(Player, Args[1])
	
	for i, Recipient in pairs(Recipients) do
		local PlayerLobbyValue = SharedLobbyFolder:FindFirstChild(Recipient.Name)
		
		if not PlayerLobbyValue then
			continue
		end
		
		local AttributeName = GetAttributeNameFromAbbreviation(PlayerLobbyValue, Args[2])
		local AttributeValue = AdminModule:GetMessageFromArgs(Args, 3)
		
		DebugModule:Print(script.Parent.Name.. " | ".. script.Name.. " | Attribute Name: ".. tostring(AttributeName).. " | Attribute Value: ".. tostring(AttributeValue))
		
		local PreviousAttributeType = typeof(PlayerLobbyValue:GetAttribute(AttributeName))
		
		if PreviousAttributeType == "string" then
			AttributeValue = tostring(AttributeValue)
		elseif PreviousAttributeType == "number" then
			AttributeValue = tonumber(AttributeValue)
		end
		
		PlayerLobbyValue:SetAttribute(AttributeName, AttributeValue)
	end
end

-- DIRECT
function CommandModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function CommandModule.GetAdminType()
	return AdminType
end

return CommandModule