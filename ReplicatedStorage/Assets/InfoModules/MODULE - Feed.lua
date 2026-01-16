local FeedInfoModule = {}

-- Core
local FeedInfo = 
{  
	["Graze"] = {Colour = Color3.fromRGB(131, 145, 192), Xp = 1},
	["HeadShot"] = {Colour = Color3.fromRGB(52, 52, 52), Xp = 5},
	["Melee"] = {Colour = Color3.fromRGB(85, 170, 127), Xp = 5},
	["Kill"] = {Colour = Color3.fromRGB(85, 85, 255), Xp = 10},
	["Betrayal"] = {Colour = Color3.fromRGB(170, 0, 0), Xp = 0},
	["Badge"] = {Colour = Color3.fromRGB(198, 198, 0)}
	
}

-- Functions
-- DIRECT
function FeedInfoModule.GetFeedInfo(NilParam, SettingName)
	return FeedInfo[SettingName]
end

function FeedInfoModule.GetAllFeedInfo()
	return FeedInfo
end

return FeedInfoModule