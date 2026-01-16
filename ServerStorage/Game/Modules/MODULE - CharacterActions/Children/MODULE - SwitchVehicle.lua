local SwitchVehicleModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- Info Modules
local VehiclesInfoModule = require(SharedInfoModulesFolder["Vehicles"])

-- Modules
local ServerVehiclesModule = require(ServerModulesFolder["Vehicles"])
local SoundsModule = require(SharedModulesFolder["Sounds"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DamageModule = require(ServerModulesFolder["Damage"])
local DebugModule = require(SharedModulesFolder["Debug"])
local ShortcutsModule = require(SharedModulesFolder["Shortcuts"])

-- Functions
-- MECHANICS
local function SwitchVehicle(CharacterActionsModule, Player, VehicleModel, SeatName, Force)
	-- Elements
	-- FOLDERS
	local VehicleCoreFolder = VehicleModel:FindFirstChild("Core")
	
	-- CORE
	local ValidVehicleTypes = {"Primary", "Secondary"}
	local Character = UtilitiesModule:GetCharacter(Player, true)
	local CharacterVehicleValue = ShortcutsModule:GetCharacterCoreValueInstance(Player, "Vehicle")
	
	if not SeatName then
		SeatName = "Occupant"
	end
	
	-- Functions
	-- INIT
	--DebugModule:Print("SwitchVehicle | Server switching Vehicle for: ".. tostring(Player).. " | VehicleType: ".. tostring(VehicleType).. " | Force: ".. tostring(Force))
	
	--DebugModule:Print"Switiching Vehicle Check 1")
	
	if not VehicleModel or not Character or DamageModule:IsPlayerDead(Player) or CharacterVehicleValue.Value ~= nil or VehicleModel == CharacterVehicleValue.Value or VehicleModel:GetAttributes()[SeatName] ~= "" then
		DebugModule:Print(script.Name.. " | Unable to switch vehicle V")
		DebugModule:Print(script.Name.. " | CharacterVehicleValue: ".. tostring(CharacterVehicleValue.Value))
		DebugModule:Print(script.Name.. " | IsPlayerDead: ".. tostring(DamageModule:IsPlayerDead(Player)))
		DebugModule:Print(script.Name.. " | Character: ".. tostring(Character))
		DebugModule:Print(script.Name.. " | Vehicle Model: ".. tostring(VehicleModel).. " | Character Vehicle Value: ".. tostring(CharacterVehicleValue.Value))
		DebugModule:Print(script.Name.. " | Seat | ".. tostring(SeatName).. " | Value: ".. tostring(VehicleModel:GetAttributes()[SeatName]))
		
		return nil
	end
	
	--DebugModule:Print"Switiching Vehicle waiting for Character to load")
	
	--[[if Character:GetAttributes()["EquippedVehicle"] == nil or Character:GetAttributes()[Character:GetAttribute("EquippedVehicle")] == nil then
		repeat
			task.wait()
		until Character:GetAttributes()["EquippedVehicle"] ~= nil and Character:GetAttributes()[Character:GetAttribute("EquippedVehicle")] ~= nil
	end]]
	
	--DebugModule:Print"Switiching Vehicle Check 2")
	
	--
	coroutine.wrap(function()
		CharacterActionsModule:ClientRequest(Player, "UnequipGun", Character:GetAttributes()[Character:GetAttribute("EquippedWeapon")])
	end)()
	--
	
	ServerVehiclesModule:InitialiseVehicle(VehicleModel)
	
	VehicleModel:SetAttribute(SeatName, Player.Name)
	CharacterVehicleValue.Value = VehicleModel
	
	local VehicleServerModule = VehicleCoreFolder:FindFirstChild("Server")
	
	if VehicleServerModule then
		VehicleServerModule = require(VehicleServerModule)
		
		if VehicleServerModule.Initialise ~= nil then
			DebugModule:Print(script.Name.. " | Initialising Server: ".. tostring(VehicleModel))
			return VehicleServerModule:Initialise()
		end
	end
end

-- DIRECT
function SwitchVehicleModule.Initialise(NilParam, ...)
	return SwitchVehicle(...)
end

return SwitchVehicleModule