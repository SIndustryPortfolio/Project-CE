local RoundTypesInfoModule = {}

-- CORE
local RoundTypesInfo = 
{
	["Light"] = {Icon = "rbxassetid://7040654129", SkipRender = true, HudRows = 2, Damage = {HeadShot = 4, LimbShot = 2}, Type = "Round", MarkColour = Color3.fromRGB(255, 255, 0)},
	["Medium"] = {Icon = "rbxassetid://7518105746", SkipRender = true, HudRows = 2, Damage = {HeadShot = 25, LimbShot = 20}, Type = "Round", MarkColour = Color3.fromRGB(255, 255, 0)},
	["Heavy"] = {Icon = "rbxassetid://10303637465", SkipRender = false, Damage = {HeadShot = 200, LimbShot = 75}, Type = "Round", MarkColour = Color3.fromRGB(255, 255, 0)},
	["Shell"] = {Icon = "rbxassetid://9200025448", SkipRender = true, HudRows = 2, Damage = {HeadShot = 100, Limbshot = 50}, Type = "Round", MarkColour = Color3.fromRGB(255, 255, 0)},
	["Plasma"] = {Icon = "", Type = "Energy", SkipRender = false, CantReloadCancel = true, MarkColour = Color3.fromRGB(0, 255, 127)}
}

-- Functions
-- MECHANICS
local function GetTypesOfRound(Type)
	-- CORE
	local Types = {}
	
	-- Functions
	-- INIT
	for _Type, _Info in pairs(RoundTypesInfo) do
		if _Info["Type"] == Type then
			table.insert(Types, _Type)
		end
	end
	
	return Types
end

-- DIRECT
function RoundTypesInfoModule.GetTypesOfRound(NilParam, Type)
	return GetTypesOfRound(Type)
end

function RoundTypesInfoModule.GetRoundTypeInfo(NilParam, SettingName)
	return RoundTypesInfo[SettingName]
end

function RoundTypesInfoModule.GetAllRoundTypeInfo()
	return RoundTypesInfo
end

return RoundTypesInfoModule