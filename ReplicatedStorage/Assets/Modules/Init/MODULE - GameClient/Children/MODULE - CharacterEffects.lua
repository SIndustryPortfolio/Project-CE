local CharacterShieldModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local EffectsHandlerModule = require(ModulesFolder["EffectsHandler"])
local DebugModule = require(ModulesFolder["Debug"])
local SoundsModule = require(ModulesFolder["Sounds"])
local InterfacesModule = require(ModulesFolder["Interfaces"])
--local FPSEffectsModule = require(ModulesFolder["EffectsHandler"]["FPSEffects"])

-- CORE
local Connections = {}
local PlayerConnections = {}

-- Services
local Players = game:GetService("Players")

-- Functions
-- MECHANICS
local function AddToCache(Key, _Connections, Cache)
	-- Functions
	-- INIT
	if Cache[Key] == nil then
		Cache[Key] = {}
	end
	
	for i, Connection in pairs(_Connections) do
		table.insert(Cache[Key], Connection)
	end
end

local function RemoveFromCache(Key, Cache)
	-- Functions
	-- INIT
	if not Cache[Key] then
		return nil
	end
	
	UtilitiesModule:DisconnectConnections(Cache[Key])
	Cache[Key] = nil
end

local function AddCharacter(Character, Player)
	if Character == nil then
		return nil
	end
	
	-- CORE
	local CharacterConnections = {}
	local WaitForHumanoidAttributes = {"Shield", "MaxShield"}
	local OverheadUi = nil
	local EmblemUi = nil
	
	local Neck = UtilitiesModule:WaitForChildTimed(Character:WaitForChild("UpperTorso"), "Neck")
	local Waist = UtilitiesModule:WaitForChildTimed(Character:WaitForChild("LowerTorso"), "Waist")
	
	--local NeckOriginC0 = Neck.C0
	--local WaistOriginC0 = Waist.C0
	
	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Character, "Humanoid")
	
	-- PARTS
	local HumanoidRootPart = Character.PrimaryPart --UtilitiesModule:WaitForChildTimed(Character, "HumanoidRootPar")
	local HeadPart = UtilitiesModule:WaitForChildTimed(Character, "Head")
	local LeftUpperArmPart = UtilitiesModule:WaitForChildTimed(Character, "LeftUpperArm")
	local EmblemPart = LeftUpperArmPart:FindFirstChild("Emblem")
	
	
	-- Functions
	-- MECHANICS
	local function GetComponents(PreName)
		-- CORE
		local Order = {"AngleRightVector", "AngleUpVector", "AngleLookVector"}
		local Order2 = {"X", "Y", "Z"}
		local Components = {}
		
		for i, PropertyName in pairs(Order2) do
			table.insert(Components, Character:GetAttribute(PreName.. "AnglePosition")[PropertyName])
		end
		
		for _, PropertyName in pairs(Order2) do
			for i, Name in pairs(Order) do
				table.insert(Components, Character:GetAttribute(PreName.. Name)[PropertyName])
				--Components[Name] = {["X"] = Character:GetAttribute(PreName.. Name).X, ["Y"] = Character:GetAttribute(PreName.. Name).Y, ["Z"] = Character:GetAttribute(PreName.. Name).Z}
			end
		end
		
		return Components
	end
	
	local function UpdateTilt()
		-- Functions
		-- INIT
		pcall(function()
			local NeckCFrame = Character:GetAttribute("NeckAngle") --CFrame.new(unpack(GetComponents("Neck")))
			local WaistCFrame = Character:GetAttribute("WaistAngle") --CFrame.new(unpack(GetComponents("Waist")))
		
			Neck.C0 = NeckCFrame
			Waist.C0 = WaistCFrame
		end)
	end
	
	-- INIT
	local LastHealth = Humanoid.Health
	local LastShield = Humanoid:GetAttribute("Shield")
	
	RemoveFromCache(Character.Name, Connections)
	
	for i, AttributeName in pairs(WaitForHumanoidAttributes) do
		repeat
			task.wait()
		until Humanoid:GetAttributes()[AttributeName] ~= nil or not Humanoid or not Player or not Character
	end	
	
	-- DIRECT
	local Connection1 = nil
	local Connection2 = nil
	
	if Player ~= Players.LocalPlayer then
		Connection1 = Humanoid:GetAttributeChangedSignal("Shield"):Connect(function()
			EffectsHandlerModule:FPSEffectProcess("ShieldDamage", Character)
			--FPSEffectsModule:EffectProcess("ShieldDamage", Character)
			
			if not Humanoid:GetAttributes()["Shield"] then
				return nil
			end
			
			if LastShield and (Humanoid:GetAttribute("Shield") or 0) < LastShield then
				SoundsModule:PlaySoundEffectByName("CharacterActions", "ShieldDamage", nil, HumanoidRootPart, nil, {Volume = 0.025})
				
				if Humanoid:GetAttribute("Shield") == 0 then
					SoundsModule:PlaySoundEffectByName("CharacterActions", "ShieldBroken", nil, HumanoidRootPart)
				end
			end
			
			LastShield = Humanoid:GetAttribute("Shield")
		end)
		
		Connection2 = Humanoid:GetAttributeChangedSignal("ShieldRegen"):Connect(function()
			if Humanoid:GetAttribute("ShieldRegen") then
				EffectsHandlerModule:FPSEffectProcess("ShieldRegen", Character)
			end
		end)
	end
	
	local Connection3 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()		
		if Humanoid.Health < LastHealth then
			EffectsHandlerModule:FPSEffectProcess("HealthDamage", Character)
		end
		
		if Player ~= game.Players.LocalPlayer then
			EffectsHandlerModule:FPSEffectProcess("ShieldDamage", Character)
		end
		
		LastHealth = Humanoid.Health
		
		if Humanoid.Health <= 0 then
			RemoveFromCache(Character.Name, Connections)
			if OverheadUi then
				local OverheadUiModule = InterfacesModule:GetUiModule(OverheadUi)
				
				if OverheadUiModule and OverheadUiModule.Dead ~= nil then
					OverheadUiModule:Dead()
				end
			end
			
			if EmblemUi then
				local EmblemUiModule = InterfacesModule:GetUiModule(EmblemUi)
				
				if EmblemUi and EmblemUiModule.End ~= nil then
					EmblemUiModule:End()
				end
			end
		end
	end)
	
	local Connection4 = Character:GetPropertyChangedSignal("Parent"):Connect(function()
		if Character.Parent ~= nil then
			return nil
		end
		
		if Player then
			RemoveFromCache(Character.Name, Connections)
		else
			RemoveFromCache(Character, Connections)
		end
	end)
	
	-- CONNECTIONS
	table.insert(CharacterConnections, Connection1)
	table.insert(CharacterConnections, Connection2)
	table.insert(CharacterConnections, Connection3)
	table.insert(CharacterConnections, Connection4)
	
	if Player then
		AddToCache(Character.Name, CharacterConnections, Connections)
	else
		AddToCache(Character, CharacterConnections, Connections)
		EffectsHandlerModule:FPSEffectProcess("SetupCharacterShield", Character)
	end
	
	-- INIT
	if Player and Player ~= Players.LocalPlayer then
		local Connection5 = Character:GetAttributeChangedSignal("WaistAngle" --[["NeckAngleRightVector"]]):Connect(function()
			return UpdateTilt()
		end)
		
		table.insert(CharacterConnections, Connection5)
		
		--if Humanoid:GetAttribute("Shield") < Humanoid:GetAttribute("MaxShield") then
			EffectsHandlerModule:FPSEffectProcess("SetupCharacterShield", Character)
		--end

		OverheadUi = InterfacesModule:LoadBillboard(HeadPart, "Overhead")
		
		if EmblemPart then
			EmblemUi = InterfacesModule:LoadSurface(EmblemPart, "Emblem", Player)
		end
		
		if OverheadUi and (not Player.Neutral and Player.Team == Players.LocalPlayer.Team) then
			OverheadUi.AlwaysOnTop = true
		end
	end
end

local function PlayerAdded(Player)
	-- Functions
	-- DIRECT
	local Connection1 = Player:GetPropertyChangedSignal("Character"):Connect(function()
		return AddCharacter(UtilitiesModule:GetCharacter(Player), Player)
	end)
	
	-- INIT
	--DebugModule:Print"Player Added Shield Effect: ".. tostring(Player))
	
	AddToCache(Player.Name, {Connection1}, PlayerConnections)
	
	if Player.Character then
		return AddCharacter(UtilitiesModule:GetCharacter(Player), Player)
	end
end

local function PlayerRemoved(Player, IsCharacter)
	-- Functions
	-- INIT
	if not IsCharacter then
		RemoveFromCache(Player.Name, Connections)
		RemoveFromCache(Player.Name, PlayerConnections)
	else
		RemoveFromCache(Player, Connections)
		RemoveFromCache(Player, PlayerConnections)
	end
end

local function Initialise()
	-- Functions
	-- DIRECT
	local Connection1 = Players.ChildAdded:Connect(function(Player)
		return PlayerAdded(Player)
	end)
	
	local Connection2 = Players.ChildRemoved:Connect(function(Player)
		return PlayerRemoved(Player)
	end)
	
	-- DIRECT
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
	
	-- INIT
	for i, Player in pairs(Players:GetPlayers()) do
		--if Player ~= Players.LocalPlayer then
			PlayerAdded(Player)
		--end
	end
end

-- DIRECT
function CharacterShieldModule.RemoveCharacter(NilParam, CharacterModel)
	return PlayerRemoved(CharacterModel, true)
end

function CharacterShieldModule.AddCharacter(NilParam, CharacterModel)
	return AddCharacter(CharacterModel)
end

function CharacterShieldModule.Initialise()
	return Initialise()
end

return CharacterShieldModule