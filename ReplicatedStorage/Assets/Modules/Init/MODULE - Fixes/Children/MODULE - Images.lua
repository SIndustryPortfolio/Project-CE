local ImagesFixesModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ViewModelGunsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["ViewModels"]["Guns"]
local ServerGunsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]

-- Info Modules
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Services
local ContentProviderService = game:GetService("ContentProvider")

-- Functions
-- MECHANICS
local function GetAllImageLoadables()
	-- Functions
	-- INIT
	local ImagesToLoad = {}
	local PropertiesToLoad = {"GunIcon", "CursorIcon", "AdsIcon"}
	
	for GunName, GunInfo in pairs(WeaponsInfoModule:GetAllWeaponInfos()) do
		for i, PropertyName in pairs(PropertiesToLoad) do
			table.insert(ImagesToLoad, GunInfo[PropertyName])
		end
	end
	
	return ImagesToLoad
end

local function Initialise()
	-- Functions
	-- INIT
	local Assets = GetAllImageLoadables()
	
	local Success, Error = pcall(function()
		return ContentProviderService:PreloadAsync(Assets)
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | Initialise | Error: ".. tostring(Error))
	end
end

-- DIRECT
function ImagesFixesModule.Initialise()
	return Initialise()
end

return ImagesFixesModule