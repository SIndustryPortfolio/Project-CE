local TagModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local CollectionsInfoModule = require(SharedInfoModulesFolder["Collections"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local SoundsModule = require(SharedModulesFolder["Sounds"])

-- CORE
local TweenDict = {}
local Connections = {}

local EffectInfo = 
{
	["Duration"] = 2,
	["Style"] = Enum.EasingStyle.Cubic,
	["Direction"] = Enum.EasingDirection.InOut		
}

-- Services
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
local function StateChanged(PowerSwitchModel, State)
	-- CORE
	local CollectionInfoModule = CollectionsInfoModule:GetCollectionItemInfo(script.Name)
	
	-- Elements
	-- MODELS
	local HandleModel = UtilitiesModule:WaitForChildTimed(PowerSwitchModel, "Handle")
	
	-- FOLDERS
	local ProxiesFolder = HandleModel["Proxies"]
	local ChosenFolder = nil
	
	-- PARTS
	local PowerSwitchHandlesPart = HandleModel["PowerSwitchHandles"]
	
	-- CORE
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	local StateToFolderName = 
	{
		[true] = "On",
		[false]	= "Off"
	}

	ChosenFolder = ProxiesFolder[StateToFolderName[State]]
	local ChosenProxyPart = ChosenFolder:FindFirstChildOfClass("UnionOperation")
	
	local tweeningInfo = {}
	tweeningInfo.CFrame = ChosenProxyPart.CFrame
	
	UtilitiesModule:CancelTween(PowerSwitchHandlesPart, TweenDict)
	
	SoundsModule:PlaySoundEffectById(CollectionInfoModule:GetInfo("SwitchSound")["Id"], nil, PowerSwitchHandlesPart)
	
	TweenDict[PowerSwitchHandlesPart] = TweenService:Create(PowerSwitchHandlesPart, tweenInfo, tweeningInfo)
	TweenDict[PowerSwitchHandlesPart]:Play()
	UtilitiesModule:CompleteTween(PowerSwitchHandlesPart, TweenDict)
end

local function Initialise(PowerSwitchModel)
	-- Functions
	-- DIRECT
	local Connection1 = PowerSwitchModel:GetAttributeChangedSignal("On"):Connect(function()
		return StateChanged(PowerSwitchModel, PowerSwitchModel:GetAttributes()["On"])
	end)
	
	-- Connections
	Connections[PowerSwitchModel] = {Connection1}
end

local function End(PowerSwitchModel)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections[PowerSwitchModel])
end

-- DIRECT
function TagModule.Initialise(NilParam, ...)
	return Initialise(...)
end

function TagModule.End(NilParam, ...)
	return End(...)
end

return TagModule