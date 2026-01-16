local CommandModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local AdminType = "Owner"

-- Functions
-- MECHANICS
local function Initialise(AdminModule, Player, Args)
	-- Functions
	-- INIT
	local Recipients = AdminModule:GetRecipientsFromString(Player, Args[1])
	
	for i, Recipient in pairs(Recipients) do
		local RecipientCharacter = UtilitiesModule:GetCharacter(Recipient, true)
		
		if not RecipientCharacter then
			continue
		end
		
		local Humanoid = UtilitiesModule:WaitForChildOfClass(RecipientCharacter, "Humanoid")
		
		Humanoid.Health = 0
		--Humanoid:TakeDamage(Humanoid.MaxHealth)
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