local AddAmmoModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])

-- Functions
-- MECHANICS
local function Initialise(WeaponModel, Amount)
	-- CORE
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponModel.Name)
	
	-- Functions
	-- INIT
	
	if not Amount then
		Amount = 0
	end
	
	if not WeaponInfo then
		return nil
	end
	
	local TotalMaxAmmo = WeaponModel:GetAttribute("MaxMags") * WeaponModel:GetAttribute("MaxRoundsInMag")
	local Remainder = 0	
	
	if WeaponModel:GetAttribute("Rounds") >= TotalMaxAmmo then
		return Amount, false
	end
	
	local AmountLeftToFillGun = TotalMaxAmmo - WeaponModel:GetAttribute("Rounds")
	
	if Amount > AmountLeftToFillGun then
		local Overspill = Amount - AmountLeftToFillGun
		WeaponModel:SetAttribute("Rounds", TotalMaxAmmo)
		
		Remainder = Overspill
	else
		WeaponModel:SetAttribute("Rounds", WeaponModel:GetAttribute("Rounds") + Amount)
	end
	
	--local AmmoAfter = WeaponModel:GetAttribute("Rounds") + Amount
	--local Remainder = 0	
	
	
	--Remainder = AmmoAfter - TotalMaxAmmo
	
	
	--[[Remainder = math.clamp(AmmoAfter - TotalMaxAmmo, 0, TotalMaxAmmo)
	
	if Remainder > 0 then
		WeaponModel:SetAttribute("Rounds", TotalMaxAmmo)
	else
		WeaponModel:SetAttribute("Rounds", AmmoAfter)
	end]]
	
	return Remainder, true
end

-- DIRECT
function AddAmmoModule.Initialise(NilPararm, ...)
	return Initialise(...)
end


return AddAmmoModule