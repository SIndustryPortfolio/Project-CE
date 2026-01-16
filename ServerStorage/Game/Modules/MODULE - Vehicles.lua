local VehiclesModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedVehiclesModulesFolder = SharedModulesFolder["Vehicles"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- Functions
-- MEHCHANICS
local function InitialiseVehicle(VehicleModel)
	-- Elements
	-- FOLDERS
	local VehicleCoreFolder = VehicleModel:FindFirstChild("Core") --- UtilitiesModule:WaitForChildTimed(VehicleModel, "Core")
	VehicleCoreFolder:ClearAllChildren()
	
	-- Functions
	-- INIT
	local FoundUpdatedFolder = SharedVehiclesModulesFolder:FindFirstChild(VehicleModel.Name)
	
	if not FoundUpdatedFolder then
		return nil
	end
	
	for i, Folder in pairs(FoundUpdatedFolder:GetChildren()) do
		local FoundVehicleModelFolder = VehicleModel:FindFirstChild(Folder.Name)
		
		if not FoundVehicleModelFolder then
			FoundVehicleModelFolder = Instance.new("Folder")
			FoundVehicleModelFolder.Name = Folder.Name
			FoundVehicleModelFolder.Parent = VehicleModel
		end
		
		for x, Module in pairs(Folder:GetChildren()) do
			if not FoundVehicleModelFolder:FindFirstChild(Folder.Name) then
				Module:Clone().Parent = FoundVehicleModelFolder
			end
		end
	end
	
	--[[for i, Module in pairs(FoundUpdatedFolder:GetChildren()) do
		Module:Clone().Parent = VehicleCoreFolder
	end]]
end

-- DIRECT
function VehiclesModule.InitialiseVehicle(NilParam, ...)
	return InitialiseVehicle(...)
end

return VehiclesModule