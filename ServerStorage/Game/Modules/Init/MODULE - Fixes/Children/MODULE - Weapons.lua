local FixModule = {}

-- Dirs
local WeaponsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]
local ViewModelsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["ViewModels"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Functions
-- MECHANICS
local function Initialise()
	-- Functions
	-- INIT
	for i, Model in pairs(ViewModelsFolder["Arms"]:GetChildren()) do
		if Model:GetAttributes()["Weapon"] == nil then
			Model:SetAttribute("Weapon", true)
		end
	end
	
	for i, Model in pairs(WeaponsFolder:GetChildren()) do
		if Model:GetAttributes()["Weapon"] == nil then
			Model:SetAttribute("Weapon", true)
		end
	end	
	
	for i, Part in pairs(--[[{unpack(WeaponsFolder:GetDescendants()), unpack(ViewModelsFolder:GetDescendants())}]] UtilitiesModule:CombineTables(WeaponsFolder:GetDescendants(), ViewModelsFolder:GetDescendants())) do
		if Part:IsA("BasePart") then
			Part.CanCollide = false
			Part.CanTouch = false
			Part.CanQuery = false
		end
	end
end

-- INIT
Initialise()

return FixModule