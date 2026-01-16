local TagModule = {}

-- Dirs
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local SharedPartsServerWeaponsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]
local SharedGameLobbyFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Lobby"]

-- Info Modules
local CollectionsInfoModule = require(SharedInfoModulesFolder["Collections"])
local ObjectsInfoModule = require(SharedInfoModulesFolder["Objects"])
local WeaponsInfoModule = require(SharedInfoModulesFolder["Weapons"])

-- Modules
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])
local ServerObjectsModule = require(ServerModulesFolder["Objects"])
local ObjectsModule = require(SharedModulesFolder["Objects"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebrisModule = require(SharedModulesFolder["Debris"])
local DebugModule = require(SharedModulesFolder["Debug"])
local PhysicsModule = require(SharedModulesFolder["Physics"])
local MapLoaderModule = require(ServerModulesFolder["Maps"]["MapLoader"])

local Connections = {}

-- Services
--local DebrisService = game:GetService("Debris")
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
--[[local function GetAllNoneBoxWeaponNames()
	-- CORE
	local NoneBoxWeaponNames = {}
	
	-- Functions
	-- INIT
	for WeaponName, WeaponInfo in pairs(WeaponsInfoModule:GetAllWeaponInfos()) do
		if WeaponInfo and WeaponInfo["DevOnly"] then
			table.insert(NoneBoxWeaponNames, WeaponName)
		end
	end
	
	return NoneBoxWeaponNames
end]]

local function SetCanQuery(MysteryBox, Value)
	-- Functions
	-- INIT
	for i, Part in pairs(MysteryBox:GetDescendants()) do
		if not Part:IsA("BasePart") then
			continue
		end
		
		pcall(function()
			Part.CanTouch = Value
			Part.CanQuery = Value
		end)
	end
end

local function AddToCache(Model, _Connections)
	-- Functions
	-- INIT
	if Connections[Model] == nil then
		Connections[Model] = {}
	end

	for i, Connection in pairs(_Connections) do
		table.insert(Connections[Model], Connection)
	end
end

local function RemoveFromCache(Model)
	-- Functions
	-- INIT
	if not Connections[Model] then
		return nil
	end

	UtilitiesModule:DisconnectConnections(Connections[Model])
	Connections[Model] = nil
end

local function Initialise(MysteryBox)
	-- Functions
	-- INIT
	--ObjectsModule:CreateInstancesFromDict(MysteryBox, CollectionsInfoModule:GetCollectionItemInfo(script.Name):GetInfo("Properties"))
	
	-- INIT
end

local function End(MysteryBox)	
	-- Functions
	-- INIT
	RemoveFromCache(MysteryBox)
	task.wait(.3)
	ServerObjectsModule:ObjectProcess("Respawn", MysteryBox)
	DebrisModule:AddItem(MysteryBox)
end

local function OpenCycle(Player, MysteryBox)
	-- Elements
	-- MODELS
	local LidModel = UtilitiesModule:WaitForChildTimed(MysteryBox, "Lid")
	
	-- PARTS
	local GunLocationPart = LidModel["GunLocation"]
	
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	--local NoneBoxWeaponNames = GetAllNoneBoxWeaponNames()
	
	if not Character then
		return nil
	end
	
	local ChangedParent = false
	local CollectionInfoModule = CollectionsInfoModule:GetCollectionItemInfo(script.Name)
	local AllWeaponNames = ShortcutsModule:GetAllNoneDevWeaponNames() --[[UtilitiesModule:GetChildrenNames(SharedPartsServerWeaponsFolder)
	
	for i, WeaponName in pairs(NoneBoxWeaponNames) do
		if table.find(AllWeaponNames, WeaponName) then
			table.remove(AllWeaponNames, table.find(AllWeaponNames, WeaponName))
		end
	end]]
	
	for i, WeaponAttributeType in pairs({"Primary", "Secondary"}) do
		if table.find(AllWeaponNames, Character:GetAttribute(WeaponAttributeType)) then
			table.remove(AllWeaponNames, table.find(AllWeaponNames, Character:GetAttribute(WeaponAttributeType)))
		end
	end
	
	local ChosenWeapon = AllWeaponNames[math.random(1, #AllWeaponNames)]
	
	-- Functions
	-- INIT
	--SetCanQuery(MysteryBox, false)
	ObjectsModule:ObjectProcess("NoneRaycastable", MysteryBox)
	
	for i = 1, CollectionInfoModule:GetInfo("Rotations") do
		local NextWeaponName = ""
		
		repeat
			NextWeaponName = AllWeaponNames[math.random(1, #AllWeaponNames)]
		until NextWeaponName ~= MysteryBox:GetAttributes()["CurrentWeapon"]
		
		MysteryBox:SetAttribute("CurrentWeapon", NextWeaponName)
		
		task.wait(math.random(1, 100) / 1000)
	end
	
	MysteryBox:SetAttribute("CurrentWeapon", "")
	
	local FoundServerWeaponModel = SharedPartsServerWeaponsFolder:FindFirstChild(ChosenWeapon):Clone()
	FoundServerWeaponModel:SetAttribute("MysteryBox", true)
	FoundServerWeaponModel:SetAttribute("RestrictedToUser", Player.Name)
	FoundServerWeaponModel:SetAttribute("DontDropNextWeapon", true)
	FoundServerWeaponModel:SetAttribute("NoneRespawnable", true)
	FoundServerWeaponModel.Parent = workspace["Dump"]["Weapons"]
	
	local FoundBasePart = FoundServerWeaponModel:FindFirstChild("Base")

	if FoundBasePart then
		FoundServerWeaponModel["Base"].CFrame = GunLocationPart.CFrame
	else
		FoundServerWeaponModel:SetPrimaryPartCFrame(GunLocationPart.CFrame)
	end
	
	for i = 1, 2 do
		RunService.Heartbeat:Wait()
	end
	
	MapLoaderModule:SetupMapWeapon(FoundServerWeaponModel, true, true)
	
	
	local Connection1 = FoundServerWeaponModel:GetPropertyChangedSignal("Parent"):Connect(function()
		ChangedParent = true
	end)
	
	--PhysicsModule:ServerRequest("Anchored", FoundServerWeaponModel, true)
	
	local Difference = 0
	local TimeNow = tick()
	
	repeat
		Difference = tick() - TimeNow
		task.wait()
	until Difference >= 10 or ChangedParent
	
	return FoundServerWeaponModel
end

local function Purchase(Player, MysteryBox)
	-- CORE
	local CollectionInfoModule = CollectionsInfoModule:GetCollectionItemInfo(MysteryBox.Name)
	local FoundPlayerLobbyValue = SharedGameLobbyFolder:FindFirstChild(Player.Name)
	
	-- Functions
	-- INIT
	if MysteryBox:GetAttributes()["Opened"] or not FoundPlayerLobbyValue then
		return nil
	end
	
	if FoundPlayerLobbyValue:GetAttributes()["Score"] < CollectionInfoModule:GetInfo("Price") then
		DebugModule:Print(script.Name.. " | Purchase failed | Insufficient funds | Player: ".. tostring(Player).. " | Player Score: ".. tostring(FoundPlayerLobbyValue:GetAttributes()["Score"]))
		return nil
	end
	
	FoundPlayerLobbyValue:SetAttribute("Score", FoundPlayerLobbyValue:GetAttribute("Score") - CollectionInfoModule:GetInfo("Price"))
	
	DebugModule:Print(script.Name.. " | Purchasing | Player: ".. tostring(Player))
	
	if not MysteryBox or not Player then
		DebugModule:Print(script.Name.. " | Purchase | Cannot purchase V")
		DebugModule:Print(script.Name.. " | MusteryBox: ".. tostring(MysteryBox))
		DebugModule:Print(script.Name.. " | Player: ".. tostring(Player))
		return nil
	end
	
	MysteryBox:SetAttribute("Occupant", Player.Name)
	MysteryBox:SetAttribute("Opened", true)
	
	task.wait(1)
	local ReturnedModel = OpenCycle(Player, MysteryBox)
	
	if ReturnedModel and not ReturnedModel:GetAttributes()["Technology"] then
		DebrisModule:AddItem(ReturnedModel)
	end
	
	MysteryBox:SetAttribute("Occupant", "")
	MysteryBox:SetAttribute("CurrentWeapon", "")
	MysteryBox:SetAttribute("Opened", false)
	
	ObjectsModule:ObjectProcess("Raycastable", MysteryBox)
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Purchase"] = Purchase
}

-- DIRECT
function TagModule.ClientRequest(NilParam, Player, FunctionName, ...)
	return ClientRequests[FunctionName](Player, ...)
end

function TagModule.Initialise(NilParam, MysteryBox)
	return Initialise(MysteryBox)
end

function TagModule.End(NilParam, MysteryBox)
	return End(MysteryBox)
end

return TagModule