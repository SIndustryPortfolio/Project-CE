local CharacterInfoModule = {}

-- CORE
local CharacterInfo = 
{
	["ShieldRegenTime"] = 5, 
	["Default"]	= 
	{
		["Root"] = 
		{
			["EquippedWeapon"] = "Primary",
			["EquippedSpecialWeapon"] = nil, -- Mounted Turrets, 
			["EquippedGrenade"] = "Frag",
			["FragGrenades"] = 0,
			["PlasmaGrenades"] = 0
		},
		["Humanoid"] = 
		{
			["DisplayDistanceType"] = Enum.HumanoidDisplayDistanceType.None,
			["WalkSpeed"] = 32, --25, -- 16
			["BaseSpeed"] = 32,
			["Health"] = 30,
			["MaxHealth"] = 30,
			["JumpPower"] = 35,
			["MaxShield"] = 50, --75, --100,
			["Shield"] = 50, --75, --100,
			["Crouch"] = false,
			["Melee"] = false,
			["Grenade"] = false,
			["Reload"] = false,
			["ShieldRegen"] = false
		}
	},

	["BodyVelocity"] = 
	{
		["MaxForce"] = Vector3.new(0, 5000, 0),
		["P"] = 1250,
		["Velocity"] = Vector3.new(0, -15, 0)	
	}
}

-- Functions
-- DIRECT
function CharacterInfoModule.GetCharacterInfo(NilParam, SettingName)
	return CharacterInfo[SettingName]
end

function CharacterInfoModule.GetAllCharacterInfo()
	return CharacterInfo
end

return CharacterInfoModule