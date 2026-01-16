local CommandModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local AdminType = "Owner"

local MaxRandomBounds = 3

-- Functions
-- MECHANICS
local function Initialise(AdminModule, Player, Args)
	-- Functions
	-- INIT
	local Recipients = AdminModule:GetRecipientsFromString(Player, Args[1])
	local PlayerCharacter = UtilitiesModule:GetCharacter(Player, true)
	local WalkSpeed = Args[2]
	
	if not PlayerCharacter then
		return nil
	end	

	local PlayerCharacterHumanoidRootPart = PlayerCharacter.PrimarPart

	for i, Recipient in pairs(Recipients) do
		local RecipientCharacter = UtilitiesModule:GetCharacter(Recipient, true)

		if not RecipientCharacter then
			continue
		end
		
		local Humanoid = UtilitiesModule:WaitForChildOfClass(RecipientCharacter, "Humanoid")
		
		Humanoid.WalkSpeed = WalkSpeed
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