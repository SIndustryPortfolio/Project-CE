local MapLoaderModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedServerWeaponsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])
local PhysicsModule = require(SharedModulesFolder["Physics"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
local DebrisModule = require(SharedModulesFolder["Debris"])

-- CORE
local MapToConnections = {}

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function LoadGrenades(Map, PickupGrenades)
	-- Functions
	-- INIT
	local ContentsFolder = UtilitiesModule:WaitForChildTimed(Map, "Contents")
	local GrenadesFolder = ContentsFolder:FindFirstChild("Grenades")
	
	if not GrenadesFolder then
		return nil
	end
	
	-- DIRECT
	local Connection1 = GrenadesFolder.ChildAdded:Connect(function(GrenadeModel)
		GrenadeModel.Parent = workspace:WaitForChild("Dump")["Grenades"]
	end)
	
	for i, GrenadeModel in pairs(GrenadesFolder:GetChildren()) do
		if PickupGrenades then
			GrenadeModel.Parent = workspace:WaitForChild("Dump")["Grenades"]
		else
			GrenadeModel:Destroy()
		end
	end
	
	return {Connection1}
end

local function UnloadVehicles(Map)
	-- Functions
	-- INIT
	for i, VehicleModel in pairs(workspace:WaitForChild("Dump")["Vehicles"]:GetChildren()) do
		VehicleModel:Destroy()
	end
end

local function LoadVehicles(Map, PickupVehicles)
	-- Functions
	-- INIT
	local ContentsFolder = UtilitiesModule:WaitForChildTimed(Map, "Contents")
	local VehiclesFolder = ContentsFolder:FindFirstChild("Vehicles")

	if not VehiclesFolder then
		return nil
	end

	-- MECHANICS
	local function SetupMapVehicle(VehicleModel)
		-- Functions
		-- INIT
		if PickupVehicles then			
			VehicleModel.Parent = workspace:WaitForChild("Dump")["Vehicles"]
		else
			VehicleModel:Destroy()
		end
	end

	-- DIRECT
	local Connection1 = VehiclesFolder.ChildAdded:Connect(function(VehicleModel)
		return SetupMapVehicle(VehicleModel)
	end)

	for i, VehicleModel in pairs(VehiclesFolder:GetChildren()) do
		SetupMapVehicle(VehicleModel)
	end

	return {Connection1}
end

local function SetupMapWeapon(WeaponModel, PickupWeapons, IgnoreClone)
	-- Functions
	-- INIT
	if PickupWeapons then			
		--WeaponModel.Parent = workspace:WaitForChild("Dump")["Weapons"]
		local FoundNewWeaponModel = SharedServerWeaponsFolder:FindFirstChild(WeaponModel.Name)

		if not FoundNewWeaponModel then
			WeaponModel.Parent = workspace:WaitForChild("Dump")["Weapons"]
			return nil
		end

		local NewWeaponClone = nil 
		
		if not IgnoreClone then
			NewWeaponClone = FoundNewWeaponModel:Clone()
			NewWeaponClone:SetPrimaryPartCFrame(WeaponModel.PrimaryPart.CFrame)
		else
			NewWeaponClone = WeaponModel
		end
		
		PhysicsModule:ServerRequest("Anchored", NewWeaponClone, true)
		ObjectsModule:ObjectProcess("Raycastable", NewWeaponClone)
		
		pcall(function()
			NewWeaponClone.Parent = workspace:WaitForChild("Dump")["Weapons"]
		end)

		if not table.find(CollectionService:GetTags(NewWeaponClone), "Weapons") then
			CollectionService:AddTag(NewWeaponClone, "Weapons")
		end
		
		if not IgnoreClone then
			WeaponModel:Destroy()
		end
	else
		if not IgnoreClone then
			WeaponModel:Destroy()
		end
	end
end

local function LoadWeapons(Map, PickupWeapons)
	-- Functions
	-- INIT
	local ContentsFolder = UtilitiesModule:WaitForChildTimed(Map, "Contents")
	local WeaponsFolder = ContentsFolder:FindFirstChild("Weapons")
	
	if not WeaponsFolder then
		return nil
	end
	
	-- MECHANICS
	-- DIRECT
	local Connection1 = WeaponsFolder.ChildAdded:Connect(function(WeaponModel)
		return SetupMapWeapon(WeaponModel, PickupWeapons)
	end)
	
	for i, WeaponModel in pairs(WeaponsFolder:GetChildren()) do
		SetupMapWeapon(WeaponModel, PickupWeapons)
	end
	
	return {Connection1}
end

local function UnloadGrenades(Map)
	-- Functions
	-- INIT
	for i, GrenadeModel in pairs(workspace:WaitForChild("Dump")["Grenades"]:GetChildren()) do
		GrenadeModel:Destroy()
	end
end

local function UnloadWeapons(Map)
	-- Functions
	-- INIT
	for i, WeaponModel in pairs(workspace:WaitForChild("Dump")["Weapons"]:GetChildren()) do
		WeaponModel:Destroy()
	end
end

local function ToggleCollections(Map, Toggle)
	-- Functions
	-- INIT
	local ContentsFolder = UtilitiesModule:WaitForChildTimed(Map, "Contents")
	local CollectionsFolder = UtilitiesModule:WaitForChildTimed(ContentsFolder, "Collections")
	local WeaponsFolder = UtilitiesModule:WaitForChildTimed(ContentsFolder, "Weapons")
	local GrenadesFolder = UtilitiesModule:WaitForChildTimed(ContentsFolder, "Grenades")
	
	if CollectionsFolder then
		for i, Folder in pairs(CollectionsFolder:GetChildren()) do
			for x, Model in pairs(Folder:GetChildren()) do
				if Toggle then
					--DebugModule:Print("MapLoader | Adding collection: ".. tostring(Folder.Name).. " | To: ".. tostring(Model))
					CollectionService:AddTag(Model, Folder.Name)
				else
					CollectionService:RemoveTag(Model, Folder.Name)
				end
			end
		end
	end
	
	--[[if WeaponsFolder then
		for i, Model in pairs(WeaponsFolder:GetChildren()) do
			if Toggle then
				CollectionService:AddTag(Model, WeaponsFolder.Name)
			else
				CollectionService:RemoveTag(Model, WeaponsFolder.Name)
			end
		end
	end]]
	
	if GrenadesFolder then
		for i, Model in pairs(GrenadesFolder:GetChildren()) do
			if Toggle then
				CollectionService:AddTag(Model, GrenadesFolder.Name)
			else
				CollectionService:Remove(Model, GrenadesFolder.Name)
			end
		end
	end
end

local function LoadMap(Map, PickupWeapons, PickupVehicles, PickupGrenades)
	-- Functions
	-- INIT
	ToggleCollections(Map, true)
	local WeaponConnections = LoadWeapons(Map, PickupWeapons)
	local GrenadeConnections = LoadGrenades(Map, PickupGrenades)
	local VehicleConnections = LoadVehicles(Map, PickupVehicles)
	
	MapToConnections[Map.Name] = UtilitiesModule:UnpackConnectionsToLargeTable(WeaponConnections, GrenadeConnections, VehicleConnections) --{unpack(WeaponConnections), unpack(GrenadeConnections)}
end

local function UnloadTemporary()
	-- Functions
	-- INIT
	for i, CategoryFolder in pairs(workspace["Temporary"]:GetChildren()) do
		for x, _Instance in pairs(CategoryFolder:GetChildren()) do
			DebrisModule:AddItem(_Instance)
		end
	end
end

local function UnloadMap(Map)
	-- Functions
	-- INIT
	ToggleCollections(Map, false)
	UnloadGrenades(Map)
	UnloadWeapons(Map)
	UnloadVehicles(Map)
	UnloadTemporary()
	
	UtilitiesModule:DisconnectConnections(MapToConnections[Map.Name])
	MapToConnections[Map.Name] = nil
end

-- DIRECT
function MapLoaderModule.SetupMapWeapon(NilParam, ...)
	return SetupMapWeapon(...)
end

function MapLoaderModule.LoadMap(NilParam, ...)
	return LoadMap(...)
end

function MapLoaderModule.UnloadMap(NilParam, Map)
	return UnloadMap(Map)
end

return MapLoaderModule