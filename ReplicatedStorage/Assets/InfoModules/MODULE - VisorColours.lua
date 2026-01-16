local VisorColoursInfoModule = {}

-- CORE
local VisorColoursInfo = 
{
	["Gold"] = {Id = 1, Crew = true, Colour = BrickColor.new("Gold"), Description = "Put your money where your mouth is", Rarity = "Legendary"},
	["Silver"] = {Id = 2, Crew = true, Colour = BrickColor.new("Silver"), Description = "Jumping feet first into hell isn't your job; making sure it's crowded when you get there is", Rarity = "Uncommon"},
	["Blue"] = {Id = 3, Crew = true, Colour = BrickColor.new("Electric blue"), Description = "It's already like they are looking at the sky, just put 'em on the ground", Rarity = "Rare"},
	["Black"] = {Id = 4, Crew = true, Colour = BrickColor.new("Black"), Description = "You can have it any colour you want... as long as it's black", Rarity = "Epic"},
	--
	["Crimson"] = {Id = 5, Price = {Coins = 250}, Colour = BrickColor.new("Crimson"), Description = "Bleed eternally", Rarity = "Uncommon"},
	["Emerald"] = {Id = 6, Price = {Coins = 450}, Colour = BrickColor.new("Sea green"), Description = "Quite luxurios, indeed", Rarity = "Epic"},
	["White"] = {Id = 7, Price = {Coins = 250}, Colour = BrickColor.new("Institutional white"), Description = "Pretty angelic, huh", Rarity = "Uncommon"},
	["Violet"] = {Id = 8, Price = {Coins = 250}, Colour = BrickColor.new("Bright violet"), Description = "The colour of royalty enriched with plenty of fame", Rarity = "Uncommon"},
	["Aged"] = {Id = 9, Price = {Coins = 250}, Colour = BrickColor.new("Brown"), Description = "Has this ever been given a wash? I think not", Rarity = "Uncommon"},
	["Pinkest"] = {Id = 10, Price = {Coins = 250}, Colour = BrickColor.new("Hot pink"), Description = "Become the most eye popping spartan in existence", Rarity = "Uncommon"}
		
}

-- Functions
-- MECHANICS
local function GetSellable()
	-- CORE
	local Sellable = {}
	
	-- Functions
	-- INIT
	for VisorName, VisorInfo in pairs(VisorColoursInfo) do
		if VisorInfo["Crew"] then
			continue
		end
		
		table.insert(Sellable, VisorName)
	end
	
	return Sellable
end

local function UnpackId(Id)
	-- Functions
	-- INIT
	for VisorName, VisorInfo in pairs(VisorColoursInfo) do
		if VisorInfo["Id"] == Id then
			return VisorName
		end
	end
end

-- DIRECT
function VisorColoursInfoModule.UnpackId(NilParam, Id)
	return UnpackId(Id)
end

function VisorColoursInfoModule.GetSellable()
	return GetSellable()
end

function VisorColoursInfoModule.GetInfo(NilParam, VisorColourName)
	return VisorColoursInfo[VisorColourName]
end

function VisorColoursInfoModule.GetAllInfo()
	return VisorColoursInfo
end

return VisorColoursInfoModule