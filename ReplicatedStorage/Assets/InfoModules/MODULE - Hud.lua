local HudInfoModule = {}

-- CORE
local HudInfo = 
{
	["HealthBarEffectInfo"] = 
	{
		["Duration"] = 0.3,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut	
	},

	["TeleportFlash"] = 
	{
		["Colour"] = Color3.fromRGB(255, 255, 255),
		["Transparency"] = 0,
		["EffectInfo"] = 
		{
			["Style"] = Enum.EasingStyle.Cubic,
			["Direction"] = Enum.EasingDirection.InOut,
			["Duration"] = 1		
		}
	},
		
	["ShieldDamageFlash"] = 
	{
		["Colour"] = Color3.fromRGB(255, 255, 255),
		["Transparency"] = 0.5,
		["EffectInfo"] = 
		{
			["Style"] = Enum.EasingStyle.Cubic,
			["Direction"] = Enum.EasingDirection.InOut,
			["Duration"] = 0.3		
		}
	},
		
	["DamageFlash"] = 
	{
		["Colour"] = Color3.fromRGB(255, 0, 0),
		["Transparency"] = 0.5,
		["EffectInfo"] = 
		{
			["Style"] = Enum.EasingStyle.Cubic,
			["Direction"] = Enum.EasingDirection.InOut,
			["Duration"] = 0.3		
		}
	},

	["HealFlash"] = 
	{
		["Colour"] = Color3.fromRGB(255, 255, 255),
		["Transparency"] = 0.5,
		["EffectInfo"] = 
		{
			["Style"] = Enum.EasingStyle.Cubic,
			["Direction"] = Enum.EasingDirection.InOut,
			["Duration"] = 0.3		
		}
	},
		
	["PowerUpDropFlash"] = 
	{
		["Colour"] = Color3.fromRGB(255, 255, 255),
		["Transparency"] = 0.5,
		["EffectInfo"] = 
		{
			["Style"] = Enum.EasingStyle.Cubic,
			["Direction"] = Enum.EasingDirection.InOut,
			["Duration"] = .5	
		}
	},

	["CursorToColour"] = 
	{
		["Neutral"] = Color3.fromRGB(131, 145, 192),
		["Team"] = Color3.fromRGB(0, 170, 127),
		["Target"] = Color3.fromRGB(170, 0, 0)	
	},
		
	["HealthToColour"] = 
	{
		["Health"] = Color3.fromRGB(170, 0, 0),
		["Shield"] = Color3.fromRGB(131, 145, 192)	
	}
}

-- Functions
-- DIRECT
function HudInfoModule.GetHudInfo(NilParam, SettingName)
	return HudInfo[SettingName]
end

function HudInfoModule.GetAllHudInfo()
	return HudInfo
end

return HudInfoModule