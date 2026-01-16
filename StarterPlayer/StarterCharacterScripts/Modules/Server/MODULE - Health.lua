local HealthModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent
local Player = game.Players:GetPlayerFromCharacter(Character)

-- EXT
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]

-- InfoModules
local CharacterInfoModule = require(ServerInfoModulesFolder["Character"])

-- Modules
local CharacterActionsModule = require(ServerModulesFolder["CharacterActions"])
local DamageModule = require(ServerModulesFolder["Damage"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])

-- Elements
-- HUMANOIDS
local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")

-- CORE
local Connections = {}
local ShieldIncrement = 1

-- Functions
-- MECHANICS
local function RegenShield()	
	-- Functions
	-- INIT
	local LastShieldValue = Humanoid:GetAttribute("Shield")
	
	Humanoid:SetAttribute("ShieldRegen", true)
	Humanoid:SetAttribute("LastHit", "")
	DamageModule:RemoveAssistTable(Character)
	
	repeat
		LastShieldValue = Humanoid:GetAttribute("Shield")
		if LastShieldValue < Humanoid:GetAttribute("Shield") then
			break
		end
		
		Humanoid:SetAttribute("Shield", math.clamp(Humanoid:GetAttribute("Shield") + ShieldIncrement , 0, Humanoid:GetAttribute("MaxShield"))) 
		task.wait(.03)
	until Humanoid:GetAttribute("Shield") >= Humanoid:GetAttribute("MaxShield") or Humanoid:GetAttribute("Shield") - ShieldIncrement ~= LastShieldValue or Humanoid.Health <= 0
	
	Humanoid:SetAttribute("ShieldRegen", false)
end

local function HandleShieldRegen()	
	-- CORE
	local ShieldChanged = false
	local LastHealth = Humanoid.Health
	
	-- Functions
	-- DIRECT
	local Connection1 = Humanoid:GetAttributeChangedSignal("Shield"):Connect(function()
		ShieldChanged = true
	end)
	
	local Connection2 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health < LastHealth then
			ShieldChanged = true
		end
		
		LastHealth = Humanoid.Health
	end)
	
	-- Connections
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
	
	-- INIT
	----DebugModule:Print"Handling Shield Regen")
	task.wait(CharacterInfoModule:GetCharacterInfo("ShieldRegenTime"))
	
	if not ShieldChanged then
		RegenShield()
	end
	
	if UtilitiesModule then
		UtilitiesModule:DisconnectConnections({Connection1, Connection2})
	end
end

local function Dead()
	-- Functions
	-- INIT
	DebugModule:Print("Health | Dropping weapon on death | Player: ".. tostring(Player))
	CharacterActionsModule:ClientRequest(Player, "DropWeapon")
	CharacterActionsModule:ClientRequest(Player, "DropGrenades")
end

-- DIRECT
function HealthModule.ForceHeal()
	UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess"):FireClient(Player, "Heal")

	coroutine.wrap(function()
		RegenShield()
	end)()
end

function HealthModule.Initialise()	
	-- DIRECT
	local Connection1 = Humanoid:GetAttributeChangedSignal("Shield"):Connect(function()
		return HandleShieldRegen()
	end)
	
	local Connection2 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		--DebugModule:Print("Health | Character Health Changed: ".. tostring(Humanoid.Health))
		--if Humanoid.Health <= 0 then
			--return Dead()
		--end
		
		HandleShieldRegen()
	end)
	
	-- Connections
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
end

function HealthModule.GarbageCollect()
	-- Functions
	-- INIT
	Character = nil
	Player = nil
	--
	ServerInfoModulesFolder = nil
	SharedModulesFolder = nil
	ServerModulesFolder = nil
	--
	CharacterInfoModule = nil
	--
	CharacterActionsModule = nil
	DamageModule = nil
	UtilitiesModule = nil
	DebugModule = nil
	--
	Humanoid = nil
	--
	Connections = nil
	ShieldIncrement = nil
	
end

function HealthModule.End()
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Connections)
	Dead()
end

return HealthModule