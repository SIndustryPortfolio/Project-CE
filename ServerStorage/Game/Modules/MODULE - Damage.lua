local DamageModule = {}

-- Dirs
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local SharedInfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedGameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")

-- Info Modules
local GameModesInfoModule = require(SharedInfoModulesFolder["GameModes"])

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local AssistTable = {}

-- Functions
-- MECHANICS
local function HandleAssistTable(TargetCharacter, Damage, Player)
	-- CORE
	local TargetPlayer = game.Players:GetPlayerFromCharacter(TargetCharacter)
	
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(TargetCharacter, "Humanoid")
	
	-- Functions
	-- INIT
	if TargetPlayer then
		if TargetPlayer.Team == Player.Team then
			return nil
		end
	end
	
	if not AssistTable[TargetCharacter] then
		AssistTable[TargetCharacter] = {}
	end
	
	local FoundLastHitIndex = table.find(AssistTable[TargetCharacter], Player.Name)
	
	if FoundLastHitIndex then
		table.remove(AssistTable[TargetCharacter], FoundLastHitIndex)
	end
	
	if Humanoid and Humanoid:GetAttributes()["LastHit"] ~= nil and Humanoid:GetAttribute("LastHit") ~= Player.Name and not table.find(AssistTable[TargetCharacter], Humanoid:GetAttribute("LastHit")) then
		table.insert(AssistTable[TargetCharacter], Humanoid:GetAttribute("LastHit"))
	end
end

local function TakeDamage(Humanoid, Damage, Player, WeaponType, Location)
	-- CORE
	local HealthDamaged = false
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(SharedGameFolder:GetAttribute("GameMode"))
	
	-- Functions
	-- INIT
	if Humanoid.Health <= 0 then
		return nil
	end
		
	if Player then
		HandleAssistTable(Humanoid.Parent, Damage, Player)	
		Humanoid:SetAttribute("LastHit", Player.Name)
	---elseif Humanoid and Humanoid:GetAttribute("LastHit") then
		--Player = game.Players:FindFirstChild(Humanoid:GetAttribute("LastHit"))
	end
	
	if Location then
		Humanoid:SetAttribute("LastHitPosition", Location)
	end
	
	local TargetCharacter = Humanoid.Parent
	local TargetPlayer = game.Players:GetPlayerFromCharacter(TargetCharacter)
	
	if TargetPlayer and Player and TargetPlayer ~= Player then
		if not GameModeInfo["FriendlyFire"] and GameModeInfo["Teams"] and UtilitiesModule:HasProperty(Player, "Team") then
			if Player.Team == TargetPlayer.Team then
				return nil
			end
		end
	end
	
	if Humanoid:GetAttributes()["Shield"] ~= nil then
		if Humanoid:GetAttribute("Shield") > 0 then
	
			local Result = Humanoid:GetAttribute("Shield") - Damage

			if Result < 0 then
				Humanoid:SetAttribute("Shield", 0)
				
				if (-Result > 0) then
					HealthDamaged = true
					Humanoid:TakeDamage(-Result)
				end
			else
				Humanoid:SetAttribute("Shield", Humanoid:GetAttribute("Shield") - Damage)
			end

			if Humanoid.Health < 0 then
				Humanoid.Health = 0
			end
		else
			HealthDamaged = true
			Humanoid:TakeDamage(Damage)
		end
	else
		HealthDamaged = true
		Humanoid:TakeDamage(Damage)
	end
	
	if Humanoid.Health <= 0 then
		Humanoid.Health = 0
		
		return true, HealthDamaged, true
	end
	
	return false, HealthDamaged, true
end

local function IsPlayerDead(Player)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player)
	
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	-- Functions
	-- INIT
	if Humanoid.Health <= 0 then
		return true
	else
		return false
	end
end

-- DIRECT
function DamageModule.Reset()
	AssistTable = {}
end

function DamageModule.RemoveAssistTable(NilParam, Character)
	AssistTable[Character] = nil
end

function DamageModule.GetAssistTable(NilParam, Character)
	return AssistTable[Character]
end

function DamageModule.IsPlayerDead(NilParam, Player)
	return IsPlayerDead(Player)
end

function DamageModule.TakeDamage(NilParam, ...)
	return TakeDamage(...)
end

return DamageModule