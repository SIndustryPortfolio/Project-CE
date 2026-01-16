local UpdatePingModule = {}

-- Functions
-- MECHANICS
local function UpdatePing(Player, TimeSent)
	-- CORE
	local Ping = math.floor((tick() - TimeSent) * 1000)
	
	-- Functions
	-- INIT
	Player:SetAttribute("Ping", math.clamp(Ping, 0, math.huge))
	
	return Ping
end

-- DIRECT
function UpdatePingModule.Initialise(NilParam, Player, TimeSent)
	return UpdatePing(Player, TimeSent)
end

return UpdatePingModule