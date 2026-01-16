local DebugModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ClientSignalsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["Client"]["Signals"]
local ClientRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["Client"]["Remotes"]
local SharedServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["Server"]["Remotes"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Client
local Player = game.Players.LocalPlayer

-- Elements
-- REMOTES
local ClientProcessRemote = ClientRemotesFolder["ClientProcess"]
local ServerProcessRemote = SharedServerRemotesFolder["ServerProcess"]
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- SIGNALS
local ClientRequestSignal = ClientSignalsFolder["ClientRequest"]

-- CORE
local BackLog = {}
local BackLogLimit = 200
local DebugMode = false

-- Services
local RunService = game:GetService("RunService")

-- Functions
-- MECAHNICS
local function LogToExternal(String)
	-- Functions
	-- INIT
	if RunService:IsServer() then
		ServerProcessRemote:Fire("Webhook", "Log", String)
	else
		GameProcessRemote:FireServer("Webhook", "Log", String)
	end
end

local function ReEnabled()
	-- Functions
	-- INIT
	for i = 1, #BackLog do
		local Success, Error = pcall(function()
			return DebugModule:Print("BACKLOGGED | ".. BackLog[i]["String"].. " | Time: ".. tostring(BackLog[i]["Time"])--[[.. " | Tick: ".. tostring(BackLog[i]["Tick"])]], BackLog[i]["Type"])
		end)
		
		table.remove(BackLog, #BackLog)
	end
end

local function Print(String, Type)
	-- Functions
	-- INIT
	--[[if not DebugMode and not RunService:IsStudio() then
		return nil
	end]]
	
	if DebugMode then
		--[[if ConsoleUiModule then
			ConsoleUiModule:Add("Debug", "DEBUG", String)
		end]]
		if Player then
			ClientProcessRemote:Fire("Debug", "Debug", "DEBUG", String)
		end
	end
	
	table.insert(BackLog, {["Type"] = Type, ["String"] = String, ["Tick"] = tick(), ["Time"] = os.date("*t")["hour"].. ":".. os.date("*t")["min"].. ":".. os.date("*t")["sec"]})
	
	if #BackLog > 200 then
		table.remove(BackLog, #BackLog)
	end
	
	local String = tostring(String)
	
	if not Type or Type == "Normal" then
		
		if (string.find(String.lower(String), "error") ~= nil) then
			LogToExternal(String)
		end
		
		if script:GetAttribute("Enabled") then
			print(String)
		end
	elseif Type == "Error" then
		LogToExternal(String)
		error(String)
	end
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Print"] = function(String, Type)
		return Print(String, Type)
	end,	
}

-- DIRECT
function DebugModule.Request(NilParam, FunctionName, ...)
	return ClientRequests[FunctionName](...)
end

function DebugModule.Print(NilParam, String, Type)
	return Print(String, Type)
end

-- CONNECTIONS
local Connection1 = script:GetAttributeChangedSignal("Enabled"):Connect(function()
	if script:GetAttribute("Enabled") then
		return ReEnabled()
	end
end)

return DebugModule