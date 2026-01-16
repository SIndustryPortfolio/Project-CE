local TagModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Client
local Player = game.Players.LocalPlayer

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- CORE
local ConnectionsCache = {}
local ClientTouchingSafeDeathZone = false
local MaxSafeDeathZoneTime = 10 -- Seconds

local PreString = "RETURN TO BATTLEFIELD: "

-- Functions
-- MECHANICS
local function AddToCache(SafeDeathZonePart, Connections)
	-- Functions
	-- INIT
	if not ConnectionsCache[SafeDeathZonePart] then
		ConnectionsCache[SafeDeathZonePart] = {}
	end
	
	for i, Connection in pairs(Connections) do
		table.insert(ConnectionsCache[SafeDeathZonePart], Connection)
	end
end

local function RemoveFromCache(SafeDeathZonePart)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(ConnectionsCache[SafeDeathZonePart])
	ConnectionsCache[SafeDeathZonePart] = nil
end

local function IsTouchClient(Hit)
	-- Functions
	-- INIT
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if not Character then
		return nil
	end
	
	if Character:GetAttributes()["ServerLoaded"] and Hit:IsDescendantOf(Character) then
		return true
	end
end

local function CheckAllDeathZonesForPlayer()
	-- CORE
	local IsPlayerTouching = false
	local Character = UtilitiesModule:GetCharacter(Player)
	
	if not Character then
		return false
	end
	
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	if not Humanoid or Humanoid.Health <= 0 then
		return false
	end
	
	-- Functions
	-- INIT
	for SafeDeathZonePart, Connections in pairs(ConnectionsCache) do
		for i, Part in pairs(SafeDeathZonePart:GetTouchingParts()) do
			if IsTouchClient(Part) then
				return true
			end
		end
	end
end

local function LocalPlayerTouched()
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	
	if not Character then
		return nil
	end
	
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	local HudInterfaceModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	-- Functions
	-- INIT
	if HudInterfaceModule then
		HudInterfaceModule:HudProcess("SafeDeathZone", "Update", PreString.. tostring(MaxSafeDeathZoneTime))
		HudInterfaceModule:HudProcess("SafeDeathZone", "Show")
	end
	
	for i = 1, MaxSafeDeathZoneTime do
		for x = 1, 10 do
			ClientTouchingSafeDeathZone = CheckAllDeathZonesForPlayer()

			if not ClientTouchingSafeDeathZone then
				break
			end
			task.wait(.1)
		end
		
		if not ClientTouchingSafeDeathZone then
			break
		end
		
		if HudInterfaceModule then
			HudInterfaceModule:HudProcess("SafeDeathZone", "Update", PreString.. tostring(MaxSafeDeathZoneTime - i))
		end
	end
	
	if ClientTouchingSafeDeathZone then
		if Humanoid then
			Humanoid:TakeDamage(Humanoid.MaxHealth)
			--
			local CharacterProcessRemote = UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess")
			
			if CharacterProcessRemote then
				CharacterProcessRemote:FireServer("Collections", "SafeDeathZone", "Dead")
			end
		end
		ClientTouchingSafeDeathZone = false
	end
	
	if HudInterfaceModule then
		HudInterfaceModule:HudProcess("SafeDeathZone", "Hide")
	end
end

local function Initialise(SafeDeathZonePart)
	-- Functions
	-- MECHANICS
	local function onHit(TouchPart)
		if ClientTouchingSafeDeathZone then
			return nil
		end
		
		if IsTouchClient(TouchPart) then
			return LocalPlayerTouched()
		end
	end
	
	-- DIRECT
	local Connection1 = SafeDeathZonePart.Touched:Connect(function(Hit)
		return onHit(Hit)
	end)
	
	-- INIT
	AddToCache(SafeDeathZonePart, {Connection1})
end

local function End(SafeDeathZonePart)
	-- Functions
	-- INIT
	RemoveFromCache(SafeDeathZonePart)
end

-- DIRECT
function TagModule.Initialise(NilParam, SafeDeathZonePart)
	return Initialise(SafeDeathZonePart)
end

function TagModule.End(NilParam, SafeDeathZonePart)
	return End(SafeDeathZonePart)
end

return TagModule