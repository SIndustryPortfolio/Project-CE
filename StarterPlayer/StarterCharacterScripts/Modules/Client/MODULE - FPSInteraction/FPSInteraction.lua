local FPSInteractionModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent

-- EXT
local DumpFolder = workspace:WaitForChild("Dump")
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local ClientRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["Client"]["Remotes"]

local WorkspaceMapFolder = workspace:WaitForChild("Map")

-- Client
local Player = game.Players.LocalPlayer

-- Info Modules
local CharacterInfoModule = require(InfoModulesFolder["Character"])
local KeybindsInfoModule = require(InfoModulesFolder["Keybinds"])
local CollectionsInfoModule = require(InfoModulesFolder["Collections"])
---local CollectionsInfoModule = require(InfoModulesFolder["Collections"])

-- Modules
local DebrisModule = require(ModulesFolder["Debris"])
local MapsModule = require(ModulesFolder["Maps"])
local InterfacesModule = require(ModulesFolder["Interfaces"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])
local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud", true)
local OnTouchModule = require(UtilitiesModule:WaitForChildTimed(script, "OnTouch"))
--local ShortcutsModule = require(ModulesFolder["Shortcuts"])

-- Elements
-- FOLDERS
local CharacterCoreFolder = UtilitiesModule:WaitForChildTimed(Character, "Core")
local ServerMapFolder = WorkspaceMapFolder:WaitForChild("Server")

-- VALUES
local CharacterVehicleValue = CharacterCoreFolder["Vehicle"]

-- REMOTES
local InterfaceRemote = ClientRemotesFolder["Interface"]

-- HUMANOIDS
local Humanoid = Character:FindFirstChildOfClass("Humanoid")

-- PARTS
local HumanoidRootPart = Character.PrimaryPart --Character:WaitForChild("HumanoidRootPart")

-- FOLDERS
local WeaponsFolder = DumpFolder["Weapons"]
local CharacterRemotesFolder = UtilitiesModule:WaitForChildTimed(Character, "Remotes")

if not CharacterRemotesFolder then
	return {}
end

local CharacterClientServerRemotesFolder = CharacterRemotesFolder["ClientServer"]["Remotes"]

-- Remotes
local CharacterProcessRemote = CharacterClientServerRemotesFolder["CharacterProcess"]

-- CORE
local BlackListDump = {"Misc", "Ui", "Client"}

local Connections = {}
local CustomConnections = {}

local RequiredModules = {}

--local TouchedOnly = {"Power Up Drops"} -- PHYSICAL COLLISSION (NOT DISTANCE CHECK)

local MapBlacklistFolders = {"Fusion Coil", "Plasma Battery", "Death Zone", "Sentinel", "Wooden Pallet"}

local DebouncedObjects = {}

local DebounceTime = .5 -- Seconds

local InteractDebounceTime = .5
local InteractDebounce = false

--local CharacterVehicleValue = ShortcutsModule:GetCharacterCoreValueInstance(Player, "Vehicle")

local Touching = {}

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function CreateHighlight()
	-- Functions
	-- INIT
	local Highlight = Instance.new("Highlight")
	Highlight.FillTransparency = 1
	
	return Highlight
end

local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(UtilitiesModule:WaitForChildTimed(script, "Handlers"), true, FPSInteractionModule)
end

local function TouchEnd(Model)
	-- Functions
	-- INIT
	if typeof(Model) ~= "Instance" then
		DebugModule:Print(script.Name.. " | TouchEnd | Model: ".. tostring(Model))
		return nil
	end
	
	local Parent = Model.Parent
	
	for i, Highlight in pairs(Model:GetChildren()) do
		if not Highlight:IsA("Highlight") then
			continue
		end
		
		DebrisModule:AddItem(Highlight)
	end
	
	--[[local FoundHighlight = Model:FindFirstChildOfClass("Highlight")
	
	if FoundHighlight then
		DebrisModule:AddItem(FoundHighlight)
	end]]
	
	Touching[Model] = nil
	
	--[[if Parent and RequiredModules[Parent.Name] ~= nil then
		--DebugModule:Print("FPSInteraction | Ending touch: ".. tostring(Model))
		return RequiredModules[Parent.Name]:End(Model)
	end]]
end

local function OnTouch(Model, PhysicalTouch)
	-- Functions
	-- INIT
	if not Model or not Character then
		return nil
	end
	
	if not Model:FindFirstChildOfClass("Highlight") and not PhysicalTouch then
		local HighLight = CreateHighlight()
		HighLight.Parent = Model
	end
		
	table.insert(DebouncedObjects, Model)
	
	local Parent = Model.Parent
	
	----DebugModule:Print"Touched: ".. tostring(Model.Name))
	
	Touching[Model] = true
	
	coroutine.wrap(function()
		task.wait(DebounceTime)
		local FoundIndex = table.find(DebouncedObjects, Model)
		
		if FoundIndex then
			table.remove(DebouncedObjects, FoundIndex)
		end
	end)()	
	
	if Parent and RequiredModules[Parent.Name] ~= nil then
		local Success, Error = pcall(function()
			return RequiredModules[Parent.Name]:Initialise(Model)
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | OnTouch | Model: ".. tostring(Model).. " | Parent: ".. tostring(Parent).. " | Error: ".. tostring(Error))
		else
			return Error
		end
	end
end

local function CheckSubFolder(SubFolder, _PartToCheckName)
	-- Functions
	-- INIT
	local Touched, _Distance, _Model = false, math.huge, nil
	
	for x, Model in pairs(SubFolder:GetChildren()) do
		local PartToCheck = nil
		local IsTouchOnly = false
		
		if _PartToCheckName then
			PartToCheck = Model:FindFirstChild(_PartToCheckName) or UtilitiesModule:GetPartToShift(Model)	
		else
			PartToCheck = UtilitiesModule:GetPartToShift(Model)
		end
		
		--[[if not PartToCheck then
			if Model:IsA("Model") and not Model.PrimaryPart then
				continue
			elseif Model:IsA("Model") then
				PartToCheck = PartToCheck.PrimaryPart
			end
		end]]
		
		if not PartToCheck then
			continue
		end
		
		local AllTags = CollectionService:GetTags(Model)
		
		for i, TagName in pairs(AllTags) do
			local FoundInfoModule = CollectionsInfoModule:GetCollectionInfo(TagName)
			
			if not FoundInfoModule then
				continue
			end
			
			if FoundInfoModule:GetInfo("TouchOnly") then
				IsTouchOnly = true
			end
		end
		
		
		local Distance = (PartToCheck.Position - HumanoidRootPart.Position).Magnitude
		
		if Distance <= CharacterInfoModule:GetCharacterInfo("PickupDistance") and Distance < _Distance and not --[[table.find(TouchedOnly, SubFolder.Name)]] IsTouchOnly then			
			local RayDirection = (PartToCheck.Position - HumanoidRootPart.Position).Unit * (CharacterInfoModule:GetCharacterInfo("PickupDistance") * 3)
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = {Character, unpack(MapsModule:GetMapRaycastBlacklistFolders())}
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude --Enum.RaycastFilterType.Blacklist
			local raycastResult = workspace:Raycast(HumanoidRootPart.Position, RayDirection, raycastParams)

			if raycastResult and raycastResult.Instance then
				if not raycastResult.Instance:IsDescendantOf(Model) and raycastResult.Instance ~= PartToCheck then
					DebugModule:Print("FPSInteraction | Skipping this iteration -> Something blocked the way: ".. tostring(raycastResult.Instance).. " | Model: ".. tostring(Model).. " | Parent: ".. tostring(raycastResult.Instance.Parent).. " | Ancestor: ".. tostring(raycastResult.Instance.Parent.Parent))
					continue
				end
			end
			
			Touched = true
			
			if not table.find(DebouncedObjects, Model) then
				--OnTouch(Model)
				_Distance = Distance
				_Model = Model
				--DebugModule:Print("Player touched: ".. tostring(Model))
			end
		end
	end
	
	--[[if Touched and _Model then
		OnTouch(_Model) -- TRY IT CONTINUE
	end]]
	
	return Touched, _Model, _Distance
end

local function CheckAll()
	-- Functions
	-- INIT
	if not SharedGameFolder or CharacterVehicleValue.Value ~= nil then
		--[[DebugModule:Print(script.Name.. " | Skipping check v")
		DebugModule:Print(script.Name.. " | SharedGameFolder: ".. tostring(SharedGameFolder))
		DebugModule:Print(script.Name.. " | CharacterVehicleValue: ".. tostring(CharacterVehicleValue.Value))]]
		
		return nil
	end
	
	local MapFolder = ServerMapFolder:FindFirstChild(SharedGameFolder:GetAttributes()["Map"])
	
	if not MapFolder then
		return nil
	end
	
	for TouchingModel, Value in pairs(Touching) do
		local Success, Error = pcall(function()
			local PartToShift = UtilitiesModule:GetPartToShift(TouchingModel)
			
			if not --[[TouchingModel:IsDescendantOf(workspace["Dump"])]] TouchingModel or TouchingModel == CharacterVehicleValue.Value or (Character.PrimaryPart.Position - PartToShift.Position).Magnitude > CharacterInfoModule:GetCharacterInfo("PickupDistance") then -- -- - -
				return TouchEnd(TouchingModel)
			end
		end)
	end
	
	local Closest, TouchingModel = math.huge, nil
	
	for i, SubFolder in pairs(DumpFolder:GetChildren()) do
		if table.find(BlackListDump, SubFolder.Name) ~= nil then
			continue
		end
		local HasTouched, TouchModel, Distance = CheckSubFolder(SubFolder, "Base")
		
		if HasTouched then
			if Distance < Closest then
				Closest = Distance
				TouchingModel = TouchModel
			end
		end
		
		--DebugModule:Print(script.Name.. " | SubFolder: ".. tostring(SubFolder.Name).. " | HasTouched: ".. tostring(HasTouched))
		
		if not HasTouched and RequiredModules[SubFolder.Name] and RequiredModules[SubFolder.Name].SetTouching ~= nil then
			local Success, Error = pcall(function()
				return RequiredModules[SubFolder.Name]:SetTouching(nil)

				--[[if HudGuiModule then
					HudGuiModule:HudProcess("WeaponSwitch", "StopHint")
				end]]
			end)

			if not Success then
				DebugModule:Print(script.Name.. " | CheckAll | Error: ".. tostring(Error))
			end
			
			continue
		end
		
		--[[if SubFolder.Name == "Weapons" and not HasTouched then
			local Success, Error = pcall(function()
				RequiredModules["Weapons"]:SetTouchingWeapon(nil)

				if HudGuiModule then
					HudGuiModule:HudProcess("WeaponSwitch", "StopHint")
				end
			end)

			if not Success then
				DebugModule:Print(script.Name.. " | Error: ".. tostring(Error))
			end
			
			continue
		end
		
		if SubFolder.Name == "Vehicles" and not HasTouched then
			local Success, Error = pcall(function()
				RequiredModules["Vehicles"]:SetTouchingVehicle(nil)

				if HudGuiModule then
					HudGuiModule:HudProcess("VehicleSwitch", "StopHint")
				end
			end)

			if not Success then
				DebugModule:Print(script.Name.. " | Error: ".. tostring(Error))
			end
			
			continue
		end]]
		
		if not HasTouched and RequiredModules[SubFolder.Name] and RequiredModules[SubFolder.Name].End ~= nil then
			RequiredModules[SubFolder.Name]:End()
		end
	end
	
	for i, SubFolder in pairs(UtilitiesModule:WaitForChildTimed(MapFolder, "Contents")["Collections"]:GetChildren()) do
		if table.find(MapBlacklistFolders, SubFolder.Name) ~= nil then
			continue
		end
		
		local InfoModule = CollectionsInfoModule:GetCollectionItemInfo(SubFolder.Name)
		
		if InfoModule and InfoModule:GetInfo("TouchOnly") then
			continue
		end
		
		local HasTouched, TouchModel, Distance = CheckSubFolder(SubFolder)
		
		if HasTouched then
			if Distance < Closest then
				Closest = Distance
				TouchingModel = TouchModel
			end
		end
		
		if not HasTouched and RequiredModules[SubFolder.Name] and RequiredModules[SubFolder.Name].SetTouching ~= nil then
			local Success, Error = pcall(function()
				return RequiredModules[SubFolder.Name]:SetTouching(nil)

				--[[if HudGuiModule then
					HudGuiModule:HudProcess("WeaponSwitch", "StopHint")
				end]]
			end)

			if not Success then
				DebugModule:Print(script.Name.. " | CheckAll | Error: ".. tostring(Error))
			end

			continue
		end
		
		if TouchingModel then
			OnTouch(TouchingModel)
		end
		
		if not HasTouched then
			if RequiredModules[SubFolder.Name] and RequiredModules[SubFolder.Name].End ~= nil then
				DebugModule:Print("FPSInteraction | Touch End: ".. tostring(SubFolder))
				RequiredModules[SubFolder.Name]:End()
			end
		end
	end
end

local function End()
	-- Functions
	-- INIT
	RunService:UnbindFromRenderStep("FPSInteraction")
	UtilitiesModule:DisconnectCustomConnections(CustomConnections)
	UtilitiesModule:DisconnectConnections(Connections)
	
	for ModuleName, RequiredModule in pairs(RequiredModules) do
		if RequiredModule and RequiredModule.End ~= nil then
			RequiredModule:End()
			
			if RequiredModule.GarbageCollect ~= nil then
				RequiredModule:GarbageCollect()
			end
		end
	end
	
	for i, Model in pairs(Touching) do
		TouchEnd(Model)
	end
end

local function Interact()
	-- Functions
	-- INIT
	if InteractDebounce then
		return nil
	end
		
	local ClosestModule, ClosestModel, Distance = nil, nil, math.huge
	
	for ModuleName, Module in pairs(RequiredModules) do
		if Module.Switch == nil or Module.GetTouching == nil then
			continue
		end
		
		local TouchingModel = Module:GetTouching()
		
		if not TouchingModel then
			continue
		end
		
		local _Distance = nil
		
		pcall(function()
			_Distance = (Character.PrimaryPart.Position - UtilitiesModule:GetPartToShift(TouchingModel).Position).Magnitude
		end)
		
		if _Distance and _Distance <= Distance then
			ClosestModule = Module
			ClosestModel = TouchingModel
			Distance = _Distance
		end
	end
	
	if ClosestModule and ClosestModule.Switch ~= nil then
		InteractDebounce = true
		
		local Success, Error = pcall(function()
			ClosestModule:Switch()
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | Interact | Error: ".. tostring(Error))
		end
		
		task.wait(InteractDebounceTime)
		InteractDebounce = false
	end
end

local function Initialise()
	-- CORE
	local LastHoldTime = tick()
	local EndTime = 0
	
	-- Functions
	-- DIRECT
	local Connection1 = UserInputService.InputBegan:Connect(function(InputObject, GameProcessedEvent)
		if GameProcessedEvent or InteractDebounce then
			return nil
		end

		if table.find(KeybindsInfoModule:GetKeybindInfo("Interact"), InputObject.KeyCode) ~= nil then
			LastHoldTime = tick()
			
			repeat
				task.wait()
				
				if EndTime > LastHoldTime then
					return nil
				end
				
			until tick() - LastHoldTime > .1
			
			Interact()
		end
	end)
	
	local Connection2 = UserInputService.InputEnded:Connect(function(InputObject, GameProcessedEvent)
		if GameProcessedEvent or InteractDebounce then
			return nil
		end
		
		if table.find(KeybindsInfoModule:GetKeybindInfo("Interact"), InputObject.KeyCode) ~= nil then
			local TimeNow = tick()
			
			EndTime = TimeNow
		end

	end)
	
	-- CONNECTIONS
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
	
	-- INIT
	local CustomConnection = UtilitiesModule:CreateCustomConnection(CustomConnections)
	
	local Success, Error = pcall(function()
		return OnTouchModule:Initialise(FPSInteractionModule)
	end)
	
	if not Success then
		DebugModule:Print(script.Name.. " | Initialise | Module: OnTouch | Error: ".. tostring(Error))
	end
	
	RunSubModules()
	
	RunService:BindToRenderStep("FPSInteraction", Enum.RenderPriority.Last.Value, CheckAll)
	
	--[[coroutine.wrap(function()
		while task.wait() and CustomConnection and CustomConnection.Value and Humanoid and Humanoid.Health >= 0 do
			CheckAll()
		end
	end)()]]
end

local function GarbageCollect()
	-- Functions
	-- INIT
	Character = nil
	--
	DumpFolder = nil
	ModulesFolder = nil
	InfoModulesFolder = nil
	SharedGameFolder = nil
	ClientRemotesFolder = nil
	WorkspaceMapFolder = nil
	--
	CharacterInfoModule = nil
	KeybindsInfoModule = nil
	--
	InterfacesModule = nil
	UtilitiesModule = nil
	DebugModule = nil
	HudGuiModule = nil
	--
	InterfaceRemote = nil
	--
	Humanoid = nil
	--
	HumanoidRootPart = nil
	--
	WeaponsFolder = nil
	CharacterRemotesFolder = nil
	--
	CharacterClientServerRemotesFolder = nil
	--
	CharacterProcessRemote = nil
	--
	BlackListDump = nil
	Connections = nil
	CustomConnections = nil
	RequiredModules = nil
	MapBlacklistFolders = nil
	DebouncedObjects = nil
	DebounceTime = nil
end

-- DIRECT
function FPSInteractionModule.GarbageCollect()
	GarbageCollect()
end

function FPSInteractionModule.OnTouch(NilParam, Model, ...)
	if Model and Model.Parent --[[and table.find(TouchedOnly, Model.Parent.Name)]] then
		return OnTouch(Model, ...)
	end
end

function FPSInteractionModule.Initialise()
	return Initialise()
end

function FPSInteractionModule.End()
	return End()
end

return FPSInteractionModule