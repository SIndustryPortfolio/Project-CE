local KillStreaksInfoModule = {}

-- CORE
local RapidKillStreaks = 
{
		[2] = {Xp = 10, Name = "Double Kill",  Image = {Id = "rbxassetid://8696386161"}, Sound = {Id = "rbxassetid://11882613861"} --[[{Id = "rbxassetid://5404338660", FromTime = 38, EndTime = 39.5}]]}, --SoundId = "rbxassetid://151710118"},
		[3] = {Xp = 25, Name = "Triple Kill", Image = {Id = "rbxassetid://8696385595"}, Sound = {Id = "rbxassetid://11882613913"} --[[{Id = "rbxassetid://5404338660", FromTime = 39, EndTime = 40.5}]]},--SoundId = "rbxassetid://151710120"},
		[4] = {Xp = 50, Name = "Over Kill", Image = {Id = "rbxassetid://8696385756"}, Sound = {Id = "rbxassetid://11882613519"} --[[, FromTime = 40, EndTime = 41.5}]]},
		[5] = {Xp = 75, Name = "Killtacular",Image = {Id = "rbxassetid://8696385968"}, Sound = {Id = "rbxassetid://11882613250"} --[[, FromTime = 42.8, EndTime = 45}]]},
		[6] = {Xp = 100, Name = "Killtrocity", Image = {Id = "rbxassetid://11644467161"}, Sound = {Id = "rbxassetid://11882613796"}},
		[7] = {Xp = 125, Name = "Killmanjaro", Image = {Id = "rbxassetid://11644467640"}, Sound = {Id = "rbxassetid://11882613632"}},
		[8] = {Xp = 150, Name = "Killtastrophe", Image = {Id = "rbxassetid://11644467298"}, Sound = {Id = "rbxassetid://11882613418"}},
		[9] = {Xp = 175, Name = "Killpocalypse", Image = {Id = "rbxassetid://11644467511"}, Sound = {Id = "rbxassetid://11882613344"}},
		[10] = {Xp = 200, Name = "Killionaire", Image = {Id = "rbxassetid://11644468715"}, Sound = {Id = "rbxassetid://11882613716"}}
}

local GenericKillStreaks = 
{
	["FromTheGrave"] = {Image = {Id = "rbxassetid://10190175148"}},
	["Melee"] = {Image = {Id = "rbxassetid://8696386323"}},
	["KillJoy"] = {Name = "KillJoy", Image = {Id = "rbxassetid://8701896031"}, Sound = {Id = "rbxassetid://11882656011"} --[[, FromTime = 36, EndTime = 38.5}]]},
	["Assist"] = {Name = "Assist", Image = {Id = "rbxassetid://8831813963"}},
	["HeadCase"] = {Name = "Head Case", Image = {Id = "rbxassetid://8833182190"}},
	["SniperHeadshot"] = {Name = "Snipe", Image = {Id = "rbxassetid://10966183571"}},	
	["Explosion"] = {Name = "Explosive", Image = {Id = "rbxassetid://9998712932"}},
	["Stuck"] = {Name = "Stuck", Image = {Id = "rbxassetid://10938108225"}},
	["Beatdown"] = {Name = "Beatdown", Image = {Id = "rbxassetid://10946954874"}},
	[5] = {Xp = 25, Name = "Killing Spree", Image = {Id = "rbxassetid://8701896171"}, Sound = {Id = "rbxassetid://11882616028"} --[[, FromTime = 44, EndTime = 45}]]},
	[10] = {Xp = 50, Name = "Killing Frenzy", Image = {Id = "rbxassetid://8701896319"}, Sound = {Id = "rbxassetid://11882615706"} --[[, FromTime = 53, EndTime = 54.5}]]},
	[15] = {Xp = 75, Name = "Running Riot", Image = {Id = "rbxassetid://8701895760"}, Sound = {Id = "rbxassetid://11882616259"} --[[, FromTime = 54, EndTime = 56}]]},
	[20] = {Xp = 100, Name = "Rampage", Image = {Id = "rbxassetid://11887669096"}, Sound = {Id = "rbxassetid://11882615481"}},
	[25] = {Xp = 125, Name = "Untouchable", Image = {Id = "rbxassetid://11887668881"}, Sound = {Id = "rbxassetid://11882615084"}},
	[30] = {Xp = 150, Name = "Invincible", Image = {Id = "rbxassetid://11887669213"}, Sound = {Id = "rbxassetid://11882615850"}},
	[35] = {Xp = 175, Name = "Inconceivable", Image = {Id = "rbxassetid://11887669350"}, Sound = {Id = "rbxassetid://11882616129"}}
		
}

-- CORE FUNCTIONS
local TypeToStreakInfo = 
{
	["Rapid"] = RapidKillStreaks,
	["Generic"] = GenericKillStreaks	
}

-- Functions
-- DIRECT
function KillStreaksInfoModule.GetKillStreakInfo(NilParam, Type, SettingName)
	return TypeToStreakInfo[Type][SettingName]
end

return KillStreaksInfoModule