local RarityInfoModule = {}

-- CORE
local RarityInfo = 
{
	["Common"] = {Colour = BrickColor.new("Medium stone grey")},
	["Uncommon"] = {Colour = BrickColor.new("Lime green")},
	["Rare"] = {Colour = BrickColor.new("Cyan")},
	["Epic"] = {Colour = BrickColor.new("Royal purple")},
	["Legendary"] = {Colour = BrickColor.new("Gold")}	
}

-- Functions
-- DIRECT
function RarityInfoModule.GetRarityInfo(NilParam, RarityName)
	return RarityInfo[RarityName]
end

function RarityInfoModule.GetAllRaritysInfo()
	return RarityInfo
end

return RarityInfoModule