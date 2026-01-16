local StatsInfoModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Info Modules
local CharacterInfoModule = require(InfoModulesFolder["Character"])
local RanksInfoModule = require(InfoModulesFolder["Ranks"])
local EmblemsInfoModule = require(InfoModulesFolder["Emblems"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local StatsInfo = 
{
		
}

local CrewStats = 
{
	["CrewTier"] = {Name = "TIER", ClassName = "IntValue", DefaultValue = 1},
	["CrewXp"] = {Name = "XP", ClassName = "IntValue", DefaultValue = 0}
}

local CurrencyStats = 
{
	["Coins"] = {Name = "COINS", ClassName = "IntValue", DefaultValue = 0}	
}

local MiscStats = 
{
	["LinkedComms"] = {Name = "LINKED COMMS", ClassName = "BoolValue", DefaultValue = false},
	["VoiceChat"] = {Name = "VOICE CHAT", ClassName = "BoolValue", DefaultValue = false}
}

local ArmourStats = 
{
	["Variant"] = {Name = "VARIANT", ClassName = "StringValue", DefaultValue = "Mark1"},
	--["VisorColour"] = {Name = "VISOR COLOUR", ClassName = "BrickColorValue", DefaultValue = BrickColor.new("Bright yellow")--[[, AssociatedInventory = "VisorColours"]]},
	["Colour"] = {Name = "ARMOUR COLOUR", ClassName = "BrickColorValue", DefaultValue = {Function = UtilitiesModule.ChooseRandomFromArray, Params = {nil, CharacterInfoModule:GetCharacterInfo("Colours")}}, AcceptedValues = CharacterInfoModule:GetCharacterInfo("Colours")},
	["SecondaryColour"] = {Name = "SECONDARY ARMOUR COLOUR", ClassName = "BrickColorValue", DefaultValue = {Function = UtilitiesModule.ChooseRandomFromArray, Params = {nil, CharacterInfoModule:GetCharacterInfo("Colours")}}, AcceptedValues = CharacterInfoModule:GetCharacterInfo("Colours")},
	["ClanTag"] = {Name = "CLAN TAG", ClassName = "StringValue", DefaultValue = "0000"},
	["EmblemIcon1"] = {Name = "EMBLEM ICON 1", ClassName = "StringValue", DefaultValue = {Function = UtilitiesModule.ChooseRandomFromArray, Params = {nil, UtilitiesModule:GetDictKeys(EmblemsInfoModule:GetAllEmblemsInfo())}}},
	["EmblemIcon2"] = {Name = "EMBLEM ICON 2", ClassName = "StringValue", DefaultValue = {Function = UtilitiesModule.ChooseRandomFromArray, Params = {nil, UtilitiesModule:GetDictKeys(EmblemsInfoModule:GetAllEmblemsInfo())}}}
}

local GeneralStats = 
{
	["Kills"] = {Name = "KILLS", ClassName = "IntValue", DefaultValue = 0},
	["Deaths"] = {Name = "DEATHS", ClassName = "IntValue", DefaultValue = 0},
	["TimePlayed"] = {Name = "TIME PLAYED", ClassName = "IntValue", DefaultValue = 0, TimeBased = true},
	["Rank"] = {Name = "RANK", ClassName = "IntValue", DefaultValue = 1, Conversion = RanksInfoModule:GetAllRanksInfo()},
	["Xp"] = {Name = "XP", ClassName = "IntValue", DefaultValue = 0},
	["GamesWon"] = {Name = "GAMES WON", ClassName = "IntValue", DefaultValue = 0},
	["BadgesEarned"] = {Name = "BADGES EARNED", ClassName = "IntValue", DefaultValue = 0}
}

-- FUNCTIONS
-- CORE FUNCTIONS
local StatsConversion = 
{
	["General"] = GeneralStats,
	["Armour"] = ArmourStats,
	["Misc"] = MiscStats,
	["Crew"] = CrewStats,
	["Currency"] = CurrencyStats
}

-- MECHANICS
local function GetAllStatNames()
	-- CORE
	local StatNames = {}	

	-- Functions
	-- INIT
	for Category, CategoryInfo in pairs(StatsConversion) do
		for StatName, StatInfo in pairs(CategoryInfo) do
			table.insert(StatNames, StatName)
		end
	end
	
	return StatNames
end

-- DIRECT
function StatsInfoModule.GetStatInfo(NilParam, Type, Name)
	return StatsConversion[Type][Name]
end

function StatsInfoModule.GetAllStatNames()
	return GetAllStatNames()
end

function StatsInfoModule.GetStatConversion(NilParam, Type)
	return StatsConversion[Type]
end

function StatsInfoModule.GetAllStatsConversion()
	return StatsConversion
end

function StatsInfoModule.GetStatsInfo(NilParam, SettingName)
	return StatsInfo[SettingName]
end

function StatsInfoModule.GetAllStatsInfo()
	return StatsInfo
end

return StatsInfoModule

