local CharacterInfoModule = {}

-- CORE
local CharacterInfo = 
{
	["MeleeDistance"] = 15,
	["PickupDistance"] = 10, -- Studs
	["HipHeight"] = 4.55,
	["CrouchHipHeight"] = 2.75,
	["CrouchSpeedMultiplier"] = 0.5,
	["Colours"] = 
	{
		BrickColor.new("Institutional white"),
		BrickColor.new("Black"),
		BrickColor.new("Really red"),
		BrickColor.new("Really blue"),
		BrickColor.new("Mid gray"),
		BrickColor.new("Bright yellow"),
		BrickColor.new("Neon green"),
		BrickColor.new("Hot pink"),
		BrickColor.new("Royal purple"),
		BrickColor.new("Cyan"),
		BrickColor.new("Electric blue"),
		BrickColor.new("Deep orange"),
		BrickColor.new("Teal"),
		BrickColor.new("Sage green"),
		BrickColor.new("Brown"),
		BrickColor.new("Med. yellowish orange"),
		BrickColor.new("Maroon"),
		BrickColor.new("Salmon")
		--[[BrickColor.new("Really red"),
		BrickColor.new("Really blue"),
		BrickColor.new("Neon orange"),
		BrickColor.new("Electric blue"),
		BrickColor.new("Brown"),
		BrickColor.new("Light pink"),
		BrickColor.new("Black"),
		BrickColor.new("Bright yellow"),
		BrickColor.new("Royal purple"),
		BrickColor.new("Cyan"),
		BrickColor.new("Sea green"),
		BrickColor.new("White"),
		BrickColor.new("Grey"),
		BrickColor.new("Burlap"),
		BrickColor.new("Dark grey"),
		BrickColor.new("Dark Royal blue")]]
	}
}

-- Functions
-- DIRECT
function CharacterInfoModule.GetCharacterInfo(NilParam, SettingName)
	return CharacterInfo[SettingName]
end

function CharacterInfoModule.GetAllCharacterInfo()
	return CharacterInfo
end

return CharacterInfoModule