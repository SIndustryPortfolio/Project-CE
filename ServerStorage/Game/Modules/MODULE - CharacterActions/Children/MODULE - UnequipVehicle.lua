local UnequipVehicleModule = {}

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
local function GetPlayerSeatName(Player, VehicleModel)
	-- Functions
	-- INIT
	local SeatNames = {"Occupant", "Passenger1", "Passenger2", "Passenger3"}
	
	for i, SeatName in pairs(SeatNames) do
		if VehicleModel:GetAttributes()[SeatName] == Player.Name then
			return SeatName
		end
	end
end

local function UnequipVehicle(CharacterActionsModule, Player)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if not Character then
		DebugModule:Print(script.Name.. " | No character")
		return nil
	end
	
	-- Functions
	-- INIT	
	DebugModule:Print(script.Name.. " | Unequipping vehicle | Player: ".. tostring(Player.Name))

	local PlayerVehicleValue = ShortcutsModule:GetCharacterCoreValueInstance(Player, "Vehicle")	
	
	if not PlayerVehicleValue.Value then
		DebugModule:Print(script.Name.. " | Player not in vehicle! | Player: ".. tostring(Player.Name))
		return nil
	elseif not PlayerVehicleValue.Value:GetAttributes()["ServerLoaded"] then
		DebugModule:Print(script.Name.. " | Vehicle not loaded | Player: ".. tostring(Player).. " | Vehicle: ".. tostring(PlayerVehicleValue.Value))
		return nil
	end
	
	-- Elements
	-- MODULES
	local VehicleServerModule = ShortcutsModule:GetVehicleModule(PlayerVehicleValue.Value, "Server")
	
	-- INIT
	local PlayerSeatName = GetPlayerSeatName(Player, PlayerVehicleValue.Value)
	
	if not PlayerSeatName then
		DebugModule:Print(script.Name.. " | Cannot find Player Seat Name | Player: ".. tostring(Player.Name).. " | Vehicle: ".. tostring(PlayerVehicleValue.Value))
		return nil
	end
	
	VehicleServerModule:End()	
	PlayerVehicleValue.Value:SetAttribute(PlayerSeatName, "")
	PlayerVehicleValue.Value = nil
	
	
	CharacterActionsModule:ClientRequest(Player, "ForceEquipGun", Player:WaitForChild("Backpack"):FindFirstChild(Character:GetAttributes()[Character:GetAttribute("EquippedWeapon")]))
end

-- DIRECT
function UnequipVehicleModule.Initialise(NilParam, ...)
	return UnequipVehicle(...)
end

return UnequipVehicleModule