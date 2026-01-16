local CommandModule = {}

-- Dirs
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- CORE
local AdminType = "Owner"

-- Functions
-- MECHANICS
local function Initialise(AdminModule, Player, Args)
	-- Functions
	-- INIT	
	return GameProcessRemote:FireClient(Player, "Admin", "Debug")
end

-- DIRECT
function CommandModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function CommandModule.GetAdminType()
	return AdminType
end


return CommandModule