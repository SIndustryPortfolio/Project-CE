local EmblemsInfoModule = {}

-- CORE
local EmblemsInfo = 
{
	["Triangular"] = {Id = 1, Wrap = {Id = "rbxassetid://11328824322"}},
	["ToxicWarning"] = {Id = 2, Wrap = {Id = "rbxassetid://11328824415"}},
	["ThickLayeredPoint"] = {Id = 3, Wrap = {Id = "rbxassetid://11328824524"}},
	["Square"] = {Id = 4, Wrap = {Id = "rbxassetid://11328824601"}},
	["SpiralInnerCircle"] = {Id = 5, Wrap = {Id = "rbxassetid://11328824670"}},
	["SpadeCircle"] = {Id = 6, Wrap = {Id = "rbxassetid://11328824779"}},
	["Smiley"] = {Id = 7, Wrap = {Id = "rbxassetid://11328824912"}},
	["Sign"] = {Id = 8, Wrap = {Id = "rbxassetid://11328825017"}},
	["Shield"] = {Id = 9, Wrap = {Id = "rbxassetid://11328825125"}},
	["SciFiCursor"] = {Id = 10, Wrap = {Id = "rbxassetid://11328825276"}},
	["SadSmiley"]=  {Id = 11, Wrap = {Id = "rbxassetid://11328825434"}},
	["Ripple"] = {Id = 12, Wrap = {Id = "rbxassetid://11328825530"}},
	["Rank"] = {Id = 13, Wrap = {Id = "rbxassetid://11328825653"}},
	["Poly"] = {Id = 14, Wrap = {Id = "rbxassetid://11328825793"}},
	["NinjaStar"] = {Id = 15, Wrap = {Id = "rbxassetid://11328825905"}},
	["LayeredPoint"] = {Id = 16, Wrap = {Id = "rbxassetid://11328826030"}},
	["HoneyComb"] = {Id = 17, Wrap = {Id = "rbxassetid://11328826118"}},
	["HeartLips"] = {Id = 18, Wrap = {Id = "rbxassetid://11328826225"}},
	["HeartCircle"] = {Id = 19, Wrap = {Id = "rbxassetid://11328826367"}},
	["DoubleCrescent"] = {Id = 20, Wrap = {Id = "rbxassetid://11328826477"}},
	["DiamondCircle"] = {Id = 21, Wrap = {Id = "rbxassetid://11328826624"}},
	["Diamond"] = {Id = 22, Wrap = {Id = "rbxassetid://11328826810"}},
	["Cube"] = {Id = 23, Wrap = {Id = "rbxassetid://11328826939"}},
	["Covenant"] = {Id = 24, Wrap = {Id = "rbxassetid://11328827053"}},
	["ClubCircle"] = {Id = 25, Wrap = {Id = "rbxassetid://11328827161"}},
	["Circle"] = {Id = 26, Wrap = {Id = "rbxassetid://11328827324"}},
	["BungieCog"] = {Id = 27, Wrap = {Id = "rbxassetid://11328827456"}},
	["Bullseye"] = {Id = 28, Wrap = {Id = "rbxassetid://11328827586"}},
	["Anger"] = {Id = 29, Wrap = {Id = "rbxassetid://11328827666"}},
	["Meds"] = {Id = 30, Wrap = {Id = "rbxassetid://11328828396"}},
	["Blank"] = {Id = 31, Wrap = {Id = ""}}
}

-- Functions
-- MECHANICS
local function GetEmblemFromId(Id)
	-- Functions
	-- INIT
	local StringId = tostring(Id)

	for EmblemName, EmblemInfo in pairs(EmblemsInfo) do
		if tostring(EmblemInfo["Id"]) == StringId then
			return EmblemName
		end
	end
end

-- DIRECT
function EmblemsInfoModule.UnpackId(NilParam, Id)
	return GetEmblemFromId(Id)
end

function EmblemsInfoModule.GetAllEmblemsInfo()
	return EmblemsInfo
end

function EmblemsInfoModule.GetEmblemInfo(NilParam, SettingName)
	return EmblemsInfo[SettingName]
end

return EmblemsInfoModule