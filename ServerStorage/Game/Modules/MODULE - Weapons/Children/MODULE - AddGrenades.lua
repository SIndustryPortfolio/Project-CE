local AddGrenadesModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local GrenadesInfoModule = require(InfoModulesFolder["Grenades"])

-- Functions
-- MECHANICS
local function Initialise(Character, GrenadeName,  Amount)
	-- Functions
	-- INIT
	local CurrentGrenades = Character:GetAttributes()[GrenadeName.. "Grenades"] or 0
	
	local RemainingGrenades = (CurrentGrenades + Amount) - GrenadesInfoModule:GetGrenadeSetting("MaxGrenades")
	
	Character:SetAttribute(GrenadeName.. "Grenades", math.clamp(CurrentGrenades + Amount, 0, GrenadesInfoModule:GetGrenadeSetting("MaxGrenades")))
	
	if RemainingGrenades and RemainingGrenades > 0 then
		return RemainingGrenades
	end
end

-- DIRECT
function AddGrenadesModule.Initialise(NilPararm, ...)
	return Initialise(...)
end

return AddGrenadesModule