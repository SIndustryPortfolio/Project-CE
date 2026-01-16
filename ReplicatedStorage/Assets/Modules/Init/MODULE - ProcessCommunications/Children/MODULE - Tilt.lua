local TiltReplicateProcessCommunicationsModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])

-- CLIENT
local LocalPlayer = game.Players.LocalPlayer

-- Functions
-- MECHANICS
local function ApplyProperties(_Instance, Properties)
	-- Functions
	-- INIT
	for PropertyName, PropertyValue in pairs(Properties) do
		local Success, Error = pcall(function()
			_Instance[PropertyName] = PropertyValue
		end)
		
		if not Success then
			DebugModule:Print(script.Name.. " | ApplyProperties | Error: ".. tostring(Error))
		end
	end
end

local function Initialise(Player, _Instance, Properties)
	-- Functions
	-- INIT
	if Player == LocalPlayer then
		return nil
	end
	
	return ApplyProperties(_Instance, Properties)
end

-- DIRECT
function TiltReplicateProcessCommunicationsModule.Initialise(NilParam, ...)
	return Initialise(...)
end

return TiltReplicateProcessCommunicationsModule