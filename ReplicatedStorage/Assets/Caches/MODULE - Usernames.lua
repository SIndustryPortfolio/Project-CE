local UsernamesCache = {}

-- CORE
local Usernames = {}

-- Functions
-- MECHANICS
local function Add(UserId)
	-- Functions
	-- INIT
	if not Usernames[UserId] then
		local Success, Username = nil, nil
		
		repeat
			Success, Username = pcall(function()
				return game.Players:GetNameFromUserIdAsync(UserId)
			end)
		until Success or Username
		
		Usernames[UserId] = Username
	end
	
	return Usernames[UserId]
end

local function Remove(UserId)
	-- Functions
	-- INIT
	Usernames[UserId] = nil
end

local function Get(UserId)
	-- Functions
	-- INIT
	return Usernames[UserId]
end

-- DIRECT
function UsernamesCache.Get(NilParam, UserId)
	return Get(UserId)
end

function UsernamesCache.Add(NilParam, UserId)
	return Add(UserId)
end

function UsernamesCache.Remove(NilParam, UserId)
	return Remove(UserId)
end

return UsernamesCache