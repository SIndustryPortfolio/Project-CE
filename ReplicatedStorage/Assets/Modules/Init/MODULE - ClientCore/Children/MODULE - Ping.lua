local PingModule = {}

-- Dirs
local ClientServerSignalsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Signals"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Elements
-- SIGNALS
local ClientRequestSignal = ClientServerSignalsFolder["ClientRequest"]

-- Modules
local DebugModule = require(SharedModulesFolder["Debug"])

-- CORE
local PingUpdateDelay = 5 -- Seconds
local LastTime = tick()

-- Services
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function Render()
	-- Functions
	-- INIT
	local TimeNow = tick()
	
	if TimeNow - LastTime < PingUpdateDelay then
		return nil
	end
	
	local Ping = ClientRequestSignal:InvokeServer("UpdatePing", TimeNow)
	
	LastTime = TimeNow
end

local function Initialise()
	-- Functions
	-- INIT
	RunService:BindToRenderStep("PingUpdate", Enum.RenderPriority.Last.Value, Render)
	--[[coroutine.wrap(function()
		while task.wait(PingUpdateDelay) do
			--DebugModule:Print("Ping | Ping updating")
			local Ping = ClientRequest:InvokeServer("UpdatePing", tick())
		end
	end)()]]
end

-- DIRECT
function PingModule.Initialise()
	return Initialise()
end

return PingModule