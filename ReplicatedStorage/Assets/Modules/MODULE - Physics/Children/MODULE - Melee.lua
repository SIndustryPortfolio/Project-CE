local MeleeModule = {}

-- Dirs
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Elements
-- REMOTES
local PhysicsRemote = ClientServerRemotesFolder["PhysicsRemote"]

-- Functions
-- MECHANICS
local function MeleeEffect(SessionId, PartToShift, raycastResult)
	-- Functions
	-- INIT
	
	
	return true
end

-- DIRECT
function MeleeModule.Initialise(NilParam, SessionId, PartToShift, raycastResult)
	return MeleeEffect(SessionId, PartToShift, raycastResult)
end

return MeleeModule