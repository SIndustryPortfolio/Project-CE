local FpsInfoModule = {}

-- CORE
local FpsInfo = 
{

	["FirstPersonOffset"] = Vector3.new(),
	["ThirdPersonOffset"] = Vector3.new(2, 3, 6),
	["TiltUpdateDelay"] = 0.05,
	["SensitivityMultiplier"] = 1,
	["AdsSensitivityMultiplier"] = 0.5,
	["AdsSpreadMultiplier"] = 0.5,
	--
	["RayWidth"] = 0.1,	
	--
	["RayLength"] = 1000,
	["MouseSensitivity"] = 0.15,
	["JoystickSensitivity"] = 0.2,
	--
	["BopLerpIntensity"] = 1,
	["LerpIntensity"] = 0.4,
	["MaxBlur"] = 7.5,
	["MaxYAngle"] = 75,
	--
	["AnimationPriorities"] = 
	{
		["Equip"] = Enum.AnimationPriority.Action,
		["Fire"] = Enum.AnimationPriority.Action2,
		["Unequip"] = Enum.AnimationPriority.Action,
		["Reload"] = Enum.AnimationPriority.Action3,
		["Melee"] = Enum.AnimationPriority.Action4,
		["Idle"] = Enum.AnimationPriority.Idle
	},	
		
	--
	["MeleeBudgeEffectInfo"] = 
	{
		["Duration"] = .3,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut	
	},
	["AdsEffectInfo"] = 
	{
		["Duration"] = 0.3,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut
	}
}

-- Functions
-- DIRECT
function FpsInfoModule.GetFpsInfo(NilParam, SettingName)
	return FpsInfo[SettingName]
end

return FpsInfoModule