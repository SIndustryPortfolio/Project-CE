local WeaponsInitialiserModule = {}

-- Dirs
local WeaponsModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]["Weapons"]
local PartsViewModelsGunsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["ViewModels"]["Guns"]
local PartsWeaponsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Elements
-- FOLDERS
local ServerWeaponModulesFolder = WeaponsModulesFolder["Server"]
local ViewModelsWeaponModulesFolder = WeaponsModulesFolder["ViewModel"]

-- Functions
-- MECHANICS
local function InsertIntoWeapon(WeaponModel, Module)
	-- CORE
	local WeaponCoreFolder = UtilitiesModule:WaitForChildTimed(WeaponModel, "Core")
	
	-- Functions
	-- INIT
	local FoundOldModule = WeaponCoreFolder:FindFirstChild(Module.Name)
	
	if FoundOldModule then
		FoundOldModule:Destroy()
	end
	
	Module:Clone().Parent = WeaponCoreFolder
end

local function Initialise()
	-- Functions
	-- INIT
	for i, ModuleInstance in pairs(ServerWeaponModulesFolder:GetChildren()) do
		for x, WeaponModel in pairs(PartsWeaponsFolder:GetChildren()) do
			InsertIntoWeapon(WeaponModel, ModuleInstance)
		end
	end
	
	for i, ModuleInstance in pairs(ViewModelsWeaponModulesFolder:GetChildren()) do
		for x, WeaponModel in pairs(PartsViewModelsGunsFolder:GetChildren()) do
			InsertIntoWeapon(WeaponModel, ModuleInstance)
		end
	end
end

-- DIRECT
function WeaponsInitialiserModule.Initialise()
	return Initialise()
end

return WeaponsInitialiserModule