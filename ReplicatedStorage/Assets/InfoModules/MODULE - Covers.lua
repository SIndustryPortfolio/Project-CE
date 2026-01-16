local CoversInfoModule = {}

-- CORE
local CoversInfo = 
{
	["Chocky"] = {Id = 1, Wrap = {Id = "rbxassetid://11326411469", Scale = Enum.ScaleType.Stretch}, Description = "Deliciously chocolatey", Rarity = "Epic"},
	["Floral"] = {Id = 2, Wrap = {Id = "rbxassetid://11326411195", Scale = Enum.ScaleType.Stretch}, Description = "Smells as good as it looks", Rarity = "Epic"},
	["Fence"] = {Id = 3, Wrap = {Id = "rbxassetid://11326411319", Scale = Enum.ScaleType.Stretch}, Description = "Very chainy", Rarity = "Uncommon"},
	["Blocks"] = {Id = 4, Wrap = {Id = "rbxassetid://11326411588", Scale = Enum.ScaleType.Stretch}, Description = "Looks like a simulation", Rarity = "Common"}
}

-- Functions
-- MECHANICS
local function GetCoverFromId(Id)
	-- Functions
	-- INIT
	local StringId = tostring(Id)

	for CoverName, CoverInfo in pairs(CoversInfo) do
		if tostring(CoverInfo["Id"]) == StringId then
			return CoverName
		end
	end
end

-- DIRECT
function CoversInfoModule.UnpackId(NilParam, Id)
	return GetCoverFromId(Id)
end

function CoversInfoModule.GetAllInfo()
	return CoversInfo
end

function CoversInfoModule.GetInfo(NilParam, SettingName)
	return CoversInfo[SettingName]
end


return CoversInfoModule