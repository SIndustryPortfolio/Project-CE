local RanksInfoModule = {}

-- CORE
local RanksInfo = 
{
	[1] = {Name = "Recruit", RequiredXp = 0, Icon = {Id = "rbxassetid://9805354230", Colour = BrickColor.new("Bronze")}},
	[2] = {Name = "Apprentice", RequiredXp = 400, Icon = {Id = "rbxassetid://9805355757", Colour = BrickColor.new("Bronze")}},
	[3] = {Name = "Apprentice Grade 2", RequiredXp = 1000, Icon = {Id = "rbxassetid://10191398841", Colour = BrickColor.new("Bronze")}},
	[4] = {Name = "Private", RequiredXp = 1800, Icon = {Id = "rbxassetid://9805354353", Colour = BrickColor.new("Bright yellow")}},
	[5] = {Name = "Private Grade 2", RequiredXp = 2800, Icon = {Id = "rbxassetid://10191391470", Colour = BrickColor.new("Bright yellow")}},
	[6] = {Name = "Corporal", RequiredXp = 4000, Icon = {Id = "rbxassetid://9805355084", Colour = BrickColor.new("Bright yellow")}},
	[7] = {Name = "Corporal Grade 2", RequiredXp = 5400, Icon = {Id = "rbxassetid://10191395330", Colour = BrickColor.new("Bright yellow")}},
	[8] = {Name = "Sergeant", RequiredXp = 7000, Icon = {Id = "rbxassetid://9805353922", Colour = BrickColor.new("Bright yellow")}},
	[9] = {Name = "Sergeant Grade 2", RequiredXp = 8800, Icon = {Id = "rbxassetid://10191391295", Colour = BrickColor.new("Bright yellow")}},
	[10] = {Name = "Sergeant Grade 3", RequiredXp = 10800, Icon = {Id = "rbxassetid://10191391042", Colour = BrickColor.new("Bright yellow")}},
	[11] = {Name = "Gunnery Sergeant", RequiredXp = 13000, Icon = {Id = "rbxassetid://9805354874", Colour = BrickColor.new("Bright yellow")}},
	[12] = {Name = "Gunnery Sergeant Grade 2", RequiredXp = 15400, Icon = {Id = "rbxassetid://10191394443", Colour = BrickColor.new("Bright yellow")}},
	[13] = {Name = "Gunnery Sergeant Grade 3", RequiredXp = 18000, Icon = {Id = "rbxassetid://10191394144", Colour = BrickColor.new("Bright yellow")}},
	[14] = {Name = "Gunnery Sergeant Grade 4", RequiredXp = 21000, Icon = {Id = "rbxassetid://10191393814", Colour = BrickColor.new("Bright yellow")}},
	[15] = {Name = "Lieutenant", RequiredXp = 24200, Icon = {Id = "rbxassetid://9805354670", Colour = BrickColor.new("Silver")}},
	[16] = {Name = "Liuetenant Grade 2", RequiredXp = 27600, Icon = {Id = "rbxassetid://10191392827", Colour = BrickColor.new("Silver")}},
	[17] = {Name = "Lieutenant Grade 3", RequiredXp = 31200, Icon = {Id = "rbxassetid://10191392477", Colour = BrickColor.new("Silver")}},
	[18] = {Name = "Lieutenant Grade 4", RequiredXp = 35000, Icon = {Id = "rbxassetid://10191392267", Colour = BrickColor.new("Silver")}},
	[19] = {Name = "Captain", RequiredXp = 39000, Icon = {Id = "rbxassetid://9805355513", Colour = BrickColor.new("Silver")}},
	[20] = {Name = "Captain Grade 2", RequiredXp = 43200, Icon = {Id = "rbxassetid://10191397505", Colour = BrickColor.new("Silver")}},
	[21] = {Name = "Captain Grade 3", RequiredXp = 47600, Icon = {Id = "rbxassetid://10191397256", Colour = BrickColor.new("Silver")}},
	[22] = {Name = "Captain Grade 4", RequiredXp = 52200, Icon = {Id = "rbxassetid://10191397028", Colour = BrickColor.new("Silver")}},
	[23] = {Name = "Major", RequiredXp = 57000, Icon = {Id = "rbxassetid://9805354502", Colour = BrickColor.new("Silver")}},
	[24] = {Name = "Major Grade 2", RequiredXp = 62000, Icon = {Id = "rbxassetid://10191392047", Colour = BrickColor.new("Silver")}},
	[25] = {Name = "Major Grade 3", RequiredXp = 67200, Icon = {Id = "rbxassetid://10191391843", Colour = BrickColor.new("Silver")}},		
	[26] = {Name = "Major Grade 4", RequiredXp = 72600, Icon = {Id = "rbxassetid://10191391660", Colour = BrickColor.new("Silver")}},
	[27] = {Name = "Commander", RequiredXp = 78200, Icon = {Id = "rbxassetid://9805355259", Colour = BrickColor.new("Silver")}},
	[28] = {Name = "Commander Grade 2", RequiredXp = 84000, Icon = {Id = "rbxassetid://10191395957", Colour = BrickColor.new("Silver")}},	
	[29] = {Name = "Commander Grade 3", RequiredXp = 90000, Icon = {Id = "rbxassetid://10191395750", Colour = BrickColor.new("Silver")}},
	[30] = {Name = "Commander Grade 4", RequiredXp = 96200, Icon = {Id = "rbxassetid://10191395555", Colour = BrickColor.new("Silver")}},
	[31] = {Name = "Colonel", RequiredXp = 102600, Icon = {Id = "rbxassetid://9805355384", Colour = BrickColor.new("Silver")}},
	[32] = {Name = "Colonel Grade 2", RequiredXp = 109200, Icon = {Id = "rbxassetid://10191396807", Colour = BrickColor.new("Silver")}},	
	[33] = {Name = "Colonel Grade 3", RequiredXp = 116000, Icon = {Id = "rbxassetid://10191396510", Colour = BrickColor.new("Silver")}},	
	[34] = {Name = "Colonel Grade 4", RequiredXp = 123000, Icon = {Id = "rbxassetid://10191396276", Colour = BrickColor.new("Silver")}},	
	[35] = {Name = "Brigadier", RequiredXp = 130200, Icon = {Id = "rbxassetid://9805355628", Colour = BrickColor.new("Silver")}},
	[36] = {Name = "Brigadier Grade 2", RequiredXp = 137600, Icon = {Id = "rbxassetid://10191398595", Colour = BrickColor.new("Silver")}},
	[37] = {Name = "Brigadier Grade 3", RequiredXp = 145200, Icon = {Id = "rbxassetid://10191398356", Colour = BrickColor.new("Silver")}},
	[38] = {Name = "Brigadier Grade 4", RequiredXp = 153000, Icon = {Id = "rbxassetid://10191397725", Colour = BrickColor.new("Silver")}},
	[39] = {Name = "General", RequiredXp = 161000, Icon = {Id = "rbxassetid://9805354976", Colour = BrickColor.new("Gold")}},
	[40] = {Name = "General Grade 2", RequiredXp = 169200, Icon = {Id = "rbxassetid://10191395074", Colour = BrickColor.new("Gold")}},
	[41] = {Name = "General Grade 3", RequiredXp = 177600, Icon = {Id = "rbxassetid://10191394893", Colour = BrickColor.new("Gold")}},
	[42] = {Name = "General Grade 4", RequiredXp = 186200, Icon = {Id = "rbxassetid://10191394714", Colour = BrickColor.new("Gold")}},
	[43] = {Name = "Hero", RequiredXp = 195000, Icon = {Id = "rbxassetid://10191393512", Colour = BrickColor.new("Gold")}},
	[44] = {Name = "Legend", RequiredXp = 204000, Icon = {Id = "rbxassetid://10191393100", Colour = BrickColor.new("Gold")}},
	[45] = {Name = "Mythic", RequiredXp = 213200, Icon = {Id = "rbxassetid://10248342582", Colour = BrickColor.new("Institutional white")}},
	[46] = {Name = "Noble", RequiredXp = 222600, Icon = {Id = "rbxassetid://10248342295", Colour = BrickColor.new("Institutional white")}},
	[47] = {Name = "Eclipse", RequiredXp = 232200, Icon = {Id = "rbxassetid://10284173463", Colour = BrickColor.new("Dark orange")}},
	[48] = {Name = "Nova", RequiredXp = 242000, Icon = {Id = "rbxassetid://10284172587", Colour = BrickColor.new("Dark orange")}},
	[49] = {Name = "Forerunner", RequiredXp = 252000, Icon = {Id = "rbxassetid://10284173153", Colour = BrickColor.new("Institutional white")}},
	[50] = {Name = "Reclaimer", RequiredXp = 262200, Icon = {Id = "rbxassetid://10284172294", Colour = BrickColor.new("Institutional white")}},
	[51] = {Name = "Inheritor", RequiredXp = 272600, Icon = {Id = "rbxassetid://10284172899", Colour = BrickColor.new("Institutional white")}}
}

-- Functions
-- DIRECT
function RanksInfoModule.GetAllRanksInfo()
	return RanksInfo
end

function RanksInfoModule.GetRankInfo(NilParam, SettingName)
	return RanksInfo[SettingName]
end

return RanksInfoModule