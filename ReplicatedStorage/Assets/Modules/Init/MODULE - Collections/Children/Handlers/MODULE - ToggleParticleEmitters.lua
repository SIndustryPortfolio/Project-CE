local TagModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Client
local Player = game.Players.LocalPlayer

-- Modules
local GameClientModule = require(ModulesFolder["Init"]["GameClient"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local Cache = {}

-- Functions
-- MECHANICS
local function ForceToggleAttachment(Attachment, ToggleValue)
	-- Functions
	-- INIT
	if Attachment:IsA("ParticleEmitter") then
		Attachment.Enabled = ToggleValue
	end

	for i, Effect in pairs(Attachment:GetChildren()) do
		if Effect:IsA("ParticleEmitter") then
			Effect.Enabled = ToggleValue
		end
	end
end

local function UpdateAttachment(Attachment)
	-- Functions
	-- INIT
	local IgnorePlayerName = Attachment:GetAttributes()["PlayerToIgnore"]
	
	if IgnorePlayerName ~= nil then
		local FoundPlayer = game.Players:FindFirstChild(IgnorePlayerName)

		if FoundPlayer then
			if FoundPlayer == Player then
				return ForceToggleAttachment(Attachment, false)
			end
		elseif IgnorePlayerName == Player.Name then
			return ForceToggleAttachment(Attachment, false)
		end
	end
end

local function ToggleEffect(Attachment, ToggleValue)
	-- Functions
	-- DIRECT
	local Connection1 = Attachment:GetAttributeChangedSignal("PlayerToIgnore"):Connect(function()
		return UpdateAttachment(Attachment)
	end)
	
	if Cache[Attachment] then
		UtilitiesModule:DisconnectConnections(Cache[Attachment])
	end
	
	-- CONNECTIONS
	Cache[Attachment] = {Connection1}
	
	-- INIT	
	if not Attachment then
		return nil
	end

	if Attachment:IsA("BasePart") and not Attachment:FindFirstChildOfClass("ParticleEmitter") then
		Attachment = Attachment:FindFirstChildOfClass("Attachment")
		
		if not Attachment then
			return nil
		end
	end

	local IgnorePlayerName = Attachment:GetAttributes()["PlayerToIgnore"]
	
	if IgnorePlayerName then
		local FoundPlayer = game.Players:FindFirstChild(IgnorePlayerName)

		if FoundPlayer then
			if FoundPlayer == Player then
				return nil
			end
		elseif IgnorePlayerName == Player.Name then
			return nil
		end
	end
	
	ForceToggleAttachment(Attachment, ToggleValue)
end

local function Initialise(Attachment)
	-- Functions
	-- INIT
	return ToggleEffect(Attachment, true)
end

local function End(Attachment)
	-- Functions
	-- INIT
	return ToggleEffect(Attachment, false)
end

-- DIRECT
function TagModule.Initialise(NilParam, Attachment)
	return Initialise(Attachment)
end

function TagModule.End(NilParam, Attachment)
	return End(Attachment)
end

return TagModule