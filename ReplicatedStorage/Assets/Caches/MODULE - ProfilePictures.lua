local ProfilePicturesCache = {}

-- CORE
local ProfilePictures = {}

-- Functions
-- MECHANICS
local function Add(Player)
	-- Functions
	-- INIT
	if not ProfilePictures[Player.UserId] then
		local Success, ProfilePicture = nil
		
		repeat
			Success, ProfilePicture = pcall(function()
				return game.Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
			end)
			task.wait()
		until Success or not Player
		
		if Player then
			ProfilePictures[Player.UserId] = ProfilePicture
		end
	end
	
	return ProfilePictures[Player.UserId]
end

local function Remove(Player)
	-- Functions
	-- INIT
	ProfilePictures[Player.UserId] = nil
end

local function Get(Player)
	-- Functions
	-- INIT
	return ProfilePictures[Player.UserId]
end

-- DIRECT
function ProfilePicturesCache.Get(NilParam, Player)
	return Get(Player)
end

function ProfilePicturesCache.Add(NilParam, Player)
	return Add(Player)
end

function ProfilePicturesCache.Remove(NilParam, Player)
	return Remove(Player)
end

return ProfilePicturesCache