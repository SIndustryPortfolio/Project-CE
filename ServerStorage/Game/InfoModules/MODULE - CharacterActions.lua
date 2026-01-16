local CharacterActionsInfoModule = {}

-- CORE
local CharacterActionsInfo = 
{
	["Melee"] = 
	{
		["Damage"] = 50,
		["PushbackForce"] = 20,
		--["MaxDistance"] = 15, -- Studs
		["Duration"] = 1, -- Seconds
		["Cooldown"] = .5 -- Seconds	
	}
}

-- Functions
-- DIRECT
function CharacterActionsInfoModule.GetCharacterActionInfo(NilParam, SettingName)
	return CharacterActionsInfo[SettingName]
end

function CharacterActionsInfoModule.GetAllCharacterActionInfo()
	return CharacterActionsInfo
end

return CharacterActionsInfoModule