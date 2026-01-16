local InventoryModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerAPIsFolder = game:GetService("ServerStorage"):WaitForChild("Game")["APIs"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- APIs
local DataStore2Module = nil 

local Success, Error = pcall(function()
	DataStore2Module = require(ServerAPIsFolder["DataStore2"])
end)

-- Info Modules
local InventoryInfoModule = require(InfoModulesFolder["Inventory"])
local CamosInfoModule = require(InfoModulesFolder["Camos"])
local CoversInfoModule = require(InfoModulesFolder["Covers"])
local ArmourEffectsInfoModule = require(InfoModulesFolder["ArmourEffects"])
local VisorColoursInfoModule = require(InfoModulesFolder["VisorColours"])
local HelmetsInfoModule = require(InfoModulesFolder["Helmets"])

-- Modules
local ServerInventoryModule = require(ServerModulesFolder["Inventory"])
local DebugModule = require(SharedModulesFolder["Debug"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
--[[local TypeToHeap = 
{
	["Helmets"] = {InfoModule = HelmetsInfoModule, Heap = HelmetsInfoModule.GetAllHelmets},
	["Covers"] = {InfoModule = CoversInfoModule, Heap = CoversInfoModule.GetAllCoversInfo},
	["Camos"] = {InfoModule = CamosInfoModule, Heap = CamosInfoModule.GetAllCamosInfo},
	["ArmourEffects"] = {InfoModule = ArmourEffectsInfoModule, Heap = ArmourEffectsInfoModule.GetAllArmourEffects},
	["VisorColours"] = {InfoModule = VisorColoursInfoModule, Heap = VisorColoursInfoModule.GetAllVisorColoursInfo}
}]]

-- Functions
-- MECHANICS
local function CreateArrayFromDirectory(Directory)
	-- CORE
	--[[local Heap = TypeToHeap[Directory.Name]
	
	if Heap then
		Heap = Heap["Heap"]()
	else
		return {}
	end]]
	
	local Heap = require(UtilitiesModule:WaitForChildTimed(InfoModulesFolder, Directory.Name)):GetAllInfo()
	
	local Array = {}
	
	-- Functions
	-- INIT
	for i, Value in pairs(Directory:GetChildren()) do
		if Heap[Value.Name] then
			table.insert(Array, Heap[Value.Name]["Id"])
		else
			DebugModule:Print("Inventory | Item: ".. tostring(Value.Name).. " doesn't exist in heap: ".. tostring(Directory.Name))
		end
	end
	
	return Array
	
end

local function UnpackPlayerData(Player, CategoryFolder, PlayerData)
	-- CORE
	--local HeapInfo = TypeToHeap[CategoryFolder.Name]
	
	--if not HeapInfo then
	--	return nil
	--end
	
	local HeapInfoModule = require(UtilitiesModule:WaitForChildTimed(InfoModulesFolder, CategoryFolder.Name))
	
	-- Functions
	-- INIT
	if not PlayerData or PlayerData == {} then
		DebugModule:Print("Inventory | Failed to unpack: No player data for: ".. tostring(Player))
		return nil
	end
	
	for i, Id in pairs(PlayerData) do
		DebugModule:Print("Inventory | Unpacking Id: ".. tostring(Id).. " | Category: ".. tostring(CategoryFolder))
		
		local UnpackedValue = HeapInfoModule:UnpackId(Id) --HeapInfo["InfoModule"]:UnpackId(Id)
		
		if UnpackedValue then
			ServerInventoryModule:AddItem(Player, CategoryFolder.Name, UnpackedValue)
		end
	end
end

local function CreatePlayerInventory(Player)
	-- CORE
	local _Connections = {}
	
	-- Functions
	-- INIT
	local InventoryFolder = Instance.new("Folder")
	InventoryFolder.Name = "Inventory"
	InventoryFolder.Parent = Player
	
	for CategoryName, CategoryInfo in pairs(InventoryInfoModule:GetInventoryInfo("Categories")) do
		-- CORE
		--local HeapInfo = TypeToHeap[CategoryName]
		local HeapInfoModule = nil
		
		if InfoModulesFolder:FindFirstChild(CategoryName) then
			HeapInfoModule = require(UtilitiesModule:WaitForChildTimed(InfoModulesFolder, CategoryName))
		end
				
		local Success, Store = pcall(function()
			return DataStore2Module(CategoryName, Player)
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | CreatePlayerInventory | Error: ".. tostring(Store))
			continue
		end
		
		local EquippedStore = DataStore2Module("Equipped".. tostring(CategoryName), Player)
		local Heap = nil 
		
		if HeapInfoModule then
			Heap = HeapInfoModule:GetAllInfo()
		end
		
		--if HeapInfo then
		--	Heap = HeapInfo["Heap"]()
		--end
		
		-- INSTANCING
		local CategoryFolder = Instance.new("Folder")
		CategoryFolder.Name = CategoryName
		CategoryFolder.Parent = InventoryFolder	
		
		if not Heap then
			continue
		end
		
		-- MECHANICS
		local function Update()
			-- Functions
			-- INIT			
			local ToStore = CreateArrayFromDirectory(CategoryFolder)
			Store:Set(ToStore)
			
			local Equipped = CategoryFolder:GetAttributes()["Equipped"]
			
			DebugModule:Print("Inventory | Updating store | Category: ".. tostring(CategoryName).. " | Equipped: ".. tostring(Equipped))
			
			if Equipped and Equipped ~= "" then
				EquippedStore:Set(Heap[CategoryFolder:GetAttribute("Equipped")]["Id"])
			else
				EquippedStore:Set("")
			end
		end
		
		-- INIT
		UnpackPlayerData(Player, CategoryFolder, Store:Get({}))
		if HeapInfoModule then
			CategoryFolder:SetAttribute("Equipped", --[[HeapInfo["InfoModule"]] HeapInfoModule:UnpackId(EquippedStore:Get("")))
		end
		
		Update()
		
		-- DIRECT
		local Connection1 = CategoryFolder.ChildAdded:Connect(function()
			return Update()
		end)
		
		local Connection2 = CategoryFolder:GetAttributeChangedSignal("Equipped"):Connect(function()
			return Update()
		end)
		
		-- Connections
		table.insert(_Connections, Connection1)
		table.insert(_Connections, Connection2)
	end
	
	return _Connections
end

-- DIRECT
function InventoryModule.CreatePlayerInventory(NilParam, PlayerManagementModule, Player)
	DebugModule:Print("NilParam: ".. tostring(NilParam))
	DebugModule:Print("Player Management Module: ".. tostring(PlayerManagementModule))
	DebugModule:Print("Player: ".. tostring(Player))
	return CreatePlayerInventory(Player)
end

-- INIT
if not Success then
	DebugModule:Print(script.Name.. " | Error requiring Datastore2 Module: ".. tostring(Error))
	
	local Index = 0
	
	repeat
		Success, Error = pcall(function()
			DataStore2Module = require(ServerAPIsFolder["DataStore2"])
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | attempting to re require DataStore2 Module | Attempt: ".. tostring(Index))
		end
		
		Index += 1
		
		task.wait(1)
	until Success
end

return InventoryModule