local RotateModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])

-- Services
local RunService = game:GetService("RunService")

-- CORE
local DefaultIncrement = .5

-- Functions
-- MECHANICS
local function Rotate(Element, CustomConnection, Increment)
	-- Functions
	-- INIT
	local _Inc = Increment or DefaultIncrement
	
	--[[coroutine.wrap(function()
		while Element and CustomConnection and CustomConnection.Value and task.wait() do
			Element.Rotation += _Inc
		end
		
		if CustomConnection then
			UtilitiesModule:DisconnectCustomConnections({CustomConnection})
		end
	end)()]]
	
	local Connection1 = nil
	
	Connection1 = RunService.Stepped:Connect(function()
		Element.Rotation += _Inc
		
		if not CustomConnection or not CustomConnection.Value then
			return UtilitiesModule:DisconnectConnections({Connection1})
		end
	end)
	
	return {Connection1}
end

-- DIRECT
function RotateModule.Initialise(NilParam, Element, CustomConnection, Increment)
	return Rotate(Element, CustomConnection, Increment)
end

function RotateModule.End()
	
end

return RotateModule