local CamosInfoModule = {}

-- CORE
local CamosInfo = 
{
	-- BATTLE PASS
	["Neon Orange"] = {Id = 1, Crew = true, Wrap = {Id = "rbxassetid://9999121633", Scale = Enum.ScaleType.Stretch}, Description = "Bright with citrus", Rarity = "Common"},
	["Neon Blue"] = {Id = 2, Crew = true, Wrap = {Id = "rbxassetid://2816725660", Scale = Enum.ScaleType.Stretch}, Description = "Blind them in blue", Rarity = "Common"},
	["Neon Green"] = {Id = 3, Crew = true, Wrap = {Id = "rbxassetid://2816725095", Scale = Enum.ScaleType.Stretch}, Description = "Apple or Watermelon", Rarity = "Common"},
	["Neon Yellow"] = {Id = 4, Crew = true, Wrap = {Id = "rbxassetid://250800317", Scale = Enum.ScaleType.Stretch}, Description = "Don't stare for too long", Rarity = "Common"},
	["Forest"] = {Id = 5, Crew = true, Wrap = {Id = "rbxassetid://105985413", Scale = Enum.ScaleType.Stretch}, Description = "Blend in with nature", Rarity  = "Uncommon"},
	["Red Tiger"] = {Id = 6, Crew = true, Wrap = {Id = "rbxassetid://141041098", Scale = Enum.ScaleType.Stretch}, Description = "Roaringly stylish", Rarity = "Uncommon"},
	["Nether Portal"] = {Id = 7, Crew = true, Wrap = {Id = "rbxassetid://1114603291", Scale = Enum.ScaleType.Stretch}, Description = "Your handheld portal", Rarity = "Uncommon"},
	["Blood"] = {Id = 8, Crew = true, Wrap = {Id = "rbxassetid://7163030933", Scale = Enum.ScaleType.Stretch}, Description = "A murdering thirst", Rarity = "Uncommon"},
	["Error"] = {Id = 9, Crew = true, Wrap = {Id = "rbxassetid://6153356804", Scale = Enum.ScaleType.Stretch}, Description = "Something went wrong", Rarity = "Uncommon"},
	["Stone"] = {Id = 10, Crew = true, Wrap = {Id = "rbxassetid://88686165", Scale = Enum.ScaleType.Stretch}, Description = "Rock hard and durable", Rarity = "Rare"},
	["Grass"] = {Id = 11, Crew = true, Wrap = {Id = "rbxassetid://132291035", Scale = Enum.ScaleType.Stretch}, Description = "All grass no dirt", Rarity = "Rare"},
	["Diamond"] = {Id = 12, Crew = true, Wrap = {Id = "rbxassetid://3974987340", Scale = Enum.ScaleType.Stretch}, Description = "Combact Carbon", Rarity = "Rare"},
	["Bricks"] = {Id = 13, Crew = true, Wrap = {Id = "rbxassetid://14088862", Scale = Enum.ScaleType.Stretch}, Description = "Building supplies covered", Rarity = "Epic"},
	["Metalique"] = {Id = 14, Crew = true, Wrap = {Id = "rbxassetid://4525193044", Scale = Enum.ScaleType.Stretch}, Description = "What metal is this", Rarity = "Epic"},
	["Marble"] = {Id = 15, Crew = true, Wrap = {Id = "rbxassetid://7055033842", Scale = Enum.ScaleType.Stretch}, Description = "Fancy and expensive", Rarity = "Epic"},
	["Bamboo"] = {Id = 16, Crew = true, Wrap = {Id = "rbxassetid://7136129736", Scale = Enum.ScaleType.Stretch}, Descritpion = "Summon the pandas", Rarity = "Legendary"},
	["Lava"] = {Id = 17, Crew = true, Wrap = {Id = "rbxassetid://1112726928", Scale = Enum.ScaleType.Stretch}, Description = "Incinerating to the touch", Rarity = "Legendary"},
	["Graphite"] = {Id = 18, Crew = true, Wrap = {Id = "rbxassetid://9453746978", Scale = Enum.ScaleType.Stretch}, Description = "Also in your pencils", Rarity = "Legendary"},
		
	-- CLAIMABLE
	["Cubic"] = {Id = 19, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://2062021684", Scale = Enum.ScaleType.Stretch}, Description = "Dangerously mesmerising", Rarity = "Common"},
	["Pinkadots"] = {Id = 20, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://422063713", Scale = Enum.ScaleType.Stretch}, Description = "Keep it cute", Rarity = "Common"},
	["Wavy"] = {Id = 21, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://4597451414", Scale = Enum.ScaleType.Stretch}, Description = "Heavy waves. Too much to count", Rarity = "Common"},
	["Cubic Green"] = {Id = 22, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://2832671181", Scale = Enum.ScaleType.Stretch}, Description = "Greenishly mesmerising", Rarity = "Uncommon"},
	["Rainbow Tiger"] = {Id = 23, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://546728125", Scale = Enum.ScaleType.Stretch}, Animated = true, Description = "Drop their jaws and maul them", Rarity = "Legendary"},
	["Glass Shards"] = {Id = 24, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://26431367", Scale = Enum.ScaleType.Stretch}, Description = "Don't cut youself", Rarity = "Uncommon"},
	["Marble Paint"] = {Id = 25, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://9729995770", Scale = Enum.ScaleType.Stretch}, Description = "How long did it take to make this", Rarity = "Legendary"},
	["Hexagons"] = {Id = 26, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://5558536229", Scale = Enum.ScaleType.Stretch}, Animated = true, Description = "Octagons are better", Rarity = "Rare"},
	["Pewdiepie"] = {Id = 27, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://9072580452", Scale = Enum.ScaleType.Stretch}, Animated = true, Description = "Bro fist", Rarity = "Legendary"},
	["Panda"] = {Id = 28, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://5096894141", Scale = Enum.ScaleType.Stretch}, Description = "Search for bamboo", Rarity = "Uncommon"},
	["Linear"] = {Id = 29, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://1472693536", Scale = Enum.ScaleType.Stretch}, Description = "It's just majorly linear", Rarity = "Common"},
	["Aesthetic"] = {Id = 30, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://4674423236", Scale = Enum.ScaleType.Stretch}, Description = "Calming, very very calming", Rarity = "Common"},
	["Cloudy"] = {Id = 31, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://5464605174", Scale = Enum.ScaleType.Stretch}, Description = "Smoke or Clouds", Rarity = "Rare"},
	["No Signal"] = {Id = 32, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://7340074669", Scale = Enum.ScaleType.Stretch}, Description = "Change the channel", Rarity = "Rare"},
	["Lemons"] = {Id = 33, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://7340074669", Scale = Enum.ScaleType.Stretch}, Description = "When life gives you lemons. Use them.", Rarity = "Uncommon"},
	["Checkered"] = {Id = 34, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://68048786", Scale = Enum.ScaleType.Stretch}, Description = "Up for a game of chess", Rarity = "Common"},
	["Ice Burgs"] = {Id = 35, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://2901069547", Scale = Enum.ScaleType.Stretch}, Description = "Remember, global warming caused this", Rarity = "Rare"},
	["Ancient"] = {Id = 36, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://2901069547", Scale = Enum.ScaleType.Stretch}, Description = "Antiqueness without the smell", Rarity = "Common"},
	["Stars"] = {Id = 37, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://5438498736", Scale = Enum.ScaleType.Stretch}, Description = "Become the star of the show", Rarity = "Common"},
	["Rainbow"] = {Id = 38, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://9688010255", Scale = Enum.ScaleType.Stretch}, Description = "Pride", Rarity = "Epic"},
	["Blush"] = {Id = 39, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://5251746842", Scale = Enum.ScaleType.Stretch}, Description = "Another cute one", Rarity = "Common"},
	["Pink Grid"] = {Id = 40, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://3553465", Scale = Enum.ScaleType.Stretch}, Description = "Whats this for", Rarity = "Common"},
	["Beans"] = {Id = 41, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://6080008779", Scale = Enum.ScaleType.Stretch}, Description = "Baked or Cold", Rarity = "Uncommon"},
	["Tiger"] = {Id = 42, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://6810540829", Scale = Enum.ScaleType.Stretch}, Description = "Found it at the zoo", Rarity = "Rare"},
	["Ambush"] = {Id = 43, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://9843020231", Scale = Enum.ScaleType.Stretch}, Description = "Ambush", Rarity = "Epic"},
	["Flamingos"] = {Id = 44, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://3405816520", Scale = Enum.ScaleType.Stretch}, Description = "Flim flam", Rarity = "Legendary"},
	["Pink Leopard"] = {Id = 45, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://5438992749", Scale = Enum.ScaleType.Stretch}, Description = "Pink in nature", Rarity = "Epic"},
	["Euphoria"] = {Id = 46, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://7136162164", Scale = Enum.ScaleType.Stretch}, Description = "Enchant the mood", Rarity = "Rare"},
	["Flowers"] = {Id = 47, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://4928832149", Scale = Enum.ScaleType.Stretch}, Description = "Photosynthesis gone wrong", Rarity = "Uncommon"},
	["Scales"] = {Id = 48, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://31988839", Scale = Enum.ScaleType.Stretch}, Description = "Overly scaley", Rarity = "Epic"},
	["Peacock"] = {Id = 49, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://5415402005", Scale = Enum.ScaleType.Stretch}, Description = "Feathers or eyes", Rarity = "Epic"},
	["Zigzags"] = {Id = 50, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://157075274", Scale = Enum.ScaleType.Stretch}, Description = "We've all made this pattern once", Rarity = "Uncommon"},
	["Wallpaper"] = {Id = 51, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://1976592702", Scale = Enum.ScaleType.Stretch}, Description = "Decorate your home", Rarity = "Rare"},
	["Sky"] = {Id = 52, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://2203590993", Scale = Enum.ScaleType.Stretch}, Description = "Take the altitude with you", Rarity = "Epic"},
	["Peaches"] = {Id = 53, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://3314037288", Scale = Enum.ScaleType.Stretch}, Description = "Remember your 5 a day", Rarity = "Uncommon"},
	["Hearts"] = {Id = 54, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://70924334", Scale = Enum.ScaleType.Stretch}, Description = "Not as harmless as it seems", Rarity = "Common"},
	["Aztec"] = {Id = 55, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://59004848", Scale = Enum.ScaleType.Stretch}, Description = "Aztec", Rarity = "Epic"},
	["Galaxy"] = {Id = 56, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://139638566", Scale = Enum.ScaleType.Stretch}, Animated = true, Description = "An infinite void", Rarity = "Legendary"},
	["Pumpkins"] = {Id = 57, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://139638566", Scale = Enum.ScaleType.Stretch}, Description = "Spoopy", Rarity = "Rare"},
	["Coconuts"] = {Id = 58, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://5288532869", Scale = Enum.ScaleType.Stretch}, Description = "The coconut nut is a giant nut", Rarity = "Uncommon"},
	["Roblox"] = {Id = 59, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://9246293415", Scale = Enum.ScaleType.Stretch}, Description = "The best game platform", Rarity = "Legendary"},
	["Streaks"] = {Id = 60, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://6520201026", Scale = Enum.ScaleType.Stretch}, Animated = true, Description = "Bursting with energy", Rarity = "Rare"},
	["GG"] = {Id = 61, Price = {Coins = 600}, Wrap = {Id = "rbxassetid://205580099", Scale = Enum.ScaleType.Stretch}, Description = "Become the dripster", Rarity = "Legendary"},
	["Floorboards"] = {Id = 62, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://2060107477", Scale = Enum.ScaleType.Stretch}, Description = "At least they aren't croaky"},	["Leaves"] = {Id = 47, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://5267014016", Scale = Enum.ScaleType.Stretch}, Description = "Chloroplastical", Rarity = "Common"},
	["Diamonds"] = {Id = 63, Price = {Coins = 750}, Wrap = {Id = "rbxassetid://9581681500", Scale = Enum.ScaleType.Stretch}, Description = "How much is this worth", Rarity = "Legendary"},
	["Supremer"] = {Id = 64, Price = {Coins = 600}, Wrap = {Id = "rbxassetid://1172258685", Scale = Enum.ScaleType.Stretch}, Description = "Exclusive and Expensive", Rarity = "Legendary"},
	["Denim"] = {Id = 65, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://1172258685", Scale = Enum.ScaleType.Stretch}, Description = "Matches your jeans", Rarity = "Uncommon"},
	["Metallic Vaporwave"] = {Id = 66, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://872373147", Scale = Enum.ScaleType.Stretch}, Description = "Very attractive of course", Rarity = "Epic"},
	["Emerald"] = {Id = 67, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://1605909728", Scale = Enum.ScaleType.Stretch}, Description = "Now go find a villager", Rarity = "Epic"},
	["Technology"] = {Id = 68, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://5860384543", Scale = Enum.ScaleType.Stretch}, Description = "Insert binary joke", Rarity = "Uncommon"},
	["Purple Diamonds"] = {Id = 69, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://5853482378", Scale = Enum.ScaleType.Stretch}, Description = "Only the richest", Rarity = "Legendary"},
	["Luis Vuiton"] = {Id = 70, Price = {Coins = 600}, Wrap = {Id = "rbxassetid://1108207632", Scale = Enum.ScaleType.Stretch}, Animated = true, Description = "Ball out in designer", Rarity = "Legendary"},
	["Off Black"] = {Id = 71, Price = {Coins = 600}, Wrap = {Id = "rbxassetid://1477167840", Scale = Enum.ScaleType.Stretch}, Description = "Edgy and cool", Rarity = "Legendary"},
	["Black Bricks"] = {Id = 72, Price = {Coins = 90}, Wrap = {Id = "rbxassetid://423900591", Scale = Enum.ScaleType.Stretch}, Description = "Dark and heavy", Rarity = "Uncommon"},
	["Gold"] = {Id = 73, Price = {Coins = 300}, Wrap = {Id = "rbxassetid://265021864", Scale = Enum.ScaleType.Stretch}, Description = "How many karrats", Rarity = "Legendary"},

}

-- Functions
-- MECHANICS
local function GetCamoFromId(Id)
	-- Functions
	-- INIT
	local StringId = tostring(Id)
	
	for CamoName, CamoInfo in pairs(CamosInfo) do
		if tostring(CamoInfo["Id"]) == StringId then
			return CamoName
		end
	end
end

local function GetSellable()
	-- CORE
	local Sellable = {}
	
	-- Functions
	-- INIT
	for CamoName, CamoInfo in pairs(CamosInfo) do
		if CamoInfo["Crew"] then
			continue
		end
		
		table.insert(Sellable, CamoName)
	end
	
	return Sellable
end

-- DIRECT
function CamosInfoModule.GetSellable()
	return GetSellable()
end

function CamosInfoModule.UnpackId(NilParam, Id)
	return GetCamoFromId(Id)
end

function CamosInfoModule.GetInfo(NilParam, SettingName)
	return CamosInfo[SettingName]
end

function CamosInfoModule.GetAllInfo()
	return CamosInfo
end

return CamosInfoModule