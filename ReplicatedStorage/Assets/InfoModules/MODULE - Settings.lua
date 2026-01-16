local SettingsInfoModule = {}

-- CORE
local VideoSettings = 
{
	--["RenderQuality"] = {Title = "RENDER QUALITY", Type = "Toggle", AcceptableValues = {"ULTRA HIGH", "HIGH", "MEDIUM", "LOW", "ULTRA LOW"}, DefaultValue = "HIGH", Hint = "Change the chunk loading distance and texture quality.", Experimental = false},
	--["CastShadows"] = {Title = "CAST SHADOWS", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "ON", Hint = "Enable or Disable shadows.", Experimental = false},
	["BulletSpecular"] = {Title = "BULLET SPECULAR", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "ON", Hint = "Enable or Disable muzzle flash specular.", Experimental = false},
	["LightingSpecular"] = {Title = "LIGHTING SPECULAR", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "ON", Hint = "Enable or Disable special lighting.", Experimental = false},
	["ExplosionSpecular"] = {Title = "EXPLOSION SPECULAR", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "ON", Hint = "Enable or Disable custom particle physics.", Experimental = false},
	["AnimatedCamos"] = {Title = "ANIMATED CAMOS", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "OFF", Hint = "Enable or Disable animated camos on weapons.", Experimental = true},		
	["MapLighting"] = {Title = "MAP LIGHTING", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "ON", Hint = "Enable or Disable map lighting.", Experimental = false},
	["MotionBlur"] = {Title = "MOTION BLUR", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "ON", Hint = "Enable or Disable motion blur.", Experimental = false},
	--["PerformanceMode"] = {Title = "PERFORMANCE MODE", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "OFF", Hint = "Enable or Disable performance mode.", Experimental = true},
	["Blood"] = {Title = "BLOOD", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue =  "ON", LockedValue = {Device = "Console", Value = "OFF"}, Hint = "Enable or Disable blood (OFF for XBOX).", Experimental = false},
	["BloodSpecular"] = {Title = "BLOOD SPECULAR", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "OFF", LockedValue = {Device = "Console", Value = "OFF"}, Hint = "Enable or Disable blood specular (OFF for XBOX)", Experimental = false},	
	["Brightness"] = {Title = "BRIGHTNESS", Type = "Adjustable", AcceptableValueBounds = {Min = 0, Max = 10}, DefaultValue = 3, Hint = "Darken / Brighten the atmosphere", Experimental = false}
}

local GameSettings = 
{
	--["MouseSensitivity"] = {Title = "SENSITIVITY", Type = "Adjustable", AcceptableValueBounds = {Min = 0, Max = 10}, DefaultValue = 5, Hint = "Increase / Decrease mouse sensitivity", Experimental = false},
	["GamepadXSensitivity"] = {Title = "GAMEPAD X SENSITIVITY", Type = "Adjustable", AcceptableValueBounds = {Min = 0, Max = 10}, DefaultValue = 5, Hint = "Increase / Decrease gamepad sensitivity", Experimental = false},
	["GamepadYSensitivity"] = {Title = "GAMEPAD Y SENSITIVITY", Type = "Adjustable", AcceptableValueBounds = {Min = 0, Max = 10}, DefaultValue = 5, Hint = "Increase / Decrease gamepad sensitivity", Experimental = false},
	["Hints"] = {Title = "HINTS", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "ON", Hint = "Enable or Disable visual hints.", Experimental = false},
	["VisualDamage"] = {Title = "VISUAL DAMAGE", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "ON", Hint = "Enable or Disable visual damage.", Experimental = false},
	["Music"] = {Title = "MUSIC", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "ON", Hint = "Enable or Disable music.", Experimental = false},
	["FancyCamera"] = {Title = "FANCY CAMERA", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "ON", Hint = "Enable or Disable fancy camera.", Experimental = false},
	["ThirdPerson"] = {Title = "THIRD PERSON", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "OFF", Hint = "Enable or Disable third person.", Experimental = true},
	["ToggleCrouch"] = {Title = "TOGGLE CROUCH", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "OFF", Hint = "Enable or Disable toggle crouch.", Experimental = false},
	["ToggleAds"] = {Title = "TOGGLE ADS", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "OFF", Hint = "Enable or Disable toggle ads.", Experimental = false},
	["HitMarker"] = {Title = "HIT MARKER", Type = "Toggle", AcceptableValues = {"ON", "OFF"}, DefaultValue = "ON", Hint = "Enable or Disable hit markers.", Experimental = false},
	["ShootCancelsReload"] = {Title = "SHOOT CANCELS RELOAD", AcceptableValues = {"ON", "OFF"}, DefaultValue = "ON", Hint = "Enable or Disable shoot cancels reload", Experimental = false} 
}

local LowPreset = 
{
		--["RenderQuality"] = "LOW",
	["Video"] = 
	{
		["MotionBlur"] = "OFF",
		["BulletSpecular"] = "OFF",
		["ExplosionSpecular"] = "OFF",
		["LightingSpecular"] = "OFF",
		["AnimatedCamos"] = "OFF",
		["BloodSpecular"] = "OFF"		
	},
	["Game"] = 
	{
		["VisualDamage"] = "OFF"		
	}
}

local HighPreset = 
{
	--["RenderQuality"] = "HIGH",
	["Video"] = 
	{
		["BloodSpecular"] = "OFF",
		["MotionBlur"] = "ON",
		["BulletSpecular"] = "ON",
		["ExplosionSpecular"] = "ON",
		["LightingSpecular"] = "ON",
		["AnimatedCamos"] = "OFF"		
	},
	["Game"] = 
	{
		["VisualDamage"] = "OFF"		
	}
}

local MobilePreset = 
{
	["Game"] = 
	{
		["ToggleAds"] = "ON",
		["ToggleCrouch"] = "ON"			
	}
}

local ConsolePreset = 
{
	["Video"] = 
	{
		["Blood"] = "OFF"
	},
	["Game"] = 
	{
		["ToggleAds"] = "ON",
	}
}

--
local Presets = 
{
	["Low"] = LowPreset,
	["High"] = HighPreset	
}

local DevicePresets = 
{
	["Mobile"] = MobilePreset,
	["Console"] = ConsolePreset
}

local SettingPages = 
{
	["Video"] = {LayoutOrder = 1, Table = VideoSettings},
	["Game"] = {LayoutOrder = 2, Table = GameSettings}
}

-- Functions
-- DIRECT
function SettingsInfoModule.GetDeviceSettingPresetInfo(NilParam, Preset)
	return DevicePresets[Preset]
end

function SettingsInfoModule.GetSettingPresetInfo(NilParam, Preset)
	return Presets[Preset]
end

function SettingsInfoModule.GetSettingPageInfo(NilParam, Type)
	return SettingPages[Type]["Table"]
end

function SettingsInfoModule.GetAllSettingPageInfo()
	return SettingPages
end


return SettingsInfoModule