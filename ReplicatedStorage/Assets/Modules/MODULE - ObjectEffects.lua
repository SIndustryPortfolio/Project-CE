local ObjectEffectsModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- CORE
local EffectInfos = 
{		
	["ExpandObject"] = 
	{
		["Duration"] = 1,
		["Style"] = Enum.EasingStyle.Linear,
		["Direction"] = Enum.EasingDirection.InOut		
	}			
}

local TweenDict = {}
local ElementsCache = {}

-- Services
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
local function ExpandObject(Object)
	-- CORE
	local EffectInfo = EffectInfos["ExpandObject"]
	
	-- Functions
	-- INIT
	UtilitiesModule:CreateElementCache(Object, {"Size"}, ElementsCache)
	
	Object.Size = Vector3.new()
	
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	local tweeningInfo = {}
	tweeningInfo.Size = ElementsCache[Object]["Size"]
	
	UtilitiesModule:CancelTween(Object, TweenDict)
	TweenDict[Object] = TweenService:Create(Object, tweenInfo, tweeningInfo)
	TweenDict[Object]:Play()
	UtilitiesModule:CompleteTween(Object, TweenDict)
end

-- DIRECT
function ObjectEffectsModule.ExpandObject(NilParam, ...)
	return ExpandObject(...)
end


return ObjectEffectsModule