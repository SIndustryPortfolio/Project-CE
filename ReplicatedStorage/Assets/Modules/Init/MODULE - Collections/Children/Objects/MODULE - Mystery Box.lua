local TagModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedServerWeaponsPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Weapons"]

-- Client
local Player = game.Players.LocalPlayer

-- Info Modules
local CollectionsInfoModule = require(InfoModulesFolder["Collections"])

-- Modules
local SharedObjectsModule = require(ModulesFolder["Objects"])
local PhysicsModule = require(ModulesFolder["Physics"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local SoundsModule = require(ModulesFolder["Sounds"])
local DebrisModule = require(ModulesFolder["Debris"])

-- CORE
local TweenDict = {}
local Cache = {}

local EffectInfo = 
{
	["Duration"] = 1,
	["Style"] = Enum.EasingStyle.Bounce,
	["Direction"] = Enum.EasingDirection.Out		
}

-- Services
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
local function OnStatusChanged(Model)
	-- CORE
	local CollectionInfoModule = CollectionsInfoModule:GetCollectionItemInfo(script.Name)
	
	-- Elements
	-- MODELS
	local LidModel = UtilitiesModule:WaitForChildTimed(Model, "Lid")
	
	-- PARTS
	local LidPart = LidModel["Lid"]
	
	-- FOLDERS
	local ProxiesFolder = LidModel["Proxies"] --UtilitiesModule:WaitForChildTimed(LidModel, "Proxies")
	
	-- Functions
	-- INIT
	local tweeningInfo = {}
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	local PartToTweenTo = nil
	local IdToPlay = nil
	
	if Model:GetAttributes()["Opened"] then
		PartToTweenTo = ProxiesFolder["Opened"]:FindFirstChildOfClass("Part")
		IdToPlay = CollectionInfoModule:GetInfo("OpenSound")["Id"]
	else
		PartToTweenTo = ProxiesFolder["Closed"]:FindFirstChildOfClass("Part")
	end
	
	tweeningInfo.CFrame = PartToTweenTo.CFrame
	
	UtilitiesModule:CancelTween(LidPart, TweenDict)
	TweenDict[LidPart] = TweenService:Create(LidPart, tweenInfo, tweeningInfo)
	
	if Model:GetAttributes()["Occupant"] == Player.Name then
		SoundsModule:PlaySoundEffectByName("Shop", "PurchaseComplete")
	end
	
	if IdToPlay then
		SoundsModule:PlaySoundEffectById(IdToPlay, nil, LidPart)
	end
	
	TweenDict[LidPart]:Play()
	UtilitiesModule:CompleteTween(LidPart, TweenDict)
end

local function OnCurrentWeaponChanged(Model)
	-- CORE
	local CollectionInfoModule = CollectionsInfoModule:GetCollectionItemInfo(Model.Name)
	
	-- Elements
	-- MODELS
	local LidModel = UtilitiesModule:WaitForChildTimed(Model, "Lid")
	
	-- PARTS
	local GunLocationPart = LidModel["GunLocation"]
	
	-- Functions
	-- INIT
	--[[local FoundPreviousWeaponModel = GunLocationPart:FindFirstChildOfClass("Model")
	
	if FoundPreviousWeaponModel then
		DebrisModule:AddItem(FoundPreviousWeaponModel)
	end]]
	
	for i, ChildModel in pairs(GunLocationPart:GetChildren()) do
		DebrisModule:AddItem(ChildModel)
	end
	
	local FoundNewWeaponModel = SharedServerWeaponsPartsFolder:FindFirstChild(Model:GetAttributes()["CurrentWeapon"])
	
	if not FoundNewWeaponModel then
		return nil
	end
	
	FoundNewWeaponModel = FoundNewWeaponModel:Clone()
	local FoundBasePart = FoundNewWeaponModel:FindFirstChild("Base")

	if FoundBasePart then
		FoundNewWeaponModel["Base"].CFrame = GunLocationPart.CFrame
	else
		FoundNewWeaponModel:SetPrimaryPartCFrame(GunLocationPart.CFrame)
	end
	
	FoundNewWeaponModel.Parent = GunLocationPart
	
	SoundsModule:PlaySoundEffectById(CollectionInfoModule:GetInfo("TickSound")["Id"], nil, GunLocationPart)
	
	task.wait(.05)
	
	if FoundNewWeaponModel then
		pcall(function()
			PhysicsModule:ServerRequest("Anchored", FoundNewWeaponModel, true)
		end)
	end 
end

local function Initialise(Model)
	-- Functions
	-- DIRECT
	local Connection1 = Model:GetAttributeChangedSignal("Opened"):Connect(function()
		return OnStatusChanged(Model)
	end)
	
	local Connection2 = Model:GetAttributeChangedSignal("CurrentWeapon"):Connect(function()
		return OnCurrentWeaponChanged(Model)
	end)
	
	-- CONNECTIONS
	Cache[Model] = {Connection1, Connection2}
end

local function End(Model)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Cache[Model])
end

-- DIRECT
function TagModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function TagModule.End(NilParam, ...)
	return End(...)
end

return TagModule