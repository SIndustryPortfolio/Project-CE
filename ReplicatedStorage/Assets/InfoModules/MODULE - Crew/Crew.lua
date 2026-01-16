local CrewInfoModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local RanksInfoModule = require(InfoModulesFolder["Ranks"])

-- CORE
local Tiers = 
{
	--[[[1] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Neon Orange"}}},
	[2] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "250", Value = 250}}},
	[3] = {RequiredXp = 0, Rewards = {{Type = "CECoins", Name = "50", Value = 50}}},
	[4] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Neon Blue"}}},
	[5] = {RequiredXp = 0, Rewards = {{Type = "VisorColours", Name = "Silver"}}},
	[6] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "300", Value = 300}}},
	[7] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Forest"}}},
	[8] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Neon Green"}}},
	[9] = {RequiredXp = 0, Rewards = {{Type = "CECoins", Name = "50", Value = 50}}},
	[10] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "350", Value = 350}}},
	[11] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Neon Yellow"}}},
	[12] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "400", Value = 400}}},
	[13] = {RequiredXp = 0, Rewards = {{Type = "VisorColours", Name = "Blue"}}},
	[14] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Red Tiger"}}},
	[15] = {RequiredXp = 0, Rewards = {{Type = "CECoins", Name = "50", Value = 50}}},
	[16] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "450", Value = 450}}},
	[17] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Nether Portal"}}},
	[18] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "500", Value = 500}}},
	[19] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Blood"}}},
	[20] = {RequiredXp = 0, Rewards = {{Type = "CECoins", Name = "50", Value = 50}}},
	[21] = {RequiredXp = 0, Rewards = {{Type = "ArmourEffects", Name = "Stench"}}},
	[22] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "550", Value = 550}}},
	[23] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Error"}}},
	[24] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "600", Value = 600}}},
	[25] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Stone"}}},
	[26] = {RequiredXp = 0, Rewards = {{Type = "CECoins", Name = "50", Value = 50}}},
	[27] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "650", Value = 650}}},
	[28] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Grass"}}},
	[29] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "700", Value = 700}}},
	[30] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Diamond"}}},
	[31] = {RequiredXp = 0, Rewards = {{Type = "CECoins", Name = "50", Value = 50}}},
	[32] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "750", Value = 750}}},
	[33] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Bricks"}}},
	[34] = {RequiredXp = 0, Rewards = {{Type = "VisorColours", Name = "Black"}}},
	[35] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "800", Value = 800}}},
	[36] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Metalique"}}},
	[37] = {RequiredXp = 0, Rewards = {{Type = "CECoins", Name = "50", Value = 50}}},
	[38] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "850", Value = 850}}},
	[39] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Marble"}}},
	[40] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "900", Value = 900}}},
	[41] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Bamboo"}}},
	[42] = {RequiredXp = 0, Rewards = {{Type = "ArmourEffects", Name = "Inclement Weather"}}},
	[43] = {RequiredXp = 0, Rewards = {{Type = "CECoins", Name = "50", Value = 50}}},
	[44] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "950", Value = 950}}},
	[45] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Lava"}}},
	[46] = {RequiredXp = 0, Rewards = {{Type = "VisorColours", Name = "Gold"}}},
	[47] = {RequiredXp = 0, Rewards = {{Type = "Xp", Name = "1000", Value = 1000}}},
	[48] = {RequiredXp = 0, Rewards = {{Type = "Camos", Name = "Graphite"}}},
	[49] = {RequiredXp = 0, Rewards = {{Type = "CECoins", Name = "50", Value = 50}}},
	[50] = {RequiredXp = 0, Rewards = {{Type = "ArmourEffects", Name = "Fire"}}},]]
}

local CrewInfo = 
{
	["Purchaseable"] = 
	{
		["NextTier"] = 25,
		["AllTiers"] = 2000	
	},
	["Icons"] = 
	{
		["Xp"] = {Id = "rbxassetid://10209311764"},
		["Camos"] = {Id = "rbxassetid://10209312015"},
		["Armour"] = {Id = "rbxassetid://10209312374"},
		["VisorColours"] = {Id = "rbxassetid://10209312374"},
		["CECoins"] = {Id = "rbxassetid://11636184648"} --{Id = "rbxassetid://10319213220"}
	}	
}

-- Functions
-- MECHANICS
local function Setup()
	-- Functions
	-- INIT
	for i, Module in pairs(script:GetChildren()) do
		local RequiredModule = require(Module)
		Tiers[tonumber(Module.Name)] = RequiredModule
	end
end

local function SetRequiredXPs()
	-- Functions
	-- INIT
	for SlotIndex, RankInfo in pairs(RanksInfoModule:GetAllRanksInfo()) do
		local CrewSlotInfo = Tiers[SlotIndex]
		
		if not CrewSlotInfo then
			continue
		end
		
		CrewSlotInfo["RequiredXp"] = RankInfo["RequiredXp"] * 0.75
		--print("Index: ".. tostring(SlotIndex).. " | RequiredXp: ".. tostring(CrewSlotInfo["RequiredXp"]))
	end
end

-- DIRECT
function CrewInfoModule.GetCrewInfo(NilParam, SettingName)
	return CrewInfo[SettingName]
end

function CrewInfoModule.GetAllCrewInfo()
	return CrewInfo
end

function CrewInfoModule.GetAllTiers()
	return Tiers
end

function CrewInfoModule.GetTierInfo(NilParam, Index)
	return Tiers[Index]
end

-- INIT
Setup()
SetRequiredXPs()

return CrewInfoModule