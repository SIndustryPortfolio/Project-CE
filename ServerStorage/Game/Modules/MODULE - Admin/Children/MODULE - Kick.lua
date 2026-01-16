local CommandModule = {}

-- CORE
local AdminType = "Owner"

-- Functions
-- MECHANICS
local function Initialise(AdminModule, Player, Args)
	-- Functions
	-- INIT
	local Recipients = AdminModule:GetRecipientsFromString(Player, Args[1])
	local KickMessage = AdminModule:GetMessageFromArgs(Args, 2)
	
	for i, Recipient in pairs(Recipients) do
		Recipient:Kick(KickMessage.. " | Kicked by: ".. tostring(Player.Name))
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