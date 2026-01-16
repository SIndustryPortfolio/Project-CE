local MapsInfoModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local MapsInfo = UtilitiesModule:RunSubModules(script, true)
MapsInfo["Default"] = {Icon = {Image = --[["rbxassetid://8625764822"]] "rbxassetid://10915892941", ScaleType = Enum.ScaleType.Crop}}


--[[{
	
	--["Labroratory"] = {Image = "rbxassetid://8324243970", ScaleType = Enum.ScaleType.Crop},
	--["Acolade"] = {Image = "rbxassetid://8980567973", ScaleType = Enum.ScaleType.Crop},
	--["Battle Creek"] = {Image = ""}
}]]

-- Functions
-- MECHANICS
local function GetAllMapsInfo()
	-- CORE
	--local _MapsInfo = {}
	
	-- Functions
	-- INIT
	--[[for i, Module in pairs(script:GetChildren()) do
		_MapsInfo[Module.Name] = require(Module)
	end]]
	
	--MapsInfo = UtilitiesModule:RunSubModules(script, true)
	
	--return _MapsInfo
	
	return MapsInfo
end

-- DIRECT
function MapsInfoModule.GetMapInfo(NilParam, SettingName)
	local MapInfo = MapsInfo[SettingName]
	
	if script:FindFirstChild(SettingName) then
		return require(script[SettingName])
	end
	
	return MapInfo
end

function MapsInfoModule.GetAllMapsInfo()
	return GetAllMapsInfo() --MapsInfo
end

return MapsInfoModule