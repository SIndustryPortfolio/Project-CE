local TagModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local GameClientModule = require(ModulesFolder["Init"]["GameClient"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local Cache = {}

-- Functions
-- MECHANICS
local function Initialise(Model)
	-- CORE
	local Humanoid = UtilitiesModule:WaitForChildOfClass(Model, "Humanoid")
	local AnimationSpeedAdjust = 1
	
	local Animations = 
	{
		["Run"] = {Id = "rbxassetid://9101585731"}		
	}	
	
	local AnimationInstances = {}
	local AnimationToLoad = {}
	
	-- Functions
	-- MECHANICS
	local function StopAllAnimations()
		-- Functions
		-- INIT
		for AnimationName, AnimationLoad in pairs(AnimationToLoad) do
			AnimationLoad:Stop()
		end
	end
	
	local function RunChanged()
		-- Functions
		-- INIT
		if Humanoid:GetAttribute("Run") then
			if not AnimationToLoad["Run"].IsPlaying then
				AnimationToLoad["Run"]:Play()
				AnimationToLoad["Run"]:AdjustSpeed(AnimationSpeedAdjust)
			end
		else
			AnimationToLoad["Run"]:Stop()
		end
	end
	
	local function HealthChanged()
		-- Functions
		-- INIT
		if Humanoid.Health <= 0 then
			StopAllAnimations()
		end
	end
	
	local function UpdateAnimationSpeed()
		-- Functions
		-- INIT
		if not Humanoid or not Humanoid:GetAttributes()["BaseSpeed"] or not Humanoid:GetAttributes()["AnimationBaseSpeed"] then
			return nil
		end
		
		if Humanoid:GetAttributes()["AnimationBaseSpeed"] then
			AnimationSpeedAdjust = Humanoid.WalkSpeed / tonumber(Humanoid:GetAttributes()["AnimationBaseSpeed"])
		else
			AnimationSpeedAdjust = Humanoid.WalkSpeed / tonumber(Humanoid:GetAttributes()["BaseSpeed"])
		end
		
		if AnimationToLoad["Run"].IsPlaying then
			AnimationToLoad["Run"]:AdjustSpeed(AnimationSpeedAdjust)
		end
	end
	
	-- DIRECT
	local Connection1 = Humanoid:GetAttributeChangedSignal("Run"):Connect(function()
		return RunChanged()
	end)
	
	local Connection2 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		return HealthChanged()
	end)
	
	local Connection3 = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		return UpdateAnimationSpeed()
	end)
	
	-- INIT
	Cache[Model] = {Connection1, Connection2, Connection3}
	
	UtilitiesModule:LoadAnimations(Animations, AnimationInstances, AnimationToLoad, Humanoid, true)
	RunChanged()
	UpdateAnimationSpeed()
	
	GameClientModule:GameClientProcess("CharacterEffects", "AddCharacter", Model)
end

local function End(Model)
	-- Functions
	-- INIT
	UtilitiesModule:DisconnectConnections(Cache[Model])
	GameClientModule:GameClientProcess("CharacterEffects", "RemoveCharacter", Model)
end

-- DIRECT
function TagModule.Initialise(NilParam, Model)
	return Initialise(Model)
end

function TagModule.End(NilParam, Model)
	return End(Model)
end

return TagModule