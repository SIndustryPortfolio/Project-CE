local RedeemCodesInfoModule = {}

-- CORE
local RedeemCodesInfo = 
{
	["Corny"] = {Id = 1, Rewards = {{Type = "CECoins", Name = "50", Value = 50}}}
}

-- Functions
-- MECHANICS
local function UnpackId(Id)
	-- Functions
	-- INIT
	for Name, Info in pairs(RedeemCodesInfo) do
		if Info.Id == Id then
			return Name
		end
	end
end

-- DIRECT
function RedeemCodesInfoModule.UnpackId(NilParam, Id)
	return UnpackId(Id)
end

function RedeemCodesInfoModule.GetRedeemCodeInfo(NilParam, SettingInfo)
	return RedeemCodesInfo[SettingInfo]
end

function RedeemCodesInfoModule.GetAllRedeemCodeInfo()
	return RedeemCodesInfo
end

return RedeemCodesInfoModule
