local AnimationFixesModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ViewModelGunsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["ViewModels"]["Guns"]
local ServerGunsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Services
local ContentProviderService = game:GetService("ContentProvider")

-- Functions
-- MECHANICS
local function GetAllAnimationIds(Folder)
	-- Functions
	-- INIT
	local Ids = {}
	
	for i, WeaponModel in pairs(Folder:GetChildren()) do
		-- Elements
		-- FOLDERS
		local CoreFolder = UtilitiesModule:WaitForChildTimed(WeaponModel, "Core")
		
		-- Modules
		local AnimationsModule = require(CoreFolder["Animations"])
		
		for AnimationName, AnimationInfo in pairs(AnimationsModule) do
			table.insert(Ids, AnimationInfo["Id"])
		end
	end
	
	return Ids
end

local function Initialise()
	-- Functions
	-- INIT
	local Assets = UtilitiesModule:CombineTables(GetAllAnimationIds(ServerGunsFolder), GetAllAnimationIds(ViewModelGunsFolder)) --{unpack(GetAllAnimationIds(ServerGunsFolder)), unpack(GetAllAnimationIds(ViewModelGunsFolder))}
	
	local Success, Error = pcall(function()
		return ContentProviderService:PreloadAsync(Assets)
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | Initialise | Error: ".. tostring(Error))
	end
end

-- DIRECT
function AnimationFixesModule.Initialise()
	return Initialise()
end

return AnimationFixesModule